#!/usr/bin/env bash

# Directory to store state files
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/eww-brightness"
mkdir -p "$RUNTIME_DIR"

get_b() {
    local display=$1
    # Try to read from cache first for instant UI (optional, but good for performance)
    # If you prefer absolute truth from hardware every time, comment the next 2 lines.
    if [[ -f "$RUNTIME_DIR/cache_$display" ]]; then
        cat "$RUNTIME_DIR/cache_$display"
        return
    fi

    local val
    val=$(ddcutil getvcp 10 --display "$display" --brief 2>/dev/null | awk '{print $4}')
    
    if [[ "$val" =~ ^[0-9]+$ ]]; then 
        echo "$val" > "$RUNTIME_DIR/cache_$display"
        echo "$val"
    else 
        echo "0"
    fi
}

apply_worker() {
    local display=$1
    local lockfile="$RUNTIME_DIR/worker_$display.lock"
    local targetfile="$RUNTIME_DIR/target_$display"

    # Create a lock to ensure only one worker runs per display
    if [[ -f "$lockfile" ]]; then return; fi
    touch "$lockfile"

    # Loop until the hardware matches the latest target
    while true; do
        # Read the most recent target value requested by the slider
        local target
        target=$(cat "$targetfile")

        # Apply it
        ddcutil setvcp 10 "$target" --display "$display" 2>/dev/null
        
        # Update our read cache so the slider doesn't jump back
        echo "$target" > "$RUNTIME_DIR/cache_$display"

        # Check if the user moved the slider again while we were working
        local new_target
        new_target=$(cat "$targetfile")
        
        # If target hasn't changed, we are done.
        if [[ "$target" == "$new_target" ]]; then
            break
        fi
        # If it changed, the loop runs again immediately with the new value
    done

    rm "$lockfile"
}

set_b() {
    local display=$1
    local value=$2
    
    # 1. Write the target value to a file immediately
    echo "$value" > "$RUNTIME_DIR/target_$display"
    
    # 2. Trigger the background worker (if not already running)
    apply_worker "$display" &
}

case $1 in
    "get-all")
        # Returns JSON for eww (d1, d2, d3)
        b1=$(get_b 1)
        b2=$(get_b 2)
        b3=$(get_b 3)
        echo "{\"d1\": $b1, \"d2\": $b2, \"d3\": $b3}"
        ;;
    "set")
        set_b "$2" "$3"
        ;;
esac
