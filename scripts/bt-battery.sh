#!/usr/bin/env bash

DEVICE=$(upower -e | grep -i headset)

if [ -z "$DEVICE" ]; then
    exit 0
fi

PERCENT=$(upower -i "$DEVICE" | grep -E "percentage" | awk '{print $2}')

if [ -n "$PERCENT" ]; then
    echo "󰂯 $PERCENT"
fi
