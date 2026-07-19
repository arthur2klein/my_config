#!/usr/bin/env bash

# Bound to prefix-g in .tmux.conf, run inside a display-popup so its
# progress output is visible while the work happens.
# Given a branch name and the current pane path:
# - creates the branch from the repo default branch if it does not exist
# - adds a git worktree for it next to the main repo checkout
# - copies untracked and ignored files (env files, vendor, ...) over
# - opens the worktree in a new tmux session with the standard window
#   template (same as prefix-t), leaving the current session untouched

set -euo pipefail

# The popup closes as soon as we exit, so pause on error to let the
# message be read instead of flashing away.
die() {
  printf '\nworktree error: %s\n' "$1" >&2
  printf 'press enter to close...'
  read -r _ || true
  exit 1
}

step() {
  printf '==> %s\n' "$1"
}

branch="${1:-}"
cwd="${2:-$PWD}"

[ -n "$branch" ] || die "no branch name given"
cd "$cwd" 2>/dev/null || die "cannot cd to $cwd"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$cwd is not inside a git repo"

# Root of the worktree we were called from (copy source).
src_root="$(git rev-parse --show-toplevel)"

# Locate where sibling worktrees live and the repo name, supporting two
# layouts:
#  - classic: the main checkout holds a real ".git" dir; worktrees are
#    created as siblings of that checkout (main_root non-empty).
#  - bare: the shared DB is a "<repo>.git" bare dir with no owning
#    checkout; every branch (including the canonical one) is a peer
#    worktree living beside the bare dir (main_root empty).
# In both cases worktrees are named "<wt_parent>/<repo_name>--<branch>".
common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
if [ "$(basename "$common_dir")" = ".git" ]; then
  main_root="$(dirname "$common_dir")"
  wt_parent="$(dirname "$main_root")"
  repo_name="$(basename "$main_root")"
else
  main_root=""
  wt_parent="$(dirname "$common_dir")"
  repo_name="$(basename "$common_dir")"
  repo_name="${repo_name%.git}"
fi

# tmux session names cannot contain '.' or ':'; keep paths flat too.
safe_branch="$(printf '%s' "$branch" | tr '/:. ' '----')"
wt_path="$wt_parent/${repo_name}--${safe_branch}"
session="${repo_name}--${safe_branch}"

if ! tmux has-session -t "=$session" 2>/dev/null; then
  if [ ! -d "$wt_path" ]; then
    if git show-ref --verify --quiet "refs/heads/$branch" \
      || git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      # Existing branch (worktree add tracks origin/<branch> if needed).
      step "adding worktree for existing branch '$branch'"
      git worktree add "$wt_path" "$branch"
    else
      default="$(git symbolic-ref --quiet --short \
        refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')" || true
      if [ -z "$default" ]; then
        for b in main master; do
          if git show-ref --verify --quiet "refs/heads/$b"; then
            default="$b"
            break
          fi
        done
      fi
      # Last resort (no remote, no main/master): the branch the main
      # checkout (classic) or the bare repo's HEAD (bare) points at.
      if [ -z "$default" ] && [ -n "$main_root" ]; then
        default="$(git -C "$main_root" symbolic-ref --quiet --short HEAD)" \
          || true
      fi
      if [ -z "$default" ]; then
        default="$(git --git-dir="$common_dir" symbolic-ref --quiet --short \
          HEAD)" || true
      fi
      [ -n "${default:-}" ] || die "cannot determine default branch"
      step "creating branch '$branch' from '$default' and its worktree"
      git worktree add -b "$branch" "$wt_path" "$default"
    fi

    # Bring over everything git does not version so the new worktree is
    # ready to use without reinstalling or reconfiguring anything.
    step "copying untracked and ignored files"
    git -C "$src_root" ls-files --others --directory -z \
      | rsync -ar --from0 --files-from=- "$src_root/" "$wt_path/"
  else
    step "worktree already exists at $wt_path"
  fi

  step "starting session '$session'"
  tmux new-session -d -s "$session" -c "$wt_path"
  tmux rename-window -t "$session:1" "main💻"
  tmux new-window -t "$session:2" -n "exec🚀" -c "$wt_path"
  tmux new-window -t "$session:3" -n "test🎯" -c "$wt_path"
  tmux new-window -t "$session:9" -n "note📝" -c "$wt_path"
  tmux new-window -t "$session:10" -n "edit✍" -c "$wt_path"
else
  step "session '$session' already exists"
fi

step "switching to '$session'"
tmux switch-client -t "$session"
