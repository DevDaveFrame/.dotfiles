# dotfiles

## Setup

```bash
git clone https://github.com/daveframe/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./run
```

## Stow packages

Each directory is a [GNU Stow](https://www.gnu.org/software/stow/) package.
`stow --restow <pkg>` symlinks its contents into `$HOME`.

| Package    | Targets                    |
|------------|----------------------------|
| `git`      | `~/.gitconfig`             |
| `nvim`     | `~/.config/nvim/`          |
| `starship` | `~/.config/starship.toml`  |
| `zsh`      | `~/.zshrc`, `~/.zshenv`    |
| `zellij`   | `~/.config/zellij/`        |
| `skhd`     | `~/.config/skhd/`          |
| `yabai`    | `~/.config/yabai/`         |
| `sketchybar` | `~/.config/sketchybar/`  |
| `shell`    | `~/.config/.aliases`, `~/.config/.functions`, `~/.config/completion.zsh` |
| `ghostty`  | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `claude`   | `~/.claude/settings.json`, `statusline-command.sh`, `skills/` |
| `kanata`   | `~/.config/kanata/` (plus two LaunchDaemons, see below) |

`shell/` **is** stowed — `.zshrc` sources `$HOME/.config/.aliases` and friends,
which stow symlinks back here. (It was previously documented as "not stowed,
sourced directly from `$DOTFILES`", which was never true: those were real,
untracked files and the repo copies had gone stale.)

## Drift

`stow` does nothing when a target already exists as a real file, and says so
only in passing. When that happens the config still works, so nothing looks
wrong — but edits go to an untracked copy and the repo silently rots. This bit
`nvim`, `zsh`, `zellij`, `skhd` and `shell` for months.

Two guards:

- `run` refuses to stow if any target is a real file, and prints the offenders.
  It compares resolved paths rather than testing `-L` on each file, because
  stow folds a whole directory into a single symlink where it can — every file
  under `~/.config/yabai` is reached through one link, and testing the leaves
  reported all of them as drift.
- The `<app>config` aliases point into `$DOTFILES` rather than `~/.config`, so
  editing always touches the tracked file and a wrong path fails loudly.

To check by hand:

```bash
ls -l ~/.config/nvim ~/.zshrc ~/.config/.aliases   # want symlinks, not files
```

## claude

`~/.claude` is mostly runtime state and secrets — `.credentials.json` holds OAuth
tokens, `history.jsonl` is the full prompt history, `projects/` and `sessions/`
are transcripts. The package therefore tracks **only** `settings.json`,
`statusline-command.sh` and `skills/`.

`.gitignore` enforces this as a whitelist: everything under `claude/.claude/` is
ignored and the three tracked paths are re-included by name. Tracking something
new there means adding a negation deliberately. Do not replace this with a
blacklist.

## ghostty

The config hard-references `./ghostty-shaders/cursor_blaze_tapered.glsl`, so the
shader directory is a dependency, not an extra — Ghostty fails to apply the
custom shader without it.

The shaders are **vendored**, not a submodule. They came from
[hackr-sh/ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders) (at
`a17573f`), but `cursor_blaze_tapered.glsl` — the one actually referenced — is a
local addition that was never committed upstream, so a submodule would restore
an empty-looking checkout and silently break the config. `run` also clones
without `--recursive`. Vendoring keeps a fresh machine working.

## SketchyBar

TokyoNight status bar, one bordered pill per widget. Layout:

```
[ 1 2 3 ] ❯   [  Ghostty ]        ·notch·        [ 󰝚 Track — Artist ]   [mem] [wifi] [vol] [batt] [date] [time]
```

- `variables.sh` — palette, font, geometry, and the shared `pill()` styling helper.
- `icons.sh` — **generated**; Nerd Font glyph constants plus the `app_icon()` lookup
  used by `front_app`. Stock Nerd Font glyphs only, no `sketchybar-app-font`.
- `items/<name>.sh` — appearance and subscriptions. `plugins/<name>.sh` — logic.
- `helpers/check_glyphs.sh` — verifies every glyph in `icons.sh` exists in the font.
  A missing glyph renders as a silent tofu box, so run this after editing icons.
- `helpers/media_listener.sh` — bridges `media-control stream` to a custom
  `media_update` event.

Requires **Berkeley Mono** (a paid font, not installable via brew) patched with
Nerd Font — the config expects `BerkeleyMonoVariable Nerd Font Mono` in
`~/Library/Fonts`. Point `FONT` in `variables.sh` at another Nerd Font to change it.

Notes:
- Spaces are display-only. SIP is enabled, so yabai's scripting addition cannot
  load and click-to-focus would silently do nothing.
- The media widget is player-agnostic (TIDAL, Spotify, Music, browsers) via
  `media-control`. SketchyBar's built-in `media_change` event is unreliable since
  macOS 15.4 locked down MediaRemote.
- `yabairc` reserves the bar strip with `external_bar all:30:0`. That 30 must be
  kept in step with `BAR_HEIGHT` in `variables.sh`.

## kanata

Home row mods and caps lock as SUPER on the built-in keyboard. `skhdrc`
documents the grammar; `kanata/.config/kanata/kanata.kbd` supplies the key.

```
caps (tap)   esc
caps (hold)  SUPER = ctrl + alt + cmd
a s d f  /  j k l ;   held = ctrl alt cmd shift, outward from the index finger
```

Holds only fire when the *next* key is on the other hand
(`defhands` + `tap-hold-opposite-hand`), so same-hand rolls still type letters.

### Three things that must line up

kanata talks to the Karabiner virtual HID driver over a **versioned IPC
protocol**: driver `v6.x` is protocol 5, `v7.x` is 6, `v8.x` is 7. Homebrew
kanata 1.12.0 speaks protocol 5, so `run` pins the driver to **v6.2.0**. A
newer driver produces a daemon kanata connects to and cannot talk to, with no
useful error. Bump `KANATA_DRIVER_VERSION` in `run` only alongside the driver
version named in the kanata release notes.

**Do not install Karabiner-Elements.** It looks like a shortcut — it bundles
the driver and runs the virtual HID daemon for you — but the cask auto-updates
its driver past v6 and silently breaks kanata.

Because there is no Karabiner-Elements, nothing starts the virtual HID daemon,
and kanata then loops `connect_failed asio.system:2` forever. Hence two
LaunchDaemons rather than one:

| Label | Purpose |
|---|---|
| `org.pqrs.Karabiner-VirtualHIDDevice-Daemon` | the virtual keyboard kanata writes through |
| `dev.kanata.kanata` | kanata itself |
| `dev.kanata.logcap` | caps the log file — see below |

Both live in `kanata/launchd/` and are installed to `/Library/LaunchDaemons`
as `root:wheel` by `run` — not stowed, which is what the package's
`.stow-local-ignore` is for. They are LaunchDaemons and not LaunchAgents
because the driver's IPC socket is under a root-only directory.

### Permissions, and the upgrade trap

kanata needs **Input Monitoring** and **Accessibility** in System Settings >
Privacy & Security. Add the *resolved* binary, not the symlink:

```bash
readlink -f /opt/homebrew/bin/kanata   # /opt/homebrew/Cellar/kanata/1.12.0/bin/kanata
```

macOS stores the resolved path, so **every `brew upgrade kanata` invalidates
the grant** and it has to be re-added. That is the usual cause of "it worked
yesterday". The symptom in `/var/log/kanata.log` is:

```
IOHIDDeviceOpen error: (iokit/common) not permitted Apple Internal Keyboard / Trackpad
```

Also make sure Caps Lock is set back to **Caps Lock** in System Settings >
Keyboard > Keyboard Shortcuts > Modifier Keys for the internal keyboard.
kanata owns that key now and supplies escape on tap.

### The log is capped, not rotated

kanata 1.12.0 prints `virtual_hid_keyboard_ready true` in a tight loop —
[jtroo/kanata#2109](https://github.com/jtroo/kanata/issues/2109), harmless, and
measured here at **2.5 MB/day** into `/var/log/kanata.log`.

Nothing easy silences it:

- It comes from the C++ driverkit client, not kanata's Rust logger, so
  `--quiet` (which only sets the Rust log level) does not touch it.
- kanata's own `[INFO]` lines go to **stdout** too (`TerminalMode::Mixed` puts
  only warnings and errors on stderr), so pointing `StandardOutPath` at
  `/dev/null` would also throw away `keyboard grabbed` and
  `driver version matched` — the lines you actually want after a reboot.
- newsyslog cannot rotate it. launchd opens `StandardOutPath` once at spawn and
  never reopens it, so a rotation would leave kanata writing to the rotated
  inode, and macOS newsyslog has no truncate-in-place flag (`B C D G J N U Z`).

So `dev.kanata.logcap` truncates the file in place when it passes 10 MB,
checked hourly. Truncating under a running kanata is safe: launchd opens the
file `O_APPEND`, so the next write lands at offset 0. Worst case, if it did not,
the file would go sparse — the disk space is reclaimed either way.

By hand, if you want it clean now:

```bash
sudo truncate -s 0 /var/log/kanata.log
```

Delete `kanata/launchd/dev.kanata.logcap.plist` and drop it from the loop in
`run` once homebrew ships a kanata newer than 1.12.0 with #2109 fixed.

### Escape hatches

`macos-dev-names-include` scopes kanata to the internal keyboard, so an
external keyboard is never grabbed and always works. Beyond that:

```bash
lctl+spc+esc                                    # held together, exits kanata
sudo launchctl bootout system/dev.kanata.kanata # stop it for good
sudo launchctl kickstart -k system/dev.kanata.kanata  # reload after a config edit
sudo tail -f /var/log/kanata.log
```

`KeepAlive` is deliberately the `SuccessfulExit=false` dict form, not `true`,
so launchd does not instantly undo the panic key.

## Adding a new config

1. `mkdir -p <app>/.config/<app>` (mirror the path relative to `$HOME`)
2. Move your config files into it
3. Add the package name to `STOW_PACKAGES` in `run`
4. `stow --restow <app>`
