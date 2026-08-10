#!/usr/bin/env bash
#
# Battery percentage with a five-step glyph ramp, plus a charging indicator.
# Turns red below 20% while on battery.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

BATT="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT" | grep -Eo '\d+%' | head -1 | cut -d% -f1)"
CHARGING="$(echo "$BATT" | grep 'AC Power')"

case "$PERCENTAGE" in
  ''|*[!0-9]*) exit 0 ;;
esac

if [ "$PERCENTAGE" -ge 90 ]; then
  ICON="$ICON_BAT_100"
elif [ "$PERCENTAGE" -ge 60 ]; then
  ICON="$ICON_BAT_75"
elif [ "$PERCENTAGE" -ge 30 ]; then
  ICON="$ICON_BAT_50"
elif [ "$PERCENTAGE" -ge 10 ]; then
  ICON="$ICON_BAT_25"
else
  ICON="$ICON_BAT_0"
fi

COLOR="$CYAN"
if [ -n "$CHARGING" ]; then
  ICON="$ICON_BAT_CHARGING"
elif [ "$PERCENTAGE" -lt 20 ]; then
  COLOR="$RED"
fi

sketchybar --set "$NAME" $(pill "$COLOR") icon="$ICON" label="${PERCENTAGE}%"
