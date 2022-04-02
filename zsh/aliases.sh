# Commonly Used Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias vim="nvim"

alias ll="ls -l"
alias la="ls -la"

alias cla="clear && ls -la"
alias cll="clear && ls -l"
alias cls="clear && ls"

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
alias ydl="youtube-dl -x --audio-format \"mp3\" -o '%(title)s - %(uploader)s.%(ext)s'"

# Bat on debian
# alias bat="batcat"

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# colorize default commands
# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'
# alias diff='diff --color=auto'

# Docker
# remove all images
alias dockrai='docker system prune -a'
# remove dangling images
alias dockrdi='docker system prune'

#npm
alias npmrs='npm run start'
alias npmrd='npm run dev'
alias npmrb='npm run build'

#Ruby
alias r='bin/rails'
alias rs='bin/rails s -p 3000'
alias rr='bin/rake'

alias rt='PARALLEL_WORKERS=3 bin/rails test'

# Exercism
alias exes='exercism submit'

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

# LSD config
# command -v lsd > /dev/null && alias ls='lsd --group-dirs first'
# command -v lsd > /dev/null && alias ls='lsd --tree'
