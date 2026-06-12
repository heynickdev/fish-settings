#!/usr/bin/env fish

set -g GOOGLE_DRIVE_ROOT "$HOME/Cloud/GoogleDrive"
set -g TIMESTAMP (date '+%Y-%m-%d_%H-%M-%S')
set -g MACHINE_ARG ''
set -g BACKED_UP
set -g SKIPPED
set -g REPORTS
set -g RSYNC_EXCLUDES \
    --exclude .cache \
    --exclude Cache \
    --exclude cache \
    --exclude node_modules \
    --exclude target \
    --exclude dist \
    --exclude build \
    --exclude .git \
    --exclude '*.log'

function log
    printf '%s\n' $argv
end

function usage
    printf '%s\n' \
        'Usage: backup.fish [pc|laptop]' \
        '' \
        'Creates a timestamped backup under:' \
        '  ~/Cloud/GoogleDrive/LinuxBackups/<pc|laptop>/<timestamp>' \
        '' \
        'Also refreshes:' \
        '  ~/Cloud/GoogleDrive/LinuxBackups/<pc|laptop>/latest' \
        '' \
        'Machine detection is automatic, but you can force it with pc or laptop.'
end

function resolve_machine
    if test -n "$MACHINE_ARG"
        printf '%s\n' "$MACHINE_ARG"
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
            case pc laptop
                set -g MACHINE_ARG "$arg"
            case --help -h
                usage
                exit 0
            case '*'
                printf 'Unknown argument: %s\n\n' "$arg" >&2
                usage >&2
                exit 2
        end
    end
end

function relative_home_path -a source_path
    string replace -- "$HOME/" '' "$source_path"
end

function record_report -a report
    set -ga REPORTS "$report"
end

function copy_path -a source_path
    if not test -e "$source_path"
        set -ga SKIPPED "$source_path"
        log "Skipping missing path: $source_path"
        return 0
    end

    set -l rel_path (relative_home_path "$source_path")
    set -l dest_path "$HOME_BACKUP_DIR/$rel_path"

    log "Backing up: $source_path -> $dest_path"
    mkdir -p (dirname "$dest_path")

    if test -d "$source_path"; and not test -L "$source_path"
        mkdir -p "$dest_path"
        rsync -a --safe-links $RSYNC_EXCLUDES "$source_path/" "$dest_path/"
    else
        rsync -a --safe-links $RSYNC_EXCLUDES "$source_path" "$dest_path"
    end

    set -ga BACKED_UP "$source_path"
end

function detect_keybind_files
    set -l output_file "$REPORTS_DIR/detected-keybind-files.txt"

    log "Detecting possible keybind files under $HOME/.config"
    if not test -d "$HOME/.config"
        printf 'No ~/.config directory found.\n' >"$output_file"
        record_report detected-keybind-files.txt
        return 0
    end

    if command -q rg
        rg --files-with-matches \
            --hidden \
            --glob '!.git/**' \
            --glob '!**/.cache/**' \
            --glob '!**/Cache/**' \
            --glob '!**/cache/**' \
            --glob '!**/node_modules/**' \
            --glob '!**/target/**' \
            --glob '!**/dist/**' \
            --glob '!**/build/**' \
            --glob '!**/*.log' \
            --glob '!**/Code/User/workspaceStorage/**' \
            --glob '!**/Code/User/globalStorage/**' \
            --glob '!**/VSCodium/User/workspaceStorage/**' \
            --glob '!**/VSCodium/User/globalStorage/**' \
            -e 'bind[[:space:]]*=' \
            -e 'bindm[[:space:]]*=' \
            -e 'bindel[[:space:]]*=' \
            -e 'bindl[[:space:]]*=' \
            -e keybind \
            -e shortcut \
            -e binds \
            "$HOME/.config" 2>/dev/null | sort >"$output_file"
    else
        find "$HOME/.config" \
            \( -path '*/.git/*' -o -path '*/.cache/*' -o -path '*/Cache/*' -o -path '*/cache/*' -o -path '*/node_modules/*' -o -path '*/target/*' -o -path '*/dist/*' -o -path '*/build/*' \) -prune \
            -o -type f ! -name '*.log' -print0 \
            | xargs -0 grep -IlE 'bind[[:space:]]*=|bindm[[:space:]]*=|bindel[[:space:]]*=|bindl[[:space:]]*=|keybind|shortcut|binds' 2>/dev/null \
            | sort >"$output_file"
    end

    if not test -s "$output_file"
        printf 'No matching keybind files detected.\n' >"$output_file"
    end

    record_report detected-keybind-files.txt
