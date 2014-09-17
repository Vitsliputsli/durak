#!/bin/bash
if [ "x$1" == "xs" ]; 
then #server
	output='out.fifo'
	user_out='uout.fifo'
elif [ "x$1" == "xc" ];
then #client
	output='out2.fifo'
	user_out='uout2.fifo'
fi

rm -f "$output" && mkfifo "$output"
rm -f "$user_out" && mkfifo "$user_out"

if [ "x$1" == "xs" ]; 
then #server
	user='server';
	port="$2"
	nc="ncat -l $2"
elif [ "x$1" == "xc" ];
then #client
	user='client';
	server="$2"
	port="$3"
	nc="ncat $2 $3"
else
	echo 'run server: dur s [port]'
	echo 'run client: dur c [server-address] [server-port]'
	exit
fi

echo 'net-game Durak with 2 players'
echo

# create cards
unset card
for q in $'\u2660' $'\u2663' $'\u2665' $'\u2666'; do
	card[${#card[*]}]='6'"$q"
	card[${#card[*]}]='7'"$q"
	card[${#card[*]}]='8'"$q"
	card[${#card[*]}]='9'"$q"
	card[${#card[*]}]='10'"$q"
	card[${#card[*]}]='J'"$q"
	card[${#card[*]}]='Q'"$q"
	card[${#card[*]}]='K'"$q"
	card[${#card[*]}]='A'"$q"
done

if [ "$user" == 'server' ]; then
	# shuffle a deck of cards
	unset deck
	for q in {0..35}; do
		num=$[RANDOM*35/32767]
		for q2 in `seq $num 35; seq 0 $num`
		do
			if [ "x${deck[$q2]}" == 'x' ]; then 
				deck[$q2]=${card[$q]}
				break
			fi
		done
	done
fi

function choose_card() {
	q2=1
	for q in $1; do
		echo "$q2) $q"
		q2=$[q2+1]
	done
	#read -p 'Choose card:' choosecard
	return
}

deck_pos=36

while true; do cat "$output"; done | $nc | while read f;
do 
if [ "$user" == 'server' ]; then
	case "${f%|*}" in
		'start') 
				echo 'start game'
				server_hand=''
				for q in {1..6}; do
					deck_pos=$[deck_pos-1];
					server_hand="$server_hand ${deck[$deck_pos]}"
				done
				s='deck|'
				for q in {1..6}; do
					deck_pos=$[deck_pos-1];
					s="$s ${deck[$deck_pos]}"
				done
				#last card
				echo 'last card: '"${deck[0]}"
				echo "lastcard|${deck[0]}" >"$output"
				echo "$s" >"$output"
			;;
#		'go')
				#choose_card "$server_hand"
				#echo "$choosecard"
				#read -p '1111111111111' f
#			;;
		*) echo ">$f";;
	esac
	echo 'your deck:'"$server_hand"
	
elif [ "$user" == 'client' ]; then
	case "${f%|*}" in
		'wait')
				echo 'has got answer from server'
				echo 'start|' >"$output"
			;;
		'lastcard')
				echo 'last card: '"${f#*|}"
			;;
		'deck') 
				client_hand="${f#*|}"
				echo 'go|' >"$output"
			;;
		*) echo ">$f";;
	esac
	echo 'your deck:'"$client_hand"
	
fi
done &

#start game
if [ "$user" == 'server' ]; then 
	echo 'wait for connect...'
	echo 'wait' >"$output"
fi
if [ "$user" == 'client' ]; then 
	echo 'connect to server...'
fi

#user control
while true; do
	read u; echo "$u" > "$output"
done
