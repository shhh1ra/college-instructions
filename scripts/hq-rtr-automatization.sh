#!/usr/bin/env bash
set -euo pipefail

HOST="ens36"
VLAN1="ens36.100"
VLAN2="ens36.200"
VLAN3="ens36.999"
VLAN1_ID="100"
VLAN2_ID="200"
VLAN3_ID="999"
IFACES_FOLDER="/etc/net/ifaces

# --- Создание интов --- 
# trunk
cd $IFACES_FOLDER
mkdir -p $HOST && cd $HOST
echo "TYPE=eth" >> options
echo "BOOTPROTO=none" >> options
echo "ONBOOT=yes" >> options

# vlan1 (.100)
cd $IFACES_FOLDER
mkdir -p $VLAN1 && cd $VLAN1
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN1_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options

# vlan2 (.200)
cd $IFACES_FOLDER
mkdir -p $VLAN2 && cd $VLAN2
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN2_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options

# vlan3 (.999)
cd $IFACES_FOLDER
mkdir -p $VLAN3 && cd $VLAN3
echo "TYPE=vlan" >> options
echo "HOST=$HOST" >> options
echo "VID=$VLAN3_ID" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
