# Создаем systemd unit:
cat > /etc/systemd/system/ip-forward-onboot.service <<'EOF'
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
