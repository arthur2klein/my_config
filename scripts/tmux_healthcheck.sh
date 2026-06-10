#!/usr/bin/env bash
#
# Per-machine healthchecks for the tmux status bar.
#
# The actual checks live OUTSIDE this repo, in
#   ~/.config/tmux/healthchecks.conf
# (seeded from tmux/healthchecks.conf.example, see setup_symlinks.sh).
# That file defines an `healthchecks` array of "label|command" entries;
# a command exiting 0 is healthy (green), anything else is down (red).
#
# Probes run on a background daemon every $INTERVAL seconds and write a
# pre-colored status string to $CACHE. The status bar only reads $CACHE,
# so redraws never block and the services are not hammered on every
# refresh. The daemon is self-bootstrapping: `display` restarts it if it
# died.
#
# Modes:
#   display   print the cached line, ensure the daemon is alive (default)
#   once      run every check once and refresh the cache, then exit
#   daemon    the probe loop (started in the background by `display`)

set -uo pipefail

CONFIG="${TMUX_HEALTHCHECK_CONFIG:-$HOME/.config/tmux/healthchecks.conf}"
CACHE="${TMUX_HEALTHCHECK_CACHE:-/tmp/tmux_healthcheck.status}"
PIDFILE="${TMUX_HEALTHCHECK_PIDFILE:-/tmp/tmux_healthcheck.pid}"

# Defaults, overridable by the config file.
INTERVAL=60
TIMEOUT=10
healthchecks=()

[ -r "$CONFIG" ] && . "$CONFIG"

# Run every check once and write the colored result to $CACHE atomically.
# Re-source the config on every call so edits are picked up within one
# $INTERVAL without restarting the daemon.
run_checks() {
  [ -r "$CONFIG" ] && . "$CONFIG"

  local out="" entry label cmd
  for entry in "${healthchecks[@]}"; do
    label="${entry%%|*}"
    cmd="${entry#*|}"
    if timeout "$TIMEOUT" bash -c "$cmd" >/dev/null 2>&1; then
      out+="#[fg=green]●${label} "
    else
      out+="#[fg=red]●${label} "
    fi
  done
  out+="#[default]"

  local tmp
  tmp="$(mktemp "${CACHE}.XXXXXX")" || return 1
  printf '%s' "$out" >"$tmp"
  mv -f "$tmp" "$CACHE"
}

daemon_alive() {
  [ -r "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null
}

daemon_loop() {
  # Atomic claim of the pidfile; bail if another daemon already holds it.
  if ! ( set -o noclobber; echo $$ >"$PIDFILE" ) 2>/dev/null; then
    daemon_alive && exit 0      # a live daemon is already running
    echo $$ >"$PIDFILE"         # stale pidfile, take it over
  fi
  trap 'rm -f "$PIDFILE"' EXIT
  while :; do
    run_checks
    sleep "$INTERVAL"
  done
}

case "${1:-display}" in
  once)
    run_checks
    ;;
  daemon)
    daemon_loop
    ;;
  display)
    # Nothing to show without a config: stay completely dark.
    [ -r "$CONFIG" ] || exit 0
    daemon_alive || setsid -f "$0" daemon >/dev/null 2>&1 < /dev/null
    cat "$CACHE" 2>/dev/null
    ;;
  *)
    echo "usage: $0 [display|once|daemon]" >&2
    exit 64
    ;;
esac
