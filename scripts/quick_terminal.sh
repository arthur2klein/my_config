#!/bin/bash

CLASS="scratchpad"
WS="magic_scratchpad"

if hyprctl clients | grep -q "class: $CLASS"; then
  hyprctl dispatch togglespecialworkspace "$WS"
else
  $1 --class "$CLASS"
fi
