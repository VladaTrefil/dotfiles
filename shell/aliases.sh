# Commonly Used Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias ll="ls -l"
alias la="ls -la"

alias cla="clear && ls -la"
alias cll="clear && ls -l"
alias cls="clear && ls"

# Tmux shortcuts
alias t="tmux"
alias ta="tmux attach"
alias td="tmux detach"

# VIM
alias vim="nvim"

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

# Random
alias whatever="echo '¯\_(ツ)_/¯' | pbcopy"

# Custom functions
chpwd() ll

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# colorize default commands
# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'
# alias diff='diff --color=auto'

#npm
alias npmrs='npm run start'
alias npmrd='npm run dev'
alias npmrb='npm run build'

#Ruby
alias r='bin/rails'
alias rs='bin/rails s -p 3000'
alias rr='bin/rake'

alias rt='PARALLEL_WORKERS=3 bin/rails test'

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

# Go up [n] directories
up()
{
    local cdir="$(pwd)"
    if [[ "${1}" == "" ]]; then
        cdir="$(dirname "${cdir}")"
    elif ! [[ "${1}" =~ ^[0-9]+$ ]]; then
        echo "Error: argument must be a number"
    elif ! [[ "${1}" -gt "0" ]]; then
        echo "Error: argument must be positive"
    else
        for ((i=0; i<${1}; i++)); do
            local ncdir="$(dirname "${cdir}")"
            if [[ "${cdir}" == "${ncdir}" ]]; then
                break
            else
                cdir="${ncdir}"
            fi
        done
    fi
    cd "${cdir}"
}

# LSD config
# command -v lsd > /dev/null && alias ls='lsd --group-dirs first'
# command -v lsd > /dev/null && alias ls='lsd --tree'
