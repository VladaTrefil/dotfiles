# shellcheck shell=bash
# shellcheck disable=SC2139 # Intentional expansion when defining aliases.
# Commonly Used Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias cdd='cd -- "$DEV_PATH"'
alias cd.='cd -- "$DOTFILES_PATH"'

# cd to git root directory
cdgr() {
  local root
  root=$(git rev-parse --show-toplevel) || return
  cd -- "$root" || return
}

alias l="ls -l"
# GNU ls flags; stock macOS ls needs a separate implementation.
alias la="ls -la --group-directories-first --color=always"

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

alias cl="clear && ls -l"

# Git aliases
alias gaa="git add ."
alias gd="git --no-pager diff"
alias gs="git status"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"
alias grb="git rebase -i"
alias gb="git branch"
alias gcom="git commit"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gpo="git push origin"
alias gpu="git pull"
alias gpuo="git pull origin"

alias lgit='SKIP_TESTS="true" lazygit'

# Copy a file (the legacy interface), or stdin when no file is given.
clip() {
  if [ "$#" -eq 0 ]; then
    wl-copy
  elif [ "$#" -eq 1 ]; then
    wl-copy < "$1"
  else
    printf 'Usage: clip [file]\n' >&2
    return 2
  fi
}

# clear-branches stays disabled until its helper is repaired in the script block.
# Custom scripts (provisioned by a later block)
alias kill-server="sh $BIN_PATH/usr/kill-rails-server.sh"

# Youtube-DL download music
alias ydl="bash $HOME/.local/bin/usr/ydl-clip.sh"

# NVIM
alias vim="nvim"
alias history="$EDITOR $XDG_STATE_HOME/zsh/history"

# Docker
alias dockrai='docker system prune -a' # remove all images
alias dockrdi='docker system prune' # remove dangling images

# Npm
alias npmrs='npm run start'
alias npmrd='npm run dev'
alias npmrb='npm run build'

# Yarn

# Ruby
alias r='bin/rails'
alias rs='r s -p 3000'
alias rss='FORCE_SSL=1 r s -b "ssl://localhost:3000?key=/home/vlada/Documents/ssl-cert/localhost.key&cert=/home/vlada/Documents/ssl-cert/localhost.crt"'
alias rr='bin/rake'
alias rt='PARALLEL_WORKERS=3 r test'
alias rmig='r db:migrate'
alias rroll='r db:rollback'
alias rremig='r db:rollback && r db:migrate'

# Rails
alias rgm="r g migration"

alias bug="bundle exec guard"
alias bui="bundle install"
alias buu="bundle update "

# Python
alias python='python3'
alias python2='python3'

# Brave

# Exercism
alias exes='exercism submit'

# Exercism
alias qmkm='qmk compile -c -km manna-harbour_miryoku -e MIRYOKU_ALPHAS=QWERTY'

# Etcher

alias codespell='codespell --config "$XDG_CONFIG_HOME/codespell/codespellrc"'

# Create a directory and cd into it
mkcd() {
  mkdir -- "$1" && cd -- "$1" || return
}

# Use: ffmpeg-cut input.mp4 output.mp4 00:00:00 00:01:00
ffmpeg-cut() {
  ffmpeg -i "${1}" -ss "${3}" -to "${4}" -c:v copy -c:a copy "${2}"
}

# Employer aliases are supplied by the private dotfiles-work repository.
if [ -f "$XDG_CONFIG_HOME/shell/work.sh" ]; then
  # shellcheck disable=SC1091 # Optional private file is intentionally not in this repo.
  . "$XDG_CONFIG_HOME/shell/work.sh"
fi
