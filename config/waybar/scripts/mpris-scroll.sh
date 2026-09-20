#!/bin/bash
WIDTH=25
SPEED=0.35
GAP="   ✦   "
pos=0

while true; do
  status=$(playerctl status 2>/dev/null)

  if [ -z "$status" ]; then
    echo '{"text":"", "tooltip":"No player", "class":"stopped"}'
    pos=0
    sleep 1
    continue
  fi

  artist=$(playerctl metadata artist 2>/dev/null)
  title=$(playerctl metadata title 2>/dev/null)

  if [ -z "$title" ]; then
    echo '{"text":"", "tooltip":"No media", "class":"stopped"}'
    pos=0
    sleep 1
    continue
  fi

  if [ -n "$artist" ]; then text="$artist - $title"; else text="$title"; fi

  icon="▶"
  class="playing"
  [ "$status" = "Paused" ] && icon="⏸" && class="paused"

  len=${#text}
  if [ "$len" -le "$WIDTH" ]; then
    display="$icon  $text"
    pos=0
  else
    loop="$text$GAP"
    looplen=${#loop}
    pos=$((pos % looplen))
    double="$loop$loop"
    display="$icon  ${double:$pos:$WIDTH}"
    pos=$((pos + 1))
  fi

  d=$(printf '%s' "$display" | sed 's/\\/\\\\/g; s/"/\\"/g')
  t=$(printf '%s' "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')
  echo "{\"text\":\"$d\", \"tooltip\":\"$t\", \"class\":\"$class\"}"
  sleep "$SPEED"
done
