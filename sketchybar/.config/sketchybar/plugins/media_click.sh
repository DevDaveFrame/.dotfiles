#!/usr/bin/env bash
#
# Left-click  → toggle playback.
# Right-click → toggle the prev / play-pause / next popup.
#
# $BUTTON is supplied by SketchyBar for click_script invocations.

source "$HOME/.config/sketchybar/variables.sh"

case "$BUTTON" in
  right)
    POPUP="$(sketchybar --query media | jq -r '.popup.drawing')"
    if [ "$POPUP" = "on" ]; then
      sketchybar --set media popup.drawing=off
    else
      sketchybar --set media popup.drawing=on
    fi
    ;;
  *)
    media-control toggle-play-pause
    # The stream listener will fire media_update, but nudge it so the pill
    # reflects the new state immediately rather than after the debounce.
    sleep 0.2
    sketchybar --trigger media_update
    ;;
esac
