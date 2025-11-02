export ZDOTDIR="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"

setopt extendedglob autocd correct
HIST_FILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

source "$ZDOTDIR/aliases.zsh"

#### LOAD PLUGINS ####
FAST_THEME="XDG:catppuccin-mocha"
source $ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fpath=($ZDOTDIR/plugins/zsh-completions/src $fpath)
autoload -Uz compinit && compinit -d ~/.cache/zcompdump

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/kost/.lmstudio/bin"
# End of LM Studio CLI section

