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

# FZF catppuccin mocha theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

eval "$(fzf --zsh)"



# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/kost/.lmstudio/bin"
# End of LM Studio CLI section

