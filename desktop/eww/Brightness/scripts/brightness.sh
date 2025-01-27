#!/bin/bash

get_brightness() {
    local display=$1
    brightness=$(ddcutil getvcp 10 --display $display 2>/dev/null | grep -oP 'current value =\s*\K\d+')
    echo "${brightness:-0}"
}

set_brightness() {
    local display=$1
    local value=$2
    ddcutil setvcp 10 $value --display $display
}

case $1 in
    "get")
        get_brightness $2
        ;;
    "set")
        set_brightness $2 $3
        ;;
esac
