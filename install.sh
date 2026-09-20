#!/usr/bin/env bash
#
# Violet Rice — installer
# https://github.com/Whoscent
#
# Safe by design:
#   - never deletes anything (existing files are copied to a backup folder first)
#   - refuses to run as root, so your configs land in your home, not /root
#   - every step can be skipped, and the whole thing can be re-run
#   - --dry-run shows you every command without touching the disk
#
# Usage:
#   ./install.sh                 interactive install
#   ./install.sh --dry-run       show what would happen, change nothing
#   ./install.sh --yes           don't ask, just do it
#   ./install.sh --skip-packages --skip-grub
#   ./install.sh --help
#

set -euo pipefail

# ---------------------------------------------------------------- settings ---

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.violet-rice-backup/$(date +%Y%m%d-%H%M%S)"

GRUB_THEME_NAME="violetgrub"
SDDM_THEME_NAME="violet-sddm"
DEFAULT_GFXMODE="1366x768"

DRY_RUN=0
ASSUME_YES=0
SKIP_PACKAGES=0
SKIP_CONFIG=0
SKIP_SERVICES=0
SKIP_BASHRC=0
SKIP_VEILA=0
SKIP_WLOGOUT=0
SKIP_GRUB=0
SKIP_SDDM=0

# ------------------------------------------------------------------ output ---

C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
C_VIOLET=$'\033[38;5;140m'; C_TEAL=$'\033[38;5;108m'
C_GOLD=$'\033[38;5;179m'; C_RED=$'\033[38;5;167m'

if [[ ! -t 1 ]]; then
    C_RESET=""; C_DIM=""; C_BOLD=""
    C_VIOLET=""; C_TEAL=""; C_GOLD=""; C_RED=""
fi

step()  { printf '\n%s==>%s %s%s%s\n' "$C_VIOLET" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info()  { printf '    %s\n' "$*"; }
ok()    { printf '    %s✓%s %s\n' "$C_TEAL" "$C_RESET" "$*"; }
warn()  { printf '    %s!%s %s\n' "$C_GOLD" "$C_RESET" "$*" >&2; }
skip()  { printf '    %s·%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "$*" "$C_RESET"; }
die()   { printf '\n%serror:%s %s\n\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# Print a command, and run it unless we're in dry-run mode.
run() {
    if (( DRY_RUN )); then
        printf '    %s$ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    else
        "$@"
    fi
}

confirm() {
    (( ASSUME_YES )) && return 0
    (( DRY_RUN ))    && return 0
    local reply
    printf '    %s?%s %s [y/N] ' "$C_GOLD" "$C_RESET" "$1"
    read -r reply </dev/tty || return 1
    [[ "$reply" =~ ^[Yy]$ ]]
}

usage() {
    sed -n '3,18p' "${BASH_SOURCE[0]}" | sed 's/^#//; s/^ //'
    exit 0
}

# -------------------------------------------------------------------- args ---

for arg in "$@"; do
    case "$arg" in
        --dry-run)       DRY_RUN=1 ;;
        --yes|-y)        ASSUME_YES=1 ;;
        --skip-packages) SKIP_PACKAGES=1 ;;
        --skip-config)   SKIP_CONFIG=1 ;;
        --skip-services) SKIP_SERVICES=1 ;;
        --skip-bashrc)   SKIP_BASHRC=1 ;;
        --skip-veila)    SKIP_VEILA=1 ;;
        --skip-wlogout)  SKIP_WLOGOUT=1 ;;
        --skip-grub)     SKIP_GRUB=1 ;;
        --skip-sddm)     SKIP_SDDM=1 ;;
        --help|-h)       usage ;;
        *)               die "unknown option: $arg  (try --help)" ;;
    esac
done

# ------------------------------------------------------------ sanity checks ---

# Running under sudo would put every user config into /root instead of your home.
if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    die "don't run this as root or with sudo.
       Run it as your normal user — it will ask for sudo only where it needs to.
       (Running as root would install your configs into /root/.config)"
fi

command -v sudo >/dev/null 2>&1 || die "sudo not found — this script needs it for the system-wide steps."

[[ -n "${HOME:-}" && -d "$HOME" ]] || die "\$HOME is not set to a real directory. Refusing to continue."

# Locate the pieces. The repo has been laid out two different ways, so accept both.
find_dir() {
    local candidate
    for candidate in "$@"; do
        if [[ -d "$REPO_DIR/$candidate" ]]; then
            printf '%s' "$REPO_DIR/$candidate"
            return 0
        fi
    done
    return 1
}

