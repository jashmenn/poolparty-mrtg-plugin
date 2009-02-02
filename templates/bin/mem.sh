#!/bin/sh

# Thierry Nkaoua tnkaoua@yahoo.fr

USED=`free -b|grep cache:|cut -d ":" -f2|cut -c1-11`
FREE=`free -b|grep cache:|cut -d ":" -f2|cut -c12-22`
echo $FREE
echo $USED




