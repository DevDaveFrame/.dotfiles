#!/usr/bin/env bash
#
# Player-agnostic now-playing, sitting immediately left of the notch.
#
# The article's version was Spotify-only and drove off SketchyBar's built-in
# `media_change` event. That event is backed by MediaRemote, which Apple locked
# down in macOS 15.4, so it is unreliable on macOS 26. Instead this reads the
# system now-playing session via `media-control`, which works for TIDAL,
# Spotify, Music and browser audio alike with no per-app branching.
#
# Position `q` (left of notch) rather than `e` (right of notch): on this 1512pt
# display the right-hand widgets begin at x=955 and the notch ends near x=856,
# leaving only ~99pt of clearance, while this pill is up to 228pt wide. At `e`
# it collided with the memory and wifi pills. The `q` region is right-anchored
# against the notch, so this is added BEFORE front_app in sketchybarrc to end up
# as the rightmost of the two.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Custom event fired by helpers/media_listener.sh.
sketchybar --add event media_update

sketchybar --add item media q \
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
