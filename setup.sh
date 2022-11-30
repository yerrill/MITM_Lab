#!/bin/bash

# Setup ---
apt update -y && apt upgrade -y
rfkill unblock wlan
apt install -y iptables hostapd isc-dhcp-server dnsutils

# dhcpcd ---
echo "# MITM Lab Entries =====" >> /etc/dhcpcd.conf
echo "interface wlan0" >> /etc/dhcpcd.conf
echo "static ip_address=192.168.16.1/24" >> /etc/dhcpcd.conf
echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

# isc-dhcp-server ---
echo "# MITM Lab Entries =====" >> /etc/dhcp/dhcpd.conf
echo "authoritative;" >> /etc/dhcp/dhcpd.conf
echo -e 'subnet 192.168.16.0 netmask 255.255.255.0 {\n\trange 192.168.16.10 192.168.16.250;\n\toption broadcast-address 192.168.16.255;\n\toption routers 192.168.16.1;\n\toption domain-name "local";\n\toption domain-name-servers 8.8.8.8, 8.8.4.4;\n}' >> /etc/dhcp/dhcpd.conf

mv /etc/default/isc-dhcp-server /etc/default/backup-isc-dhcp-server
echo "# MITM Lab Entries ===== Old config moved to /etc/default/backup-isc-dhcp-server" >> /etc/default/isc-dhcp-server
echo 'INTERFACESv4="wlan0"' >> /etc/default/isc-dhcp-server

# isc-dhcp-server systemd entry
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/isc-dhcp-server.service.ini
mv ./isc-dhcp-server.service.ini /etc/systemd/system/isc-dhcp-server.service
systemctl daemon-reload
systemctl disable isc-dhcp-server
systemctl enable isc-dhcp-server

# hostapd ---
# cp /usr/share/doc/hostapd/examples/hostapd.conf /etc/hostapd/
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/hostapd.conf
mv ./hostapd.conf /etc/hostapd/
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd
systemctl unmask hostapd.service
systemctl enable hostapd.service

# Network traffic ---
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.up.rules
mv /etc/rc.local /etc/backup-rc.local
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/rc.local
mv ./rc.local /etc/
chmod +x /etc/rc.local

# Enable traffic forwarding ---
sysctl -w net.ipv4.ip_forward=1
echo "# MITM Lab Entries =====" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Download and move falseserver and iprules
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/false_server.py
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/iprules.sh
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/AttackPage.html
mv ./false_server.py /bin/falseserver
mv ./iprules.sh /bin/iprules
chmod +x /bin/falseserver
chmod +x /bin/iprules

# End
echo "===== Time to reboot ====="