#!/bin/sh

server_pipe='server_out.fifo'

rm -f "$server_pipe" && mkfifo "$server_pipe"

port="$1"
nc="ncat -l $1"

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



echo 'Welcome to net-game Durak'
echo

while true; do cat "$server_pipe"; done | $nc | while read f;
do
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
				echo "lastcard|${deck[0]}" >"$server_pipe"
				echo "$s" >"$server_pipe"
			;;
#		'go')
				#choose_card "$server_hand"
				#echo "$choosecard"
				#read -p '1111111111111' f
#			;;
		*) echo ">$f";;
	esac
	echo 'your deck:'"$server_hand"

done &

#start game
echo 'wait for connect...'
echo 'wait' >"$server_pipe"


#user control
while true; do
	read u; echo "$u" > "$server_pipe"
done




