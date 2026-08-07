#!/bin/bash

CLASS="scratchpad"
WS="magic_scratchpad"

if hyprctl clients | grep -q "class: $CLASS"; then
  hyprctl dispatch "hl.dsp.workspace.toggle_special('$WS')"
else
  $1 --class "$CLASS"
fi
