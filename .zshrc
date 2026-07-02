PROMPT='%F{magenta}%*%f %F{cyan}%n%f %B%F{yellow}%~%f%b %# '

export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"
export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"

eval "$(fnm env --use-on-cd --shell zsh)"


export EDITOR="/opt/homebrew/bin/vim"

# >>> bomi workspace-tools env (managed by install-workflow) >>>
[ -f "/Users/agoder/.config/bomi/env.sh" ] && . "/Users/agoder/.config/bomi/env.sh"
# <<< bomi workspace-tools env <<<
