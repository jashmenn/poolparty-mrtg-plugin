#!/bin/bash
#
# Script MRTG - David Du SERRE-TELMON (daviddst@netcourrier.com)
# Indique le nombre de connexions TCP actives avec Netfilter
#
# Syntaxe : 
#
# ./tcpcount
#   => Nombre de connexions tcp totales traversant la passerelle
# ./tcpcount 21
#   => Nombre de connexions FTP
# ./tcpcount 80 dst www.linux-sottises.net
#    => Nombre de connexion web vers le serveur web www.linux-sottises.net
# ./tcpcount 1214 src 192.168.0.2
#   => Nombre de connexions Kazaa pour l'utilisateur 192.168.0.2

netstat="/bin/netstat"
grep="/bin/grep"
sed="/bin/sed"
wc="/usr/bin/wc"
cat="/bin/cat"
printf="/usr/bin/printf"
host="/usr/bin/host"
port=$1
filter="$2"
ip="$3"

ip_conntrack=`$cat /proc/net/ip_conntrack | $grep ESTABLISHED`

if [ -n "$port" ]
then
  if [ "$filter" = src ] || [ "$filter" = dst ]
  then
    ip=`$host "$3" | grep "has address" | cut -d" " -f4`
    res=`$printf "$ip_conntrack" | $grep "dport=$port " | $grep "$filter=$ip" | $wc -l | $sed s/" "//g`
  else
    res=`$printf "$ip_conntrack" | grep "dport=$port " | $wc -l | $sed s/" "//g`
  fi
else
  res=`$printf "$ip_conntrack" | $wc -l | $sed s/" "//g`
fi
printf "$res\n$res\n"

