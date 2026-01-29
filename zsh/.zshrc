zmodload zsh/zprof
export XDG_Z="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"

setopt extendedglob autocd correct
HIST_FILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

export EDITOR="nvim"

source "$XDG_Z/aliases.zsh"

#### LOAD PLUGINS ####
FAST_THEME="XDG:gruvbox-dark"
source $XDG_Z/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $XDG_Z/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fpath=($XDG_Z/plugins/zsh-completions/src $fpath)
autoload -Uz compinit

autoload -Uz compinit
if [[ -n ~/.cache/zcompdump && -f ~/.cache/zcompdump ]]; then
  compinit -C -d ~/.cache/zcompdump
else
  compinit -d ~/.cache/zcompdump
fi

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# FZF Gruvbox Dark theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#3C3836,bg:#1D2021,spinner:#D79921,hl:#FABD2F \
--color=fg:#EBDBB2,header:#FB4934,info:#83A598,pointer:#FB4934 \
--color=marker:#FE8019,fg+:#EBDBB2,prompt:#D3869B,hl+:#FABD2F \
--color=selected-bg:#504945 \
--color=border:#665C54,label:#EBDBB2"

eval "$(fzf --zsh)"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/kost/.lmstudio/bin"
# End of LM Studio CLI section

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kost/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
