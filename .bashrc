# Aliases
alias ls="ls --color"
alias ll="ls -l --color"

# Git aliases
alias gcp="git commit -am 'Checkpoint'"
alias gca="git commit -a --amend"
alias greb="git rebase -i origin/master"

# Easier to include user binaries in path
export PATH=$PATH:~/bin

# Defaults
export EDITOR=vim
export PAGER=less

# Pretty shell
export PS1="\[\033[35m\]\t\[\033[m\] \[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h \[\033[33;1m\]\w\[\033[m\] \$ "

function scan() {
  grep -R "$@" .
}