end

function refresh_latest
    log "Refreshing latest mirror: $LATEST_DIR"
    mkdir -p "$LATEST_DIR"
    rsync -a --delete "$BACKUP_DIR/" "$LATEST_DIR/"
end

function print_summary
    log ''
    log 'Backup complete.'
    log "Machine:            $MACHINE"
    log "Timestamped backup: $BACKUP_DIR"
    log "Latest mirror:      $LATEST_DIR"
    log ''
    log "Copied paths: "(count $BACKED_UP)
    for path in $BACKED_UP
        log "  - $path"
    end
    log ''
    log "Skipped missing paths: "(count $SKIPPED)
    for path in $SKIPPED
        log "  - $path"
    end
    log ''
    log "Reports generated: "(count $REPORTS)
    for report in $REPORTS
        log "  - reports/$report"
    end
end

parse_args $argv
set -g MACHINE (resolve_machine)
set -g BASE_DEST "$GOOGLE_DRIVE_ROOT/LinuxBackups/$MACHINE"
set -g BACKUP_DIR "$BASE_DEST/$TIMESTAMP"
set -g LATEST_DIR "$BASE_DEST/latest"
set -g HOME_BACKUP_DIR "$BACKUP_DIR/home"
set -g REPORTS_DIR "$BACKUP_DIR/reports"

if not test -d "$GOOGLE_DRIVE_ROOT"
    printf 'Error: Google Drive sync folder not found: %s\n' "$GOOGLE_DRIVE_ROOT" >&2
    printf 'Create or mount it first, then rerun this script.\n' >&2
    exit 1
end

mkdir -p "$HOME_BACKUP_DIR" "$REPORTS_DIR"

log "Creating backup for $MACHINE: $BACKUP_DIR"
log ''

set -l config_paths \
    "$HOME/.config/hypr" \
    "$HOME/.config/waybar" \
    "$HOME/.config/wofi" \
    "$HOME/.config/rofi" \
    "$HOME/.config/dunst" \
    "$HOME/.config/mako" \
    "$HOME/.config/swaync" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/gtk-4.0" \
    "$HOME/.config/qt5ct" \
    "$HOME/.config/qt6ct" \
    "$HOME/.config/Kvantum" \
    "$HOME/.config/nwg-look" \
    "$HOME/.config/wlogout" \
    "$HOME/.config/wallpapers" \
    "$HOME/Pictures/Wallpapers" \
    "$HOME/.config/ghostty" \
    "$HOME/.config/fastfetch" \
    "$HOME/.config/nvim" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/fish" \
    "$HOME/.zshrc" \
    "$HOME/.bashrc" \
    "$HOME/.profile" \
    "$HOME/.xprofile" \
    "$HOME/.pam_environment" \
    "$HOME/.gitconfig" \
    "$HOME/.gitignore_global" \
    "$HOME/.config/git" \
    "$HOME/.config/lazygit" \
    "$HOME/.config/btop" \
    "$HOME/.config/tmux" \
    "$HOME/.tmux.conf" \
    "$HOME/.config/Code/User/settings.json" \
    "$HOME/.config/Code/User/keybindings.json" \
    "$HOME/.config/VSCodium/User/settings.json" \
    "$HOME/.config/VSCodium/User/keybindings.json" \
    "$HOME/.config/paru" \
    "$HOME/.config/yay"

for path in $config_paths
    copy_path "$path"
end

detect_keybind_files
refresh_latest
print_summary
