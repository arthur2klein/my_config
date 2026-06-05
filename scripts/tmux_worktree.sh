#!/usr/bin/env bash

# Bound to prefix-g in .tmux.conf.
# Given a branch name and the current pane path:
# - creates the branch from the repo default branch if it does not exist
# - adds a git worktree for it next to the main repo checkout
# - copies untracked and ignored files (env files, vendor, ...) over
# - opens the worktree in a new tmux session with the standard window
#   template (same as prefix-t), leaving the current session untouched

set -euo pipefail

die() {
  tmux display-message "worktree: $1"
  exit 1
}

branch="${1:-}"
cwd="${2:-$PWD}"

[ -n "$branch" ] || die "no branch name given"
cd "$cwd" 2>/dev/null || die "cannot cd to $cwd"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$cwd is not inside a git repo"

# Root of the worktree we were called from (copy source) and root of the
# main checkout (worktrees are created as siblings of it, and it stays
# valid even when prefix-g is used from another worktree).
src_root="$(git rev-parse --show-toplevel)"
repo_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
repo_name="$(basename "$repo_root")"

# tmux session names cannot contain '.' or ':'; keep paths flat too.
safe_branch="$(printf '%s' "$branch" | tr '/:. ' '----')"
wt_path="$(dirname "$repo_root")/${repo_name}--${safe_branch}"
session="${repo_name}--${safe_branch}"

if ! tmux has-session -t "=$session" 2>/dev/null; then
  if [ ! -d "$wt_path" ]; then
    if git show-ref --verify --quiet "refs/heads/$branch" \
      || git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      # Existing branch (worktree add tracks origin/<branch> if needed).
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
      # Last resort (no remote, no main/master): main checkout's branch.
      if [ -z "$default" ]; then
        default="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD)" \
          || true
      fi
      [ -n "${default:-}" ] || die "cannot determine default branch"
      git worktree add -b "$branch" "$wt_path" "$default"
    fi

    # Bring over everything git does not version so the new worktree is
    # ready to use without reinstalling or reconfiguring anything.
    git -C "$src_root" ls-files --others --directory -z \
      | rsync -ar --from0 --files-from=- "$src_root/" "$wt_path/"
  fi

  tmux new-session -d -s "$session" -c "$wt_path"
  tmux rename-window -t "$session:1" "main💻"
  tmux new-window -t "$session:2" -n "exec🚀" -c "$wt_path"
  tmux new-window -t "$session:3" -n "test🎯" -c "$wt_path"
  tmux new-window -t "$session:9" -n "note📝" -c "$wt_path"
  tmux new-window -t "$session:10" -n "edit✍" -c "$wt_path"
fi

tmux switch-client -t "$session"
