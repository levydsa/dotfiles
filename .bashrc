#
# ~/.bashrc
#

# If not running interactively, don't do anything

case $- in
	*i*) ;;
	*) return ;;
esac

set -o vi

# shellcheck source=.config/shell/prompt
source ~/.config/shell/prompt

bind 'set show-mode-in-prompt on'
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

alias la='ls -lAhX --group-directories-first'
alias ls='ls --color=auto'
alias neoc='neocities'
alias shut='doas shutdown now'
alias wget='wget --hsts-file=$XDG_DATA_HOME/wget-hsts'
alias dof='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias man='man -m $HOME/.local/share/man'
