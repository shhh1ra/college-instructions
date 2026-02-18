#!/usr/bin/env bash
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
