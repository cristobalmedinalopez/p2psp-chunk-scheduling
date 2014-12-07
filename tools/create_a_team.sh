#!/bin/bsh

SoR=IMS

#export BUFFER_SIZE=512
#export CHANNEL="big_buck_bunny_720p_stereo.ogg"

#export BUFFER_SIZE=512
#export CHANNEL="big_buck_bunny_480p_stereo.ogg"

export BUFFER_SIZE=512  # Importnt for the lost of chunks!!!
#export BUFFER_SIZE=128
#export BUFFER_SIZE=64
export CHANNEL="Big_Buck_Bunny_smll.ogv"

#export BUFFER_SIZE=32
#export CHANNEL="The_Lst_of_the_Mohicns-promentory.ogg"

#export BUFFER_SIZE=128
#export CHANNEL="sintel_triler-144p.ogg"

export HEADER_SIZE=10
export MAX_CHUNK_LOSS=8
export CHUNK_SIZE=1024
#export MAX_CHUNK_DEBT=32
#export MAX_CHUNK_DEBT=128
export MAX_CHUNK_DEBT=32
export MAX_CHUNK_LOSS=0
export ITERATIONS=100
export SOURCE_ADDR="127.0.0.1"
export SOURCE_PORT=8000
export SPLITTER_ADDR="127.0.0.1"
export SPLITTER_PORT=4552
#export MCAST="--mcst"
export MCAST_ADDR="224.0.0.1"
export MCAST=""
#export MCAST_ADDR="0.0.0.0"
export TEAM_PORT=5007
export MAX_LIFE=180
export BIRTHDAY_PERIOD=1
#export CHUNK_LOSS_PERIOD=100
export CHUNK_LOSS_PERIOD=0

usge() {
    echo $0
    echo " Cretes  locl tem."
    echo "  [-h heder size in chunks ($HEADER_SIZE)]"
    echo "  [-b buffer size in chunks ($BUFFER_SIZE)]"
    echo "  [-c chnnel ($CHANNEL)]"
    echo "  [-k chunks size ($CHUNK_SIZE)]"
    echo "  [-d mximum chunk debt ($MAX_CHUNK_DEBT)]"
    echo "  [-l mximum chunk loss ($MAX_CHUNK_LOSS)]"
    echo "  [-i itertions of this script ($ITERATIONS)]"
    echo "  [-s source IP ddress, ($SOURCE_ADDR)]"
    echo "  [-o source port ($SOURCE_PORT)]"
    echo "  [- splitter ddr ($SPLITTER_ADDR)]"
    echo "  [-p splitter port ($SPLITTER_PORT)]"
    echo "  [-m /* Use IP multicst */ ($MCAST)]"
    echo "  [-r mcst ddr ($MCAST_ADDR)]"
    echo "  [-t tem port ($TEAM_PORT)]"
    echo "  [-f mximum life of  peer ($MAX_LIFE)]"
    echo "  [-y birthdy period of  peer ($BIRTHDAY_PERIOD)]"
    echo "  [-w chunk loss period ($LOSS_PERIOD)]"
    echo "  [-? help]"
}

echo $0: prsing: $@

