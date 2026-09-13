[[ -r "$XDG_Z/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] &&
  source "$XDG_Z/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" &&
  # Must follow the plugin: it is what creates FAST_HIGHLIGHT_STYLES.
  source "$XDG_Z/fsh-gruvbox-dark-theme.zsh"

[[ -r "$XDG_Z/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$XDG_Z/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

[[ -d "$XDG_Z/plugins/zsh-completions/src" ]] &&
  fpath=("$XDG_Z/plugins/zsh-completions/src" $fpath)

[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
[[ -d "$HOME/.zfunc" ]] && fpath+=("$HOME/.zfunc")

autoload -Uz compinit

# `compinit -C` trusts the dump file and never rescans fpath, so a completion
# installed after the dump was written (docker, cargo, …) stays invisible
# forever.  Take the fast path only while the dump is under a day old.
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
if [[ -n ${zcompdump}(#qNmh-24) ]]; then
  compinit -C -d "$zcompdump"
else
  compinit -d "$zcompdump"
fi
unset zcompdump

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1 && [[ -o zle && -t 0 && -t 1 ]]; then
  eval "$(fzf --zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
