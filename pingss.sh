#!/bin/bash
# 测试ss 丢包和延迟
#pgrep ss-redir > /dev/null && \
#echo $(date +"%m%d %H:%M")" "$(ping  -q -n -c 5 $(iptables -S -t nat | awk -F '[ /]'  '/BYPASS -d/{print $4;exit}') | tr '\n' ' ' | awk -F '[ /]' '{printf "%s %d %d",$10,$19,$31}') >> /var/log/pingss.log
#pgrep ss-redir > /dev/null && ping  -q -n -c 5 $(/sbin/iptables -S -t nat | awk -F '[ /]'  '/BYPASS -d/{print $4;exit}') | tr '\n' ' ' | awk -F '[ /]' 'BEGIN{system("date +\"%m%d %H:%M\"")};{printf "%s %d %d",$10,$19,$31}' | xargs >> /var/log/pingss.log
pgrep ss-redir > /dev/null && ping  -q -n -c 5 $( cat /root/pi-net/bypass/white/02-vps ) | tr '\n' ' ' | awk -F '[ /]' 'BEGIN{system("date +\"%m%d %H:%M\"")};{printf "%s %d %d",$10,$19,$31}' | xargs >> /var/log/pingss.log
