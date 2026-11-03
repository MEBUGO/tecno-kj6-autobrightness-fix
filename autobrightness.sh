#!/system/bin/sh
# TECNO KJ6 Auto-Brightness Hardware Daemon
# Uses native sysfs ALS sensor node: /sys/devices/virtual/hf_manager/hf_manager/als

MODDIR="${0%/*}"
CONF="$MODDIR/config.conf"

# Default configuration values
MIN_BRIGHTNESS=8
MAX_BRIGHTNESS=255
BRIGHTNESS_OFFSET=0
POLLING_INTERVAL=1.5

# Load custom config if present
if [ -f "$CONF" ]; then
    . "$CONF"
fi

ALS_NODE="/sys/devices/virtual/hf_manager/hf_manager/als"
LAST_APPLIED=-1

calc_target() {
    local l=$1
    local b=8
    if [ "$l" -le 0 ]; then
        b=8
    elif [ "$l" -le 5 ]; then
        b=$(( 8 + l * 7 / 5 ))
    elif [ "$l" -le 15 ]; then
        b=$(( 15 + (l - 5) * 15 / 10 ))
    elif [ "$l" -le 40 ]; then
        b=$(( 30 + (l - 15) * 20 / 25 ))
    elif [ "$l" -le 100 ]; then
        b=$(( 50 + (l - 40) * 35 / 60 ))
    elif [ "$l" -le 250 ]; then
        b=$(( 85 + (l - 100) * 40 / 150 ))
    elif [ "$l" -le 600 ]; then
        b=$(( 125 + (l - 250) * 40 / 350 ))
    elif [ "$l" -le 1500 ]; then
        b=$(( 165 + (l - 600) * 45 / 900 ))
    elif [ "$l" -le 3000 ]; then
        b=$(( 210 + (l - 1500) * 45 / 1500 ))
    else
        b=255
    fi

    # Apply user offset
    b=$(( b + BRIGHTNESS_OFFSET ))

    # Clamp to configured min/max
    if [ "$b" -lt "$MIN_BRIGHTNESS" ]; then
        b=$MIN_BRIGHTNESS
    elif [ "$b" -gt "$MAX_BRIGHTNESS" ]; then
        b=$MAX_BRIGHTNESS
    fi

    echo "$b"
}

# Main service loop
while true; do
    # Check if auto-brightness mode is enabled in system settings
    # 0 = Manual, 1 = Automatic
    mode=$(settings get system screen_brightness_mode 2>/dev/null)
    if [ "$mode" != "1" ]; then
        LAST_APPLIED=-1
        sleep 2
        continue
    fi

    # Check if screen is awake
    if ! dumpsys power 2>/dev/null | grep -q 'mWakefulness=Awake'; then
        # Screen is off or dozing, pause sensor processing
        LAST_APPLIED=-1
        sleep 3
        continue
    fi

    # Read current ambient light lux
    if [ -f "$ALS_NODE" ]; then
        raw_lux=$(cat "$ALS_NODE" 2>/dev/null | tr -dc '0-9')
        if [ -n "$raw_lux" ]; then
            target=$(calc_target "$raw_lux")

            # Check deadband (hysteresis) to avoid jitter
            diff=$(( target - LAST_APPLIED ))
            if [ "$diff" -lt 0 ]; then
                diff=$(( -diff ))
            fi

            # Apply only if difference >= 4 or if first initialization
            if [ "$LAST_APPLIED" -eq -1 ] || [ "$diff" -ge 4 ]; then
                settings put system screen_brightness "$target" 2>/dev/null
                LAST_APPLIED=$target
            fi
        fi
    fi

    sleep "$POLLING_INTERVAL"
done
