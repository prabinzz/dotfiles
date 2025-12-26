# Enable Vi mode
bindkey -v

# Reduce delay when switching modes (Escape key responsiveness)
export KEYTIMEOUT=1

# Change cursor shape for different modes (if terminal supports it)
# 2 = block (Normal), 6 = beam (Insert)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
  else
    echo -ne '\e[6 q'
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

# Ensure cursor shape is correct on startup
# Using add-zsh-hook to avoid overriding other precmd functions
autoload -Uz add-zsh-hook
function _fix_cursor_on_start() {
  echo -ne '\e[6 q'
}
add-zsh-hook precmd _fix_cursor_on_start

# Edit command line in editor with 'v' in Normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line