#!/usr/bin/env bash

TYPE="${1:-sink}"

case "$TYPE" in
  sink|output)
    MEDIA_CLASS="Audio/Sink"
    PROMPT="Audio Output"
    ;;
  source|input)
    MEDIA_CLASS="Audio/Source"
    PROMPT="Audio Input"
    ;;
  *)
    echo "Usage: $0 [sink|source]"
    exit 1
    ;;
esac

pw-dump |
  jq --arg media "$MEDIA_CLASS" -r '.[] | select(.info.props."media.class"==$media) | "\(.id): \(.info.props."node.description")"' |
  rofi -dmenu -p "$PROMPT" |
  cut -d: -f1 |
  xargs -r wpctl set-default

