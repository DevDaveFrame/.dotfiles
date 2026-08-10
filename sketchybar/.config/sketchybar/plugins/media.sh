#!/usr/bin/env bash
#
# Refreshes the now-playing pill.
#
# Visibility rule: the pill hides when there is no media session at all (nothing
# loaded, player quit), but stays visible — dimmed — while merely paused.
# Hiding on pause too would make the popup's play button unreachable, which is
# the one control you actually want when paused.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Closing the popup is the only thing this script does for mouse events.
if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set media popup.drawing=off
  exit 0
fi

hide() {
  sketchybar --set media drawing=off popup.drawing=off
  exit 0
}

# --no-artwork matters: without it every call drags several hundred kilobytes
# of base64 artwork through the pipe.
JSON="$(media-control get --no-artwork 2>/dev/null)"
if [ -z "$JSON" ] || [ "$JSON" = "null" ]; then
  hide
fi

TITLE="$(echo "$JSON" | jq -r '.title // empty')"
ARTIST="$(echo "$JSON" | jq -r '.artist // empty')"
PLAYING="$(echo "$JSON" | jq -r '.playing // false')"

if [ -z "$TITLE" ]; then
  hide
fi

LABEL="$TITLE"
[ -n "$ARTIST" ] && LABEL="$TITLE — $ARTIST"

if [ "$PLAYING" = "true" ]; then
  COLOR="$GREEN"
  TOGGLE_ICON="$ICON_MEDIA_PAUSE"
else
  COLOR="$COMMENT"
  TOGGLE_ICON="$ICON_MEDIA_PLAY"
fi

sketchybar --set media drawing=on \
                       label="$LABEL" \
                       icon.color="$COLOR" \
                       label.color="$COLOR" \
                       background.border_color="$COLOR" \
           --set media.toggle icon="$TOGGLE_ICON" icon.color="$COLOR" \
           --set media.prev icon.color="$COLOR" \
           --set media.next icon.color="$COLOR"
