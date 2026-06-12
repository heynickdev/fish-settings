#!/usr/bin/env fish

set -g GOOGLE_DRIVE_ROOT "$HOME/Cloud/GoogleDrive"
set -g TIMESTAMP (date '+%Y-%m-%d_%H-%M-%S')
set -g APPLY 0
set -g MACHINE ''
set -g BACKUP_REF latest
set -g RESTORED
set -g SKIPPED
set -g PRESERVED

function log
    printf '%s\n' $argv
end

function usage
    printf '%s\n' \
        'Usage: restore.fish [--apply] [pc|laptop] [latest|timestamp]' \
        '' \
        'Default behavior is preview only.' \
        'Use --apply to actually copy settings into your home directory.' \
        '' \
        'Examples:' \
        '  restore.fish' \
        '  restore.fish laptop' \
        '  restore.fish --apply laptop' \
        '  restore.fish --apply pc 2026-06-12_14-30-00'
end

function resolve_machine
    if test -n "$MACHINE"
        printf '%s\n' "$MACHINE"
        return 0
    end

    if set -q LINUX_BACKUP_MACHINE
        switch $LINUX_BACKUP_MACHINE
            case pc laptop
                printf '%s\n' "$LINUX_BACKUP_MACHINE"
                return 0
        end
    end

    if command -q hostnamectl
        set -l chassis (hostnamectl chassis 2>/dev/null)
        switch "$chassis"
            case laptop notebook convertible tablet handset
                printf '%s\n' laptop
                return 0
            case desktop tower vm embedded
                printf '%s\n' pc
                return 0
        end
    end

    printf '%s\n' pc
end

function parse_args
    for arg in $argv
        switch "$arg"
            case --apply
                set -g APPLY 1
            case --help -h
                usage
                exit 0
            case pc laptop
                set -g MACHINE "$arg"
            case latest
                set -g BACKUP_REF latest
            case '*'
                if string match -qr '^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$' -- "$arg"
                    set -g BACKUP_REF "$arg"
                else
                    printf 'Unknown argument: %s\n\n' "$arg" >&2
                    usage >&2
                    exit 2
                end
        end
    end
end

function relative_home_path -a target_path
    string replace -- "$HOME/" '' "$target_path"
end

function preserve_existing -a target_path
    if not test -e "$target_path"
        return 0
    end

    set -l rel_path (relative_home_path "$target_path")
    set -l preserve_path "$PRE_RESTORE_DIR/home/$rel_path"

    mkdir -p (dirname "$preserve_path")

    if test -d "$target_path"; and not test -L "$target_path"
        mkdir -p "$preserve_path"
        rsync -a --safe-links "$target_path/" "$preserve_path/"
    else
        rsync -a --safe-links "$target_path" "$preserve_path"
    end

    set -ga PRESERVED "$target_path"
end

function restore_path -a rel_path
    set -l source_path "$SOURCE_HOME_DIR/$rel_path"
    set -l target_path "$HOME/$rel_path"

    if not test -e "$source_path"
        set -ga SKIPPED "$rel_path"
        log "Skipping missing backup path: home/$rel_path"
        return 0
    end

    if test "$APPLY" -eq 0
        log "Would restore: $source_path -> $target_path"
        set -ga RESTORED "$target_path"
        return 0
    end

    preserve_existing "$target_path"
    mkdir -p (dirname "$target_path")

    log "Restoring: $source_path -> $target_path"
    if test -d "$source_path"; and not test -L "$source_path"
        mkdir -p "$target_path"
        rsync -a --safe-links "$source_path/" "$target_path/"
    else
        rsync -a --safe-links "$source_path" "$target_path"
    end

    set -ga RESTORED "$target_path"
end

function print_summary
    log ''
    if test "$APPLY" -eq 1
        log 'Restore complete.'
        log "Pre-restore backup: $PRE_RESTORE_DIR"
    else
        log 'Preview complete. No files were changed.'
        log 'Run again with --apply to restore these settings.'
    end

    log "Machine:       $MACHINE"
    log "Backup source: $BACKUP_DIR"
    log ''
    log "Restore targets: "(count $RESTORED)
    for path in $RESTORED
        log "  - $path"
    end
    log ''
    log "Skipped missing backup paths: "(count $SKIPPED)
    for path in $SKIPPED
        log "  - home/$path"
    end

    if test "$APPLY" -eq 1
        log ''
        log "Existing paths preserved first: "(count $PRESERVED)
        for path in $PRESERVED
            log "  - $path"
        end
    end
end

parse_args $argv
set -g MACHINE (resolve_machine)
set -g BASE_DEST "$GOOGLE_DRIVE_ROOT/LinuxBackups/$MACHINE"
set -g BACKUP_DIR "$BASE_DEST/$BACKUP_REF"
set -g SOURCE_HOME_DIR "$BACKUP_DIR/home"
set -g PRE_RESTORE_DIR "$BASE_DEST/pre-restore-$TIMESTAMP"

if not test -d "$BACKUP_DIR"
    printf 'Error: backup source not found: %s\n' "$BACKUP_DIR" >&2
    exit 1
end

if not test -d "$SOURCE_HOME_DIR"
    printf 'Error: backup home directory not found: %s\n' "$SOURCE_HOME_DIR" >&2
    exit 1
end

if test "$APPLY" -eq 1
    mkdir -p "$PRE_RESTORE_DIR/home"
end

log "Restoring from $BACKUP_DIR for $MACHINE"
if test "$APPLY" -eq 0
    log 'Preview mode: no files will be changed.'
end
log ''

set -l restore_paths \
    .config/hypr \
    .config/waybar \
    .config/wofi \
    .config/rofi \
    .config/dunst \
    .config/mako \
    .config/swaync \
    .config/gtk-3.0 \
    .config/gtk-4.0 \
    .config/qt5ct \
    .config/qt6ct \
    .config/Kvantum \
    .config/nwg-look \
    .config/wlogout \
    .config/wallpapers \
    Pictures/Wallpapers \
    .config/ghostty \
    .config/fastfetch \
    .config/nvim \
    .config/starship.toml \
    .config/fish \
    .zshrc \
    .bashrc \
    .profile \
    .xprofile \
    .pam_environment \
    .gitconfig \
    .gitignore_global \
    .config/git \
    .config/lazygit \
    .config/btop \
    .config/tmux \
    .tmux.conf \
    .config/Code/User/settings.json \
    .config/Code/User/keybindings.json \
    .config/VSCodium/User/settings.json \
    .config/VSCodium/User/keybindings.json \
    .config/paru \
    .config/yay

for rel_path in $restore_paths
    restore_path "$rel_path"
end

print_summary
