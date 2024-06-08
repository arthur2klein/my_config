FROM ubuntu:latest

# Installation tools

RUN \
  apt update; \
  apt install -y curl git

# Node
RUN \
  apt update; \
  apt install -y nodejs npm

# vim

RUN \
  apt update; \
  apt install -y vim

# tmux

RUN \
  apt update; \
  apt install -y tmux

###############################################################################

USER ubuntu

# Configuraion file
COPY .vimrc /home/ubuntu/.vimrc
COPY .tmux.conf /home/ubuntu/.tmux.conf

# Plugin manager

RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN \
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# Plugins installation

RUN vim -i NONE -c "PlugInstall" -c "qa"
