#!/bin/bash
# ============================================
# Bluetooth Device Selector via Rofi
# ============================================

# Check if bluetooth is powered on
POWERED=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$POWERED" = "no" ]; then
  # Bluetooth off — offer to power on
  ACTION=$(echo -e "󰂯  Turn On Bluetooth
󰂲  Cancel" | rofi -dmenu -p "Bluetooth" -theme-str 'window {width: 400px;} listview {lines: 2;}')

  if [[ "$ACTION" == *"Turn On"* ]]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Powered on" --icon=bluetooth
  fi
  exit 0
fi

# Get paired devices
PAIRED=$(bluetoothctl devices Paired | awk '{print $3, $2}')

# Get connected device
CONNECTED=$(bluetoothctl info | grep "Name:" | cut -d' ' -f2-)

# Build rofi menu
MENU=""

# Add connected device at top (with disconnect option)
if [ -n "$CONNECTED" ]; then
  MENU="󰂯  $CONNECTED (Connected)
󰂲  Disconnect
󰂃  Remove Device
"
fi

# Add paired devices
while IFS= read -r line; do
  NAME=$(echo "$line" | awk '{$NF=""; print $0}' | sed 's/ *$//')
  MAC=$(echo "$line" | awk '{print $NF}')

  if [ "$NAME" != "$CONNECTED" ]; then
    MENU="${MENU}󰂯  $NAME
"
  fi
done <<<"$PAIRED"

# Add scan option
MENU="${MENU}󰂰  Scan for New Devices
󰂲  Turn Off Bluetooth"

# Show rofi
SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "󰂯 Bluetooth" -theme-str 'window {width: 500px;} listview {lines: 8;}')

# Handle selection
case "$SELECTED" in
*"Disconnect"*)
  bluetoothctl disconnect
  notify-send "Bluetooth" "Disconnected" --icon=bluetooth
  ;;
*"Remove Device"*)
  MAC=$(bluetoothctl devices Paired | grep "$CONNECTED" | awk '{print $2}')
  bluetoothctl remove "$MAC"
  notify-send "Bluetooth" "Removed $CONNECTED" --icon=bluetooth
  ;;
*"Scan"*)
  notify-send "Bluetooth" "Scanning for devices..." --icon=bluetooth
  bluetoothctl scan on &
  sleep 10
  bluetoothctl scan off

  # Show discovered devices
  FOUND=$(bluetoothctl devices | grep -v "Paired" | awk '{print $3, $2}')
  if [ -n "$FOUND" ]; then
    DEV=$(echo -e "$FOUND" | rofi -dmenu -p "Found Devices" -theme-str 'window {width: 500px;}')
    if [ -n "$DEV" ]; then
      MAC=$(echo "$DEV" | awk '{print $NF}')
      NAME=$(echo "$DEV" | awk '{$NF=""; print $0}' | sed 's/ *$//')
      bluetoothctl pair "$MAC"
      bluetoothctl trust "$MAC"
      bluetoothctl connect "$MAC"
      notify-send "Bluetooth" "Connected to $NAME" --icon=bluetooth
    fi
  else
    notify-send "Bluetooth" "No devices found" --icon=bluetooth
  fi
  ;;
*"Turn Off"*)
  bluetoothctl power off
  notify-send "Bluetooth" "Powered off" --icon=bluetooth
  ;;
*"Connected"*)
  # Already connected, do nothing
  ;;
*)
  # Try to connect to selected device
  if [ -n "$SELECTED" ]; then
    NAME=$(echo "$SELECTED" | sed 's/󰂯  //')
    MAC=$(bluetoothctl devices Paired | grep "$NAME" | awk '{print $2}')
    if [ -n "$MAC" ]; then
      bluetoothctl connect "$MAC"
      notify-send "Bluetooth" "Connecting to $NAME..." --icon=bluetooth
    fi
  fi
  ;;
esac
