#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -n "$SSH_CONNECTION" ]]; then
	sleep 0
else
	startx
fi
