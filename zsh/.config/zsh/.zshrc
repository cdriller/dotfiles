setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

export HISTFILE="$XDG_STATE_HOME/zsh/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

source "$XDG_CONFIG_HOME/zsh/aliases"

zmodload zsh/complist

autoload -U compinit; compinit

# Autocomplete hidden files
_comp_options+=(globdots)
source "$XDG_CONFIG_HOME/zsh/external/completion.zsh"

fpath=($ZDOTDIR/external $fpath)

autoload -Uz prompt_purification_setup; prompt_purification_setup

setopt AUTO_PUSHD

setopt PUSHD_IGNORE_DUPS

setopt PUSHD_SILENT

bindkey -v
export KEYTIMEOUT=1

autoload -Uz cursor_mode && cursor_mode

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -e

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source "$XDG_CONFIG_HOME/zsh/external/bd.zsh"
source "$XDG_CONFIG_HOME/zsh/scripts.sh"

if [ $(command -v "fzf") ]; then
    source /usr/share/fzf/completion.zsh
    source /usr/share/fzf/key-bindings.zsh
fi


if [ "$(tty)" = "/dev/tty1" ];
then
    pgrep i3 || exec startx "$XDG_CONFIG_HOME/X11/.xinitrc"
fi

alias n='NVIM_APPNAME=nvim.clean nvim'

if [ -z "$TMUX" ]; then
    tmux new-session -As scratchpad
fi

export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
