#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$PATH:/home/zent/.scripts/:/home/zent/.cargo/bin/:/home/zent/.local/bin"

reloadwttr

source ~/.wificreds

(cat ~/.cache/wal/sequences &)
source ~/.cache/wal/colors-tty.sh

randomcolors

alias _cat="/usr/bin/cat"
alias cat="bat"
alias la="ls -laH"
alias ls="ls -lH --color=auto"
alias ncls="ls --color=never"
alias inecho="echo -n"
alias vim="nvim"

export EDITOR="vim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export NNN_SSHFS="sshfs -o follow_symlinks"
export NNN_TRASH=1

alias scrot="date -Ins | xargs -I {} scrot screenshots/{}.png"

setxkbmap it
PS1=$(tput setaf 2; inecho '['; tput setaf 6; inecho '\u'; tput setaf 4; inecho '@'; tput setaf 6; inecho '\h'; tput setaf 5; inecho ' \W'; tput setaf 2; inecho ']'; tput sgr0; inecho '\$ ')
[ -n "$NNNLVL" ] && PS1="N$NNNLVL $PS1"

if [[ -n $SSH_CONNECTION ]]; then
	IP=$(echo $SSH_CONNECTION | awk '{print $1}')
	#IP=$(who | awk '{print $5}' | tr -d \(\))	<----	Why did I even think this implementation could work lmao?
	sshherbe "Accepted SSH Connection From IP $IP" &
fi
