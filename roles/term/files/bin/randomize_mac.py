#!/usr/bin/python
import os
import subprocess
import random
import sys

class mac_changer(object):
    """ an interface to change the mac address of a NIC """

    def __init__(self):
        if os.geteuid():
            exit("Not running as root, exiting")

    def change_mac(self, interface):
        rc = 1

        if not self.check_interface(interface):
            rc = self.randomize_interface(interface)

        return rc

    def check_interface(self, interface):
        """ make sure the interface we are looking for exists """

        command = "ifconfig %s > /dev/null" % interface
        return subprocess.call(command, shell=True)

    def get_rand_mac(self):
        """
            Returns a random 48-bit MAC addr
            in the form 'AA:BB:CC:DD:EE:FF'
        """
        random_mac = []

        # add manufacturer
        random_mac.append(self.get_rand_manufact())

        # generate the last 24 bits of the random hex
        for i in range(0, 3):
            rand_digit1 = self.get_rand_hex_digit()
            rand_digit2 = self.get_rand_hex_digit()
            random_mac.append(rand_digit1 + rand_digit2)

        return ':'.join(random_mac)

    def get_rand_manufact(self):
        manufacts = [
            '00:03:7F',
            '00:00:09',
            '00:40:96',
            '00:30:BD',
            '00:40:DC',
            '00:1B:2F'
        ]

        return manufacts[random.randint(0, len(manufacts) - 1)]

    def get_rand_hex_digit(self):
        return str(hex(random.randint(0, 15)))[2:]

    def randomize_interface(self, interface):
        """
            Generates a random MAC addr and changes the interface
            the random MAC
        """
        mac = self.get_rand_mac()
        command = "ifconfig %s hw ether %s" % (interface, mac)

        subprocess.call("ifconfig %s down" % interface, shell=True)
        rc = subprocess.call(command, shell=True)
        subprocess.call("ifconfig %s up" % interface, shell=True)

        return rc


if __name__ == "__main__":
    if len(sys.argv) > 1:
        interfaces = sys.argv[1].split(",")
        m = mac_changer()

        for interface in interfaces:
            output = m.change_mac(interface)
    else:
        sys.exit("usage: randomize_mac.py iface,iface,iface")
