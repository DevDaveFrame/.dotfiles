#!/usr/bin/env bash
#
# Nerd Font glyphs, plus the front_app icon lookup.
#
# GENERATED FILE - regenerate rather than hand-editing glyphs, so codepoints
# stay exact. Every codepoint below is verified present in the charset of
# BerkeleyMonoVariable Nerd Font Mono; see helpers/check_glyphs.sh.
#
# No sketchybar-app-font here by design - these are all stock Nerd Font glyphs.

# ── chrome ──────────────────────────────────────────────────────────────────
export ICON_SEPARATOR="❯"         # U+276F nf-oct-chevron_right

# ── status widgets ──────────────────────────────────────────────────────────
export ICON_MEMORY="󰍛"            # U+F035B nf-md-memory
export ICON_WIFI="󰖩"              # U+F05A9 nf-md-wifi
export ICON_WIFI_OFF="󰖪"          # U+F05AA nf-md-wifi_off
export ICON_ETHERNET="󰈀"          # U+F0200 nf-md-ethernet
export ICON_CALENDAR=""          # U+F073 nf-fa-calendar
export ICON_CLOCK=""             # U+F017 nf-fa-clock_o

# ── volume ramp ─────────────────────────────────────────────────────────────
export ICON_VOL_HIGH=""          # U+F028 nf-fa-volume_up
export ICON_VOL_MID=""           # U+F027 nf-fa-volume_down
export ICON_VOL_LOW=""           # U+F026 nf-fa-volume_off
export ICON_VOL_MUTE="󰝟"          # U+F075F nf-md-volume_mute

# ── battery ramp ────────────────────────────────────────────────────────────
export ICON_BAT_100="󰁹"           # U+F0079 nf-md-battery
export ICON_BAT_75="󰁾"            # U+F007E nf-md-battery_70
export ICON_BAT_50="󰁼"            # U+F007C nf-md-battery_50
export ICON_BAT_25="󰁺"            # U+F007A nf-md-battery_20
export ICON_BAT_0="󰂎"             # U+F008E nf-md-battery_outline
export ICON_BAT_CHARGING="󰂄"      # U+F0084 nf-md-battery_charging

# ── media ───────────────────────────────────────────────────────────────────
export ICON_MEDIA="󰝚"             # U+F075A nf-md-music
export ICON_MEDIA_PREV=""        # U+F04A nf-fa-step_backward
export ICON_MEDIA_PLAY=""        # U+F04B nf-fa-play
export ICON_MEDIA_PAUSE=""       # U+F04C nf-fa-pause
export ICON_MEDIA_NEXT=""        # U+F04E nf-fa-step_forward

# app_icon <app name>
#
# Echoes a Nerd Font glyph for the given application name. Names come straight
# from SketchyBar's front_app_switched $INFO, which is the app's display name.
app_icon() {
  case "$1" in
    "Google Chrome" | "Chromium" | "Brave Browser" | "Microsoft Edge")
      printf "%s" "" ;;   # U+F268
    "Firefox" | "Firefox Developer Edition" | "Zen" | "Zen Browser")
      printf "%s" "" ;;   # U+F269
    "Safari" | "Safari Technology Preview")
      printf "%s" "" ;;   # U+F267
    "Slack")
      printf "%s" "" ;;   # U+F198
    "Discord")
      printf "%s" "󰙯" ;;   # U+F066F
    "Ghostty" | "Terminal" | "iTerm2" | "Alacritty" | "kitty" | "WezTerm")
      printf "%s" "" ;;   # U+E795
    "Code" | "Visual Studio Code" | "VSCodium")
      printf "%s" "󰨞" ;;   # U+F0A1E
    "Cursor" | "Zed" | "Xcode" | "Sublime Text" | "IntelliJ IDEA" | "PyCharm")
      printf "%s" "" ;;   # U+F121
    "Obsidian" | "Notes" | "Antinote" | "Stickies" | "Bear")
      printf "%s" "󰠮" ;;   # U+F082E
    "Postman" | "Bruno" | "Insomnia")
      printf "%s" "" ;;   # U+F1D8
    "TablePlus" | "Sequel Ace" | "DBeaver")
      printf "%s" "" ;;   # U+F1C0
    "Spotify")
      printf "%s" "" ;;   # U+F1BC
    "TIDAL" | "Music" | "Logic Pro" | "Model D" | "Dubler2" | "Flynth" | "GarageBand")
      printf "%s" "" ;;   # U+F001
    "Podcasts" | "Overcast")
      printf "%s" "" ;;   # U+F2CE
    "TV" | "QuickTime Player" | "iMovie" | "OpenEmu")
      printf "%s" "" ;;   # U+F26C
    "OBS" | "FaceTime" | "Zoom" | "zoom.us" | "DeskPad")
      printf "%s" "" ;;   # U+F03D
    "Preview" | "Photos" | "Photo Booth" | "Image Capture" | "Astropad Slate")
      printf "%s" "" ;;   # U+F03E
    "Mail" | "Spark Desktop" | "Microsoft Outlook")
      printf "%s" "" ;;   # U+F0E0
    "Messages" | "Signal" | "WhatsApp" | "Telegram")
      printf "%s" "" ;;   # U+F075
    "Calendar" | "Fantastical")
      printf "%s" "" ;;   # U+F073
    "Finder")
      printf "%s" "" ;;   # U+F07B
    "System Settings" | "System Preferences")
      printf "%s" "" ;;   # U+F013
    "OrbStack" | "Docker" | "Docker Desktop")
      printf "%s" "" ;;   # U+F308
    "UTM" | "Parallels Desktop" | "VirtualBox" | "Screen Sharing")
      printf "%s" "" ;;   # U+F108
    "Microsoft Word")
      printf "%s" "󰈙" ;;   # U+F0219
    "Microsoft Excel" | "Soulver 3" | "Numbers" | "Calculator")
      printf "%s" "󰈇" ;;   # U+F0207
    "Microsoft PowerPoint" | "Keynote")
      printf "%s" "󰈔" ;;   # U+F0214
    "Dashlane" | "Passwords" | "Hotspot Shield" | "OpenVPN Connect")
      printf "%s" "" ;;   # U+F023
    "Steam" | "shadPS4QtLauncher" | "BB_Launcher" | "Games")
      printf "%s" "" ;;   # U+F1B6
    "LM Studio" | "Ollama" | "Stability Matrix")
      printf "%s" "󱂀" ;;   # U+F1080
    "Activity Monitor" | "Console" | "System Information")
      printf "%s" "" ;;   # U+F0E4
    "Disk Utility" | "balenaEtcher" | "Raspberry Pi Imager" | "qFlipper")
      printf "%s" "" ;;   # U+F0A0
    "qbittorrent" | "The Unarchiver")
      printf "%s" "" ;;   # U+F019
    "Books" | "Amazon Kindle" | "Dash" | "Dictionary")
      printf "%s" "" ;;   # U+F02D
    "App Store" | "Apps")
      printf "%s" "" ;;   # U+F179
    "Maps" | "FindMy")
      printf "%s" "" ;;   # U+F279
    "Weather")
      printf "%s" "" ;;   # U+F0C2
    "Reminders" | "Amphetamine" | "InYourFace" | "One Thing" | "BUSY")
      printf "%s" "" ;;   # U+F0F3
    "QMK Toolbox" | "keymapp" | "ZMK Studio" | "Elgato Stream Deck" | "logioptionsplus")
      printf "%s" "" ;;   # U+F0AD
    *)
      printf "%s" "" ;;   # U+F2D0 fallback
  esac
}
