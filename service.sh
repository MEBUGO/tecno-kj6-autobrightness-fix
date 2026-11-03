#!/system/bin/sh
MODDIR="${0%/*}"

# Wait until Android boot completed
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Extra wait to let SystemUI and content providers settle
sleep 3

# Load configuration
CONF="$MODDIR/config.conf"
FORCE_QS_AUTO_BUTTON=1
if [ -f "$CONF" ]; then
    . "$CONF"
fi

# 1. Enable Quick Settings Auto-Brightness Button in Lineage/crDroid Settings
if [ "$FORCE_QS_AUTO_BUTTON" = "1" ]; then
    settings put secure qs_show_auto_brightness 1 2>/dev/null
    settings put system qs_show_auto_brightness 1 2>/dev/null
    content insert --uri content://lineagesettings/secure --bind name:s:qs_show_auto_brightness --bind value:s:1 2>/dev/null
fi

# 2. Kill existing daemon if running, then launch autobrightness daemon
killall -9 autobrightness.sh 2>/dev/null
if [ -f "$MODDIR/autobrightness.sh" ]; then
    chmod 0755 "$MODDIR/autobrightness.sh"
    nohup sh "$MODDIR/autobrightness.sh" >/dev/null 2>&1 &
fi
