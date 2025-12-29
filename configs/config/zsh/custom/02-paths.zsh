# Ensure duplicates are removed
typeset -U path

# Add user paths
#    Zsh automatically syncs the 'path' array with the 'PATH' string
path+=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.bun/bin
    $HOME/.cache/.bun/bin
)

# Export PATH
export PATH
