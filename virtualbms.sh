#!/bin/bash
# /data/dbus-virtualbms/virtualbms.sh

# Test if there is already a can8 adapter installed
if ! grep -q $INTERFACE /etc/network/interfaces
then
#    echo "$INTERFACE wird installiert..."
    echo "# CAN installed by Virtualbms" >>/etc/network/interfaces
    echo "auto $INTERFACE" >>/etc/network/interfaces
    echo "  iface $INTERFACE inet manual" >>/etc/network/interfaces
    echo "  pre-up /sbin/ip link set $INTERFACE type can bitrate 500000" >>/etc/network/interfaces
    echo "  up /sbin/ifconfig $INTERFACE up" >>/etc/network/interfaces
    echo "  down /sbin/ifconfig $INTERFACE down " >>/etc/network/interfaces
fi

ifdown $INTERFACE
sleep 2
/sbin/ifup $INTERFACE

SoC=50

# Set up vitual CANBus Interface:
if  [ ! -d "/proc/sys/net/ipv4/conf/vcan0" ]; then
  /sbin/modprobe vcan
  /sbin/ip link add dev vcan0 type vcan
  /sbin/ip link set up vcan0
fi

# Config file with BMS Settings
sysconfdir="/data/dbus-virtualbms"
if test -f ${sysconfdir}/config.ini ; then
  . ${sysconfdir}/config.ini
else
  echo "Error: Config file config.ini does not exist."
  exit 1
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

# Prepare data from config.ini file
  . ${sysconfdir}/config.ini


  DEC_VALUE=$MAX_VOLTAGE
  DEC2HEX
  VOLTAGE=$HEX_VALUE

  DEC_VALUE=$UPPER_CURRENT
  DEC2HEX
  CURRENT=$HEX_VALUE

# Save data from Stream and inject new setpoints
  # Save CANBUS ID
  ID=`echo $line|cut -b6-8`
  # Save CANBUS Data 
  DATEN=`echo $line|cut -b5-|tr -d " "|sed 's/\[8\]/#/g'` 

# SoC auslesen und ggf reagieren
  if [ $ID = 355 ]; then
    SoC=$((16#`echo $line|cut -b14-15`))
  fi


  if [ $ID = 351 ]; then
    VALUE=$VOLTAGE
    DATA=$DATEN
    FIRST=4
    LAST=9
    REPLACE_BYTES

      if [ $SoC -ge $SOC_DEGRADE_LIMIT ]; then
        VALUE=$CURRENT
        DATA=$DATEN
        FIRST=8
        LAST=13
        REPLACE_BYTES
      fi

    cansend vcan0 $DATEN 
  else
# Send unchanged data which does not match our CANBUS ID 351
    cansend vcan0 $DATEN 
  fi
done


