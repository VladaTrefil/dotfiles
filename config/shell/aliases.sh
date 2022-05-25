# Commonly Used Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias l="ls -l"
alias la="ls -la"

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

alias cdd="cd $DEV_PATH"
alias cd.="cd $DOTFILES_PATH"

# Xclip
alias clip='xclip -sel clip <'

# Custom scripts
alias clear-branches="sh $BIN_PATH/shell/clear-git-branches.sh"
alias kill-server="sh $BIN_PATH/shell/kill-rails-server.sh"
alias sinfin-init="sh $BIN_PATH/shell/init-sinfin-project.sh"
alias folio-test-account="bundle exec rails runner \"eval(File.read '$BIN_PATH/folio/folio-test-account.rb')\""

# Youtube-DL download music
alias ydl="youtube-dl -x --audio-format \"mp3\" -o '%(title)s - %(uploader)s.%(ext)s' --embed-thumbnail"

# NVIM
alias vim="nvim"

# Docker
alias dockrai='docker system prune -a' # remove all images
alias dockrdi='docker system prune' # remove dangling images

# Npm
alias npmrs='npm run start'
alias npmrd='npm run dev'
alias npmrb='npm run build'

# Yarn
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"' # move config

# Ruby
alias r='bin/rails'
alias rs='r s -p 3333'
alias rr='bin/rake'
alias rt='PARALLEL_WORKERS=3 r test'

# Rails
alias rgc="r g folio:cell"
alias rgm="r g migration"

# Python
alias python='python3'
alias python2='python3'

# Exercism
alias exes='exercism submit'

# Etcher
alias etcher="sudo $IMAGES_PATH/balenaEtcher.AppImage"

# cd to git root directory
alias cdgr='cd "$(git root)"'

# Create a directory and cd into it
mkcd() {
  mkdir "${1}" && cd "${1}"
}
