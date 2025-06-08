#!/bin/sh

DIR="/mtd_down/homebrew"
SCRIPT="$DIR/$(basename "$0")"

if [ ! -f "$SCRIPT" ]; then
    mkdir -p "$DIR"
    cp "$0" "$SCRIPT"
    echo "Payload copied to /mtd_down/homebrew"
fi

echo "████████╗██╗░░██╗░░░░░░██████╗░██╗░░░░░░░██╗███╗░░██╗"
echo "╚══██╔══╝╚██╗██╔╝░░░░░░██╔══██╗██║░░██╗░░██║████╗░██║"
echo "░░░██║░░░░╚███╔╝░█████╗██████╔╝╚██╗████╗██╔╝██╔██╗██║"
echo "░░░██║░░░░██╔██╗░╚════╝██╔═══╝░░████╔═████║░██║╚████║"
echo "░░░██║░░░██╔╝╚██╗░░░░░░██║░░░░░░╚██╔╝░╚██╔╝░██║░╚███║"
echo "░░░╚═╝░░░╚═╝░░╚═╝░░░░░░╚═╝░░░░░░░╚═╝░░░╚═╝░░╚═╝░░╚══╝"

sed -i s#^root:[^:]*:#root::# /etc/passwd
ifconfig eth0 192.168.1.108 netmask 255.255.255.0 up
route add default gw 192.168.1.100
telnetd
