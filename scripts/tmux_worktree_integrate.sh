#!/usr/bin/env bash

# Bound to prefix-i in .tmux.conf, run inside a display-popup so its
# progress output is visible while the work happens.
# Merges the current feature branch into a long-lived staging worktree:
# - figures out the feature branch from the current worktree's HEAD
# - locates the staging worktree by branch (robust to where it lives),
#   falling back to the conventional <repo>--<staging> sibling, creating
#   it on first use so staging is never checked out in a feature worktree
# - fast-forwards staging to origin when possible, then merges --no-ff
# - lands you in the staging session (created from the standard template)
#   to push, or to resolve conflicts. The push stays manual on purpose.

set -euo pipefail

# The popup closes as soon as we exit, so pause on error to let the
# message be read instead of flashing away.
die() {
  printf '\nintegrate error: %s\n' "$1" >&2
  printf 'press enter to close...'
  read -r _ || true
  exit 1
}

step() {
  printf '==> %s\n' "$1"
}

staging="${1:-staging}"
cwd="${2:-$PWD}"

[ -n "$staging" ] || die "no staging branch name given"
cd "$cwd" 2>/dev/null || die "cannot cd to $cwd"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$cwd is not inside a git repo"

feature="$(git symbolic-ref --quiet --short HEAD)" \
  || die "detached HEAD; check out a feature branch first"
[ "$feature" != "$staging" ] \
  || die "already on '$staging'; switch to a feature branch to integrate it"

# The merge uses the committed tip of the feature branch; uncommitted
# work would be silently left out, so refuse until it is committed.
# (--quiet ignores untracked files, e.g. the copied env/vendor files.)
if ! git diff --quiet || ! git diff --cached --quiet; then
  die "feature worktree has uncommitted changes; commit or stash first"
fi

# Root of the main checkout (worktrees are siblings of it, and it stays
# valid even when prefix-i is used from a linked worktree).
repo_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
repo_name="$(basename "$repo_root")"
safe_staging="$(printf '%s' "$staging" | tr '/:. ' '----')"
wt_path="$(dirname "$repo_root")/${repo_name}--${safe_staging}"
session="${repo_name}--${safe_staging}"

# Find the worktree that currently holds the staging branch, wherever it
# is; fall back to the conventional sibling path; create it if neither.
staging_wt="$(git worktree list --porcelain | awk -v b="refs/heads/$staging" '
  /^worktree /{w=substr($0,10)} $0=="branch "b{print w; exit}')"

if [ -z "$staging_wt" ]; then
  if [ -d "$wt_path" ]; then
    staging_wt="$wt_path"
  elif git show-ref --verify --quiet "refs/heads/$staging" \
    || git show-ref --verify --quiet "refs/remotes/origin/$staging"; then
    step "no '$staging' worktree; creating one at $wt_path"
    git worktree add "$wt_path" "$staging"
    staging_wt="$wt_path"
  else
    die "branch '$staging' does not exist locally or on origin"
  fi
fi

# The dedicated staging worktree must be clean before we merge into it.
if ! git -C "$staging_wt" diff --quiet \
  || ! git -C "$staging_wt" diff --cached --quiet; then
  die "staging worktree '$staging_wt' has uncommitted changes; clean it first"
fi

# Bring staging up to date with origin when we can (fast-forward only):
# local staging may legitimately be ahead of origin (unpushed merges),
# in which case we just merge on top of what is there.
if git -C "$staging_wt" rev-parse --verify --quiet \
  "refs/remotes/origin/$staging" >/dev/null; then
  step "fetching origin/$staging"
  git -C "$staging_wt" fetch origin "$staging" || die "fetch failed"
  if git -C "$staging_wt" merge --ff-only "origin/$staging" >/dev/null 2>&1; then
    step "staging fast-forwarded to origin/$staging"
  else
    step "staging ahead of / diverged from origin (unpushed merges?), merging on local '$staging'"
  fi
fi

step "merging '$feature' into '$staging'"
merge_status=0
git -C "$staging_wt" merge --no-ff "$feature" || merge_status=$?

# Open the staging session from the standard template if it is not up yet
# (same windows as prefix-t), then land there to push or resolve.
if ! tmux has-session -t "=$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$staging_wt"
  tmux rename-window -t "$session:1" "main💻"
  tmux new-window -t "$session:2" -n "exec🚀" -c "$staging_wt"
  tmux new-window -t "$session:3" -n "test🎯" -c "$staging_wt"
  tmux new-window -t "$session:9" -n "note📝" -c "$staging_wt"
  tmux new-window -t "$session:10" -n "edit✍" -c "$staging_wt"
fi

tmux switch-client -t "$session"
if [ "$merge_status" -eq 0 ]; then
  tmux display-message "integrated '$feature' into '$staging' - review & push from $session"
else
  tmux display-message "MERGE CONFLICTS: '$feature' into '$staging' - resolve in $session"
fi
