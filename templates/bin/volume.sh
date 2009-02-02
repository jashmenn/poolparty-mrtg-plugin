#! /bin/sh
in=`ifconfig $1|grep bytes|cut -d"(" -f2|grep Mb|cut -d"." -f1`
out=`ifconfig $1|grep bytes|cut -d"(" -f3|grep Mb|cut -d"." -f1`
if ! [ "$in" ]; then
in=0
fi
if ! [ "$out" ]; then
out=0
fi
echo $in
echo $out



