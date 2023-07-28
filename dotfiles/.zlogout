_is_ssh
test $? -eq 0 && notify-send "$(whoami) has ended their SSH connection"
