if command -v gpgconf >/dev/null 2>&1; then
  unset SSH_AGENT_PID
  if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

# FZF Gruvbox Dark theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#3C3836,bg:#1D2021,spinner:#D79921,hl:#FABD2F \
--color=fg:#EBDBB2,header:#FB4934,info:#83A598,pointer:#FB4934 \
--color=marker:#FE8019,fg+:#EBDBB2,prompt:#D3869B,hl+:#FABD2F \
--color=selected-bg:#504945 \
--color=border:#665C54,label:#EBDBB2"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
