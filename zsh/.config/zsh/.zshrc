# Options
setopt AUTO_PARAM_SLASH AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
unsetopt CASE_GLOB

# History
export HISTFILE="$XDG_STATE_HOME/zsh/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

# Completions
[[ -d /opt/homebrew/share/zsh-completions ]] && \
  fpath=(/opt/homebrew/share/zsh-completions $fpath)

zmodload zsh/complist
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
_comp_options+=(globdots) # Autocomplete hidden files
source "$XDG_CONFIG_HOME/zsh/external/completion.zsh"

# Prompt
fpath=($ZDOTDIR/external $fpath)
autoload -Uz prompt_purification_setup; prompt_purification_setup

# Keybindings
bindkey -e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Plugins
source "$XDG_CONFIG_HOME/zsh/external/bd.zsh"
source "$XDG_CONFIG_HOME/zsh/scripts.sh"

# FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# NVM
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# i3/startx (Linux)
if [ "$(tty)" = "/dev/tty1" ]; then
  pgrep i3 || exec startx "$XDG_CONFIG_HOME/X11/.xinitrc"
fi

# Tmux
if [ -z "$TMUX" ]; then
  tmux new-session -As scratchpad
fi

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"
source <(atuin gen-completions --shell zsh)

export PATH="$HOME/.local/bin:$PATH"
