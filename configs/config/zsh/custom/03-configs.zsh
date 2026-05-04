# fnm setup
eval "$(fnm env --use-on-cd --shell zsh)"

# starship setup
eval "$(starship init zsh)"

# zoxide setup
eval "$(zoxide init zsh)"

source /etc/profile

## android-studio
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH
