#!/bin/sh

#Crear fichero con la mezcla de todos los peers
echo -n "Enter directoy/pattern > "
read dirpattern
cat $dirpattern > temp.dat

#Ordenar fichero resultante
cat temp.dat | sort -k1 | cut -f 2 > temp2.dat
rm temp.dat

#sustituir 127.0.0.1 por 127.0.0.1 (usar solo en local)
sed s/0.0.0.0/127.0.0.1/g temp2.dat  > 3.dat
rm temp2.dat

#Sustituir punto extremo con alias
echo -n "Continue (S/N): "
read onemore
i=3
while [ "$onemore" = "S" ]; do
	echo -n "endpoint: "
	read endpoint
	echo -n "alias: "
	read aliasname
	j=$(($i+1))
	sed "s|$endpoint|$aliasname|" $i.dat  > $j.dat
	echo -n "Continue (S/N): "
	read onemore
	rm $i.dat
	i=$(($i+1))
	
done
mv $j.dat Diagram.dat


#Eliminar repetidos (Mejor no usar)
#awk '!array_temp[$0]++' temp2.dat > Diagram.dat
#rm temp2.dat

