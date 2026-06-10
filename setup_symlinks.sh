#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

# Create a symlink at $2 pointing to $1. Idempotent:
# - creates parent dir if missing
# - skips (does not clobber) if $2 already exists as a real file or directory
# - replaces an existing symlink in place
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "skip: $dst exists and is not a symlink" >&2
    return 0
  fi
  ln -snf "$src" "$dst"
}

# Shell, tmux, vim, formatter
link ~/my_config/.zshrc          ~/.zshrc
link ~/my_config/.p10k.zsh       ~/.p10k.zsh
link ~/my_config/.tmux.conf      ~/.tmux.conf
link ~/my_config/.vimrc          ~/.vimrc
link ~/my_config/.prettierrc.json ~/.prettierrc.json

# Neovim
link ~/my_config/init.lua    ~/.config/nvim/init.lua
link ~/my_config/lua/plugins ~/.config/nvim/lua/plugins
link ~/my_config/lua/custom  ~/.config/nvim/lua/custom
# dbs.lua holds DB credentials, stays out of the repo. Seed from template if missing.
mkdir -p ~/.config/nvim/lua
if [ ! -e ~/.config/nvim/lua/dbs.lua ]; then
  cp ~/my_config/lua/dbs.lua.example ~/.config/nvim/lua/dbs.lua
fi

# tmux healthchecks are opt-in per machine (work vs personal differ, may
# hold local creds), so they are NOT seeded automatically. To enable on a
# given machine, copy the template and edit it:
#   cp ~/my_config/tmux/healthchecks.conf.example ~/.config/tmux/healthchecks.conf
# Leaving the file absent keeps the status bar unchanged.

# Wayland / desktop
link ~/my_config/hypr    ~/.config/hypr
link ~/my_config/swaync  ~/.config/swaync
link ~/my_config/kitty   ~/.config/kitty
link ~/my_config/rofi    ~/.config/rofi
link ~/my_config/scripts ~/.config/scripts
link ~/my_config/theme   ~/.config/theme
link ~/my_config/waybar  ~/.config/waybar
link ~/my_config/bat     ~/.config/gat

# Oh-my-zsh custom themes (only if oh-my-zsh is installed)
if [ -d ~/.oh-my-zsh/themes ]; then
  for theme in ~/my_config/themes/*; do
    link "$theme" ~/.oh-my-zsh/themes/"$(basename "$theme")"
  done
fi

# Brightness control binary: build only if missing or source is newer, and
# only if libddcutil is available (headless/WSL machines often lack it).
mkdir -p ~/bin
brightness_src=~/my_config/src/brightness_control.c
brightness_bin=~/bin/brightness_control
if [ ! -e "$brightness_bin" ] || [ "$brightness_src" -nt "$brightness_bin" ]; then
  if ldconfig -p 2>/dev/null | grep -q libddcutil; then
    gcc -lddcutil -o "$brightness_bin" "$brightness_src"
  else
    echo "skip: libddcutil not available, brightness_control not built" >&2
  fi
fi
