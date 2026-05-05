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
alias gemini="bun run gemini"
# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# tmux 
alias ta='tmux a || tmux'

alias hotspot-on='sudo create_ap --no-virt --freq-band 2.4 wlan0 enp8s0 Prabin 12345678'
#nbfc fan
alias fanfull='nbfc set -s 100 -f 0 && nbfc set -s 100 -f 1'
alias fan50='nbfc set -s 50 -f 0 && nbfc set -s 50 -f 1'
alias fan20='nbfc set -s 20 -f 0 && nbfc set -s 20 -f 1'
alias fanauto='nbfc set -a -f 0 && nbfc set -a -f 1'

alias ff='fastfetch'
