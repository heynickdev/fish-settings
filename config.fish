source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
    command clear
    fastfetch_random
end

# if status is-login
#     if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
#         mkdir -p ~/.cache
#         exec start-hyprland >~/.cache/hyprland.log 2>&1
#     end
# end

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Disable the default fish greeting
    set -g fish_greeting

    # clear and c
    alias clear='fish_greeting'
    alias cl='fish_greeting'
    alias cd='z'
    alias v='nvim'
    alias vim='nvim'
    alias vnim='nvim'

    # Modern eza aliases (icons, dirs first, tree support)
    alias ls='eza -l --icons=always --group-directories-first'
    alias la='eza -la --icons=always --group-directories-first'
    alias lt='eza --tree --level=2 --icons=always --group-directories-first'
    alias lta='eza --tree --level=2 -a --icons=always --group-directories-first'
    alias grep='grep --color=auto'

    # Package management aliases
    alias update='paru -Syu'
    alias install='paru -S'
    alias remove='paru -Rns'

    # Git aliases
    alias gs='git status'
    alias gaa='git add .'
    alias gc='git commit -m'
    alias gp='git push'

    # all abbreviations
    abbr -a c clear
    abbr -a ga git add
    abbr -a mkdir mkdir -p
    abbr -a temple 'templ generate --watch --proxy="http://localhost:8080" --cmd="go run ./cmd"'
    abbr -a c clear
    abbr -a homeserver "ssh mrcor@194.163.229.212"
    abbr -a server "ssh root@87.106.44.220"
    abbr -a home "ssh nick@192.168.1.153"
    abbr -a prox "ssh root@142.132.248.114"
    abbr -a python python3
    abbr -a py python3
    abbr -a p python3
    abbr -a v nvim
    abbr -a vi nvim
    abbr -a vim nvim
    abbr -a gss git status -s
    abbr -a gaa git add --all
    abbr -a gcm git commit -m
    abbr -a proxmox ssh -J nick@142.132.248.114 nick@192.168.1.2

    # Go environment setup
    set -gx GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

set -g fish_ambiguous_completions
set -q fish_case_insensitive_completion; or set -g fish_case_insensitive_completion 1
zoxide init fish | source

thefuck --alias | source
