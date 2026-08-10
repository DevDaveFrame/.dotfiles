#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"

sketchybar --set "$NAME" label="$(date '+%a %d. %b')"
