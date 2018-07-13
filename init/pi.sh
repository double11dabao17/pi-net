#!/bin/bash

apt update || exit
echo apt is ok

echo "* * * * * /root/pi-net/pingss.sh" | crontab -

# init
rm ../noipddns.sh ../ss/ss.json ../kcp/ss.json ../kcp/kcp.json ../../*.tar
cp rc.sh ../

# too many file
cat << EOF >>/etc/security/limits.conf
*               soft    nofile           102400
*               hard    nofile          102400
root               soft    nofile           102400
root               hard    nofile          102400
EOF
sudo bash -c 'echo "fs.file-max=102400" >> /etc/sysctl.conf'
echo -e "session required\tpam_limits.so">> /etc/pam.d/common-session

# fix ax88179_178a 3-1:1.0 eth1: kevent 2 may have been dropped
sudo bash -c 'echo "vm.min_free_kbytes=32768" >> /etc/sysctl.conf'
sudo bash -c 'echo "vm.vfs_cache_pressure=300" >> /etc/sysctl.conf'

# 开启bbr,提高差网络环境下的网速
sudo bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
sudo bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
# 使配置生效
sysctl -p
# 显示bbr cubic reno
lsmod | grep bbr

cp dnsmasq.conf rc.local hostapd.conf /etc
cp -r dnsmasq.d /etc

cp 73-usb-net-by-mac.rules /lib/udev/rules.d

cd ssbin && cp ss-* client_linux_arm7 /usr/bin

systemctl disable apt-daily
sed -i 's/1/0/g' /etc/apt/apt.conf.d/20auto-upgrades
sed -i "s/nobody')/root')/g" /usr/lib/python3.5/http/server.py

timedatectl set-timezone Asia/Shanghai #设置时区
mv /lib/systemd/system/wpa_supplicant.service  /lib/systemd/system/wpa_supplicant.service.bak #取消Wi-Fi连接

#设置网卡启动时间最多15s
mkdir /etc/systemd/system/networking.service.d/
cat << EOF > /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=5
EOF

apt update && apt-get install -y tcpdump denyhosts ipset iftop pppoeconf shellinabox libev-dev libmbedtls-dev libsodium-dev

cat << 'EOF' > /etc/default/shellinabox
# Should shellinaboxd start automatically
SHELLINABOX_DAEMON_START=1
SHELLINABOX_PORT=90
SHELLINABOX_ARGS="--no-beep -t --service=/:SSH:127.0.0.1"
EOF

# Denyhosts ingore local ip
echo "ALL:127.0.0.1/8" >> /etc/hosts.allow
echo "ALL:10.0.0.1/24" >> /etc/hosts.allow

cd /root/pi-net/ && ./auto_router.sh install
