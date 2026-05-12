[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
[[ -d "$HOME/.zfunc" ]] && fpath+=("$HOME/.zfunc")

autoload -Uz compinit

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
if [[ -f "$zcompdump" ]]; then
  compinit -C -d "$zcompdump"
else
  compinit -d "$zcompdump"
fi

unset zcompdump
