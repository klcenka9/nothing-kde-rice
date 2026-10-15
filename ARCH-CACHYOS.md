# Arch / CachyOS safer installation (experimental)

This is a **separate opt-in installer** for the fork. It does not replace the original Kubuntu installer.

## Why separate?
The upstream `./install.sh` invokes `apt-get`, and its optional root scripts
modify SDDM, Plymouth, GRUB and initramfs using Debian-specific commands.
**Never run upstream `./install.sh all` on Arch/CachyOS.**

## Before you install
- Log in to **KDE Plasma 6**, not Hyprland.
- Ensure Git, curl, Python 3, Plasma 6 tools, kstart and Konsole are installed.
- Recommended pacman packages (check names in your distro repos):
  `sudo pacman -S --needed git curl python plasma-workspace kio-extras papirus-icon-theme libinput konsole imagemagick`
- Install missing optional dependencies using your distribution's package manager only after reviewing them.
- **Back up your home directory or take a filesystem snapshot** before running; the built-in backup is not a complete system backup.

```bash
git clone https://github.com/klcenka9/nothing-kde-rice.git
cd nothing-kde-rice
git switch feat/cachyos-safe-installer
bash arch-safe-install.sh
```

The installer **does not run as root**, does not install packages, and skips the Ubuntu `10-packages` step, and both root steps `50-login-screen` and `60-boot-animation`.
It asks permission before applying downloaded third-party themes/widgets and asks **again** before replacing existing panels.
It backs up known Plasma configuration files in `~/.nothing-rice-backups/arch-safe-<timestamp>`, without touching monitor-specific KScreen configuration.

## Security / limitations
- Upstream `20-upstream.sh` downloads live third-party GitHub and KDE Store content without pinning/checksums; review these dependencies.
- Upstream `30-components.sh` sets up user-level services and changes appearance; its touchpad watcher only runs when the account already has access to input devices. **Do not add yourself to the `input` group** just for this rice.
- Upstream `40-layout.sh` removes all current panels and rebuilds a new layout primarily for desktop screen 0; multi-monitor layout may need manual adjustment.
- The upstream `uninstall/revert-desktop.sh` only partially restores settings; the snapshot here provides additional recovery files, but this is **not a transactional installer**.
- No claims of full malware audit: all third-party code may change.

### Restore saved configuration files manually
Log out of Plasma or stop plasmashell before copying back configuration. Use the **exact backup directory printed by the installer**, then review its contents before restoring:
```bash
ls ~/.nothing-rice-backups/arch-safe-*/
```
Do not copy arbitrary backups onto a running desktop without reviewing them.

Upstream reference: https://github.com/buddi0812/nothing-kde-rice
