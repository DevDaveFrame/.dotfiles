#!/usr/bin/env bash
#
# label.width is fixed on the item so the seconds ticking over never reflows
# the pills to its left.

source "$HOME/.config/sketchybar/variables.sh"

sketchybar --set "$NAME" label="$(date '+%H:%M:%S')"
