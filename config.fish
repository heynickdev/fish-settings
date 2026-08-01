# ============================================================================
# Fish configuration
# Fedora + CachyOS + Arch-based Linux + Kitty + Starship
#
# Shared repository:
# github.com/heynickdev/fish-settings
# ============================================================================

# ----------------------------------------------------------------------------
# Environment
#
# These settings are available to both interactive and non-interactive Fish
# processes.
# ----------------------------------------------------------------------------

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

set -gx GOPATH "$HOME/go"

set -gx MANPAGER "nvim +Man!"
set -gx MANROFFOPT -c

# Store Starship in the Fish repository so the prompt is shared between
# Fedora, CachyOS and any other machines using this repository.
set -gx STARSHIP_CONFIG "$__fish_config_dir/starship.toml"

# ----------------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------------

fish_add_path \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/share/bob/nvim-bin" \
    "$GOPATH/bin"

# LM Studio is optional and may not exist on every machine.
if test -d "$HOME/.lmstudio/bin"
    fish_add_path "$HOME/.lmstudio/bin"
end

# ----------------------------------------------------------------------------
# Generated environment variables
# ----------------------------------------------------------------------------

if test -s "$HOME/.config/envman/load.fish"
    source "$HOME/.config/envman/load.fish"
end

# Everything below this point is only needed in interactive terminals.
if not status is-interactive
    return
end

# ----------------------------------------------------------------------------
# Fish command-line editing
# ----------------------------------------------------------------------------

# Use normal Fish editing:
#
# - Enter executes the command normally.
# - Arrow keys move normally.
# - Tab opens Fish completions.
# - Autosuggestions remain enabled.
# - Alt+E and Alt+V open the complete command in Neovim.
fish_default_key_bindings

# Explicitly retain external command-buffer editing.
bind \ee edit_command_buffer
bind \ev edit_command_buffer

# Readline-style alternative:
# Ctrl+X followed by Ctrl+E.
bind \cx\ce edit_command_buffer

# ----------------------------------------------------------------------------
# Greeting
# ----------------------------------------------------------------------------

function fish_greeting
    command clear

    # Avoid displaying Fastfetch inside Neovim terminal buffers.
    if set -q NVIM
        return
    end

    if type -q fastfetch_random
        fastfetch_random
    else if type -q fastfetch
        command fastfetch
    end
end

# ----------------------------------------------------------------------------
# Basic commands
# ----------------------------------------------------------------------------

function cl --description "Clear the terminal"
    command clear
    fastfetch_random
end

function v --wraps nvim --description "Open Neovim"
    command nvim $argv
end

function vim --wraps nvim --description "Open Neovim"
    command nvim $argv
end

function vnim --wraps nvim --description "Open Neovim"
    command nvim $argv
end

function grep --wraps grep --description "Colourised grep"
    command grep --color=auto $argv
end

# Only define send when the local executable exists.
if test -x "$HOME/.local/bin/send"
    function send --description "Run the local send utility"
        command "$HOME/.local/bin/send" $argv
    end
end

# ----------------------------------------------------------------------------
# Eza commands
#
# The original commands remain available by running `command eza`.
# ----------------------------------------------------------------------------

if type -q eza
    function ls --wraps eza --description "Detailed directory listing"
        command eza \
            --long \
            --icons=always \
            --group-directories-first \
            $argv
    end

    function la --wraps eza --description "List including hidden files"
        command eza \
            --long \
            --all \
            --icons=always \
            --group-directories-first \
            $argv
    end

    function lt --wraps eza --description "Two-level directory tree"
        command eza \
            --long \
            --tree \
            --level=2 \
            --icons=always \
            --group-directories-first \
            $argv
    end

    function lta --wraps eza --description "Tree including hidden files"
        command eza \
            --long \
            --tree \
            --level=2 \
            --all \
            --icons=always \
            --group-directories-first \
            $argv
    end
end

# ----------------------------------------------------------------------------
# Docker
# ----------------------------------------------------------------------------

function wdocker --description "Continuously display Docker containers"
    command watch -n 1 \
        'sudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
end

# ----------------------------------------------------------------------------
# Remove abbreviations before recreating them
#
# This prevents warnings and stale definitions when config.fish is reloaded.
# ----------------------------------------------------------------------------

for abbreviation in \
        update \
        install \
        remove \
        ga \
        gs \
        gss \
        gaa \
        gcm \
        gpm \
        gp \
        c \
        mkdir \
        temple \
        homeserver \
        server \
        home \
        prox \
        proxmox \
        python \
        py \
        p \
        vi \
        gen-env \
        gen-url \
        tss \
        rr

    abbr --erase $abbreviation 2>/dev/null
end

