#!/bin/bash
sysconfdir="/data/dbus-fakebms"
#…
if test -f ${sysconfdir}/config.ini ; then
  . ${sysconfdir}/config.ini
fi

HEX=`printf '%x\n' $MAX_SPANNUNG`
ANZAHL=`echo $HEX|wc -L`

if [ $ANZAHL = 3 ]; then
  RECHTS=`echo $HEX|cut -b2-3` 
  LINKS=`echo $HEX|cut -b1` 
  echo "$RECHTS"0"$LINKS"
else
  RECHTS=`echo $HEX|cut -b3-4` 
  LINKS=`echo $HEX|cut -b1-2` 
  echo "$RECHTS""$LINKS"
fi
