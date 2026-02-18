#!/usr/bin/env bash
set -euo pipefail

LAN1_IF="ens36"
LAN2_IF="ens37"
LAN1_NET="172.16.4.0/28"
LAN2_NET="172.16.5.0/28"

# --- Спрашиваем пользователя внешний инт --- 
read -r -p "Внешний интерфейс (WAN), например ens38: " WAN_IF

# Создаем инты:
# ens36
cd /etc/net/ifaces
mkdir ens36 && cd ens36 && touch options ipv4address
echo "TYPE=eth" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
echo "CONFIG_IPV4=yes" >> options
echo "172.16.4.1/28" >> ipv4address

# ens37
cd /etc/net/ifaces
mkdir ens37 && cd ens37 && touch options ipv4address
echo "TYPE=eth" >> options
echo "BOOTPROTO=static" >> options
echo "ONBOOT=yes" >> options
echo "CONFIG_IPV4=yes" >> options
echo "172.16.5.1/28" >> ipv4address

# Перезапуск сети и проверка статуса:
systemctl restart network && systemctl status network
sleep 5
# Проверка адресов:
ip -c a
sleep 5

# --- Маршрутизация --- 
echo "Включаем маршрутизацию:"
/sbin/sysctl -w net.ipv4.ip_forward=1 >/dev/null

IPT="/sbin/iptables"
echo "Задаем правила маршрутизации на iptables:"
# NAT наружу
$IPT -t nat -A POSTROUTING -s "LAN1_NET" -o "WAN_IF" -j MASQUERADE
$IPT -t nat -A POSTROUTING -s "LAN2_NET" -o "WAN_IF" -j MASQUERADE

# NAT с локальных сетей на внешку
$IPT -A FORWARD -i "LAN1_IF" -o "WAN_IF" -s "LAN1_NET" -j ACCEPT
$IPT -A FORWARD -i "LAN2_IF" -o "WAN_IF" -s "LAN2_NET" -j ACCEPT

# Ответы обратно
$IPT -A FORWARD -i "WAN_IF" -o "LAN1_IF" -d "LAN1_NET" -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -i "WAN_IF" -o "LAN2_IF" -d "LAN2_NET" -m state --state ESTABLISHED,RELATED -j ACCEPT


# Создаем systemd unit:
cat /etc/systemd/system/ip-forward-onboot.service <<'EOF'
[Unit]
Description=Enable IPv4 forwarding on boot (safety)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/sysctl -w net.ipv4.ip_forward=1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# перезагружаем службы:
systemctl daemon-reload
# включаем и запускаем службу
systemctl enable --now ip-forward-onboot.service