find_file() {
    local candidate
    for candidate in "$@"; do
        if [[ -f "$REPO_DIR/$candidate" ]]; then
            printf '%s' "$REPO_DIR/$candidate"
            return 0
        fi
    done
    return 1
}

CONFIG_SRC="$(find_dir ".config")"            || die "'.config/' not found in $REPO_DIR — are you running this from inside the repo?"
GRUB_SRC="$(find_dir "grub-theme" "grub")"    || GRUB_SRC=""
SDDM_SRC="$(find_dir "sddm-theme")"           || SDDM_SRC=""
WLOGOUT_SRC="$(find_dir "wlogout")"           || WLOGOUT_SRC=""
VEILA_THEME="$(find_file "veila-lock/violet.toml")" || VEILA_THEME=""
SDDM_CONF="$(find_file "etc-configs/sddm.conf.d/theme.conf" "etc-configs/sddm-theme.conf")" || SDDM_CONF=""

# -------------------------------------------------------------------- intro ---

cat <<BANNER

  ${C_VIOLET}Violet Rice${C_RESET} — installer
  ${C_DIM}repo:    $REPO_DIR
  backup:  $BACKUP_DIR${C_RESET}
BANNER

if (( DRY_RUN )); then
    printf '\n  %sDRY RUN — nothing will be written.%s\n' "$C_GOLD" "$C_RESET"
fi

# What we found, so the user knows what will and won't happen.
step "Checking the repo"
ok   "config             $CONFIG_SRC"
[[ -n "$GRUB_SRC"    ]] && ok "grub theme         $GRUB_SRC"        || { warn "grub theme not found — step will be skipped"; SKIP_GRUB=1; }
[[ -n "$SDDM_SRC"    ]] && ok "sddm theme         $SDDM_SRC"        || { warn "sddm theme not found — step will be skipped"; SKIP_SDDM=1; }
[[ -n "$WLOGOUT_SRC" ]] && ok "wlogout            $WLOGOUT_SRC"     || { warn "wlogout not found — step will be skipped"; SKIP_WLOGOUT=1; }
[[ -n "$VEILA_THEME" ]] && ok "veila theme        $VEILA_THEME"     || { warn "veila-lock/violet.toml not found — step will be skipped"; SKIP_VEILA=1; }
[[ -n "$SDDM_CONF"   ]] && ok "sddm theme.conf    $SDDM_CONF"       || warn "etc-configs sddm theme.conf not found — will be generated instead"

if ! (( DRY_RUN )); then
    echo
    confirm "Continue?" || { echo; info "Nothing was changed."; exit 0; }
    # Prime sudo once so it doesn't interrupt halfway through.
    sudo -v
fi

# ------------------------------------------------------------------ backup ---

# Copy a path into the backup folder. Never deletes the original.
backup_path() {
    local target="$1"
    [[ -e "$target" ]] || return 0
    local dest="$BACKUP_DIR/${target#/}"
    if (( DRY_RUN )); then
        printf '    %s$ cp -a %s %s%s\n' "$C_DIM" "$target" "$dest" "$C_RESET"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [[ -r "$target" ]]; then
        cp -a "$target" "$dest" 2>/dev/null || sudo cp -a "$target" "$dest"
    else
        sudo cp -a "$target" "$dest"
    fi
    ok "backed up $target"
}

step "Preparing backup folder"
run mkdir -p "$BACKUP_DIR"
ok "$BACKUP_DIR"

# ------------------------------------------------------- 1. packages --------

PKGS_CORE=(
    waybar foot rofi mako sddm starship swaybg cava fastfetch wlogout
    grub efibootmgr
    grim slurp brightnessctl playerctl pamixer
    wl-clipboard cliphist wl-clip-persist wlr-randr swayidle
    xdg-desktop-portal-wlr polkit-gnome imagemagick jq
    pipewire pipewire-alsa pipewire-pulse wireplumber
    pavucontrol alsa-utils sof-firmware
    networkmanager network-manager-applet nm-connection-editor
    thunar tumbler gvfs udiskie udisks2 xarchiver
    unzip zip unrar 7zip ntfs-3g exfatprogs
    adwaita-dark papirus-icon-theme nwg-look xsettingsd
    qt5-base qt5-svg qt5-tools
    ttf-jetbrains-mono-nerd ebgaramond-otf
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
    ttf-dejavu ttf-liberation
)

# Artix (dinit) only — these don't exist on Arch.
PKGS_DINIT=(
    sddm-dinit pipewire-dinit pipewire-pulse-dinit wireplumber-dinit
    networkmanager-dinit elogind-dinit dbus-dinit-user
    turnstile turnstile-dinit
)

