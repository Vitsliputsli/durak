#!/bin/sh

pipe='client.fifo'
rm -f "$pipe"
mkfifo "$pipe"

while true; do cat "$pipe"; done | ncat $1 $2 | while read message;
do

	case "${message%|*}" in

	    'server-stoped')
	        echo 'server is down'
	        exit 0
	        ;;

		'wait')
			echo 'has got answer from server'
			echo 'start|' > "$pipe"
			;;

		'lastcard')
			echo 'last card: '"${message#*|}"
			;;

		'deck')
			client_hand="${message#*|}"
			echo 'go|' > "$pipe"
			;;

		*)
		    echo ">$message"

	esac
	#echo 'your deck:'"$client_hand"

done &

echo 'connect to server...'

while read terminal_input; do
    echo "$terminal_input" > "$pipe"
done