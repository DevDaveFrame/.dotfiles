#!/usr/bin/env bash
#
# Verifies that every glyph used in icons.sh actually exists in the configured
# font. A missing glyph renders as a tofu box rather than erroring, so this is
# the only way to catch the problem short of squinting at the bar.
#
# Run after changing icons.sh:  ./helpers/check_glyphs.sh

source "$HOME/.config/sketchybar/variables.sh"

FONT_FILE="$HOME/Library/Fonts/BerkeleyMonoVariableNerdFontMono-Regular.ttf"

if [ ! -f "$FONT_FILE" ]; then
  echo "font file not found: $FONT_FILE" >&2
  exit 1
fi

if ! command -v fc-query >/dev/null 2>&1; then
  echo "fc-query not found (brew install fontconfig)" >&2
  exit 1
fi

# The font's charset, as hex ranges like "f0001-f1af0" (bash 3.2: no mapfile).
RANGES=""
while read -r chunk; do
  [ -n "$chunk" ] && RANGES="$RANGES $chunk"
done < <(fc-query --format "%{charset}\n" "$FONT_FILE" | tr ' ' '\n')

# Every distinct non-ASCII character used in icons.sh, one hex codepoint per line.
CODEPOINTS="$(python3 - "$HOME/.config/sketchybar/icons.sh" <<'PY'
import sys
seen = []
for ch in open(sys.argv[1], encoding="utf-8").read():
    if ord(ch) > 0x2000 and ch not in seen:
        seen.append(ch)
for ch in seen:
    print("%X" % ord(ch))
PY
)"

fail=0
count=0
for cp in $CODEPOINTS; do
  count=$((count + 1))
  dec=$((16#$cp))
  found=0
  for r in $RANGES; do
    case "$r" in
      *-*) start=$((16#${r%%-*})); end=$((16#${r##*-})) ;;
      *)   start=$((16#$r));       end=$start ;;
    esac
    if [ "$dec" -ge "$start" ] && [ "$dec" -le "$end" ]; then
      found=1
      break
    fi
  done
  if [ "$found" -eq 0 ]; then
    echo "MISSING  U+$cp"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "all $count glyphs present in $FONT"
else
  echo "some glyphs are missing from $FONT — they will render as tofu" >&2
fi
exit $fail
