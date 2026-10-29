#!/usr/bin/env python3
"""zbench: measure, attribute, and guard zsh startup latency the way Ghostty sees it.

  zbench.py run     [-n RUNS] [--only NAMES] [--save F] [--compare F] [--budget-ms [NAME=]MS ...]
  zbench.py trace   [--scenario NAME] [--min-ms MS]
  zbench.py parity  [--kind ghostty|pane] (--snapshot F | --check F)
  zbench.py freeze  DIR

`run` spawns zsh in a pseudo-terminal with Ghostty's environment and shell
integration, types a command ahead (like a user who starts typing immediately),
and records two times from process start:
  prompt: the starship prompt glyph is drawn
  ready:  the typed-ahead command has executed (the shell is usable)

`trace` shows which startup lines the time goes to. `parity` snapshots what the
shell provides (resolved commands, versions, PATH, completions) so a speedup that
breaks something shows up as a diff.

`freeze DIR` copies the current startup config into DIR, and the global
`--zdotdir DIR` runs any subcommand against that frozen copy instead, so
before/after can be compared at any time without stashing or swapping live files:

  zbench.py freeze ~/.cache/zbench/baseline
  ...edit config...
  zbench.py --zdotdir ~/.cache/zbench/baseline run --save ~/.cache/zbench/before.json
  zbench.py run --compare ~/.cache/zbench/before.json
"""
import argparse, fcntl, json, math, os, pty, re, select, shutil, signal, statistics, struct
import subprocess, sys, tempfile, termios, time

HOME = os.path.expanduser("~")
ZSH = "/bin/zsh"
GHOSTTY_RES = "/Applications/Ghostty.app/Contents/Resources/ghostty"
# The typed-ahead command's echo must not contain its output, so the output is escaped.
TYPEAHEAD = b"printf '\\x5fZB\\x5fREADY\\x5f\\n'\r"
MARKER = b"_ZB_READY_"
# starship.toml success_symbol (U+F155) / error_symbol (U+276F)
DEFAULT_PROMPT_RE = rb"\xef\x85\x95|\xe2\x9d\xaf"

# Set from the command line in main().
ZDOTDIR_OVERRIDE = None
USE_PTY = True


def base_env(kind):
    """kind: 'launchd' (bare GUI-app env), 'ghostty' (+ Ghostty's vars and shell integration),
    or 'pane' (what a nested shell like a zellij pane inherits from a configured tab)."""
    if kind == "pane":
        return dict(pane_env())
    # What launchd hands a GUI app, not whatever this script inherited.
    env = {k: os.environ[k] for k in ("USER", "LOGNAME", "TMPDIR", "LANG") if k in os.environ}
    env.update(HOME=HOME, SHELL=ZSH, PATH="/usr/bin:/bin:/usr/sbin:/sbin", TERM="xterm-256color")
    if kind == "ghostty":
        env.update(
            TERM_PROGRAM="ghostty", COLORTERM="truecolor",
            GHOSTTY_RESOURCES_DIR=GHOSTTY_RES,
            GHOSTTY_BIN_DIR="/Applications/Ghostty.app/Contents/MacOS",
            GHOSTTY_SHELL_FEATURES="cursor,title",
            TERMINFO="/Applications/Ghostty.app/Contents/Resources/terminfo",
            ZDOTDIR=f"{GHOSTTY_RES}/shell-integration/zsh",
        )
        if ZDOTDIR_OVERRIDE:
            # Ghostty's integration .zshenv hands off to this instead of unsetting ZDOTDIR.
            env["GHOSTTY_ZSH_ZDOTDIR"] = ZDOTDIR_OVERRIDE
    return env


_pane_env = None


def pane_env():
    # Exported state (PATH, FPATH, NVM_*, ...) leaks into nested shells and changes what
    # their startup does, so capture it from a real configured tab rather than guess.
    global _pane_env
    if _pane_env is None:
        out = subprocess.run([ZSH, "-l", "-i", "-c", "env -0"], cwd=HOME, env=base_env("ghostty"),
                             stdin=subprocess.DEVNULL, capture_output=True, timeout=60).stdout
        env = dict(kv.split("=", 1) for kv in out.decode(errors="replace").split("\0") if "=" in kv)
        for k in ("_", "PWD", "OLDPWD", "ZDOTDIR", "GHOSTTY_ZSH_ZDOTDIR"):
            env.pop(k, None)
        if ZDOTDIR_OVERRIDE:
            env["ZDOTDIR"] = ZDOTDIR_OVERRIDE
        env["SHLVL"] = "2"
        _pane_env = env
    return _pane_env


