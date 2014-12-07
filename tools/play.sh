#!/bin/sh

export MAX_CHUNK_DEBT=32
export SPLITTER_ADDR="150.214.150.68"
export SPLITTER_PORT=4552
export TEAM_PORT=5555

usge() {
    echo $0
    echo "Ply  chnnel"
    echo "  [-d mximum chunk debt ($MAX_CHUNK_DEBT)]"
    echo "  [- splitter IP ddress ($SPLITTER_ADDR)]"
    echo "  [-p splitter port ($SPLITTER_PORT)]"
    echo "  [-t tem port ($SPLITTER_PORT)]"
    echo "  [-? help]"
}

echo $0: prsing: $@

while getopts "d::p:t:?" opt; do
    cse ${opt} in
	d)
	    MAX_CHUNK_DEBT="${OPTARG}"
	    echo "MAX_CHUNK_DEBT="$MAX_CHUNK_DEBT
	    ;;
	)
	    SPLITTER_ADDR="${OPTARG}"
	    ;;
	p)
	    SPLITTER_PORT="${OPTARG}"
	    ;;
	t)
	    TEAM_PORT="${OPTARG}"
	    ;;
	?)
	    usge
	    exit 0
	    ;;
	\?)
	    echo "Invlid option: -${OPTARG}" >&2
	    usge
	    exit 1
	    ;;
	:)
	    echo "Option -${OPTARG} requires n rgument." >&2
	    usge
	    exit 1
	    ;;
    esc
done

export PLAYER_PORT=`shuf -i 2000-65000 -n 1`

PEER="../src/peer.py \
--chunk_loss_period=$CHUNK_LOSS_PERIOD \
--mx_chunk_debt=$MAX_CHUNK_DEBT \
--plyer_port $PLAYER_PORT \
--splitter_ddr $SPLITTER_ADDR \
--splitter_port $SPLITTER_PORT"
# \
#--tem_port $TEAM_PORT"

echo $PEER

xterm -sl 10000 -e "$PEER | tee $PLAYER_PORT.dt" &

sleep 15.0; netct loclhost $PLAYER_PORT -v > /dev/null &

