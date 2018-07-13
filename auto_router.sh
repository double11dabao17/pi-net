#!/bin/bash

CONFIG_PATH=`pwd`/routing
NET_CF_PATH=/etc/network/interfaces
SS_PATH=`pwd`/ssclient
KCP_PATH=`pwd`/kcp

RED='\033[0;31m'

NC='\033[0m'

config_eth() {
	echo -e "${RED}Backup origin network config into /etc/network/if.backup${NC}"
	cp $NET_CF_PATH /etc/network/if.backup
	cp $CONFIG_PATH/interfaces $NET_CF_PATH
}


config_routing() {
	echo -e "${RED}Config routing as a systemd service, called routing.service${NC}"
	mkdir -p /etc/routing
	cp $CONFIG_PATH/routing.sh /etc/routing/
	cp $CONFIG_PATH/routing.service /etc/systemd/system/
}

start_routing() {
	echo -e "${RED}Enable and start routing.service${NC}"
	systemctl enable routing.service
	systemctl start routing.service
#	systemctl status routing.service

	iptables -L -nv
}

start_client() {
	echo -e "${RED}Staring router client${NC}"
	`pwd`/router-control start
}

config_ss_kcp() {
	cp $KCP_PATH/config-1080.json.bk $KCP_PATH/config-1080.json
	cp $SS_PATH/shadowsocks-1080.json.bk $SS_PATH/shadowsocks-1080.json
	sed -i -e "s/R_NAME/$1/g" $KCP_PATH/config-1080.json
	sed -i -e "s/R_PORT/$2/g" $KCP_PATH/config-1080.json
	sed -i -e "s/R_NAME/$1/g" $SS_PATH/shadowsocks-1080.json
}

restore_ss_kcp_config() {
	rm $KCP_PATH/config-1080.json
	rm $SS_PATH/shadowsocks-1080.json
}

stop_client() {
	echo -e "${RED}Stop router client${NC}"
	`pwd`/router-control stop
}

restore_eth_config() {
	cp /etc/network/if.backup $NET_CF_PATH
	rm /etc/network/if.backup
}

restore_routing_config() {
	rm /etc/systemd/system/routing.service
	rm -rf /etc/routing
}
stop_routing() {
	echo -e "${RED}Stop and disable routing.service${NC}"
	systemctl disable routing.service
	systemctl stop routing.service
	systemctl status routing.service

	iptables -L -nv
}


uninstall() {
	stop_routing
#	stop_client
	restore_routing_config
	restore_eth_config
#	restore_ss_kcp_config
#	reboot
}


install() {
	./pppoe_router.sh uninstall

	sed -i '/^ifconfig/s/^/#/g' rc.sh
#	config_ss_kcp $1 $2
	config_eth
	config_routing
	start_routing
#	start_client
	reboot
}

status() {
	echo -e "${RED}interfaces${NC}"
	ifconfig
	echo -e "${RED}routing${NC}"
	iptables -L -nv
	systemctl status routing.service
	echo -e "${RED}client${NC}"
#	`pwd`/router-control status
}

case "$1" in
  install|k)
    install
    ;;

  uninstall|g)
    uninstall
    ;;

  status)
    status
    ;;
  *)
    echo $"Usage: $0 {install | uninstall | status}"
    exit 1

esac
