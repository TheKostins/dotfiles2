FAST_THEME="XDG:gruvbox-dark"

[[ -r "$XDG_Z/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] &&
  source "$XDG_Z/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

[[ -r "$XDG_Z/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$XDG_Z/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

[[ -d "$XDG_Z/plugins/zsh-completions/src" ]] &&
  fpath=("$XDG_Z/plugins/zsh-completions/src" $fpath)

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1 && [[ -o zle && -t 0 && -t 1 ]]; then
  eval "$(fzf --zsh)"
fi
