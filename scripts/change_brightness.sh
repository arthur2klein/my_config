#!/bin/bash

# File to cache detected display number
CACHE_FILE="$HOME/.cache/ddcutil_display"

# Parameters
DIRECTION="$1"  # up, down or refresh
STEP="${2:-5}"

mkdir -p "$(dirname "$CACHE_FILE")"

if [[ "$DIRECTION" == "refresh" ]]; then
    rm -f "$CACHE_FILE"
    echo "Cache cleared."
    exit 0
fi

get_display() {
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        DISPLAY_NUM=$(ddcutil detect | grep -m1 -oP 'Display \K\d+')
        if [[ -n "$DISPLAY_NUM" ]]; then
            echo "$DISPLAY_NUM" > "$CACHE_FILE"
            echo "$DISPLAY_NUM"
        else
            echo ""
        fi
    fi
}

# Use ddcutil if display is cached or can be detected
if command -v ddcutil >/dev/null 2>&1; then
    DISPLAY_NUM=$(get_display)
    if [[ -n "$DISPLAY_NUM" ]]; then
        CUR_BRIGHT=$(ddcutil getvcp 10 --display "$DISPLAY_NUM" 2>/dev/null | grep -oP 'current value = \K\d+')

        if [[ "$DIRECTION" == "up" ]]; then
            NEW_BRIGHT=$((CUR_BRIGHT + STEP))
        else
            NEW_BRIGHT=$((CUR_BRIGHT - STEP))
        fi

        # Clamp between 0 and 100
        NEW_BRIGHT=$(($NEW_BRIGHT < 0 ? 0 : $NEW_BRIGHT > 100 ? 100 : $NEW_BRIGHT))

        ddcutil setvcp 10 "$NEW_BRIGHT" --display "$DISPLAY_NUM"
        exit 0
    fi
fi

# Fallback to brightnessctl if no ddcutil display
if command -v brightnessctl >/dev/null 2>&1; then
    if [[ "$DIRECTION" == "up" ]]; then
        brightnessctl set "${STEP}%+"
    else
        brightnessctl set "${STEP}%-"
    fi
    exit 0
fi

# Neither tool found
notify-send "⚠️ Brightness control failed" "No supported tool (ddcutil or brightnessctl) found."