PKGS_AUR=(
    mangowm-git veila-bin networkmanager-dmenu-git
    rofi-emoji-git ttf-google-fonts-typewolf
)

IS_DINIT=0
command -v dinitctl >/dev/null 2>&1 && IS_DINIT=1

AUR_HELPER=""
for helper in paru yay; do
    if command -v "$helper" >/dev/null 2>&1; then
        AUR_HELPER="$helper"
        break
    fi
done

if (( SKIP_PACKAGES )); then
    step "1. Packages"
    skip "skipped (--skip-packages)"
else
    step "1. Installing packages"

    if ! command -v pacman >/dev/null 2>&1; then
        warn "pacman not found — this isn't an Arch-based system."
        warn "Install the packages listed in the README by hand, then re-run with --skip-packages."
    else
        info "${#PKGS_CORE[@]} core packages"
        # --needed skips anything already installed, so this is safe to re-run.
        run sudo pacman -S --needed --noconfirm "${PKGS_CORE[@]}" \
            || warn "some core packages failed — check the names against your repos and install them by hand"

        if (( IS_DINIT )); then
            info "${#PKGS_DINIT[@]} dinit service packages (Artix)"
            run sudo pacman -S --needed --noconfirm "${PKGS_DINIT[@]}" \
                || warn "some dinit packages failed — names vary between Artix versions"
        else
            skip "not an Artix/dinit system — skipping the *-dinit packages"
        fi

        if [[ -n "$AUR_HELPER" ]]; then
            info "${#PKGS_AUR[@]} AUR packages via $AUR_HELPER"
            run "$AUR_HELPER" -S --needed --noconfirm "${PKGS_AUR[@]}" \
                || warn "some AUR packages failed — install them by hand"
        else
            warn "no AUR helper (paru/yay) found. Install these by hand or the rice won't work:"
            printf '      %s\n' "${PKGS_AUR[@]}"
        fi
    fi
fi

# --------------------------------------------------------- 2. user config ---

if (( SKIP_CONFIG )); then
    step "2. Config"
    skip "skipped (--skip-config)"
else
    step "2. Installing config to ~/.config"

    backup_path "$HOME/.config"

    run mkdir -p "$HOME/.config"
    run cp -r "$CONFIG_SRC/." "$HOME/.config/"
    ok "copied config"

    # Make the scripts runnable. Missing folders are fine — not every layout has all of them.
    for pattern in \
        "$HOME/.config/rofi/scripts" \
        "$HOME/.config/waybar/scripts" \
        "$HOME/.config/mango/scripts" \
        "$HOME/.config/scripts"
    do
        if [[ -d "$pattern" ]]; then
            if (( DRY_RUN )); then
                printf '    %s$ chmod +x %s/*%s\n' "$C_DIM" "$pattern" "$C_RESET"
            else
                find "$pattern" -maxdepth 1 -type f -exec chmod +x {} +
                ok "made scripts executable in ${pattern/#$HOME/\~}"
            fi
        fi
    done
fi

# ------------------------------------------------------------ 3. services ---

if (( SKIP_SERVICES )); then
    step "3. Services"
    skip "skipped (--skip-services)"
elif (( ! IS_DINIT )); then
    step "3. Services"
    skip "no dinitctl found — not an Artix/dinit system"
    info "On systemd, enable the equivalents yourself:"
    info "  sudo systemctl enable NetworkManager sddm"
else
    step "3. Enabling dinit services"

    for svc in dbus elogind turnstiled NetworkManager sddm; do
        if [[ -e "/etc/dinit.d/$svc" ]]; then
            run sudo dinitctl enable "$svc" && ok "enabled $svc" \
                || warn "could not enable $svc"
        else
            warn "service '$svc' not present in /etc/dinit.d/ — skipping"
        fi
    done
    info "PipeWire and WirePlumber start per-user through turnstile, so they aren't enabled here."
fi

# -------------------------------------------------------------- 4. bashrc ---

if (( SKIP_BASHRC )); then
    step "4. Shell prompt"
    skip "skipped (--skip-bashrc)"
