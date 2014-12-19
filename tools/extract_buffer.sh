#!/bin/sh

filename = "P1.dat"

usage() {
    echo $0
    echo "Extract Buffer"
    echo "  [-f (File, \"$filename\" by default)]"
    echo "  [-? (help)]"
}

echo $0: parsing: $@

while getopts "f:?" opt; do
    case ${opt} in
	f)
	    filename="${OPTARG}"
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

#Crear fichero con la mezcla de todos los peers
#echo -n "Enter file name: "
#read filename
cat $filename | cut -f 2 | grep "note over"