def scenarios(repo):
    s = {
        # zsh with no config at all: the floor nothing can beat
        "floor": dict(argv=[ZSH, "-f"], cwd=HOME, env="launchd", prompt=False),
        # new Ghostty tab/window opened in $HOME (login shell)
        "tab-home": dict(argv=[ZSH, "-l"], cwd=HOME, env="ghostty"),
        # new Ghostty tab inheriting a git repo cwd (starship git modules run)
        "tab-repo": dict(argv=[ZSH, "-l"], cwd=repo, env="ghostty"),
        # zellij pane / nvim :terminal: non-login, nested under a configured tab
        "pane-home": dict(argv=[ZSH], cwd=HOME, env="pane"),
        # Ghostty tab right after a pane started: if the two see different fpath and share
        # a completion dump, this catches compinit rebuilding it every time
        "tab-after-pane": dict(argv=[ZSH, "-l"], cwd=HOME, env="ghostty",
                               prep=dict(argv=[ZSH, "-i", "-c", "exit"], env="pane")),
    }
    if not os.path.isdir(repo):
        del s["tab-repo"]
    return s


def measure(argv, cwd, env, prompt_re, timeout=15.0):
    """Returns (prompt_s, ready_s, output) relative to process start."""
    return (_measure_pty if USE_PTY else _measure_pipe)(argv, cwd, env, prompt_re, timeout)