else
    step "4. Setting up the shell prompt"

    BASHRC="$HOME/.bashrc"
    backup_path "$BASHRC"

    append_bashrc() {
        local marker="$1" line="$2" label="$3"
        if [[ -f "$BASHRC" ]] && grep -qF "$marker" "$BASHRC"; then
            skip "$label already in ~/.bashrc"
            return 0
        fi
        if (( DRY_RUN )); then
            printf '    %s$ echo %s >> ~/.bashrc%s\n' "$C_DIM" "$line" "$C_RESET"
        else
            printf '%s\n' "$line" >> "$BASHRC"
            ok "added $label to ~/.bashrc"
        fi
    }

    if command -v starship >/dev/null 2>&1 || (( DRY_RUN )); then
        append_bashrc 'starship init bash' 'eval "$(starship init bash)"' "starship"
    else
        warn "starship isn't installed — skipping its ~/.bashrc line"
    fi

    if command -v fastfetch >/dev/null 2>&1 || (( DRY_RUN )); then
        append_bashrc 'fastfetch --config' \
            'fastfetch --config ~/.config/fastfetch/config.jsonc' "fastfetch"
    else
        warn "fastfetch isn't installed — skipping its ~/.bashrc line"
    fi
fi

# --------------------------------------------------------------- 5. veila ---

if (( SKIP_VEILA )); then
    step "5. Lock screen"
    skip "skipped"
else
    step "5. Installing the Veila lock theme"

    VEILA_THEME_DIR="$HOME/.config/veila/themes"
    run mkdir -p "$VEILA_THEME_DIR"
    backup_path "$VEILA_THEME_DIR/violet.toml"
    run cp "$VEILA_THEME" "$VEILA_THEME_DIR/"
    ok "installed violet.toml"

    if [[ -f "$HOME/.config/veila/config.toml" ]] || (( DRY_RUN )); then
        ok "config.toml is in place (it points at theme = \"violet\")"
    else
        warn "~/.config/veila/config.toml is missing — Veila won't know which theme to use."
        warn "Create it with:  theme = \"violet\""
    fi

    command -v veila >/dev/null 2>&1 || (( DRY_RUN )) \
        || warn "the 'veila' binary isn't installed yet (paru -S veila-bin)"
fi

# ------------------------------------------------------------- 6. wlogout ---

if (( SKIP_WLOGOUT )); then
    step "6. Power menu"
    skip "skipped"
else
    step "6. Installing wlogout"

    if [[ -d "$WLOGOUT_SRC/etc/wlogout" ]]; then
        backup_path "/etc/wlogout"
        run sudo mkdir -p /etc/wlogout
        run sudo cp -r "$WLOGOUT_SRC/etc/wlogout/." /etc/wlogout/
        ok "/etc/wlogout"
    else
        warn "wlogout/etc/wlogout not found in the repo"
    fi

    if [[ -d "$WLOGOUT_SRC/usr/share/wlogout" ]]; then
        backup_path "/usr/share/wlogout"
        run sudo mkdir -p /usr/share/wlogout
        run sudo cp -r "$WLOGOUT_SRC/usr/share/wlogout/." /usr/share/wlogout/
        ok "/usr/share/wlogout"
    else
        warn "wlogout/usr/share/wlogout not found in the repo"
    fi
fi

# ---------------------------------------------------------------- 7. grub ---

# Set KEY=VALUE in /etc/default/grub, whether the line is present,
# commented out, or missing entirely.
set_grub_option() {
    local key="$1" value="$2" file="/etc/default/grub"

    if grep -qE "^[[:space:]]*${key}=" "$file" 2>/dev/null; then
        run sudo sed -i -E "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$file"
        ok "set ${key}=${value}"
    elif grep -qE "^[[:space:]]*#[[:space:]]*${key}=" "$file" 2>/dev/null; then
        run sudo sed -i -E "s|^[[:space:]]*#[[:space:]]*${key}=.*|${key}=${value}|" "$file"
        ok "uncommented and set ${key}=${value}"
    else
        if (( DRY_RUN )); then
            printf '    %s$ echo %s=%s >> %s%s\n' "$C_DIM" "$key" "$value" "$file" "$C_RESET"
        else
            printf '%s=%s\n' "$key" "$value" | sudo tee -a "$file" >/dev/null
            ok "appended ${key}=${value}"
        fi
    fi
}

if (( SKIP_GRUB )); then
    step "7. GRUB theme"
    skip "skipped"
