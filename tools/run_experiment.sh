#!/bin/bash

team_size=10
buffer_size=10
run_time=20

usage() {
    echo $0
    echo "Run a P2PSP Team in debug mode"
    echo "  [-t (number of peers, \"$team_size\" by default)]"
    echo "  [-b (buffer size, \"$buffer_size\" by default)]"
    echo "  [-r (run time in seconds, \"$run_time\" by default)]"
    echo "  [-? (help)]"
}

echo $0: parsing: $@

while getopts "t:b:r:?" opt; do
    case ${opt} in
	t)
	    team_size="${OPTARG}"
	    ;;
	b)
	    buffer_size="${OPTARG}"
	    ;;
	r)
	    run_time="${OPTARG}"
	    ;;
	?)
	    usage
	    exit 0
	    ;;
	\?)
	    echo "Invalid option: -${OPTARG}" >&2
	    usage
	    exit 1
	    ;;
	:)
	    echo "Option -${OPTARG} requires an argument." >&2
	    usage
	    exit 1
	    ;;
    esac
done

xterm -T "Splitter" -e "../src/splitter.py --buffer_size $buffer_size --diagram" &
s=$!
sleep 1

port=9999
for i in `seq 1 $team_size`
do
	xterm -T "P$i" -e "python -d ../src/peer.py --diagram P$i.dat --player_port $port" &
	sleep 1
	xterm -T "Player$i" -e "nc 127.0.0.1 $port > /dev/null" &
	p[$i]=$!
	port=$(($port-1))
	sleep 2
done
	
sleep $run_time

while [ $team_size -gt 0 ]; do
	kill -9 ${p[$team_size]}
	sleep 2
	team_size=$(($team_size-1))
done

sleep 2
kill -9 $s
