#!/bin/bash
if pgrep -x waybar > /dev/null; then
    pkill waybar
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword decoration:rounding 0
    hyprctl keyword general:border_size 0
else
    waybar &
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 10
    hyprctl keyword decoration:rounding 5
    hyprctl keyword general:border_size 2
fi
