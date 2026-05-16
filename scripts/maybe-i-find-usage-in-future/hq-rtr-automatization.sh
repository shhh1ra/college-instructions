#!/usr/bin/env bash
set -euo pipefail

IFACES_FOLDER="/etc/net/ifaces"
HOST="ens36"
VLAN1="ens36.100"
VLAN2="ens36.200"
VLAN3="ens36.999"
VLAN1_ID="100"
VLAN2_ID="200"
VLAN3_ID="999"
TUNLOCAL="172.16.4.2"
TUNREMOTE="172.16.5.2"
INT_NAME="gre1"

# --- Создание интов --- 
# trunk
cd "$IFACES_FOLDER"
mkdir -p $HOST && cd $HOST
echo "TYPE=eth" >> options
echo "BOOTPROTO=none" >> options
echo "ONBOOT=yes" >> options

# vlan1 (.100)
cd "$IFACES_FOLDER"
mkdir -p $VLAN1 && cd $VLAN1
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN1_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
echo "192.168.10.1/26" >> ipv4address

# vlan2 (.200)
cd "$IFACES_FOLDER"
mkdir -p $VLAN2 && cd $VLAN2
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN2_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
echo "192.168.20.1/28" >> ipv4address

# vlan3 (.999)
cd "$IFACES_FOLDER"
mkdir -p $VLAN3 && cd $VLAN3
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN3_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
echo "192.168.99.1/29" >> ipv4address

systemctl restart network && systemctl status network --no-pager
sleep 5
ip -c a

# --- gre ---
# Включение модуля gre
modprobe gre
echo gre >> /etc/modules

cd $IFACES_FORDER
mkdir $INT_NAME && cd $INT_NAME
echo "TYPE=iptun" >> options
echo "TUNTYPE=gre" >> options
echo "TUNLOCAL=$TUNLOCAL" >> options
echo "TUNREMOTE=$TUNREMOTE" >> options
echo "TUNOPTIONS='ttl 64'" >> options
echo "ONBOOT=yes" >> options
echo "10.10.10.1/30" >> ipv4address
