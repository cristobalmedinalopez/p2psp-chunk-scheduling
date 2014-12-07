#!/bin/sh

#Crear fichero con la mezcla de todos los peers
echo -n "Enter directoy/pattern > "
read dirpattern
cat $dirpattern > temp.dat

#Ordenar fichero resultante
cat temp.dat | sort -k1 | cut -f 2 > temp2.dat
rm temp.dat

#Sustituir punto extremo con alias
echo -n "Continue (S/N): "
read onemore
while [ "$onemore" = "S" ]; do
	echo -n "endpoint: "
	read endpoint
	echo -n "alias: "
	read aliasname
	cat temp2.dat | grep -lr -e "$endpoint" * | xargs sed -i "s/$endpoint/$aliasname/g"
	echo -n "Continue (S/N): "
	read onemore
done

#Eliminar repetidos
awk '!array_temp[$0]++' temp2.dat > Diagram.dat
rm temp2.dat

