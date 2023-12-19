#!/bin/bash
# /data/dbus-virtual/manipulator.sh

SoC=50

# Set up vitual CANBus Interface:
#/sbin/modprobe vcan
#/sbin/ip link add dev vcan0 type vcan
#/sbin/ip link set up vcan0

# Config file with BMS Settings
sysconfdir="/data/dbus-virtualbms"
if test -f ${sysconfdir}/config.ini ; then
  . ${sysconfdir}/config.ini
fi


REPLACE_BYTES () {
    LEFT=`echo $DATA|cut -b0-$FIRST`
    RIGHT=`echo $DATA|cut -b$LAST-`
    DATEN=$LEFT$VALUE$RIGHT
}

DEC2HEX () {
  HEX=`printf '%x\n' $DEC_VALUE`
  ANZAHL=`echo $HEX|wc -L`

  if [ $ANZAHL = 1 ]; then
    LINKS=`echo 00`
    RECHTS=`echo $HEX|cut -b1-2`
    HEX_VALUE=`echo "0$RECHTS""$LINKS"`
  fi

  if [ $ANZAHL = 2 ]; then
    LINKS=`echo 00`
    RECHTS=`echo $HEX|cut -b1-2`
    HEX_VALUE=`echo "$RECHTS""$LINKS"`
  fi

  if [ $ANZAHL = 3 ]; then
    RECHTS=`echo $HEX|cut -b2-3`
    LINKS=`echo $HEX|cut -b1`
    HEX_VALUE=`echo "$RECHTS"0"$LINKS"`
  fi

  if [ $ANZAHL = 4 ]; then
    RECHTS=`echo $HEX|cut -b3-4`
    LINKS=`echo $HEX|cut -b1-2`
    HEX_VALUE=`echo "$RECHTS""$LINKS"`
  fi
}

#Dump the present CAN-Interface
candump $INTERFACE|
while read line
do
  . ${sysconfdir}/config.ini

  DEC_VALUE=$MAX_VOLTAGE
  DEC2HEX
  VOLTAGE=$HEX_VALUE

  DEC_VALUE=$UPPER_CURRENT
  DEC2HEX
  CURRENT=$HEX_VALUE


  ID=`echo $line|cut -b6-8`
  DATEN=`echo $line|cut -b5-|tr -d " "|sed 's/\[8\]/#/g'` 

  if [ $ID = 355 ]; then
    SoC=$((16#`echo $line|cut -b14-15`))

#echo $((0x${hexNum}))

#    echo $SoC
#      if [ $SoC -ge 75 ]; then
#        echo "Ist goss!" 
#      fi

  fi





  if [ $ID = 351 ]; then
    ORIGINAL=`echo $DATEN|sed "s/4002/$VOLTAGE/g"` 
    ORIGINAL=`echo $ORIGINAL|sed "s/9E07/$CURRENT/"` 

    VALUE=$VOLTAGE
    DATA=$DATEN
    FIRST=4
    LAST=9
    REPLACE_BYTES


#      	DATEN=`echo $DATEN|grep 351|sed 's/4002/2802/g'` 
#    DATA=`echo $DATEN|sed "s/4002/$VOLTAGE/g"` 
#    DATEN=`echo $DATEN|sed "s/4002/$VOLTAGE/g"` 

      if [ $SoC -ge 75 ]; then
        VALUE=$CURRENT
        DATA=$DATEN
        FIRST=8
        LAST=13
        REPLACE_BYTES

#        DATEN=`echo $DATEN|sed "s/9E07/$CURRENT/"` 
#        echo "Ist goss!"
      fi



    echo "Neu     : $DATEN"
    echo "Original: $ORIGINAL"

    cansend vcan0 $DATEN 
  else
#    echo $DATEN
    cansend vcan0 $DATEN 
  fi

done


