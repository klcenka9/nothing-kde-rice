#!/usr/bin/env bash
# Safer Arch/CachyOS installer: intentionally never calls sudo or modifies boot/SDDM.
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
die(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ ${EUID} -ne 0 ]] || die "Run as a normal desktop user, never with sudo."
[[ -n "${XDG_CURRENT_DESKTOP:-}" && "${XDG_CURRENT_DESKTOP^^}" == *KDE* ]] || die "Log in to a KDE Plasma session first."
command -v pacman >/dev/null || die "Only Arch-based distributions are supported."
for cmd in plasmashell kwriteconfig6 kpackagetool6 qdbus6 kquitapp6 git curl python3; do
  command -v "$cmd" >/dev/null || die "Missing $cmd; install it through pacman."
done
command -v kstart >/dev/null || die "Missing kstart; install KDE workspace tools first."
for pkg in papirus-icon-theme libinput plasma-workspace; do
  pacman -Q "$pkg" >/dev/null 2>&1 || echo "WARNING: suggested package missing: $pkg"
done
echo "NOTE: This installs remote third-party KDE Store themes and GitHub widgets."
echo "NOTE: Some downloaded archives are not pinned by checksum in upstream scripts."
echo "Nothing will change until you explicitly approve the steps below."
printf '\nProceed with user-level installation? [y/N] '
read -r answer
[[ "$answer" == [yY] ]] || exit 0

stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/.nothing-rice-backups/arch-safe-$stamp"
mkdir -p "$backup/config" "$backup/systemd-user"
files=(kdeglobals kwinrc plasmarc plasmashellrc konsolerc
  plasma-org.kde.plasma.desktop-appletsrc kcminputrc)
for f in "${files[@]}"; do
  [[ -f "$HOME/.config/$f" ]] && cp -a "$HOME/.config/$f" "$backup/config/"
done
for d in "$HOME/.config/plasma-workspace" "$HOME/.config/panel-colorizer"; do
  [[ -d "$d" ]] && cp -a "$d" "$backup/config/"
done
for f in nothing-gestures.service nothing-net-reload.service; do
  [[ -f "$HOME/.config/systemd/user/$f" ]] && cp -a "$HOME/.config/systemd/user/$f" "$backup/systemd-user/"
done
printf 'Backup created: %s\n' "$backup"

# Guard against accidental privilege escalation and avoid default gesture/input-group changes.
bash ./install/20-upstream.sh
bash ./install/30-components.sh
echo
echo "Upstream step 30 may enable user services, but this script does NOT add you to input group."
echo "Step 40 deletes/rebuilds current KDE panels (backup above exists)."
printf 'Rebuild desktop panels and widgets? [y/N] '
read -r layout
if [[ "$layout" == [yY] ]]; then
  bash ./install/40-layout.sh
else
  echo "Skipped desktop layout. You can apply it later after reviewing install/40-layout.sh."
fi
echo "Completed user-level steps. Logout/login if needed."
echo "No SDDM, Plymouth, bootloader, initramfs or sudo steps were run."
echo "Snapshot: $backup"
