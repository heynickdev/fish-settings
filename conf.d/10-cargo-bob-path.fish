# Cargo-installed programs, including Bob.
if test -d "$HOME/.cargo/bin"
    fish_add_path --prepend "$HOME/.cargo/bin"
end

# Neovim version currently selected by Bob.
if test -d "$HOME/.local/share/bob/nvim-bin"
    fish_add_path --prepend "$HOME/.local/share/bob/nvim-bin"
end
