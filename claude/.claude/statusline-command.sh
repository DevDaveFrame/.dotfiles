#!/bin/bash
# Claude Code status line.
#
# Captured verbatim from this machine's ~/.claude/remote-settings.json, which is
# where the two-row bar actually came from -- not from any file under ~/.claude.
# Remote settings are pushed to the machine and can be re-pushed at any time, so
# this is a frozen snapshot: it reproduces the bar on machines that have no
# remote settings, and is redundant (but harmless) on ones that do.
#
# Row 1:  [Model:effort] (branch) <dir>  <badges>
# Row 2:  [<20-cell bar>] N% ctx | <session duration> | <output style> | <rate limits>
#
# The bar is green under 50% context, yellow at 50-79%, red at 80%+. The output
# style segment is omitted when it is "default"; the worktree badge and the
# rate-limit segment appear only when Claude Code sends those fields.
#
# The body below is the remote command as-is -- one jq program reading the status
# JSON on stdin. Reformatting it risks changing the rendered output, so edits
# should be made deliberately and diffed against the old rendering.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
input=$(cat)
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
esc=$(printf '\033')
printf '%s' "$input" | jq -r --arg b "$branch" --arg e "$esc" 'def fmt(s): (if s < 0 then 0 else s end) as $s | if $s >= 86400 then "\($s/86400|floor)d\((($s%86400)/3600)|floor)h" elif $s >= 3600 then "\($s/3600|floor)h\((($s%3600)/60)|floor)m" elif $s >= 60 then "\($s/60|floor)m" else "\($s)s" end; def toepoch($r): if ($r|type)=="number" then $r else ($r|sub("\\.[0-9]+Z$";"Z")|fromdateiso8601) end; def win($w; $lbl): if $w.resets_at then $lbl + ":" + fmt(toepoch($w.resets_at) - now) + (if $w.used_percentage then " (" + ($w.used_percentage|floor|tostring) + "%)" else "" end) else empty end; ($e+"[32m") as $grn | ($e+"[33m") as $ylw | ($e+"[31m") as $red | ($e+"[0m") as $rst | (.model.display_name // "?") as $m | (if .effort.level then $m + ":" + .effort.level else $m end) as $ml | (.context_window.used_percentage // 0 | floor) as $p | ($p/5 | floor) as $f0 | (if $f0 < 0 then 0 elif $f0 > 20 then 20 else $f0 end) as $f | (if $p >= 80 then $red elif $p >= 50 then $ylw else $grn end) as $col | (("█" * $f) // "") as $fill | (("░" * (20 - $f)) // "") as $empty | "\($col)[\($fill)\($empty)]\($rst)" as $bar | ((.cost.total_duration_ms // 0) / 1000 | floor) as $sd | (if $sd >= 3600 then "\($sd/3600|floor)h\((($sd%3600)/60)|floor)m" elif $sd >= 60 then "\($sd/60|floor)m" else "\($sd)s" end) as $dur | (.output_style.name // "") as $st | (if ($st == "" or $st == "default") then "" else " | 🎨 " + $st end) as $stseg | (.workspace.current_dir // .cwd // "") as $d | ($d | split("/") | last) as $base | (if $b == "" then "" else " (" + $b + ")" end) as $brseg | ([ (if .worktree.name then "⌂" + .worktree.name else empty end) ]) as $badges | (if ($badges|length) > 0 then "  " + ($badges|join(" ")) else "" end) as $badgeseg | (.rate_limits // {}) as $rl | ([ win($rl.five_hour // {}; "5h"), win($rl.seven_day // {}; "7d") ]) as $rs | (if ($rs|length) > 0 then " | ⟳ " + ($rs|join("  ")) else "" end) as $rlseg | "[\($ml)]\($brseg) 📁 \($base)\($badgeseg)" as $row1 | "\($bar) \($p)% ctx | ⏱ \($dur)\($stseg)\($rlseg)" as $row2 | $row1 + "\n" + $row2'
