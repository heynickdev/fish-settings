# linux-settings-backup

Safe local backup and restore scripts for personal Linux desktop and development settings. The backup target is your local Google Drive sync folder:

```sh
~/Cloud/GoogleDrive/LinuxBackups
```

Each run creates a timestamped backup and refreshes a `latest` mirror under a machine bucket:

```text
~/Cloud/GoogleDrive/LinuxBackups/pc
~/Cloud/GoogleDrive/LinuxBackups/laptop
```

The scripts auto-detect laptop vs desktop with `hostnamectl chassis` when available. You can also force the machine bucket with `pc` or `laptop`.

## What It Backs Up

The script backs up selected personal settings if they exist:

- Hyprland, Waybar, Wofi, Rofi, Dunst, Mako, SwayNC, GTK, Qt, Kvantum, nwg-look, wlogout, and wallpaper folders
- Ghostty, Fastfetch, Neovim, Starship, fish, shell dotfiles, Git config, LazyGit, btop, and tmux config
- VS Code and VSCodium user `settings.json` and `keybindings.json`
- `paru` and `yay` config folders
- Detected keybind-related files under `~/.config`

Backups are organized like this:

```text
LinuxBackups/
  pc/
    2026-06-12_14-30-00/
      home/
      reports/
    latest/
      home/
      reports/
  laptop/
    latest/
      home/
      reports/
```

## What It Does Not Back Up

This is intentionally not a full home directory backup. It does not copy:

- SSH private keys
- GPG private keys
- Browser profiles
- Cache folders
- `node_modules`
- Rust `target` folders
- `dist` or `build` folders
- Git repositories' `.git` directories
- Logs
- Downloads, videos, games, or large random data
- Pacman package lists
- AUR package lists
- Flatpak package lists
- System/service reports

Use a password manager or encrypted backup system for secrets.

## Safety Properties

- Does not modify existing configs
- Does not delete anything from your home directory
- Copies only an explicit allowlist of paths
- Uses `rsync` with excludes for common cache/build folders
- Creates a new timestamped backup on every run
- Refreshes `latest` from the newest timestamped backup
- Prints every copied and skipped path

The script uses `rsync --delete` only when refreshing the `latest` mirror inside the backup destination.

## How To Run

From this directory:

```sh
./backup.fish
```

Or from anywhere:

```sh
~/.config/fish/linux-settings-backup/backup.fish
```

Force a machine bucket:

```sh
~/.config/fish/linux-settings-backup/backup.fish pc
~/.config/fish/linux-settings-backup/backup.fish laptop
```

The script first checks that this folder exists:

```sh
~/Cloud/GoogleDrive
```

If it exists, the script creates the backup destination if needed:

```sh
~/Cloud/GoogleDrive/LinuxBackups
```

## How To Check The Backup

Check the newest mirror:

```sh
ls -la ~/Cloud/GoogleDrive/LinuxBackups/pc/latest
find ~/Cloud/GoogleDrive/LinuxBackups/pc/latest -maxdepth 3 -type f | sort
```

Check the detected keybind file:

```sh
ls -la ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/reports
cat ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/reports/detected-keybind-files.txt
```

## After Reinstall

Make sure Google Drive sync is available again and that your backup exists:

```sh
ls -la ~/Cloud/GoogleDrive/LinuxBackups
ls -la ~/Cloud/GoogleDrive/LinuxBackups/pc/latest
ls -la ~/Cloud/GoogleDrive/LinuxBackups/laptop/latest
```

Install your base desktop tools and apps first, then restore configs selectively. See [restore-notes.md](restore-notes.md) for manual restore commands.

## Restore With The Script

Preview what would be restored:

```sh
~/.config/fish/linux-settings-backup/restore.fish pc
~/.config/fish/linux-settings-backup/restore.fish laptop
```

Actually restore settings:

```sh
~/.config/fish/linux-settings-backup/restore.fish --apply pc
~/.config/fish/linux-settings-backup/restore.fish --apply laptop
```

Restore a specific timestamp:

```sh
~/.config/fish/linux-settings-backup/restore.fish --apply pc 2026-06-12_14-30-00
```

Before overwriting any existing target config, `restore.fish --apply` saves the current version under:

```text
~/Cloud/GoogleDrive/LinuxBackups/<pc|laptop>/pre-restore-YYYY-MM-DD_HH-MM-SS
```

The restore script does not install packages, does not restore package lists, and does not use `rsync --delete`.

## Manual Restore

Do not restore everything blindly. Review the files in `home/` and `reports/`, then copy back only what you want.

Common examples:

```sh
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/hypr/ ~/.config/hypr/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/ghostty/ ~/.config/ghostty/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/fastfetch/ ~/.config/fastfetch/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/nvim/ ~/.config/nvim/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/fish/ ~/.config/fish/
```
