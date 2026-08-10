#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item calendar right \
           --set calendar $(pill "$BLUE") \
                          icon="$ICON_CALENDAR" \
                          update_freq=15 \
                          click_script="open -a Fantastical" \
                          script="$PLUGIN_DIR/calendar.sh"
