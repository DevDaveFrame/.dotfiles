#!/usr/bin/env bash
#
# Percentage of memory in use.
#
# This does NOT use `memory_pressure`, despite the obvious-looking
# "System-wide memory free percentage: N%" line it prints. That figure is a
# memory *pressure* indicator: it counts inactive, speculative and purgeable
# pages as free, so it sits above 90% until the system is genuinely struggling.
# Deriving usage from it reported 7% on a machine that btop showed at 47%.
#
# Instead, count the pages that are actually committed:
#
#   used = active + wired down + occupied by compressor
#
# which matches btop and excludes reclaimable file cache. Note `top` disagrees
# in the other direction — it counts inactive pages as used, which is how the
# same machine reads as 89% there.

source "$HOME/.config/sketchybar/variables.sh"

eval "$(vm_stat 2>/dev/null | awk '
  NR == 1                         { print "PAGE_SIZE=" $8 }
  /^Pages active/                 { gsub(/\./, "", $NF); print "ACTIVE="     $NF }
  /^Pages wired down/             { gsub(/\./, "", $NF); print "WIRED="      $NF }
  /^Pages occupied by compressor/ { gsub(/\./, "", $NF); print "COMPRESSED=" $NF }
')"

TOTAL_BYTES="$(sysctl -n hw.memsize 2>/dev/null)"

# Leave the last good value on screen rather than flashing a bogus one.
for v in "$PAGE_SIZE" "$ACTIVE" "$WIRED" "$COMPRESSED" "$TOTAL_BYTES"; do
  case "$v" in
    ''|*[!0-9]*) exit 0 ;;
  esac
done
[ "$PAGE_SIZE" -gt 0 ] || exit 0

TOTAL_PAGES=$(( TOTAL_BYTES / PAGE_SIZE ))
[ "$TOTAL_PAGES" -gt 0 ] || exit 0

USED_PAGES=$(( ACTIVE + WIRED + COMPRESSED ))
USED_PCT=$(( 100 * USED_PAGES / TOTAL_PAGES ))

sketchybar --set "$NAME" label="${USED_PCT}%"
