#!/bin/bash
pipe='client.fifo'
rm -f $pipe
mkfifo $pipe


ip='127.0.0.1'
port=6000


function net_server {
    echo "starting server on $ip:$1"
    ./server.sh $ip $1 &

    echo 'server ready'
    net_client $ip $1
}

function net_client {
    echo 'starting client'
    echo "connecting to $1:$2"

    # тут нужно привязать nc и stdin к $pipe

    echo 'cmd ready'
    while read message <$pipe; do

        echo $message

        case $message in

            ping)
                echo 'pong'
                ;;

            exit)
                echo 'exit current game'
                break
                ;;

            *)
                echo ">$message"
                echo 'use: {exit}'

        esac

    done

}



while read comand; do
    args=( $comand )

    case ${args[0]} in

        exit)
            echo 'close durak.sh'
            exit 0
            ;;

        server)
            if [[ -z ${args[1]} ]]; then
                continue
            fi

            net_server ${args[1]}
            ;;

        client)
            if [[ -z ${args[1]} ]]; then
                continue
            fi
            if [[ -z ${args[2]} ]]; then
                continue
            fi

            net_client ${args[1]} ${args[2]}
            ;;

        *)
            echo 'use: client [ip] [port]'
            echo 'use: server [port]'
            echo 'use: exit'

    esac
done
