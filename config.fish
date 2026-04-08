source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
    command clear
    fastfetch_random
end

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Disable the default fish greeting
    set -g fish_greeting

    # clear and c
    alias c='fish_greeting' 
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
    abbr ga git add
    abbr mkdir mkdir -p

    # Go environment setup
    set -gx GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

zoxide init fish | source