# ----------------------------------------------------------------------------
# General abbreviations
# ----------------------------------------------------------------------------

abbr --add --global c clear
abbr --add --global mkdir 'mkdir -p'

abbr --add --global python python3
abbr --add --global py python3
abbr --add --global p python3

abbr --add --global vi nvim

abbr --add --global gen-env 'openssl rand -base64 32'
abbr --add --global gen-url 'openssl rand -hex 32'

abbr --add --global tss 'tailscale status'

abbr --add --global temple \
    'templ generate --watch --proxy="http://localhost:8080" --cmd="go run ./cmd"'

# Recursive removal remains explicit instead of replacing normal `rm`.
abbr --add --global rr 'rm -rf'

# ----------------------------------------------------------------------------
# Git abbreviations
# ----------------------------------------------------------------------------

abbr --add --global ga 'git add'
abbr --add --global gs 'git status --short'
abbr --add --global gss 'git status'
abbr --add --global gaa 'git add --all'
abbr --add --global gcm 'git commit -m'

# Push the currently checked-out branch rather than assuming it is main.
abbr --add --global gpm 'git push --set-upstream origin HEAD'

abbr --add --global gp 'git pull'

# ----------------------------------------------------------------------------
# SSH abbreviations
# ----------------------------------------------------------------------------

abbr --add --global homeserver 'ssh nick@194.163.229.212'
abbr --add --global server 'ssh nick@87.106.44.220'
abbr --add --global home 'ssh nick@192.168.1.153'
abbr --add --global prox 'ssh nick@142.132.248.114'

abbr --add --global proxmox \
    'ssh -J nick@142.132.248.114 nick@192.168.1.2'

# ----------------------------------------------------------------------------
# Cross-distribution package management
#
# The first matching package manager is selected automatically.
# ----------------------------------------------------------------------------

if type -q dnf
    # Fedora and RHEL-family distributions.
    abbr --add --global update 'sudo dnf upgrade --refresh'
    abbr --add --global install 'sudo dnf install'
    abbr --add --global remove 'sudo dnf remove'

else if type -q paru
    # CachyOS, EndeavourOS and Arch systems using Paru.
    abbr --add --global update 'paru -Syu'
    abbr --add --global install 'paru -S'
    abbr --add --global remove 'paru -Rns'

else if type -q yay
    # Arch systems using Yay.
    abbr --add --global update 'yay -Syu'
    abbr --add --global install 'yay -S'
    abbr --add --global remove 'yay -Rns'

else if type -q pacman
    # Plain Arch Linux.
    abbr --add --global update 'sudo pacman -Syu'
    abbr --add --global install 'sudo pacman -S'
    abbr --add --global remove 'sudo pacman -Rns'

else if type -q apt
    # Debian and Ubuntu.
    abbr --add --global update 'sudo apt update && sudo apt full-upgrade'
    abbr --add --global install 'sudo apt install'
    abbr --add --global remove 'sudo apt remove'

else if type -q zypper
    # openSUSE.
    abbr --add --global update 'sudo zypper refresh && sudo zypper update'
    abbr --add --global install 'sudo zypper install'
    abbr --add --global remove 'sudo zypper remove'

else if type -q apk
    # Alpine Linux.
    abbr --add --global update 'sudo apk update && sudo apk upgrade'
    abbr --add --global install 'sudo apk add'
    abbr --add --global remove 'sudo apk del'

else if type -q xbps-install
    # Void Linux.
    abbr --add --global update 'sudo xbps-install -Syu'
    abbr --add --global install 'sudo xbps-install'
    abbr --add --global remove 'sudo xbps-remove -R'
end

# ----------------------------------------------------------------------------
# Optional integrations
# ----------------------------------------------------------------------------

# FZF keybindings and completion.
if type -q fzf
    fzf --fish 2>/dev/null | source
end

# Peon-ping controls.
if test -f "$HOME/.claude/hooks/peon-ping/peon.sh"
    function peon --description "Control Claude peon-ping"
        command bash "$HOME/.claude/hooks/peon-ping/peon.sh" $argv
    end
end

# Thefuck starts Python whenever Fish starts, so it remains disabled for
# faster terminal startup and lower idle overhead.
#
# if type -q thefuck
#     thefuck --alias | source
# end

# ----------------------------------------------------------------------------
# Zoxide
# ----------------------------------------------------------------------------

# Replace `cd` with Zoxide's smarter navigation.
#
# The original Fish command remains available through:
#
#     builtin cd /some/path
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# ----------------------------------------------------------------------------
# Starship
#
# Keep this near the end so Starship remains the active prompt.
# ----------------------------------------------------------------------------

if type -q starship
    starship init fish | source

    # Collapse completed prompts while keeping the active prompt complete.
    enable_transience
end