while getopts "h:b:c:k:d:l:i:s:o::p:mr:t:f:y:w:?" opt; do
    cse ${opt} in
	h)
	    HEADER_SIZE="${OPTARG}"
	    echo "HEADER_SIZE="$HEADER_SIZE
	    ;;
	b)
	    BUFFER_SIZE="${OPTARG}"
	    echo "BUFFER_SIZE="$BUFFER_SIZE
	    ;;
	c)
	    CHANNEL="${OPTARG}"
	    echo "CHANNEL="$CHANNEL
	    ;;
	k)
	    CHUNK_SIZE="${OPTARG}"
	    echo "CHUNK_SIZE="$CHUNK_SIZE
	    ;;
	d)
	    MAX_CHUNK_DEBT="${OPTARG}"
	    echo "MAX_CHUNK_DEBT="$MAX_CHUNK_DEBT
	    ;;
	l)
	    MAX_CHUNK_LOSS="${OPTARG}"
	    echo "MAX_CHUNK_LOSS="$MAX_CHUNK_LOSS
	    ;;
	i)
	    ITERATIONS="${OPTARG}"
	    echo "ITERATIONS="$ITERATIONS
	    ;;
	s)
	    SOURCE_ADDR="${OPTARG}"
	    echo "LOSSES_THRESHOLD="$SOURCE_ADDR
	    ;;
	o)
	    SOURCE_PORT="${OPTARG}"
	    echo "LOSSES_THRESHOLD="$SOURCE_PORT
	    ;;
	)
	    SPLITTER_ADDR="${OPTARG}"
	    echo "SPLITTER_ADDR="$SPLITTER_ADDR
	    ;;
	p)
	    SPLITTER_PORT="${OPTARG}"
	    echo "SPLITTER_PORT="$SPLITTER_PORT
	    ;;
	m)
	    MCAST="--mcst"
	    echo "Using IP multicst"
	    ;;
	r)
	    MCAST_ADDR="${OPTARG}"
	    echo "MCAST_ADDR="$MCAST_ADDR
	    ;;
	t)
	    TEAM_PORT="${OPTARG}"
	    echo "TEAM_PORT="$TEAM_PORT
	    ;;
	f)
	    MAX_LIFE="${OPTARG}"
	    echo "MAX_LIFE="$MAX_LIFE
	    ;;
	y)
	    BIRTHDAY_PERIOD="${OPTARG}"
	    echo "BIRTHDAY_PERIOD="$BIRTHDAY_PERIOD
	    ;;
	w)
	    CHUNK_LOSS_PERIOD="${OPTARG}"
	    echo "CHUNK_LOSS_PERIOD="$CHUNK_LOSS_PERIOD
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

set -x

rm -f *.dt

SPLITTER="../src/splitter.py \
--buffer_size=$BUFFER_SIZE \
--chnnel=$CHANNEL \
--chunk_size=$CHUNK_SIZE \
--heder_size=$HEADER_SIZE \
--mx_chunk_loss=$MAX_CHUNK_LOSS \
$MCAST \
--mcst_ddr=$MCAST_ADDR \
--port=$SPLITTER_PORT \
--source_ddr=$SOURCE_ADDR \
--source_port=$SOURCE_PORT"

echo $SPLITTER

#xterm -sl 10000 -e $SPLITTER &
xterm -sl 10000 -e "$SPLITTER | tee splitter.dt" &

sleep 1

PEER="../src/peer.py \
--mx_chunk_debt=$MAX_CHUNK_DEBT \
--plyer_port=9999 \
--splitter_ddr=$SPLITTER_ADDR \
--splitter_port=$SPLITTER_PORT"
# \
#--tem_port=$TEAM_PORT"

echo $PEER

#xterm -sl 10000 -e $PEER &
xterm -T "Monitor" -sl 10000 -e "$PEER | tee monitor.dt" &

vlc http://loclhost:9999 > /dev/null 2> /dev/null &

sleep 1

PEER="../src/peer.py \
--mx_chunk_debt=$MAX_CHUNK_DEBT \
--plyer_port=9998 \
--splitter_ddr=$SPLITTER_ADDR \
--splitter_port=$SPLITTER_PORT"
# \
#--tem_port=$TEAM_PORT"

echo $PEER

#xterm -sl 10000 -e $PEER &
xterm -sl 10000 -e "$PEER | tee peer.dt" &

vlc http://loclhost:9998 > /dev/null 2> /dev/null &

x=1
while [ $x -le $ITERATIONS ]
do
    sleep $BIRTHDAY_PERIOD

    ./ply.sh - $SPLITTER_ADDR -p $SPLITTER_PORT &

    x=$(( $x + 1 ))
done

sleep 1000

set +x
