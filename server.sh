#!/bin/sh

pipe='server.fifo'
rm -f $pipe && mkfifo $pipe

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

echo 'Welcome to net-game Durak.sh'


while true; do cat $pipe; done | ncat -l $1 | while read message;
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


#		'go')
				#choose_card "$server_hand"
				#echo "$choosecard"
				#read -p '1111111111111' message
#			;;

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




