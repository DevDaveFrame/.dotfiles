#!/usr/bin/env bash
#
# Current SSID, or "Offline".
#
# `networksetup -getairportnetwork` is deprecated and unreliable on recent
# macOS; `ipconfig getsummary <iface>` still reports the SSID on macOS 26.
# The interface is discovered rather than hardcoded to en0.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

IFACE="$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Hardware Port: Wi-Fi/ { getline; print $2; exit }')"
[ -z "$IFACE" ] && IFACE="en0"

SSID="$(ipconfig getsummary "$IFACE" 2>/dev/null \
  | awk -F' SSID : ' '/ SSID : / { print $2; exit }')"

if [ -n "$SSID" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" label="$SSID" $(pill "$TEAL")
else
  sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" label="Offline" $(pill "$COMMENT")
fi
