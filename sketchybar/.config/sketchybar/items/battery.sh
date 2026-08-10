#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item battery right \
           --set battery $(pill "$CYAN") \
                         icon="$ICON_BAT_100" \
                         update_freq=120 \
                         label.width=42 \
                         label.align=right \
                         script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery power_source_change system_woke
