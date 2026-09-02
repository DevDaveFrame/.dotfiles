#!/usr/bin/env bash
# Apply a yabai grid spec to the focused window.
#
# --grid only has a stable effect on floating windows: a bsp-managed window is
# re-tiled by the layout engine as soon as the frame changes. So float first,
# unless the window already floats.
#
# usage: grid.sh <ROWS:COLS:X:Y:W:H>

set -euo pipefail

spec="${1:?usage: grid.sh <ROWS:COLS:X:Y:W:H>}"

floating=$(yabai -m query --windows --window | jq -r '."is-floating"')
[ "$floating" = "true" ] || yabai -m window --toggle float

yabai -m window --grid "$spec"
