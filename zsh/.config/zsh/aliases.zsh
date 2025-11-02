export EZB="eza --icons=always";
alias ls="$EZB"
alias l="$EZB -l"
alias ll="$EZB -la"
alias la="$EZB -a"
alias lt="$EZB -T"


alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gb='git branch -vv'
alias gco='git checkout'
alias gcob='git checkout -b'             
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gcam='git commit -am'             
alias gcl='git clone'
alias gcp='git cherry-pick'
alias gpl='git pull --ff-only'
alias gps='git push'
alias gpsf='git push --force-with-lease'
alias gph='git push -u origin HEAD' 

alias tmux='tmux new-session -A -s "$(basename "$PWD")"'

alias tmx='tmux new-session -As main -c "$PWD"'
zmx() { tmux new-session -As "${2:-$(basename $(zoxide query "$1"))}" -c "$(zoxide query "$1")"; }

