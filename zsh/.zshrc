export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_Z="${XDG_Z:-$XDG_CONFIG_HOME/zsh}"

for file in env options aliases plugins completions prompt local; do
  [[ -r "$XDG_Z/$file.zsh" ]] && source "$XDG_Z/$file.zsh"
done

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/kost/.lmstudio/bin"
# End of LM Studio CLI section

