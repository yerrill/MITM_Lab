#!/bin/bash

#if [ $EUID > 0 ] # Check seems to be buggy
#  then echo "Please run as root"
#  exit
#fi

# Setup ---
apt update -y && apt upgrade -y
rfkill unblock wlan
apt install -y iptables hostapd isc-dhcp-server python3-pip python3-venv

# dhcpcd ---
#/bin/bash -c 'echo "# MITM Lab Entries =====" >> /etc/dhcpcd.conf'
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
# cp /run/systemd/generator.late/isc-dhcp-server.service /etc/systemd/system
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

# mitmproxy ---
python3 -m pip install pipx
#python3 -m pipx ensurepath
pipx install mitmproxy

wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/start_mitmweb.sh
mv ./start_mitmweb.sh /root/.local/bin/
chmod a+x /root/.local/bin/start_mitmweb.sh

# nano /etc/systemd/system/mitmweb.service
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/mitmweb.service.txt
mv ./mitmweb.service.txt /etc/systemd/system/mitmweb.service

systemctl daemon-reload
systemctl enable mitmweb.service

# Network traffic ---
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -i wlan0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -i wlan0 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 8080
iptables-save > /etc/iptables.up.rules
mv /etc/rc.local /etc/backup-rc.local
wget https://raw.githubusercontent.com/yerrill/MITM_Lab/main/src/rc.local
mv ./rc.local /etc/
chmod +x /etc/rc.local

# Enable traffic forwarding ---
sysctl -w net.ipv4.ip_forward=1
echo "# MITM Lab Entries =====" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# End
echo "===== Time to reboot ====="