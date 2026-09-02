#!/usr/bin/env bash
#
# Focused application, shown left of the notch.

source "$HOME/.config/sketchybar/variables.sh"

sketchybar --add item front_app left \
           --set front_app $(pill "$WHITE") \
                           label.max_chars=22 \
                           associated_display=active \
                           script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
