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

