#!/bin/bash


#LAN=eth0
LAN=br0

WAN=ppp1

START() {
	bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
	iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
	iptables -A POSTROUTING -t nat -o $WAN -j MASQUERADE
	iptables -A FORWARD -i $WAN -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT
	iptables -t nat -L -vn
	iptables -L -nv
}

STOP() {
	bash -c 'echo 0 > /proc/sys/net/ipv4/ip_forward'
	iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
	iptables -D POSTROUTING -t nat -o $WAN -j MASQUERADE
	iptables -D FORWARD -i $WAN -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -D FORWARD -i $LAN -o $WAN -j ACCEPT
	iptables -t nat -L -vn
	iptables -L -nv
}

case "$1" in
  start)
    START
    ;;

  stop)
    STOP
    ;;

  *)
    echo $"Usage: $0 {\"start\"}"
    exit 1

esac
