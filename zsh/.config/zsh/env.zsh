export EDITOR="nvim"

# Keep $path (and so $PATH) free of duplicates.  Nested shells re-source
# this config with PATH already populated, so unguarded appends in
# local.zsh would otherwise stack up entry by entry.
typeset -U path PATH

setopt extendedglob autocd

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

# gpg-agent doubles as the ssh-agent (enable-ssh-support in gpg-agent.conf).
# Keep this in env, not prompt: anything that needs to reach an SSH remote
# needs SSH_AUTH_SOCK, and it is easy to lose track of if it is filed as
# prompt decoration.
if command -v gpgconf >/dev/null 2>&1; then
  unset SSH_AGENT_PID
  if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

# Gruvbox dark, to match fast-syntax-highlighting (see plugins.zsh).
export FZF_DEFAULT_OPTS=" \
--color=bg+:#3C3836,bg:#1D2021,spinner:#D79921,hl:#FABD2F \
--color=fg:#EBDBB2,header:#FB4934,info:#83A598,pointer:#FB4934 \
--color=marker:#FE8019,fg+:#EBDBB2,prompt:#D3869B,hl+:#FABD2F \
--color=selected-bg:#504945 \
--color=border:#665C54,label:#EBDBB2"
