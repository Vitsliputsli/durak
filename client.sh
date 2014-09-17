#!/bin/sh

client_pipe='client_out.fifo'
rm -f "$client_pipe" && mkfifo "$client_pipe"

server="$1"
port="$2"
nc="ncat $1 $2"

while true; do cat "$client_pipe"; done | $nc | while read f;
do

	case "${f%|*}" in
		'wait')
				echo 'has got answer from server'
				echo 'start|' >"$client_pipe"
			;;
		'lastcard')
				echo 'last card: '"${f#*|}"
			;;
		'deck')
				client_hand="${f#*|}"
				echo 'go|' >"$client_pipe"
			;;
		*) echo ">$f";;
	esac
	#echo 'your deck:'"$client_hand"

done &


echo 'connect to server...'

#user control
while true; do
	read u; echo "$u" > "$client_pipe"
done
