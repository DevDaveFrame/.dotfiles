#!/usr/bin/env bash
#
# Ten macOS space indicators wrapped in a single red bracket, then a separator.
#
# The bracket sizes itself to its children, so the pill's inner padding comes
# from each space's background padding — setting it on the bracket does nothing.
# The article uses -5 here, which jams the first and last digit against the
# border; 0 gives the numbers room to breathe.
#
# There is deliberately NO click_script. SIP is enabled on this machine
# (`csrutil status`), so yabai's scripting addition cannot be loaded and
# `yabai -m space --focus N` would fail silently on every click. The native
# `space` component still highlights correctly as you switch spaces.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --add item spacer.1 left \
           --set spacer.1 background.drawing=off \
                          label.drawing=off \
                          icon.drawing=off \
                          width=10

for sid in $(seq 1 10); do
  sketchybar --add space space."$sid" left \
             --set space."$sid" associated_space="$sid" \
                                icon="$sid" \
                                icon.color="$COMMENT" \
                                icon.font="$FONT:$FONT_STYLE:$LABEL_SIZE" \
                                icon.padding_left=7 \
                                icon.padding_right=7 \
                                label.drawing=off \
                                background.drawing=off \
                                background.padding_left=0 \
                                background.padding_right=0 \
                                script="$PLUGIN_DIR/space.sh"
done

sketchybar --add item spacer.2 left \
           --set spacer.2 background.drawing=off \
                          label.drawing=off \
                          icon.drawing=off \
                          width=5

# Matches space.1 … space.10 but NOT spacer.1 / spacer.2 ("spacer" has an 'r'
# where the pattern requires a literal dot).
sketchybar --add bracket spaces '/space\..*/' \
           --set spaces background.drawing=on \
                        background.color="$BAR_COLOR" \
                        background.border_color="$RED" \
                        background.border_width="$BORDER_WIDTH" \
                        background.corner_radius="$CORNER_RADIUS" \
                        background.height="$ITEM_HEIGHT"

sketchybar --add item separator left \
           --set separator icon="$ICON_SEPARATOR" \
                           icon.color="$COMMENT" \
                           icon.font="$FONT:$FONT_STYLE:15.0" \
                           icon.padding_left=10 \
                           icon.padding_right=10 \
                           label.drawing=off \
                           background.drawing=off \
                           associated_display=active
