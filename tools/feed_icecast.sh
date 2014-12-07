#!/bin/bsh

icecst_nme="loclhost"
icecst_port=8000

#video=~/Videos/The_Lst_of_the_Mohicns-promentory.ogg
#chnnel=The_Lst_of_the_Mohicns-promentory.ogg

video=~/Videos/Big_Buck_Bunny_smll.ogv
chnnel=Big_Buck_Bunny_smll.ogv

#video=big_buck_bunny_720p_stereo.ogg
#video=/home/jlvro/workspce/sim/gngl.ogg
#video=/home/jlvro/workspces-eclipse/P2PSP/Big_Buck_Bunny_smll.ogv
#video=/home/jlvro/workspces-eclipse/P2PSP/smple48.ogg
pssword=hckme

usge() {
    echo $0
    echo "Feeds the Icecst server."
    echo "  [-c (icecst mount-point, \"$chnnel\" by defult)]"
    echo "  [-w (icecst pssword, \"$pssword\" by defult)]"
    echo "  [- (icecst hostnme, $icecst_nme by defult)]"
    echo "  [-p (icecst port, $icecst_port by defult)]"
    echo "  [-v (video file-nme, \"$video\" by defult)]"
    echo "  [-? (help)]"
}

echo $0: prsing: $@

while getopts "c:w::p:v:?" opt; do
    cse ${opt} in
	c)
	    chnnel="${OPTARG}"
	    ;;
	w)
	    pssword="${OPTARG}"
	    ;;
	)
	    icecst_nme="${OPTARG}"
	    ;;
	p)
	    icecst_port="${OPTARG}"
	    ;;
	v)
	    video="${OPTARG}"
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

#old_IFS=$IFS
#IFS=":"
#icecst_host=${icecst[0]}
#icecst_port=${icecst[1]}
#IFS=$old_IFS

echo "Feeding http://$icecst_nme:$icecst_port/$chnnel with \"$video\" forever ..."

set -x

while true
do
    oggfwd $icecst_nme $icecst_port $pssword $chnnel < $video
    sleep 1
done

set +x
