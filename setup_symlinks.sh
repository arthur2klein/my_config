#!/bin/bash
ln -snf ~/my_config/.zshrc ~/.zshrc
ln -snf ~/my_config/.p10k.zsh ~/.p10k.zsh
mkdir -p ~/.config/nvim/
ln -snf ~/my_config/init.lua ~/.config/nvim/init.lua
ln -snf ~/my_config/.tmux.conf ~/.tmux.conf
ln -snf ~/my_config/.vimrc ~/.vimrc
ln -snf ~/my_config/hypr/ ~/.config/hypr
ln -snf ~/my_config/kitty/ ~/.config/kitty
ln -snf ~/my_config/rofi/ ~/.config/rofi
ln -snf ~/my_config/scripts/ ~/.config/scripts
ln -snf ~/my_config/theme/ ~/.config/theme
ln -snf ~/my_config/themes/* ~/.oh-my-zsh/themes/.
ln -snf ~/my_config/bat/ ~/.config/bat
ln -snf ~/my_config/waybar/ ~/.config/waybar
ln -snf ~/my_config/.prettierrc.json ~/.prettierrc.json
