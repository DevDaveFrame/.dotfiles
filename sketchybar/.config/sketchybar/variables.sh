#!/usr/bin/env bash
#
# Shared palette, typography and geometry for the SketchyBar config.
# Sourced by sketchybarrc, every items/*.sh and every plugins/*.sh.
#
# NOTE: macOS ships bash 3.2 and there is no Homebrew bash on this machine, so
# nothing here (or anywhere else in this config) may use bash 4 features such as
# `mapfile`, `declare -A` or `${var,,}`.

export CONFIG_DIR="$HOME/.config/sketchybar"
export ITEM_DIR="$CONFIG_DIR/items"
export PLUGIN_DIR="$CONFIG_DIR/plugins"
export HELPER_DIR="$CONFIG_DIR/helpers"

# ── Typography ───────────────────────────────────────────────────────────────
# Berkeley Mono's Nerd Font patch only ships Regular and Italic on this machine
# (`ls ~/Library/Fonts/BerkeleyMonoVariableNerdFont*`), so never ask for Bold —
# SketchyBar silently falls back to a system font when the style is missing.
export FONT="BerkeleyMonoVariable Nerd Font Mono"
export FONT_STYLE="Regular"
export LABEL_SIZE=13.0
export ICON_SIZE=14.0

# ── Geometry ─────────────────────────────────────────────────────────────────
# The article uses BAR_HEIGHT == ITEM_HEIGHT == 26, so its pills fill the bar
# edge to edge. Setting ITEM_HEIGHT a little shorter gives the pills vertical
# breathing room. Set both to 26 for the article's exact look.
export BAR_HEIGHT=30
export ITEM_HEIGHT=24
export CORNER_RADIUS=6
export BORDER_WIDTH=2

# ── TokyoNight (Night) ───────────────────────────────────────────────────────
# TEAL matches the JankyBorders active_color already set in ~/.config/yabai/yabairc.
export BAR_COLOR=0xff1a1b26
export BLACK=0xff15161e
export WHITE=0xffc0caf5
export COMMENT=0xff565f89
export SURFACE=0xff292e42

export RED=0xfff7768e
export ORANGE=0xffff9e64
export YELLOW=0xffe0af68
export GREEN=0xff9ece6a
export TEAL=0xff2ac3de
export CYAN=0xff7dcfff
export BLUE=0xff7aa2f7
export MAGENTA=0xffbb9af7

export TRANSPARENT=0x00000000
export POPUP_BACKGROUND=0xf01a1b26
export POPUP_BORDER=0xff414868

# ── Environment ──────────────────────────────────────────────────────────────
# SketchyBar's LaunchAgent runs with PATH=/opt/homebrew/bin:/opt/homebrew/sbin:
# /usr/bin:/bin:/usr/sbin:/sbin, but plugins are also run by hand during
# debugging. Pin the Homebrew prefix so jq/media-control always resolve.
case ":$PATH:" in
  *:/opt/homebrew/bin:*) ;;
  *) export PATH="/opt/homebrew/bin:$PATH" ;;
esac

# ── pill <accent-color> ──────────────────────────────────────────────────────
# Echoes the shared "rounded box with a coloured border" styling used by every
# widget, so the styling lives in exactly one place. Intended to be used
# UNQUOTED so the shell word-splits it into separate arguments:
#
#     sketchybar --set volume $(pill "$YELLOW") label="42%"
#
# Safe because every emitted value is whitespace-free.
pill() {
  echo "background.drawing=on \
        background.color=$BAR_COLOR \
        background.border_color=$1 \
        background.border_width=$BORDER_WIDTH \
        background.corner_radius=$CORNER_RADIUS \
        background.height=$ITEM_HEIGHT \
        icon.color=$1 \
        label.color=$1"
}
