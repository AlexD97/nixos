#!/usr/bin/env bash

get_brightness() {
    local display=$1
    local brightness

    # Try to get brightness, return 0 if it fails
    brightness=$(ddcutil getvcp 10 --display $display 2>/dev/null | grep -oP 'current value =\s*\K\d+' || echo "0")

    # Ensure we always return a number
    if [[ ! "$brightness" =~ ^[0-9]+$ ]]; then
        brightness=0
    fi

    echo "$brightness"
}

set_brightness() {
    local display=$1
    local value=$2
    ddcutil setvcp 10 "$value" --display "$display" 2>/dev/null || true
}

case $1 in
    "get")
        get_brightness "$2"
        ;;
    "set")
        set_brightness "$2" "$3"
        ;;
esac

