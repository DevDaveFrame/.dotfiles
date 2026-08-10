#!/bin/bash
# Claude Code status line, adapted from ~/.config/starship.toml
# Managed by the statusline-setup agent -- ask Claude (statusline-setup) to change this.
#
# Segments mirrored from starship.toml (as closely as practical given the
# JSON Claude Code provides on stdin):
#   [username]    -> $(whoami)
#   [directory]   -> workspace.current_dir, truncated to 3 components,
#                    with the same path substitutions (Work, divesite, etc.)
#   [git_branch]  -> current branch
#   [git_status]  -> dirty marker + ahead/behind counts
#   [time]        -> HH:MM (24h, same as starship's "%R")
# Segments that don't map to anything meaningful in a Claude Code session
# (gcloud, docker_context, cmd_duration, python/node/rust/go/java/c versions,
# the success/error character) are omitted. The following are appended as
# small, Claude-Code-specific additions (not from starship.toml):
#   - model display name
#   - context window usage: percent used + "used/max" tokens (e.g. "82k/200k"),
#     from context_window.used_percentage / total_input_tokens / context_window_size
#   - 5-hour rate-limit usage, from rate_limits.five_hour.used_percentage,
#     plus its reset time (local HH:MM) from rate_limits.five_hour.resets_at
#   - 7-day rate-limit usage, from rate_limits.seven_day.used_percentage
#     (all rate-limit fields are only shown when Claude Code actually
#     includes them in the payload -- e.g. Claude.ai subscribers only)
#
# All git calls use --no-optional-locks and never fetch, so this never
# blocks or interferes with git operations happening elsewhere.

# Compact number formatting: 82345 -> "82k", 200000 -> "200k", 1500000 -> "1.5M"
format_num() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) {
      v = n / 1000000
      if (v == int(v)) printf "%dM", v; else printf "%.1fM", v
    } else if (n >= 1000) {
      v = n / 1000
      if (v == int(v)) printf "%dk", v; else printf "%.0fk", v
    } else {
      printf "%d", n
    }
  }'
}

# Unix epoch seconds -> local HH:MM (matches the time segment's %R format).
# Tries BSD date (macOS) first, then falls back to GNU date (Linux).
epoch_to_hm() {
  local out
  out=$(date -r "$1" +%R 2>/dev/null)
  [ -z "$out" ] && out=$(date -d "@$1" +%R 2>/dev/null)
  echo "$out"
}

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
model=$(echo "$input" | jq -r '.model.display_name // ""')
user=$(whoami)

# --- directory: mirrors [directory] (truncation_length = 3 + substitutions) ---
dir="$cwd"
dir="${dir/#$HOME/~}"
IFS='/' read -ra parts <<< "$dir"
n=${#parts[@]}
if [ "$n" -gt 4 ]; then
  short="…"
  start=$((n - 3))
  for ((i = start; i < n; i++)); do
    short="$short/${parts[$i]}"
  done
  dir="$short"
fi
dir="${dir//Documents/󰈙 }"
dir="${dir//Downloads/ }"
dir="${dir//Music/󰝚 }"
dir="${dir//Pictures/ }"
dir="${dir//Develop/󰲋 }"
dir="${dir//Work/ }"
dir="${dir//divesite/󰷀}"

# --- git: mirrors [git_branch] + [git_status] ---
branch=""
git_status=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  [ -n "$porcelain" ] && git_status="*"
  ab=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
  if [ -n "$ab" ]; then
    ahead=$(echo "$ab" | awk '{print $1}')
    behind=$(echo "$ab" | awk '{print $2}')
    [ "$ahead" != "0" ] && git_status="${git_status}⇡${ahead}"
    [ "$behind" != "0" ] && git_status="${git_status}⇣${behind}"
  fi
fi

# --- time: mirrors [time] (time_format = "%R") ---
time_now=$(date +%R)

# --- context window usage (Claude-Code-specific addition) ---
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_max=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
ctx_segment=""
if [ -n "$ctx_pct" ]; then
  ctx_pct_fmt=$(awk -v p="$ctx_pct" 'BEGIN{printf "%.0f", p}')
  ctx_segment="ctx:${ctx_pct_fmt}%"
  if [ -n "$ctx_tokens" ] && [ -n "$ctx_max" ]; then
    ctx_segment="${ctx_segment} ($(format_num "$ctx_tokens")/$(format_num "$ctx_max"))"
  fi
fi

# --- 5-hour rate-limit usage (Claude-Code-specific addition) ---
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
five_h_segment=""
if [ -n "$five_h_pct" ]; then
  five_h_pct_fmt=$(awk -v p="$five_h_pct" 'BEGIN{printf "%.0f", p}')
  five_h_segment="5h:${five_h_pct_fmt}%"
  if [ -n "$five_h_resets" ]; then
    five_h_resets_fmt=$(epoch_to_hm "$five_h_resets")
    [ -n "$five_h_resets_fmt" ] && five_h_segment="${five_h_segment} (resets ${five_h_resets_fmt})"
  fi
fi

# --- 7-day rate-limit usage (Claude-Code-specific addition) ---
seven_d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_d_segment=""
if [ -n "$seven_d_pct" ]; then
  seven_d_pct_fmt=$(awk -v p="$seven_d_pct" 'BEGIN{printf "%.0f", p}')
  seven_d_segment="7d:${seven_d_pct_fmt}%"
fi

# --- colors: dimmed, since the status line is already rendered dim ---
PINK=$'\033[2;35m'
DIM=$'\033[2m'
RESET=$'\033[0m'

line="${PINK}╒═${RESET}"
line="${line}${DIM} ${user}/${dir} ${RESET}"
[ -n "$branch" ] && line="${line}${DIM} ${branch} ${RESET}"
[ -n "$git_status" ] && line="${line}${DIM}${git_status} ${RESET}"
line="${line}${DIM}  ${time_now} ${RESET}"
[ -n "$model" ] && line="${line}${DIM}[${model}]${RESET}"
[ -n "$ctx_segment" ] && line="${line}${DIM} ${ctx_segment} ${RESET}"
[ -n "$five_h_segment" ] && line="${line}${DIM} ${five_h_segment} ${RESET}"
[ -n "$seven_d_segment" ] && line="${line}${DIM} ${seven_d_segment} ${RESET}"
line="${line}${PINK} ═╛${RESET}"

printf "%s" "$line"
