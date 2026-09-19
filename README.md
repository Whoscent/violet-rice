# Violet Rice

A *Violet Evergarden* × Kanagawa Wave rice for Artix Linux, running MangoWM on Wayland.

<p align="center">
  <img src="assets/screenshots/desktop.jpg" width="820" alt="Desktop">
</p>

## About

This rice mixes the soft colors of *Violet Evergarden* with the warm tones of the Kanagawa Wave palette. The same palette and fonts follow you everywhere: boot menu, login screen, lock screen, terminal, bar, and notifications. Nothing here looks like a separate app with its own random theme.

Built and tested on a 2012 ThinkPad-era laptop (Intel i5-3320M, 1366x768), so it stays light.

## Highlights

- One palette everywhere, from GRUB to the notification popups
- Custom GRUB theme with a full landscape background and styled menu entries
- Veila lock screen with clock, date, and a now-playing panel
- Custom Starship prompt with a teal → sky → violet gradient
- Transparent wlogout that shows the wallpaper through it
- Rofi keybinds cheatsheet (`Super + /`) so you never have to grep your config
- Cava visualizer using the same gradient as the rest of the rice

## Screenshots

<details>
<summary>Desktop, Cava & Fastfetch</summary>
<img src="assets/screenshots/home.jpg" width="820">
</details>

<details>
<summary>Terminal (foot + Starship)</summary>
<img src="assets/screenshots/terminal.jpg" width="820">
</details>

<details>
<summary>Lock screen (Veila)</summary>
<img src="assets/screenshots/lock.jpg" width="820">
</details>

<details>
<summary>Login (SDDM)</summary>
<img src="assets/screenshots/sddm.jpg" width="820">
</details>

<details>
<summary>Rofi launcher</summary>
<img src="assets/screenshots/rofi.jpg" width="820">
</details>

<details>
<summary>Rofi keybinds cheatsheet</summary>
<img src="assets/screenshots/keybinds.jpg" width="820">
</details>

<details>
<summary>Rofi network menu</summary>
<img src="assets/screenshots/network.jpg" width="820">
</details>

<details>
<summary>Wlogout</summary>
<img src="assets/screenshots/wlogout.jpg" width="820">
</details>

<details>
<summary>Mako notifications</summary>
<img src="assets/screenshots/mako.png" width="440">
</details>

## Specs

```
OS          ~  Artix Linux (dinit)
WM          ~  MangoWM (Wayland)
Terminal    ~  foot
Shell       ~  bash
Prompt      ~  Starship
Bar         ~  Waybar
Launcher    ~  Rofi
Notify      ~  Mako
Lock        ~  Veila
Login       ~  SDDM
Visualizer  ~  Cava
Font (mono) ~  JetBrainsMono Nerd Font
Font (UI)   ~  Cormorant Garamond / EB Garamond
```

## Installation

There's no install script yet, so this is manual.

### 1. Packages

Most are in the Artix repos; a few need an AUR helper.

```bash
sudo pacman -S waybar rofi foot mako cava starship grub sddm \
               swaybg udiskie grim slurp playerctl brightnessctl \
               thunar imagemagick
yay -S mango veila
```

Package names vary between repos — check before installing. Fonts you'll want: `ttf-jetbrains-mono-nerd`, `ttf-cormorant`, and EB Garamond.

### 2. Copy the config

This mirrors `~/.config/`, so one copy covers the bar, WM, terminal, launcher, prompt, and lock theme:

```bash
cp -r .config/. ~/.config/
chmod +x ~/.config/rofi/scripts/show-keybinds.sh
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/mango/scripts/*.sh
chmod +x ~/.config/scripts/screenshot
```

The screenshot script saves to `$HOME/DataCaddy/Pictures` — edit `~/.config/scripts/screenshot` if you want a different folder.

### 3. Shell prompt

```bash
cp bashrc ~/.bashrc     # or append the relevant lines to your existing one
```

Starship is launched from `~/.bashrc`; make sure it ends with `eval "$(starship init bash)"`.

### 4. Veila lock screen

```bash
mkdir -p ~/.config/veila/themes
cp veila-lock/violet.toml ~/.config/veila/themes/
```

`~/.config/veila/config.toml` (already copied in step 2) just points at `theme = "violet"`.

### 5. GRUB theme

```bash
sudo cp -r grub-theme /boot/grub/themes/violet-rice
sudo cp etc-configs/default-grub /etc/default/grub   # back up yours first
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If you'd rather not replace your whole `/etc/default/grub`, just set these two lines in your existing one:

```
GRUB_THEME="/boot/grub/themes/violet-rice/theme.txt"
GRUB_GFXMODE=1366x768
```

`GRUB_GFXMODE` matters — leaving it unset lets GRUB fall back to a lower resolution on older hardware, which makes the menu boxes look oversized against a shrunken background. Set it to your own resolution.

### 6. SDDM theme

```bash
sudo cp -r sddm-theme /usr/share/sddm/themes/violet-sddm
sudo cp etc-configs/sddm-theme.conf /etc/sddm.conf.d/theme.conf
```

### 7. Wlogout

```bash
sudo cp -r wlogout/etc/wlogout /etc/wlogout
sudo cp -r wlogout/usr/share/wlogout /usr/share/wlogout
```

### 8. Reload

Log out and back in, or reboot, so everything loads together.

## Notes

- Built for **1366x768**. On a different resolution you'll want to adjust `GRUB_GFXMODE`, the GRUB `theme.txt` offsets, and the rofi window sizes. Waybar and Veila scale on their own.
- Boxes instead of icons means your font isn't a Nerd Font — set `JetBrainsMono Nerd Font`, not plain `JetBrains Mono`.
- Images here are already resized for normal use; the full-resolution originals aren't in this repo.
- This targets **dinit**, not systemd. On a systemd system the configs still work, but autostart entries in `.config/mango/cfg/autostart.conf` may need adjusting.

## Credits

- SDDM theme adapted from [melatonia/meloworld-dotfiles](https://github.com/melatonia/meloworld-dotfiles) (MIT) — background, colors, and fonts swapped.
- GRUB layout adapted from the **space-isolation** theme; the menu entry styling borrows from [Wuthering-grub2-themes](https://github.com/vinceliuice/grub2-themes).
- Wlogout icons from [onlinewebfonts](https://www.onlinewebfonts.com/) (CC 3.0) — see `wlogout/usr/share/wlogout/assets/CREDIT.md`.
- Lock screen powered by [Veila](https://github.com/naurissteins/Veila).
- Wallpapers and character art are from *Violet Evergarden* (Kyoto Animation), used here for personal theming only.

Made by [@senarch](https://github.com/senarch)
