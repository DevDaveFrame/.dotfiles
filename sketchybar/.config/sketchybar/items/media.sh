#!/usr/bin/env bash
#
# Player-agnostic now-playing, shown right of the notch.
#
# The article's version was Spotify-only and drove off SketchyBar's built-in
# `media_change` event. That event is backed by MediaRemote, which Apple locked
# down in macOS 15.4, so it is unreliable on macOS 26. Instead this reads the
# system now-playing session via `media-control`, which works for TIDAL,
# Spotify, Music and browser audio alike with no per-app branching.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Custom event fired by helpers/media_listener.sh.
sketchybar --add event media_update

sketchybar --add item media e \
           --set media $(pill "$GREEN") \
                       icon="$ICON_MEDIA" \
                       scroll_texts=on \
                       label.max_chars=25 \
                       associated_display=active \
                       updates=on \
                       update_freq=30 \
                       drawing=off \
                       script="$PLUGIN_DIR/media.sh" \
                       click_script="$PLUGIN_DIR/media_click.sh" \
           --subscribe media media_update mouse.exited.global

# ── Popup controls ───────────────────────────────────────────────────────────
# Opened with a right-click on the pill (left-click toggles playback directly).
popup_item=(
  background.drawing=off
  label.drawing=off
  icon.color="$GREEN"
  icon.font="$FONT:$FONT_STYLE:14.0"
  icon.padding_left=10
  icon.padding_right=10
)

sketchybar --add item media.prev popup.media \
           --set media.prev "${popup_item[@]}" \
                            icon="$ICON_MEDIA_PREV" \
                            click_script="media-control previous-track" \
           --add item media.toggle popup.media \
           --set media.toggle "${popup_item[@]}" \
                              icon="$ICON_MEDIA_PAUSE" \
                              click_script="media-control toggle-play-pause" \
           --add item media.next popup.media \
           --set media.next "${popup_item[@]}" \
                            icon="$ICON_MEDIA_NEXT" \
                            click_script="media-control next-track"
