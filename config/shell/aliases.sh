# Commonly Used Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias cdd="cd $DEV_PATH"
alias cd.="cd $DOTFILES_PATH"

# cd to git root directory
alias cdgr='cd "$(git root)"'

alias l="ls -l"
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

alias lgit="lazygit"

# Xclip
alias clip='xclip -sel clip <'

# Custom scripts
alias clear-branches="sh $BIN_PATH/usr/clear-git-branches.sh"
alias kill-server="sh $BIN_PATH/usr/kill-rails-server.sh"
alias sinfin-init="bash $BIN_PATH/usr/init-sinfin-project.sh"
alias folio-test-account="bundle exec rails runner \"eval(File.read '$BIN_PATH/usr/folio-test-account.rb')\""

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
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"' # move config

# Ruby
alias r='bin/rails'
alias rs='r s -p 3000'
alias rss='FORCE_SSL=1 r s -b "ssl://localhost:3000?key=/home/vlada/Documents/ssl-cert/localhost.key&cert=/home/vlada/Documents/ssl-cert/localhost.crt"'
alias rr='bin/rake'
alias rt='PARALLEL_WORKERS=3 r test'

# Rails
alias rgc="r g folio:cell"
alias rgm="r g migration"

alias bug="bundle exec guard"
alias bui="bundle install"
alias buu="bundle update "

# Python
alias python='python3'
alias python2='python3'

# Brave
alias brave-browser='brave-browser-stable'

# Exercism
alias exes='exercism submit'

# Exercism
alias qmkm='qmk compile -c -km manna-harbour_miryoku -e MIRYOKU_ALPHAS=QWERTY'
alias wally='~/Downloads/installers/wally'

# Etcher
alias etcher="sudo $IMAGES_PATH/balenaEtcher.AppImage"

alias codespell="$XDG_DATA_HOME/nvim/mason/bin/codespell --config $XDG_CONFIG_HOME/codespell/codespellrc"

# Create a directory and cd into it
mkcd() {
  mkdir "${1}" && cd "${1}"
}
