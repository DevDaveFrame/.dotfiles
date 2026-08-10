#!/usr/bin/env bash
#
# Sets the focused app's name and a matching Nerd Font glyph.
#
# Unlike the article this also draws an icon, via app_icon() from icons.sh —
# stock Nerd Font glyphs only, no sketchybar-app-font dependency.

source "$HOME/.config/sketchybar/variables.sh"
source "$HOME/.config/sketchybar/icons.sh"

APP="$INFO"

# $INFO is only populated by front_app_switched. On the initial run at config
# load there is no event, so resolve the frontmost app directly. lsappinfo
# needs no Accessibility or Screen Recording permission.
if [ -z "$APP" ]; then
  APP="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | cut -d'"' -f4)"
fi

[ -z "$APP" ] && exit 0

# macOS reports transient system agents as "frontmost" — opening Notification
# Centre or Spotlight would otherwise replace the real app name with something
# like "UserNotificationCenter". Leave the previous app on screen instead.
case "$APP" in
  UserNotificationCenter | NotificationCenter | "Control Center" | \
  Spotlight | SystemUIServer | CoreServicesUIAgent | loginwindow | \
  screencaptureui | universalaccessd | "Window Server" | Dock)
    exit 0
    ;;
esac

sketchybar --set "$NAME" icon="$(app_icon "$APP")" label="$APP"
