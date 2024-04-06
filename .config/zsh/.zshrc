
autoload -Uz compinit
zmodload zsh/complist
compinit -D
_comp_options+=(globdots)

bindkey -v

zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true

setopt inc_append_history

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

alias ls='ls --color -F'
alias la='ls -lAhX --group-directories-first'
alias wget='wget --hsts-file=$XDG_DATA_HOME/wget-hsts'
alias dof='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias man='man -m $HOME/.local/share/man'

export PS1="%B%F{red}[%F{yellow}%n%F{cyan}@%F{blue}%M %F{magenta}%1~%F{red}]%f%b$ "

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# bun completions
[ -s "/home/dante/.bun/_bun" ] && source "/home/dante/.bun/_bun"
