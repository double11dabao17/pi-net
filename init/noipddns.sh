#!/bin/bash
#(crontab -l ; echo "*/5 * * * * /root/pi-net/noipddns.sh") | crontab -

# No-IP uses emails as usernames
USERNAME=xx
PASSWORD=xx
HOST=xx
LOGFILE=/var/log/noip.log
STOREDIPFILE=/var/log/current_ip

if [ ! -e $STOREDIPFILE ]; then
    touch $STOREDIPFILE
fi

NEWIP=$(ip route get 8.8.8.8 | awk '{print $NF;exit}')

STOREDIP=$(cat $STOREDIPFILE)

if [ -z "$NEWIP" ];then
    LOGLINE="[$(date +"%Y-%m-%d %H:%M:%S")] NoIP found"
    echo $LOGLINE >> $LOGFILE
    exit 1
fi

if [ "$NEWIP" != "$STOREDIP" ]; then
    RESULT=$(curl -s -u $USERNAME:$PASSWORD "https://dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$NEWIP")
    LOGLINE="[$(date +"%Y-%m-%d %H:%M:%S")] $RESULT"
    echo $NEWIP > $STOREDIPFILE
else
    LOGLINE="[$(date +"%Y-%m-%d %H:%M:%S")] Not change"
fi

echo $LOGLINE >> $LOGFILE

exit 0
