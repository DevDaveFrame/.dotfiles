#!/usr/bin/env bash
#
# Added first of the right-hand items, so it lands at the far right of the bar.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item clock right \
           --set clock $(pill "$MAGENTA") \
                       icon="$ICON_CLOCK" \
                       update_freq=1 \
                       label.width=72 \
                       label.align=right \
                       script="$PLUGIN_DIR/clock.sh"
