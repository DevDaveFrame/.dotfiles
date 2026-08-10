#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item volume right \
           --set volume $(pill "$YELLOW") \
                        icon="$ICON_VOL_MID" \
                        label.width=42 \
                        label.align=right \
                        script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
