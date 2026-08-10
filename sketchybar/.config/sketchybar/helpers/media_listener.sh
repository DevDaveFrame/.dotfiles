#!/usr/bin/env bash
#
# Long-running bridge: turns `media-control stream` output into SketchyBar
# `media_update` events. Started by sketchybarrc; exactly one instance survives
# a --reload.
#
# The stream payload is not parsed here — plugins/media.sh re-reads the current
# state with `media-control get`. That keeps all rendering logic in one place
# and avoids reassembling `stream`'s partial diffs.
#
# Process hygiene: `media-control` is a Perl wrapper around a long-lived
# MediaRemote adapter. A naive `cmd | while read` pipeline leaks that adapter on
# every reload — killing this script by name reaps the shell but reparents the
# adapter to init, where it streams forever. So the adapter is started as an
# explicit background child via a FIFO, its PID recorded, and a trap reaps it on
# any exit path.

source "$HOME/.config/sketchybar/variables.sh"

RUN_DIR="${TMPDIR:-/tmp}"
PIDFILE="$RUN_DIR/sketchybar_media_listener.pid"
FIFO="$RUN_DIR/sketchybar_media_listener.fifo"

# Supersede a previous listener, including one that was SIGKILLed before its
# trap could run and so left an adapter behind.
if [ -f "$PIDFILE" ]; then
  while read -r old_pid; do
    [ -n "$old_pid" ] && kill "$old_pid" 2>/dev/null
  done < "$PIDFILE"
  rm -f "$PIDFILE"
fi

rm -f "$FIFO"
mkfifo "$FIFO" || exit 1

# --debounce collapses the burst of updates a player emits on track change.
# --no-artwork avoids pushing hundreds of KB of base64 per update.
media-control stream --no-artwork --debounce=250 > "$FIFO" 2>/dev/null &
STREAM_PID=$!

printf '%s\n%s\n' "$$" "$STREAM_PID" > "$PIDFILE"

cleanup() {
  kill "$STREAM_PID" 2>/dev/null
  rm -f "$FIFO" "$PIDFILE"
}
trap cleanup EXIT INT TERM

while read -r _line; do
  sketchybar --trigger media_update
done < "$FIFO"
