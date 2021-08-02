#!/usr/bin/bash

### Setup Audio Driver's Settings
alsactl --file ~/.config/asound.state restore

### Setup Desktop Enviroment's Settings
reloadwal

### Add Data to DWM
reloadwttr

bardate() {
	date | awk '{print $1" "$2" "$3" "$4}'
}

barip() {
	{ ip route get "1.2.3.4" &> /dev/null; } && { ip route get "1.2.3.4" | awk '{print $7}'; } || { echo "Disconnected"; }
}

barbattery() {
	echo -e "$(cat /sys/class/power_supply/BAT1/capacity)% B"
}

bartemp() {
	cat ~/.wttr.in
}

bardisk() {
	echo -e "$(df | grep "/dev/sda2" | awk '{print $5}') D"
}

while true; do
	xsetroot -name " $(barbattery) | $(bardisk) | $(barip) | $(bartemp) | $(bardate) "
	sleep 1
done &

### Start Desktop Enviroment
picom &
#xautolock -time 30 -locker slock &
exec dwm

