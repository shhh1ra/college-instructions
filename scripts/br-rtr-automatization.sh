#!/usr/bin/env bash

IFACES_FOLDER="/etc/net/ifaces"
TUNLOCAL="172.16.5.2"
TUNREMOTE="172.16.4.2"
INT_NAME="gre1"

# Включение модуля gre
modprobe gre
echo gre >> /etc/modules

# --- Создание инта:
cd $IFACES_FORDER
mkdir $INT_NAME && cd $INT_NAME
echo "TYPE=iptun" >> options
echo "TUNTYPE=gre" >> options
echo "TUNLOCAL=$TUNLOCAL" >> options
echo "TUNREMOTE=$TUNREMOTE" >> options
echo "TUNOPTIONS='ttl 64'" >> options
echo "ONBOOT=yes" >> options
echo "10.10.10.2/30" >> ipv4address
