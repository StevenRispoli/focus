#!/bin/bash

# if [[ $UID != 0 ]]; then
#     echo "Please run this script as root:"
#     echo "sudo $0 $*"
#     exit 1
# fi

#http://stackoverflow.com/questions/6990978/how-can-i-know-which-of-the-dev-input-eventx-x-0-7-have-the-linux-input-stre#answer-23039208
eventNumber=$(cat /proc/bus/input/devices | awk '/keyboard/{for(a=0;a>=0;a++){getline;{if(/kbd/==1){ print $NF;exit 0;}}}}')
pomodoro=1

while [ 1 ]; do
	#25 minute pomodoro
	i=25
	while [ $i -gt 0 ];do
		echo Pomodoro "$pomodoro" minutes left: "$i"
		#double dash (--) is used in bash built-in commands 
		#to signify the end of command options, after which
		#only positional parameters are accepted.
		#http://unix.stackexchange.com/questions/11376/what-does-double-dash-mean-also-known-as-bare-double-dash
		#
		#$() denotes command substitution
		a=$(sudo timeout 2s evtest /dev/input/$eventNumber | grep -- --- | wc -l)
		if (( $a < 2 )); then
			paplay /usr/share/sounds/freedesktop/stereo/bell.oga
			notify-send "Focus!" "Remember to take breaks."
		fi
		((i--))
	done
	#(()) evaluates expressions as C arithmetic and returns a boolean
	#Take long break if 4 pomodoros have past since the previous long break or if it is the first
	if ! (($pomodoro%4)); then
		#Exit script after 12 pomodoros
		if [ $pomodoro -eq 12 ]; then
			notify-send "Finished" "OMG you actually made it!"
			exit
		else
			j=20
			notify-send "Long Break" "Take a nice, long break. You've earned it."
			while [ $j -gt 0 ]; do
				echo Long "break" minutes left: "$j"
				sleep 60
				((j--))
			done
		fi
	else
		k=5
		notify-send "Short Break" "STAHP! Chill for a few."
		while [ $k -gt 0 ];do
			echo Short "break" minutes left: "$k"
			sleep 60
			((k--))
		done
	fi
	notify-send "Break's Over" "A new pomodoro has started."
	((pomodoro++))
done

