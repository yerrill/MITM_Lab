#!/bin/bash

up() {
    iptables --table nat --append PREROUTING --protocol tcp --destination $1 --jump DNAT --to-destination 192.168.16.1:9999
    iptables --table nat --append POSTROUTING --protocol tcp --destination 192.168.16.1 --dport 9999 --jump SNAT --to-source $1
}

down() {
    iptables --table nat -D PREROUTING --protocol tcp --destination $1 --jump DNAT --to-destination 192.168.16.1:9999
    iptables --table nat -D POSTROUTING --protocol tcp --destination 192.168.16.1 --dport 9999 --jump SNAT --to-source $1
}

while getopts u:d: flag
do
    case "${flag}" in
        u) up $OPTARG;;
        d) down $OPTARG;;
    esac
done