def _measure_pty(argv, cwd, env, prompt_re, timeout):
    t0 = time.perf_counter()
    pid, fd = pty.fork()
    if pid == 0:
        try:
            fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))
            os.chdir(cwd)
            os.execve(argv[0], argv, env)
        finally:
            os._exit(127)
    os.write(fd, TYPEAHEAD)
    t_prompt, t_ready, buf = _read_until_ready(fd, t0, prompt_re, timeout)
    try:
        os.write(fd, b"exit\r")
        end = time.perf_counter() + 2
        while time.perf_counter() < end:
            r, _, _ = select.select([fd], [], [], 0.1)
            if r and not os.read(fd, 65536):
                break
    except OSError:
        pass
    try:
        os.kill(pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    os.waitpid(pid, 0)
    os.close(fd)
    return t_prompt, t_ready, buf


def _measure_pipe(argv, cwd, env, prompt_re, timeout):
    # Fallback where PTYs are unavailable (e.g. a sandbox). zsh prints the prompt and runs
    # precmd without a terminal when forced interactive, but ZLE (syntax highlighting,
    # Ghostty's zle hooks) never starts, so numbers read slightly low.
    if "-i" not in argv:
        argv = [argv[0], "-i", *argv[1:]]
    t0 = time.perf_counter()
    p = subprocess.Popen(argv, cwd=cwd, env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    os.write(p.stdin.fileno(), TYPEAHEAD.replace(b"\r", b"\n"))
    t_prompt, t_ready, buf = _read_until_ready(p.stdout.fileno(), t0, prompt_re, timeout)
    try:
        p.stdin.write(b"exit\n")
        p.stdin.close()
        p.wait(2)
    except (BrokenPipeError, subprocess.TimeoutExpired):
        p.kill()
        p.wait()
    p.stdout.close()
    return t_prompt, t_ready, buf


def _read_until_ready(fd, t0, prompt_re, timeout):
    buf, t_prompt, t_ready = b"", None, None
    deadline = t0 + timeout
    while t_ready is None:
        r, _, _ = select.select([fd], [], [], max(0.0, deadline - time.perf_counter()))
        if not r:
            break
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            break
        if not chunk:
            break
        now = time.perf_counter()
        buf += chunk
        if t_prompt is None and prompt_re and prompt_re.search(buf):
            t_prompt = now
        if MARKER in buf:
            t_ready = now
    rel = lambda t: None if t is None else t - t0
    return rel(t_prompt), rel(t_ready), buf


def summarize(xs):
    xs = sorted(x * 1000 for x in xs if x is not None)
    if not xs:
        return None
    p90 = xs[math.ceil(0.9 * len(xs)) - 1]  # nearest-rank
    return dict(median=statistics.median(xs), p90=p90, min=xs[0], max=xs[-1], n=len(xs))


def fmt(st, key="median"):
    return f"{st[key]:6.0f}" if st else "     -"


def cmd_run(a):
    prompt_re = re.compile(a.prompt_re.encode("latin1"))
    sc = scenarios(a.repo)
    names = a.only.split(",") if a.only else list(sc)
    unknown = [n for n in names if n not in sc]
    if unknown:
        sys.exit(f"unknown scenario(s) {unknown}; choose from {list(sc)}")
    mode = "pty" if USE_PTY else "pipe"
    results = {}
    for name in names:
        s = sc[name]
        env = base_env(s["env"])
        prompts, readys = [], []
        for i in range(a.warmup + a.runs):
            if "prep" in s:
                subprocess.run(s["prep"]["argv"], cwd=s["cwd"], env=base_env(s["prep"]["env"]),
                               stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
            p, r, out = measure(s["argv"], s["cwd"], env, prompt_re if s.get("prompt", True) else None)
            if r is None:
                sys.exit(f"{name}: shell never ran the typed-ahead command. Last output:\n"
                         + out[-800:].decode(errors="replace"))
            if i >= a.warmup:
                prompts.append(p)
                readys.append(r)
            if sys.stderr.isatty():
                print(f"\r{name:<15} {i + 1}/{a.warmup + a.runs}", end="", file=sys.stderr, flush=True)
        if sys.stderr.isatty():
            print("\r" + " " * 40 + "\r", end="", file=sys.stderr)
        results[name] = dict(prompt=summarize(prompts), ready=summarize(readys),
                             raw_ready_ms=[round(r * 1000, 1) for r in readys])

    base = json.load(open(os.path.expanduser(a.compare))) if a.compare else None
    if base and base.get("mode", "pty") != mode:
        print(f"WARNING: baseline was measured in {base.get('mode')} mode, this run in {mode} mode")
    base_res = base["results"] if base else {}
    config = ZDOTDIR_OVERRIDE or "live"
    print(f"config: {config}   mode: {mode}   runs: {a.runs}")
    print(f"{'scenario':<15} {'prompt':>6} {'ready':>6} {'p90':>6} {'min':>6} {'max':>6}"
          + (f"   vs {base.get('label') or a.compare} (ready median)" if base else ""))
    for name, r in results.items():
        line = (f"{name:<15} {fmt(r['prompt'])} {fmt(r['ready'])} {fmt(r['ready'], 'p90')}"
                f" {fmt(r['ready'], 'min')} {fmt(r['ready'], 'max')}")
        if name in base_res and base_res[name]["ready"]:
            old, new = base_res[name]["ready"]["median"], r["ready"]["median"]
            line += f"   {old:6.0f} -> {new:4.0f} ms  ({(new - old) / old * 100:+.0f}%)"
        print(line)
    print("(ms from process start; 'prompt' = starship glyph drawn, 'ready' = typed-ahead command ran)")

    if a.save:
        path = os.path.expanduser(a.save)
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        json.dump(dict(label=a.label, config=config, mode=mode, runs=a.runs,
                       when=time.strftime("%Y-%m-%dT%H:%M:%S"), results=results),
                  open(path, "w"), indent=1)
        print(f"saved {path}")
    if a.budget_ms:
        budgets = {}
        for b in a.budget_ms:
            name, _, ms = b.rpartition("=")
            budgets[name or "*"] = float(ms)
        over = []
        for n, r in results.items():
            limit = budgets.get(n, budgets.get("*"))
            if n != "floor" and limit is not None and r["ready"]["median"] > limit:
                over.append(f"{n} {r['ready']['median']:.0f} > {limit:.0f}")
        if over:
            sys.exit(f"FAIL: over budget: {', '.join(over)}")
        print("PASS: every scenario's median ready time is within budget")


# ---------------------------------------------------------------- trace
# Timestamped xtrace to a file, then the same hand-off the real startup would do.
# (%D{...} rather than $EPOCHREALTIME: PS4 only expands parameters under prompt_subst.)
TRACE_ZSHENV = r"""
typeset -g PS4='+%e %D{%s.%6.} %x:%I> '
exec 2>>"$ZB_TRACE_FILE"
setopt xtrace
"""
# Ghostty's own .zshenv restores ZDOTDIR (or unsets it), sources the user's .zshenv and
# loads its integration.
CHAIN_GHOSTTY = 'source "$ZDOTDIR/.zshenv.orig"\n'
CHAIN_PLAIN = ('if [[ -n $ZB_ZDOTDIR ]]; then export ZDOTDIR=$ZB_ZDOTDIR; else unset ZDOTDIR; fi\n'
               'unset ZB_ZDOTDIR; source "${ZDOTDIR:-$HOME}/.zshenv"\n')


def cmd_trace(a):
    s = scenarios(a.repo)[a.scenario]
    roots = ["/etc/z", f"{HOME}/.z", f"{HOME}/.config/", f"{HOME}/.dotfiles/", f"{HOME}/.cache/zsh/"]
    if ZDOTDIR_OVERRIDE:
        roots.append(ZDOTDIR_OVERRIDE.rstrip("/") + "/")
    config_path_re = re.compile("^(" + "|".join(map(re.escape, roots)) + ")")
    with tempfile.TemporaryDirectory() as d:
        trace_file = os.path.join(d, "trace.log")
        env = base_env(s["env"])
        ghostty = s["env"] == "ghostty"
        if ghostty:
            # Copy Ghostty's integration dir in, since its .zshenv finds ghostty-integration
            # relative to itself.
            src = env["ZDOTDIR"]
            for f in os.listdir(src):
                dst = ".zshenv.orig" if f == ".zshenv" else f
                shutil.copyfile(os.path.join(src, f), os.path.join(d, dst))
        else:
            env["ZB_ZDOTDIR"] = env.get("ZDOTDIR", "")
        with open(os.path.join(d, ".zshenv"), "w") as f:
            f.write(TRACE_ZSHENV + (CHAIN_GHOSTTY if ghostty else CHAIN_PLAIN))
        env.update(ZDOTDIR=d, ZB_TRACE_FILE=trace_file)
        t_start = time.time()
        _, r, _ = measure(s["argv"], s["cwd"], env, None)
        lines = open(trace_file, errors="replace").read().splitlines()

    recs = []
    for ln in lines:
        m = re.match(r"^\+(\d+) (\d+\.\d+) (.*?):(\d+)> (.*)", ln)
        if m:
            recs.append((int(m[1]), float(m[2]), m[3], int(m[4]), m[5]))
    if not recs or r is None:
        sys.exit("no trace records captured / shell never became ready")
    t_ready = t_start + r
    print(f"{a.scenario} ({ZDOTDIR_OVERRIDE or 'live'} config): ready {r * 1000:.0f} ms under xtrace "
          f"(tracing inflates absolute numbers; use the ranking, then confirm with `run`)\n")
    print(f"{(recs[0][1] - t_start) * 1000:7.1f} ms  exec + zsh start (before first traced line)")
    cfg_done, open_spans = recs[0][1], []  # open_spans: end times of printed enclosing statements
    for i, (depth, t, path, lineno, text) in enumerate(recs):
        if not config_path_re.match(path):
            continue
        # A statement lasts until the next trace line at the same or shallower depth.
        end = next((x[1] for x in recs[i + 1:] if x[0] <= depth), t_ready)
        if end < t_ready:
            cfg_done = max(cfg_done, end)
        ms = (end - t) * 1000
        if ms >= a.min_ms:
            while open_spans and t >= open_spans[-1]:
                open_spans.pop()
            short = path.replace(HOME, "~")
            print(f"{ms:7.1f} ms  {'  ' * len(open_spans)}{short}:{lineno}  {text[:80]}")
            open_spans.append(end)
    print(f"{(t_ready - cfg_done) * 1000:7.1f} ms  after config files: precmd hooks, prompt, "
          f"first command")


# ---------------------------------------------------------------- parity
PARITY_SCRIPT = r"""
for c in node npm npx nvm pyenv python python3 pip go gcloud starship brew cargo rustc docker orb nvim zellij git; do
  print -r -- "cmd $c: $(whence -w $c 2>/dev/null | cut -d' ' -f2) $(whence -p $c 2>/dev/null)"
done
print -r -- "ver node: $(node -v 2>&1)"
print -r -- "ver python: $(python -V 2>&1)"
for v in NVM_DIR NVM_BIN PYENV_ROOT PYENV_SHELL DOTFILES EDITOR GOOGLE_CLOUD_PROJECT_ID HOMEBREW_PREFIX; do
  print -r -- "env $v=${(P)v}"
done
for c in git docker gcloud pyenv brew cargo go nvm npm ssh kill; do print -r -- "comp $c: ${_comps[$c]}"; done
print -r -- "aliases: ${#aliases}"
print -rl -- "path "${^path}
"""


def parity_snapshot(kind):
    argv = [ZSH, "-l", "-i", "-c", PARITY_SCRIPT] if kind == "ghostty" else [ZSH, "-i", "-c", PARITY_SCRIPT]
    out = subprocess.run(argv, cwd=HOME, env=base_env(kind), stdin=subprocess.DEVNULL,
                         capture_output=True, text=True, timeout=60).stdout
    return [ln for ln in out.splitlines() if re.match(r"^(cmd|ver|env|comp|aliases|path) ", ln)]


def cmd_parity(a):
    snap = parity_snapshot(a.kind)
    if a.snapshot:
        path = os.path.expanduser(a.snapshot)
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        open(path, "w").write("\n".join(snap) + "\n")
        print(f"saved {len(snap)} facts to {path}")
        return
    old = open(os.path.expanduser(a.check)).read().splitlines()
    gone, new = [x for x in old if x not in snap], [x for x in snap if x not in old]
    for x in gone:
        print(f"- {x}")
    for x in new:
        print(f"+ {x}")
    if gone or new:
        sys.exit(f"PARITY DIFF: {len(gone)} removed, {len(new)} added")
    if old != snap:
        sys.exit("PARITY DIFF: same facts, different order (check PATH order)")
    print(f"parity OK: {len(snap)} facts identical")


# ---------------------------------------------------------------- freeze
STARTUP_FILES = (".zshenv", ".zprofile", ".zshrc", ".zlogin")
CONFIG_REF_RE = re.compile(r"(\$HOME|\$\{HOME\}|~)/\.config/([\w.\-]+)")


def cmd_freeze(a):
    d = os.path.abspath(os.path.expanduser(a.dir))
    os.makedirs(os.path.join(d, "config"), exist_ok=True)
    copied = []

    def snapshot_ref(m):
        # Files sourced from ~/.config would otherwise keep resolving to the live copies.
        live = os.path.join(HOME, ".config", m.group(2))
        if not os.path.isfile(live):
            return m.group(0)
        shutil.copyfile(live, os.path.join(d, "config", m.group(2)))
        copied.append(f"~/.config/{m.group(2)}")
        return "$ZDOTDIR/config/" + m.group(2)

    for name in STARTUP_FILES:
        src = os.path.join(HOME, name)
        if not os.path.isfile(src):
            continue
        text = CONFIG_REF_RE.sub(snapshot_ref, open(src).read())
        if name == ".zshenv":
            starship = os.path.join(HOME, ".config/starship.toml")
            if os.path.isfile(starship):
                shutil.copyfile(starship, os.path.join(d, "config/starship.toml"))
                copied.append("~/.config/starship.toml")
                text = 'export STARSHIP_CONFIG="$ZDOTDIR/config/starship.toml"\n' + text
        open(os.path.join(d, name), "w").write(text)
        copied.append(f"~/{name}")
    print(f"froze {', '.join(copied)} into {d}")
    print(f"use it with: {sys.argv[0]} --zdotdir {d} run|trace|parity ...")


def pty_available():
    try:
        m, s = os.openpty()
        os.close(m)
        os.close(s)
        return True
    except OSError:
        return False


def main():
    global ZDOTDIR_OVERRIDE, USE_PTY
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=os.path.join(HOME, "Work/divesite"),
                    help="git repo used for the tab-repo scenario")
    ap.add_argument("--prompt-re", default=DEFAULT_PROMPT_RE.decode("latin1"),
                    help="regex (bytes) that identifies the drawn prompt")
    ap.add_argument("--zdotdir", help="run against a config frozen with `freeze` instead of the live one")
    ap.add_argument("--no-pty", action="store_true",
                    help="use pipes instead of a terminal (automatic when PTYs are unavailable)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("run")
    r.add_argument("-n", "--runs", type=int, default=15)
    r.add_argument("--warmup", type=int, default=2)
    r.add_argument("--only", help="comma-separated scenario names")
    r.add_argument("--save")
    r.add_argument("--compare")
    r.add_argument("--label", default="")
    r.add_argument("--budget-ms", action="append", metavar="[SCENARIO=]MS",
                   help="fail if a scenario's median ready time exceeds MS (repeatable)")
    t = sub.add_parser("trace")
    t.add_argument("--scenario", default="tab-home")
    t.add_argument("--min-ms", type=float, default=3.0)
    p = sub.add_parser("parity")
    p.add_argument("--kind", choices=("ghostty", "pane"), default="ghostty",
                   help="snapshot a top-level Ghostty tab or a nested pane shell")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--snapshot")
    g.add_argument("--check")
    f = sub.add_parser("freeze")
    f.add_argument("dir")
    a = ap.parse_args()

    if a.zdotdir:
        ZDOTDIR_OVERRIDE = os.path.abspath(os.path.expanduser(a.zdotdir))
        if not os.path.isfile(os.path.join(ZDOTDIR_OVERRIDE, ".zshrc")):
            sys.exit(f"{ZDOTDIR_OVERRIDE} has no .zshrc; create it with `freeze` first")
    USE_PTY = not a.no_pty and pty_available()
    if not USE_PTY and not a.no_pty and a.cmd in ("run", "trace"):
        print("note: no PTY available here; falling back to pipes (ZLE doesn't start, so numbers "
              "read slightly low)", file=sys.stderr)
    {"run": cmd_run, "trace": cmd_trace, "parity": cmd_parity, "freeze": cmd_freeze}[a.cmd](a)


if __name__ == "__main__":
    main()
