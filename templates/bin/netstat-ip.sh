#!/bin/bash
#
# Syntaxe de netstat-ip, script MRTG
#
# ./netstat [nom connexion] [interface]
#    ou
# ./netstat [nom connexion] ip [adresse ip]
#

grep="/bin/grep"
cut="/usr/bin/cut"
uptime="/usr/bin/uptime"
devsta="/proc/net/dev"
route="/sbin/route"
# netstat name interface
name=$1
interface=$2
if [ "$2" = "ip" ]
then
  interface=`$route -n | grep -w "$3" | grep -w "0.0.0.0." | cut -c73-76`
fi
if [ -n "$interface" ]
then
  line=`/bin/cat $devsta | sed s/" "*// | $grep "$interface" | $cut -d":" -f 2`
  ibytes=`echo $line | $cut -d" " -f 1`
  obytes=`echo $line | $cut -d" " -f 9`
else
  ibytes=0
  obytes=0
fi
uptim=`$uptime | $cut -d"," -f1`
uptim=`echo $uptim | $cut -d" " -f3,4`
echo $ibytes
echo $obytes
echo $uptim
echo $name
