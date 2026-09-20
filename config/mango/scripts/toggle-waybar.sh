#!/bin/bash
# Toggle waybar on/off
if pgrep -x waybar > /dev/null; then
    killall waybar
else
    waybar &
fi