else
    step "7. Installing the GRUB theme"

    if [[ ! -f "$GRUB_SRC/theme.txt" ]]; then
        warn "no theme.txt inside $GRUB_SRC — skipping GRUB entirely."
        warn "Installing a themeless GRUB entry could leave you with an unbootable menu."
    elif [[ ! -d /boot/grub ]]; then
        warn "/boot/grub doesn't exist — GRUB may not be your bootloader. Skipping."
    else
        GRUB_DEST="/boot/grub/themes/$GRUB_THEME_NAME"

        backup_path "$GRUB_DEST"
        backup_path "/etc/default/grub"

        run sudo mkdir -p "$GRUB_DEST"
        run sudo cp -r "$GRUB_SRC/." "$GRUB_DEST/"
        ok "theme copied to $GRUB_DEST"

        # Resolution matters: leaving GFXMODE unset makes GRUB fall back to a
        # lower mode on older hardware, which makes the menu look oversized.
        GFXMODE="$DEFAULT_GFXMODE"
        if ! (( ASSUME_YES )) && ! (( DRY_RUN )); then
            printf '    %s?%s Screen resolution for GRUB [%s]: ' \
                "$C_GOLD" "$C_RESET" "$DEFAULT_GFXMODE"
            read -r answer </dev/tty || answer=""
            [[ -n "$answer" ]] && GFXMODE="$answer"
        fi

        if [[ ! "$GFXMODE" =~ ^[0-9]{3,5}x[0-9]{3,5}$ ]]; then
            warn "'$GFXMODE' doesn't look like a resolution — using $DEFAULT_GFXMODE"
            GFXMODE="$DEFAULT_GFXMODE"
        fi

        set_grub_option "GRUB_THEME" "\"$GRUB_DEST/theme.txt\""
        set_grub_option "GRUB_GFXMODE" "$GFXMODE"

        echo
        info "The next step rewrites /boot/grub/grub.cfg."
        info "Your old one is backed up, and you can always run grub-mkconfig yourself later."
        if confirm "Run grub-mkconfig now?"; then
            backup_path "/boot/grub/grub.cfg"
            run sudo grub-mkconfig -o /boot/grub/grub.cfg && ok "grub.cfg regenerated" \
                || warn "grub-mkconfig failed — your existing grub.cfg is untouched"
        else
            skip "skipped — run this yourself when ready:"
            info "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
        fi
    fi
fi

# ---------------------------------------------------------------- 8. sddm ---

if (( SKIP_SDDM )); then
    step "8. Login screen"
    skip "skipped"
else
    step "8. Installing the SDDM theme"

    SDDM_DEST="/usr/share/sddm/themes/$SDDM_THEME_NAME"

    backup_path "$SDDM_DEST"
    run sudo mkdir -p "$SDDM_DEST"
    run sudo cp -r "$SDDM_SRC/." "$SDDM_DEST/"
    ok "theme copied to $SDDM_DEST"

    backup_path "/etc/sddm.conf.d/theme.conf"
    run sudo mkdir -p /etc/sddm.conf.d

    if [[ -n "$SDDM_CONF" ]]; then
        run sudo cp "$SDDM_CONF" /etc/sddm.conf.d/theme.conf
        ok "installed theme.conf from the repo"
    else
        # Generate it so the theme name always matches where we just copied it.
        if (( DRY_RUN )); then
            printf '    %s$ write /etc/sddm.conf.d/theme.conf -> Current=%s%s\n' \
                "$C_DIM" "$SDDM_THEME_NAME" "$C_RESET"
        else
            printf '[Theme]\nCurrent=%s\n' "$SDDM_THEME_NAME" \
                | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
            ok "generated theme.conf (Current=$SDDM_THEME_NAME)"
        fi
    fi

    # A mismatch here is the classic "my theme didn't apply" bug.
    if [[ -n "$SDDM_CONF" ]] && ! (( DRY_RUN )); then
        current="$(grep -oP '^\s*Current\s*=\s*\K.*' /etc/sddm.conf.d/theme.conf 2>/dev/null | tr -d '[:space:]' || true)"
        if [[ -n "$current" && "$current" != "$SDDM_THEME_NAME" ]]; then
            warn "theme.conf says Current=$current but the theme was installed as '$SDDM_THEME_NAME'."
            warn "SDDM will fall back to its default until those match."
        fi
    fi
fi

# ------------------------------------------------------------------- done ---

step "Done"

if (( DRY_RUN )); then
    info "That was a dry run — nothing on disk changed."
    info "Run without --dry-run when you're happy with the plan."
    exit 0
fi

cat <<SUMMARY

    Backup of everything replaced:
      ${C_DIM}$BACKUP_DIR${C_RESET}

    To undo a piece, copy it back from there.

    ${C_BOLD}Next:${C_RESET}
      1. Reboot, so GRUB, SDDM and the session come up together.
      2. Press ${C_BOLD}Alt + Menu${C_RESET} for the keybinds cheat sheet.
      3. Boxes instead of icons means your terminal font isn't set to
         "JetBrainsMono Nerd Font".

SUMMARY

if confirm "Reboot now?"; then
    run sudo reboot
fi
