#!/bin/bash

KEYBINDS=$(
  cat <<'EOF'
══════════════════ MEDIA CONTROLS ════════════════════
Ctrl + Shift + J                  Previous track
Ctrl + Shift + K                  Play/Pause
Ctrl + Shift + L                  Next track
Ctrl + Shift + S                  Stop media
════════════════ VOLUME & BRIGHTNESS ═════════════════
Shift + Right                     Volume +5%
Shift + Left                      Volume -5%
Ctrl + Shift + M                  Toggle mute
Shift + Up                        Brightness +10%
Shift + Down                      Brightness -10%
═════════════════════ SESSION ════════════════════════
Super + R                         Reload config
Super + M                         Quit
Super + L                         Lock screen
Super + Shift + E                 Logout menu
════════════════════ SCREENSHOT ══════════════════════
Super + P                         Screenshot
Super + Shift + S                 Screenshot (region)
═════════════════════ LAUNCH ═════════════════════════
Alt + Menu                        Show keybinds
Ctrl + Menu                       Emoji picker
Menu                              Application launcher
Super + K                         Android File Transfer
Super + Shift + C                 FeatherPad
Super + Return                    Terminal
Super + Shift + Return            Terminal (yt-x)
Super + W                         Waterfox/Browser
Super + Shift + W                 Waterfox/Browser (private)
Super + Shift + P                 PulseAudio Volume Control
Super + Shift + A                 Lollypop (Music)
Super + H                         Thunar (file manager)
Super + D                         Legcord (Discord)
Super + V                         VSCodium
Super + C                         Cava visualizer
Alt + K                           KeePassXC
═════════════════════ WINDOWS ════════════════════════
Super + Q                         Close window
Super + S                         Toggle floating
Super + F                         Toggle fullscreen
Super + Shift + F                 Toggle fake fullscreen
Super + A                         Toggle maximize
Super + G                         Toggle gaps
Super + I                         Minimize window
Super + Shift + I                 Restore minimized window
Super + O                         Toggle overlay
Super + Z                         Toggle scratchpad
Super + T                         Toggle global mode
Alt + B                           Toggle jump
Alt + Tab                         Focus next window
Ctrl + Tab                        Focus previous window
═══════════════════════ FOCUS ═══════════════════════
Super + Tab                       Focus next
Super + Ctrl + Left               Focus left
Super + Ctrl + Right              Focus right
Super + Ctrl + Up                 Focus up
Super + Ctrl + Down               Focus down
════════════════════ SWAP WINDOWS ════════════════════
Super + Shift + Up                Swap with window above
Super + Shift + Down              Swap with window below
Super + Shift + Left              Swap with window on the left
Super + Shift + Right             Swap with window on the right
═════════════════ MOVE FLOATING WINDOW ═══════════════
Ctrl + Shift + Up                 Move window up
Ctrl + Shift + Down               Move window down
Ctrl + Shift + Left               Move window left
Ctrl + Shift + Right              Move window right
═══════════════ RESIZE FLOATING WINDOW ═══════════════
Ctrl + Up                         Resize window vertically
Ctrl + Down                       Resize window vertically
Ctrl + Left                       Resize window horizontally
Ctrl + Right                      Resize window horizontally
════════════════════════ GAPS ════════════════════════
Super + Shift + X                 Increase gaps
Super + Shift + Z                 Decrease gaps
═══════════════════════ LAYOUT ═══════════════════════
Super + N                         Switch layout
Super + E                         Set proportion to 1.0
Super + X                         Switch proportion preset
═══════════════════ TAGS - SWITCH ════════════════════
Super + Left                      View tag to the left
Super + Right                     View tag to the right
Alt + Left                        View previous tag with a window
Alt + Right                       View next tag with a window
Super + 1-9                       Go to tag 1-9
════════════════ TAGS - MOVE WINDOW ═════════════════
Super + Shift + 1-9               Move window to tag 1-9
═══════════════ TAGS - MOVE TO MONITOR ═══════════════
Ctrl + Super + Shift + Left       Move tag to monitor on the left
Ctrl + Super + Shift + Right      Move tag to monitor on the right
════════════════════ MONITOR FOCUS ═══════════════════
Super + Alt + Left                Focus monitor on the left
Super + Alt + Right               Focus monitor on the right
Super + Ctrl + Alt + Left         Move window to monitor on the left
Super + Ctrl + Alt + Right        Move window to monitor on the right
EOF
)

printf '%s\n' "$KEYBINDS" | rofi \
  -dmenu \
  -p "Keybinds:" \
  -i
