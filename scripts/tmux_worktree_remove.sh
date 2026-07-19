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

toplevel="$(readlink -f "$(git rev-parse --show-toplevel)")"
common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"

# Decide what must never be removed, a safe dir to step into, and the git
# context to run the removal from. Classic layout: the main checkout owns
# the ".git" dir; it is protected and is itself the safe cwd. Bare layout:
# no checkout owns the DB, so protect whichever worktree the canonical
# "<repo>" symlink resolves to (the live dev/IDE/Docker target), and drive
# the removal from the bare repo.
if [ "$(basename "$common_dir")" = ".git" ]; then
  protected="$(dirname "$common_dir")"
  protected_desc="the main checkout"
  safe_cwd="$protected"
  git_ctx="$protected"
else
  wt_parent="$(dirname "$common_dir")"
  repo_name="$(basename "$common_dir")"
  repo_name="${repo_name%.git}"
  canonical="$wt_parent/$repo_name"
  protected=""
  [ -L "$canonical" ] && protected="$(readlink -f "$canonical")"
  protected_desc="the worktree '$repo_name' points to"
  safe_cwd="$wt_parent"
  git_ctx="$common_dir"
fi

[ -z "$protected" ] || [ "$toplevel" != "$protected" ] \
  || die "this is $protected_desc, refusing to remove it"

# Step out of the worktree before deleting it, so our own cwd does not
# vanish mid-script.
cd "$safe_cwd"

# Leave the doomed session before killing it so the client lands
# somewhere sensible (skip if it is the only session: kill ends the
# server and drops us back to the shell).
if [ -n "$session" ] && [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 1 ]; then
  tmux switch-client -l 2>/dev/null || tmux switch-client -n 2>/dev/null || true
fi

# --force: the user confirmed, and the worktree carries copied untracked
# files that would otherwise block removal.
git -C "$git_ctx" worktree remove --force "$toplevel" \
  || die "git worktree remove failed for $toplevel"

if [ -n "$session" ] && tmux has-session -t "=$session" 2>/dev/null; then
  tmux kill-session -t "=$session"
fi

tmux display-message "removed worktree $toplevel"
