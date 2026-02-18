#!/usr/bin/env bash
set -euo pipefail

LAN1_IF="ens36"
LAN2_IF="ens37"
LAN1_NET_DEFAULT="172.16.4.0/28"
LAN2_NET_DEFAULT="172.16.5.0/28"

# --- Спрашиваем пользователя внешний инт --- 
read -r -p "Внешний интерфейс (WAN), например ens38: " WAN_IF 

# --- Маршрутизация --- 
echo "Включаем маршрутизацию:"
/sbin/sysctl -w net.ipv4.ip_forward=1 >/dev/null

IPT="/sbin/iptables"
echo "Задаем правила маршрутизации на iptables:"
# NAT наружу
$IPT -t nat -A POSTROUTING -s "LAN1_NET" -o "WAN_IF" -j MASQUERADE
$IPT -t nat -A POSTROUTING -s "LAN2_NET" -o "WAN_IF" -j MASQUERADE

# NAT с локальных сетей на внешку
$IPT -A FORWARD -i "LAN1_IF" -o ens36 -d 172.16.4.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -i "LAN1_IF" -o ens37 -d 172.16.5.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT
