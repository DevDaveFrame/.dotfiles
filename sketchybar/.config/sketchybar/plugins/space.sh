#!/usr/bin/env bash
#
# Highlights the active space. $SELECTED and $NAME are supplied by SketchyBar.

source "$HOME/.config/sketchybar/variables.sh"

if [ "$SELECTED" = "true" ]; then
  COLOR="$RED"
else
  COLOR="$COMMENT"
fi

sketchybar --animate tanh 5 --set "$NAME" icon.color="$COLOR"
