xterm -T "Splitter" -e "../src/splitter.py --buffer_size 20 --diagram" &

sleep 1

xterm -T "P1" -e "python -d ../src/peer.py --diagram P1.dat --player_port 9999" &
sleep 1
xterm -T "Player1" -e "nc 127.0.0.1 9999 > /dev/null" &
p1=$!

sleep 2

xterm -T "P2" -e "python -d ../src/peer.py --diagram P2.dat --player_port 9998" &
sleep 1
xterm -T "Player2" -e "nc 127.0.0.1 9998 > /dev/null" &
p2=$!

sleep 2

xterm -T "P3" -e "python -d ../src/peer.py --diagram P3.dat --player_port 9997" &
sleep 1
xterm -T "Player3" -e "nc 127.0.0.1 9997 > /dev/null" &
p3=$!

sleep 2

xterm -T "P4" -e "python -d ../src/peer.py --diagram P4.dat --player_port 9996" &
sleep 1
xterm -T "Player4" -e "nc 127.0.0.1 9996 > /dev/null" &
p4=$!

sleep 2

xterm -T "P5" -e "python -d ../src/peer.py --diagram P5.dat --player_port 9995" &
sleep 1
xterm -T "Player5" -e "nc 127.0.0.1 9995 > /dev/null" &
p5=$!

sleep 10

echo $p1
kill -9 $p1
sleep 2
echo $p2
kill -9 $p2
sleep 2
kill -9 $p3
sleep 2
kill -9 $p4
sleep 2
kill -9 $p5
