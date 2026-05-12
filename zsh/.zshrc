export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_Z="${XDG_Z:-$XDG_CONFIG_HOME/zsh}"

for file in env options aliases plugins completions prompt local; do
  [[ -r "$XDG_Z/$file.zsh" ]] && source "$XDG_Z/$file.zsh"
done
