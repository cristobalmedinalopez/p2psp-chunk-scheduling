# This code is distributed under the GNU General Public License (see
# THE_GENERAL_GNU_PUBLIC_LICENSE.txt for extending this information).
# Copyright (C) 2014, the P2PSP team.
# http://www.p2psp.org

# {{{

from __future__ import print_function
import threading
import sys
import socket
import struct
from color import Color
import common
import time
from datetime import datetime
from _print_ import _print_
from peer_ims import Peer_IMS

# }}}

# Some useful definitions.
ADDR = 0
PORT = 1

# DBS: Data Broadcasting Set of rules
class Peer_DBS(Peer_IMS):
    # {{{

    # {{{ Class "constants"

    MAX_CHUNK_DEBT = 32

    # }}}

    def __init__(self, peer):
        # {{{

        sys.stdout.write(Color.yellow)
        _print_("Peer DBS (list)")
        sys.stdout.write(Color.none)

        threading.Thread.__init__(self)

        self.splitter_socket = peer.splitter_socket
        self.player_socket = peer.player_socket
        self.buffer_size = peer.buffer_size
        #self.chunk_format_string = peer.message_format
        self.splitter = peer.splitter
        self.chunk_size = peer.chunk_size
        self.message_format = peer.message_format
        #self.extended_message_format = peer.message_format + "4sH"
        self.peer_list_sent = []
        self.pts = 0
        self.ts = 1
        self.first_time=True
        _print_("max_chunk_debt =", self.MAX_CHUNK_DEBT)

        # }}}

    def say_hello(self, node):
        # {{{

        self.team_socket.sendto('H', node)

        # }}}

    def say_goodbye(self, node):
        # {{{

        self.team_socket.sendto('G', node)

        # }}}

    def receive_the_number_of_peers(self):
        # {{{

        self.debt = {}      # Chunks debts per peer.
        self.peer_list = [] # The list of peers structure.

        sys.stdout.write(Color.green)
        _print_("Requesting the number of peers to", self.splitter_socket.getpeername())
        self.number_of_peers = socket.ntohs(struct.unpack("H",self.splitter_socket.recv(struct.calcsize("H")))[0])
        _print_("The size of the team is", self.number_of_peers, "(apart from me)")

        sys.stdout.write(Color.none)

        # }}}
    def receive_the_list_of_peers(self):
        # {{{

        self.debt = {}      # Chunks debts per peer.
        self.peer_list = [] # The list of peers structure.

        sys.stdout.write(Color.green)
        _print_("Requesting", self.number_of_peers, "peers to", self.splitter_socket.getpeername())
        #number_of_peers = socket.ntohs(struct.unpack("H",self.splitter_socket.recv(struct.calcsize("H")))[0])
        #_print_("The size of the team is", number_of_peers, "(apart from me)")

        tmp = self.number_of_peers
        while tmp > 0:
            message = self.splitter_socket.recv(struct.calcsize("4sH"))
            IP_addr, port = struct.unpack("4sH", message) # Ojo, !H ????
            IP_addr = socket.inet_ntoa(IP_addr)
            port = socket.ntohs(port)
            peer = (IP_addr, port)
            print("[hello] sent to", peer)
            self.say_hello(peer)
            if __debug__:
                _print_("[%5d]" % tmp, peer)
            else:
                _print_("{:.2%}\r".format((self.number_of_peers-tmp)/self.number_of_peers), end='')

            self.peer_list.append(peer)
            self.debt[peer] = 0
            tmp -= 1
        self.first_time = True
        _print_("List of peers received")
        sys.stdout.write(Color.none)

        # }}}

    def receive_my_endpoint(self):
        # {{{

        message = self.splitter_socket.recv(struct.calcsize("4sH"))
        IP_addr, port = struct.unpack("4sH", message) # Ojo, !H ????
        IP_addr = socket.inet_ntoa(IP_addr)
        port = socket.ntohs(port)
        self.me = (IP_addr, port)
        _print_("me =", self.me)

        # }}}

    def listen_to_the_team(self):
        # {{{ Create "team_socket" (UDP) as a copy of "splitter_socket" (TCP)

        self.team_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            # In Windows systems this call doesn't work!
            self.team_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        except Exception, e:
            print (e)
            pass
        self.team_socket.bind(('', self.splitter_socket.getsockname()[PORT]))

        # This is the maximum time the peer will wait for a chunk
        # (from the splitter or from another peer).
        self.team_socket.settimeout(1)

        # }}}

    def process_next_message(self):
        # {{{ Now, receive and send.

        try:
            # {{{ Receive and send

            message, sender = self.receive_the_next_message()

            if len(message) == struct.calcsize(self.message_format):
                # {{{ A videoself.receive_and_feed_counter chunk has been received

                chunk_number, chunk = self.unpack_message(message)
                self.chunks[chunk_number % self.buffer_size] = chunk
                self.received[chunk_number % self.buffer_size] = True

                if sender == self.splitter:
                    # {{{ Send the previous chunk in burst sending
                    # mode if the chunk has not been sent to all
                    # the peers of the list of peers.

                    # {{{ debug

                    if __debug__:
                        _print_(self.team_socket.getsockname(), \
                            Color.red, "<-", Color.none, chunk_number, "-", sender)

                        if Peer_IMS.DIAGRAM != "":
                            self.ts = datetime.now()
                            ts= repr(time.time())
                            s = str(ts) + "\t" + str(sender) + " -> " + str(self.team_socket.getsockname()) + " : " + str(chunk_number)+'\n'
                            Peer_IMS.DIAGRAM_FILE.write(s)

                    # }}}
                    self.receive_and_feed_counter = 0
                    if ((len(self.peer_list)-len(self.peer_list_sent)) > 1 and len(self.peer_list_sent)>0):
                        ts = repr(time.time())
                        s = str(ts) + "\t note left of " + str(self.team_socket.getsockname()) + " : BURST "+str(len(self.peer_list)-len(self.peer_list_sent))+"\n"
                        Peer_IMS.DIAGRAM_FILE.write(s)

                    while (((len(self.peer_list_sent) < len(self.peer_list)) and (self.receive_and_feed_previous!='') and len(self.peer_list_sent)>0) or (self.first_time == True and (self.receive_and_feed_previous!=''))):
                        self.first_time = False
                        peer = self.peer_list[self.receive_and_feed_counter]
                        if peer not in self.peer_list_sent:
                            self.team_socket.sendto(self.receive_and_feed_previous, peer)
                            self.sendto_counter += 1
                            self.peer_list_sent.append(peer)
                            # {{{ debug

                            if __debug__:
                                print (self.team_socket.getsockname(), "-",\
                                    socket.ntohs(struct.unpack(self.message_format, self.receive_and_feed_previous)[0]),\
                                    Color.green, "->", Color.none, peer)

                                if Peer_IMS.DIAGRAM != "":
                                    ts = repr(time.time())
                                    s = str(ts) + "\t" + str(self.team_socket.getsockname())+ " --> "+str(peer)+ " : "+ str(socket.ntohs(struct.unpack(self.message_format, self.receive_and_feed_previous)[0]))+'\n'
                                    Peer_IMS.DIAGRAM_FILE.write(s)
                            # }}}

                            self.debt[peer] += 1
                            if self.debt[peer] > self.MAX_CHUNK_DEBT:
                                del self.debt[peer]
                                self.peer_list.remove(peer)
                                print (Color.red, peer, 'removed by unsupportive', Color.none)

                        self.receive_and_feed_counter += 1

                    self.receive_and_feed_counter = 0
                    self.peer_list_sent = []
                    self.receive_and_feed_previous = message

                   # }}}
                else:
                    # {{{ The sender is a peer

                    # {{{ debug

                    if __debug__:
                        print (self.team_socket.getsockname(), \
                            Color.green, "<-", Color.none, chunk_number, "-", sender)

                        if Peer_IMS.DIAGRAM != "":
                            ts = repr(time.time())
                            s = str(ts) + "\t" +str(sender)+ " -> "+ str(self.team_socket.getsockname())+" : "+str(chunk_number)+'\n'
                            Peer_IMS.DIAGRAM_FILE.write(s)
                    # }}}

                    if sender not in self.peer_list:
                        # The peer is new
                        self.peer_list.append(sender)
                        self.debt[sender] = 0
                        print (Color.green, sender, 'added by chunk', \
                            chunk_number, Color.none)
                    else:
                        self.debt[sender] -= 1

                    # }}}

                # {{{ A new chunk has arrived and the
                # previous must be forwarded to next peer of the
                # list of peers.
                if ( self.receive_and_feed_previous != '' and sender not in self.peer_list_sent):
                    # {{{ Send the previous chunk in congestion avoiding mode.
                    if sender != self.splitter:
                        peer = sender
                        self.team_socket.sendto(self.receive_and_feed_previous, peer)
                        self.sendto_counter += 1
                        self.peer_list_sent.append(peer)
                        self.debt[peer] += 1

                        if self.debt[peer] > self.MAX_CHUNK_DEBT:
                            del self.debt[peer]
                            self.peer_list.remove(peer)
                            print (Color.red, peer, 'removed by unsupportive', Color.none)

                        # {{{ debug

                        if __debug__:
                            print (self.team_socket.getsockname(), "-", \
                                socket.ntohs(struct.unpack(self.message_format, self.receive_and_feed_previous)[0]),\
                                Color.green, "->", Color.none, peer)

                            if Peer_IMS.DIAGRAM != "":
                                ts = repr(time.time())
                                s = str(ts) + "\t" + str(self.team_socket.getsockname())+ " --> "+str(peer)+ " : "+\
                                     str(socket.ntohs(struct.unpack(self.message_format, self.receive_and_feed_previous)[0]))+'\n'
                                Peer_IMS.DIAGRAM_FILE.write(s)
                        # }}}

                        self.receive_and_feed_counter += 1

                    # }}}
                # }}}

                return chunk_number

                # }}}
            else:
                # {{{ A control chunk has been received
                print("Control received")
                if message == 'H':
                    if sender not in self.peer_list:
                        # The peer is new
                        self.peer_list.append(sender)
                        self.debt[sender] = 0
                        print (Color.green, sender, 'added by [hello]', Color.none)
                else:
                    if sender in self.peer_list:
                        sys.stdout.write(Color.red)
                        print (self.team_socket.getsockname(), '\b: received "goodbye" from', sender)
                        sys.stdout.write(Color.none)
                        self.peer_list.remove(sender)
                        del self.debt[sender]
                return -1

                # }}}

            # }}}
        except socket.timeout:
            return -2

        # }}}

    def keep_the_buffer_full(self):
        # {{{

        Peer_IMS.keep_the_buffer_full(self)
        if (self.played_chunk % self.debt_memory) == 0:
            for i in self.debt:
                self.debt[i] /= 2

        if __debug__:
            sys.stdout.write(Color.cyan)
            print ("Number of peers in the team:", len(self.peer_list)+1)
            print (self.team_socket.getsockname(),)
            for p in self.peer_list:
                print (p,)
            print ()
            sys.stdout.write(Color.none)

        # }}}

    def polite_farewell(self):
        # {{{

        print('Goodbye!')
        for x in xrange(3):
            self.process_next_message()
            self.say_goodbye(self.splitter)
        for peer in self.peer_list:
            self.say_goodbye(peer)

        Peer_IMS.DIAGRAM_FILE.close()
        # }}}

    def buffer_data(self):
        # {{{

        # Number of times that the previous received chunk has been sent
        # to the team. If this counter is smaller than the number
        # of peers in the team, the previous chunk must be sent in the
        # burst mode because a new chunk from the splitter has arrived
        # and the previous received chunk has not been sent to all the
        # peers of the team. This can happen when one o more chunks
        # that were routed towards this peer have been lost.
        self.receive_and_feed_counter = 0

        # This "private and static" variable holds the previous chunk
        # received from the splitter. It is used to send the previous
        # received chunk in the congestion avoiding mode. In that
        # mode, the peer sends a chunk only when it received a chunk
        # from another peer or om the splitter.
        self.receive_and_feed_previous = ""

        self.sendto_counter = 0

        self.debt_memory = 1 << self.MAX_CHUNK_DEBT

        Peer_IMS.buffer_data(self)

        # }}}

    def run(self):
        # {{{

        Peer_IMS.peers_life(self)
        self.polite_farewell()

        # }}}

    def am_i_a_monitor(self):
        # {{{
        print ("---------------------> number_of_peers =", self.number_of_peers)
        if self.number_of_peers == 0:
            # Only the first peer of the team is the monitor peer
            return True
        else:
            return False
        #message = self.splitter_socket.recv(struct.calcsize("c"))
        #if struct.unpack("c", message)[0] == '1':
        #    return True
        #else:
        #    return False

        # }}}

    # }}}
