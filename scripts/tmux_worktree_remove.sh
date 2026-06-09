#!/usr/bin/env bash

# Bound to prefix-G in .tmux.conf (behind a confirmation prompt).
# Removes the git worktree the current session lives in, plus that
# session, but only when it is a non-default (linked) worktree. The main
# checkout is never touched. The branch itself is kept.

set -euo pipefail

die() {
  tmux display-message "worktree-remove: $1"
  exit 1
}

cwd="${1:-$PWD}"
session="${2:-}"

cd "$cwd" 2>/dev/null || die "cannot cd to $cwd"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$cwd is not inside a git repo"

toplevel="$(git rev-parse --show-toplevel)"
# Root of the main checkout: worktrees are siblings of it.
main_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"

[ "$toplevel" != "$main_root" ] \
  || die "this is the main checkout, refusing to remove it"

# Step out of the worktree before deleting it, so our own cwd does not
# vanish mid-script.
cd "$main_root"

# Leave the doomed session before killing it so the client lands
# somewhere sensible (skip if it is the only session: kill ends the
# server and drops us back to the shell).
if [ -n "$session" ] && [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 1 ]; then
  tmux switch-client -l 2>/dev/null || tmux switch-client -n 2>/dev/null || true
fi

# --force: the user confirmed, and the worktree carries copied untracked
# files that would otherwise block removal.
git -C "$main_root" worktree remove --force "$toplevel" \
  || die "git worktree remove failed for $toplevel"

if [ -n "$session" ] && tmux has-session -t "=$session" 2>/dev/null; then
  tmux kill-session -t "=$session"
fi

tmux display-message "removed worktree $toplevel"
