# Preferred editor
export EDITOR='nvim'
export VISUAL='zededitor'

# Aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias zshconfig="nvim ~/.config/zsh/.zshrc"
alias reload="source ~/.config/zsh/.zshrc"
alias tse="~/.local/bin/tmux-sessionizer"
alias gemini="bun x gemini"
alias ta="tmux a || tmux"
alias adbwireless='adb connect $(avahi-browse -rt _adb-tls-connect._tcp -p | grep "=;" | cut -d ";" -f 8,9 | tr ";" ":")'
# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

#nbfc fan
alias fan90='nbfc set -s 100 -f 0 && nbfc set -s 100 -f 1'
alias fan50='nbfc set -s 50 -f 0 && nbfc set -s 50 -f 1'
alias fan20='nbfc set -s 20 -f 0 && nbfc set -s 20 -f 1'
alias fanauto='nbfc set -a -f 0 && nbfc set -a -f 1'

alias ff='fastfetch'
