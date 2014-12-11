#!/bin/sh

#Crear fichero con la mezcla de todos los peers
echo -n "Enter file name: "
read filename
cat $filename | cut -f 2 | grep "note over"


