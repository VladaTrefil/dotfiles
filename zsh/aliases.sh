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

# Custom scripts
alias clear-branches="sh ~/.local/bin/shell/clear-git-branches.sh"
alias kill-server="sh ~/.local/bin/shell/kill-rails-server.sh"
alias sinfin-init="sh ~/.local/bin/shell/init-sinfin-project.sh"
alias folio-test-account="bundle exec rails runner \"eval(File.read '$HOME/.local/bin/folio/folio-test-account.rb')\""

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

# Ruby
alias r='bin/rails'
alias rs='r s -p 3000'
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
alias etcher='sudo ~/Images/balenaEtcher.AppImage'

# Update dotfiles
dfu() {
  (
    cd ~/.dotfiles && git pull --ff-only && ./install -q
  )
}

# cd to git root directory
alias cdgr='cd "$(git root)"'

# Create a directory and cd into it
mkcd() {
  mkdir "${1}" && cd "${1}"
}
