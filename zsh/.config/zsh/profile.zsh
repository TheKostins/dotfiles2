# Tracked login-shell entrypoint; see rc.zsh for why ~/.zprofile is a symlink
# to the gitignored local-profile.zsh rather than to this file.

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"
export PATH="$HOME/.local/bin:$PATH"
