source /usr/share/cachyos-fish-config/cachyos-config.fish

# Custom fish greeting (runs fastfetch unless launched inside Neovim)
function fish_greeting
    command clear
    if not set -q NVIM
        fastfetch_random
    end
end

if status is-interactive
    # Commands to run in interactive sessions

    # Docker watcher abbreviation with fixed quote escaping
    abbr -a wdock 'watch -n 1 "sudo docker ps --format \'table {{.Names}}\t{{.Image}}\t{{.Status}}\'"'

    # Aliases
    alias cl='clear'
    alias v='nvim'
    alias vim='nvim'
    alias vnim='nvim'

    # Modern eza aliases (icons, dirs first, tree support)
    alias ls='eza -l --icons=always --group-directories-first'
    alias la='eza -la --icons=always --group-directories-first'
    alias lt='eza -l --tree --level=2 --icons=always --group-directories-first'
    alias lta='eza -l --tree --level=2 -a --icons=always --group-directories-first'
    alias grep='grep --color=auto'
    alias send='~/.local/bin/send'

    # Package management abbreviations
    abbr -a update 'paru -Syu --noconfirm'
    abbr -a install 'paru -S --noconfirm'
    abbr -a remove 'paru -Rns --noconfirm'

    # Git abbreviations
    abbr -a ga git add
    abbr -a gs git status -s
    abbr -a gss git status
    abbr -a gaa git add --all
    abbr -a gcm git commit -m
    abbr -a gpm git push -u origin main
    abbr -a gp git pull

    # Navigation, environment & system abbreviations
    abbr -a c clear
    abbr -a mkdir mkdir -p
    abbr -a temple 'templ generate --watch --proxy="http://localhost:8080" --cmd="go run ./cmd"'
    abbr -a homeserver "ssh nick@194.163.229.212"
    abbr -a server "ssh nick@87.106.44.220"
    abbr -a home "ssh nick@192.168.1.153"
    abbr -a prox "ssh nick@142.132.248.114"
    abbr -a python python3
    abbr -a py python3
    abbr -a p python3
    abbr -a vi nvim
    abbr -a proxmox ssh -J nick@142.132.248.114 nick@192.168.1.2
    abbr -a rm rm -rf
    abbr -a gen-env openssl rand -base64 32
    abbr -a gen-url openssl rand -hex 32
    abbr -a tss tailscale status
    abbr -a cd z

    # Go environment setup
    set -gx GOPATH $HOME/go
    fish_add_path $GOPATH/bin

    # Interactive integrations
    thefuck --alias | source
    zoxide init fish | source
end

# Fish shell completion settings
set -g fish_ambiguous_completions
set -q fish_case_insensitive_completion; or set -g fish_case_insensitive_completion 1

# Path additions
fish_add_path /home/nick/.lmstudio/bin
fish_add_path /home/nick/.local/bin

# Default system editor settings
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

# Manpage viewer in Neovim
set -gx MANPAGER "nvim +Man!"
set -gx MANROFFOPT -c

# peon-ping quick controls
function peon
    bash /home/nick/.claude/hooks/peon-ping/peon.sh $argv
end

# Generated for envman
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
