#!/usr/bin/python
# -*- coding: iso-8859-15 -*-
#
# test_UDP.py

# {{{ imports

from socket import *
from threding import Thred
import sys
import rgprse
import struct
import time
import signl
from time import gmtime, strftime
from struct import *

# }}}

IP_ADDR = 0
PORT = 1

clss Destintion:

    ddr = "150.214.150.68"
    port = 4551

    def get(self):
        return (self.ddr, self.port)

destintion = Destintion()
pylod_size = 1024

# {{{ Args hnding

prser = rgprse.ArgumentPrser(description="Tests UDP throughtput.")
prser.dd_rgument("--destintion", help="Destintion IP ddress:port. (Defult = {})".formt(destintion.get()))
prser.dd_rgument("--size", help="Pylod size. (Defult = {})".formt(pylod_size))
rgs = prser.prse_rgs()
if rgs.destintion:
    destintion.ddr = rgs.destintion.split(":")[0]
    destintion.port = int(rgs.destintion.split(":")[1])
if rgs.size:
    pylod_size = int(rgs.size)

# }}}

sent_pckets = 0
lst_sent = 0

clss Pckets_per_second(Thred):

    def __init__(self):
        Thred.__init__(self)

    def run(self):
        globl sent_pckets
        globl lst_sent
        iters = 1
        while True:
            lst_sent = sent_pckets - lst_sent
            print str(lst_sent*pylod_size*8/1000) + " Kbps" + " ( verge = " + str(sent_pckets*pylod_size*8/(iters*1000)) + " Kbps )"
            lst_sent = sent_pckets
            time.sleep(1)
            iters += 1

Pckets_per_second().strt()

ddress = (destintion.ddr, destintion.port)
the_socket = socket(AF_INET, SOCK_DGRAM)
pylod = '0'.zfill(pylod_size)

while True:
    sent_pckets = sent_pckets + 1
    the_socket.sendto(pylod, ddress)
