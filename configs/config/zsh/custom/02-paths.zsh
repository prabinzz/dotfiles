# 1. Ensure duplicates are automatically removed (Cleanliness!)
typeset -U path

# 2. Add your paths to the array
#    Zsh automatically syncs the 'path' array with the 'PATH' string
path+=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.bun/bin
    $HOME/.cache/.bun/bin
)

# 3. Export to ensure child processes see these changes
export PATH
