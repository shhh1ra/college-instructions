#!/usr/bin/env bash
set -euo pipefail

LAN1_IF="ens36"
LAN2_IF="ens37"
LAN1_NET="172.16.4.0/28"
LAN2_NET="172.16.5.0/28"

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
iptables -A FORWARD -i ens36 -o ens38 -s 172.16.4.0/28 -j ACCEPT
iptables -A FORWARD -i ens37 -o ens38 -s 172.16.5.0/28 -j ACCEPT

# Ответы обратно
$IPT -A FORWARD -i "WAN_IF" -o "LAN1_IF" -d "LAN1_NET" -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -i "WAN_IF" -o "LAN2_IF" -d "LAN2_NET" -m state --state ESTABLISHED,RELATED -j ACCEPT
