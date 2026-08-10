#!/usr/bin/env bash
#
# Wi-Fi SSID. Not in the article — replaces the CPU slot alongside memory.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item wifi right \
           --set wifi $(pill "$TEAL") \
                      icon="$ICON_WIFI" \
                      update_freq=30 \
                      label.max_chars=16 \
                      click_script="open -b com.apple.systempreferences /System/Library/PreferencePanes/Network.prefPane" \
                      script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change
