#!/usr/bin/env bash
#
# Percentage of memory in use.
#
# `memory_pressure` prints "System-wide memory free percentage: N%" as its last
# line and returns in ~3ms, so it is cheap enough for a 5s update.

source "$HOME/.config/sketchybar/variables.sh"

FREE="$(memory_pressure 2>/dev/null \
  | awk -F': ' '/System-wide memory free percentage/ { gsub(/%/, "", $2); print $2; exit }')"

case "$FREE" in
  ''|*[!0-9]*) exit 0 ;;   # unparseable — leave the last good value on screen
esac

sketchybar --set "$NAME" label="$((100 - FREE))%"
