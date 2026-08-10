#!/usr/bin/env bash
#
# Memory pressure. Stands in for the article's CPU widget.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item memory right \
           --set memory $(pill "$ORANGE") \
                        icon="$ICON_MEMORY" \
                        update_freq=5 \
                        label.width=48 \
                        label.align=right \
                        script="$PLUGIN_DIR/memory.sh"
