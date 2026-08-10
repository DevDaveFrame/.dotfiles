#!/usr/bin/env bash
#
# Output volume with a four-step speaker ramp.
#
# The article shells out to osascript twice on every volume_change. SketchyBar
# already hands the new level to us in $INFO, so osascript is only needed on the
# initial draw (when there is no event) and to distinguish muted-at-0 from
# genuinely-at-0.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

VOLUME="$INFO"

if [ -z "$VOLUME" ]; then
  VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

case "$VOLUME" in
  ''|*[!0-9]*) exit 0 ;;
esac

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  ICON="$ICON_VOL_MUTE"
else
  if [ "$VOLUME" -ge 60 ]; then
    ICON="$ICON_VOL_HIGH"
  elif [ "$VOLUME" -ge 30 ]; then
    ICON="$ICON_VOL_MID"
  else
    ICON="$ICON_VOL_LOW"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
