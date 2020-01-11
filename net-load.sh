#!/bin/bash
die() {
  echo -e "$*" 1>&2
  exit 1
}

usage() {
  die "Usage:\n net-load.sh <host>"
}

trap ctrl_c INT

function ctrl_c() {
        tput cud1
        echo -e "\nExited\n"
        exit 0
}

[[ $# -ge 1 ]] || usage

host=$1

echo -e "Current net load on ports of $host\n";\

ssh $host '\
        ifaces=($(ip link show up | grep -i up | grep -v lo | awk {"print \$2"} | tr -d :));\
        while [ 1 == 1 ]; do\
        variable=0
        let ports_count=${#ifaces[*]}+1;\
        for i in ${ifaces[*]}; do\
                RX1=$(cat /sys/class/net/${i}/statistics/rx_bytes);\
                TX1=$(cat /sys/class/net/${i}/statistics/tx_bytes);\
                sleep 1;\
                RX2=$(cat /sys/class/net/${i}/statistics/rx_bytes);\
                TX2=$(cat /sys/class/net/${i}/statistics/tx_bytes);\
                let BWRX=$RX2-$RX1;\
                let BWTX=$TX2-$TX1;\
                echo " $i Received: $BWRX B/s    Sent: $BWTX B/s";\
                variable=$((variable+1));\
                if [ $variable -eq ${#ifaces[*]} ]; then\
                        tput cuu $ports_count -T screen-bce;tput el -T screen-bce; echo;\
                fi
        done;\
        done;\
        '

