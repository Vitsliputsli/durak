#!/bin/sh

pipe='client.fifo'
rm -f "$pipe" && mkfifo "$pipe"

while true; do cat "$pipe"; done | ncat $1 $2 | while read f;
do

	case "${f%|*}" in
		'wait')
				echo 'has got answer from server'
				echo 'start|' >"$pipe"
			;;
		'lastcard')
				echo 'last card: '"${f#*|}"
			;;
		'deck')
				client_hand="${f#*|}"
				echo 'go|' >"$pipe"
			;;
		*) echo ">$f";;
	esac
	#echo 'your deck:'"$client_hand"

done &

echo 'connect to server...'

while true; do
	read u; echo "$u" > "$pipe"
done
