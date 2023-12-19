#!/bin/bash
# /data/fakemeter/manipulator.sh

/sbin/modprobe vcan
/sbin/ip link add dev vcan0 type vcan
/sbin/ip link set up vcan0


#!/bin/bash
sysconfdir="/data/dbus-fakebms"
#…
if test -f ${sysconfdir}/config.ini ; then
  . ${sysconfdir}/config.ini
fi

candump can8|
while read line
do

HEX=`printf '%x\n' $MAX_SPANNUNG`
ANZAHL=`echo $HEX|wc -L`

if [ $ANZAHL = 3 ]; then
  RECHTS=`echo $HEX|cut -b2-3`
  LINKS=`echo $HEX|cut -b1`
  SPANNUNG=`echo "$RECHTS"0"$LINKS"`
else
  RECHTS=`echo $HEX|cut -b3-4`
  LINKS=`echo $HEX|cut -b1-2`
  SPANNUNG=`echo "$RECHTS""$LINKS"`
fi


   ID=`echo $line|cut -b6-8`
   DATEN=`echo $line|cut -b5-|tr -d " "|sed 's/\[8\]/#/g'` 
   if [ $ID = 351 ]; then
#      	DATEN=`echo $DATEN|grep 351|sed 's/4002/2802/g'` 
      	DATEN=`echo $DATEN|grep 351|sed 's/4002/$SPANNUNG/g'` 
	#echo $DATEN
      	cansend vcan0 $DATEN 
   else
#	echo $DATEN
     	cansend vcan0 $DATEN 
   fi

done


