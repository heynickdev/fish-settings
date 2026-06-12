# Restore Notes

These notes are for manual restore after a reinstall. Do not restore everything blindly. Review files first, then copy only the configs you still want.

Assume the backup is available at:

```sh
~/Cloud/GoogleDrive/LinuxBackups/pc/latest
```

Use `~/Cloud/GoogleDrive/LinuxBackups/laptop/latest` on the laptop. If you want a specific timestamped backup, replace `latest` with that timestamp directory.

## Scripted Restore

Preview restore actions without changing files:

```sh
~/.config/fish/linux-settings-backup/restore.fish pc
~/.config/fish/linux-settings-backup/restore.fish laptop
```

Apply the restore:

```sh
~/.config/fish/linux-settings-backup/restore.fish --apply pc
~/.config/fish/linux-settings-backup/restore.fish --apply laptop
```

The restore script copies settings only. It does not install packages, does not restore package lists, does not restore secrets, and does not delete target files. Before overwriting existing configs, it saves them under `~/Cloud/GoogleDrive/LinuxBackups/<pc|laptop>/pre-restore-YYYY-MM-DD_HH-MM-SS`.

## Before Restoring

Install the applications you want first, then restore their config files. This avoids confusing first-run setup tools and keeps the restore easy to inspect.

Useful checks:

```sh
ls ~/Cloud/GoogleDrive/LinuxBackups/pc/latest
ls ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home
ls ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/reports
```

## Hyprland

Review the backed up Hyprland config:

```sh
ls ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/hypr
cat ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/reports/detected-keybind-files.txt
```

Restore manually:

```sh
mkdir -p ~/.config
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/hypr/ ~/.config/hypr/
```

Log out and back in, or reload Hyprland after checking the restored files.

## Ghostty

```sh
mkdir -p ~/.config
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/ghostty/ ~/.config/ghostty/
```

Restart Ghostty after restoring.

## Fastfetch

```sh
mkdir -p ~/.config
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/fastfetch/ ~/.config/fastfetch/
```

Run `fastfetch` and adjust any machine-specific paths.

## Neovim

```sh
mkdir -p ~/.config
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/nvim/ ~/.config/nvim/
```

Open Neovim and let your plugin manager reinstall plugins if needed. This backup intentionally excludes cache and build folders.

## Shell Files

Review shell files before restoring because they can contain machine-specific paths:

```sh
ls -la ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home
ls -la ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/fish
```

Restore fish config:

```sh
mkdir -p ~/.config
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/fish/ ~/.config/fish/
```

Restore individual shell files only after reviewing them:

```sh
cp -i ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.bashrc ~/
cp -i ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.zshrc ~/
cp -i ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.profile ~/
cp -i ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.xprofile ~/
cp -i ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.pam_environment ~/
```

Some of these files may not exist in your backup if they did not exist on the old install.

## Other Desktop Configs

Restore desktop config folders selectively:

```sh
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/waybar/ ~/.config/waybar/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/rofi/ ~/.config/rofi/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/dunst/ ~/.config/dunst/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/gtk-3.0/ ~/.config/gtk-3.0/
rsync -av ~/Cloud/GoogleDrive/LinuxBackups/pc/latest/home/.config/gtk-4.0/ ~/.config/gtk-4.0/
```

Only run commands for folders that exist in your backup.

## What Not To Restore

This backup is intentionally not a full home directory clone. It does not include SSH private keys, GPG private keys, browser profiles, cache folders, build outputs, games, downloads, or large random data.

Handle secrets separately with a password manager or another encrypted backup method.
