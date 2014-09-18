#!/bin/bash
pipe='server.fifo'
port=60000
nport=$port
rm -f "$pipe" && mkfifo "$pipe"


function work_with_player {
	echo 'work_with_player'
	num_player=${#player_port[*]}
	while true; do nport=$[nport+1]
		rm -f "${player_port}.fifo" && mkfifo "${player_port}.fifo"
		echo "port:$nport"
		#while true; do cat "$pipe"; done | ncat -lk $nport | while read message;
		while [ "x$mes" != 'x:stop' ]; do mes=`cat "$pipe"`; echo "$mes"; done | ( ncat -lk $nport || echo ':stop' > "$pipe" ) | while read message;
			do
				echo "$message" > "${player_port}.fifo"
			done
	done &
	while [ $num_player -eq ${#player_port[*]} ]; do sleep 0.01; done
	echo "player:${player_port[num_player]}"
}

while [ "x$mes" != 'x:stop' ]; do mes=`cat "$pipe"`; echo "$mes"; done | ( ncat -lk $port || echo ':stop' > "$pipe" ) | while read message;
do
	[ "x$message" == 'xDurakNewPlayer' ] && work_with_player
done 

#####################################
exit
#####################################

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

deck_pos=36

echo 'Welcome to net-game Durak.sh'

while true; do cat $pipe; done | ncat -l $port | while read message;
do
	case "${message%|*}" in

	    'stop')
	        echo 'server stoped'
	        echo 'server-stoped' > $pipe
	        echo $!
	        echo $$
	        exit 0
	        ;;

		'start')
            echo 'start game'
            echo 'game started' > $pipe

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
            echo "lastcard|${deck[0]}" > $pipe
            echo "$s" > $pipe
			;;

		*)
		    echo ">$message"
		    echo 'use {start|go|stop}' > $pipe
		    ;;

	esac
	echo 'your deck:'"$server_hand"

done &

echo 'wait for connect...'
echo 'wait' > $pipe

while read terminal_input; do
    echo $terminal_input > $pipe
done
