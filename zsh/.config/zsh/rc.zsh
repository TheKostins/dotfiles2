# Tracked interactive-shell entrypoint.
#
# This is NOT ~/.zshrc.  ~/.zshrc is a symlink to the gitignored local.zsh,
# which sources this file on its first line.  That indirection exists so that
# installers doing `>> ~/.zshrc` append to local.zsh instead of writing into
# version control -- which is how the LM Studio and Docker Desktop blocks
# ended up committed.  Nothing here sources local.zsh; that would be circular.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_Z="${XDG_Z:-$XDG_CONFIG_HOME/zsh}"

for file in env aliases plugins; do
  [[ -r "$XDG_Z/$file.zsh" ]] && source "$XDG_Z/$file.zsh"
done

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true
