#!/bin/bash
# Default Productive Machine Setup für Debian 13 (Trixie)
# Dieses Skript installiert Standardtools, Zabbix Agent2, Webmin und führt grundlegendes System-Hardening durch

set -e

echo "                                                                              
       ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓██████▓▒░░▒▓████████▓▒░▒▓██████████████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░  
       ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░      ░▒▓████████▓▒░▒▓██████▓▒░░▒▓█▓▒▒▓███▓▒░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 ░▒▓██████▓▒░░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
                                                                                                                                    "
echo "Default Productive Machine Installer (Debian 13 / Trixie) v1"

# Eingaben abfragen
read -rp "Zabbix-Server(Passiv): " SERVER_PASSIV
read -rp "Zabbix-Server(Active): " SERVER_ACTIVE

echo
echo "=== Überprüfen der Eingaben ==="
echo "Zabbix-Server(Passiv): $SERVER_PASSIV"
echo "Zabbix-Server(Active): $SERVER_ACTIVE"
echo "--------------------------------------"
read -rp "Fortfahren? (j/n): " CONFIRM
[[ "$CONFIRM" != "j" ]] && exit 1

echo "=== System vorbereiten ==="
sudo apt update

echo "=== Default Tools installieren ==="
sudo apt install -y curl htop vim tree unzip wget
echo "Default tools installiert."

echo "=== Zabbix Agent2 installieren ==="
wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
sudo dpkg -i zabbix-release_latest_7.4+debian13_all.deb

sudo apt update
sudo apt install -y zabbix-agent2
sudo systemctl enable zabbix-agent2

echo "Zabbix Agent2 installiert."

echo "=== Zabbix Agent2 konfigurieren ==="
HOSTNAME=$(hostname)

sudo sed -i "s/Server=127.0.0.1/Server=$SERVER_PASSIVE/g" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=$SERVER_ACTIVE/g" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/Hostname=Zabbix server/Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agent2.conf
echo "AllowKey=system.run[*]" | sudo tee -a /etc/zabbix/zabbix_agent2.conf

sudo systemctl restart zabbix-agent2
echo "Zabbix Agent2 konfiguriert und gestartet."

echo "=== Webmin installieren ==="
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sudo sh webmin-setup-repo.sh
sudo apt update
sudo apt install -y webmin --install-recommends

echo "Webmin installiert."

echo "=== System Hardening ==="

echo "--- SSH Hardening ---"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
echo "SSH gehärtet."

echo "--- Fail2Ban installieren ---"
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "Fail2Ban aktiviert."

echo "--- Shared Memory Hardening ---"
if ! grep -q "/run/shm" /etc/fstab; then
    echo "none /run/shm tmpfs defaults,ro,nosuid,nodev,noexec 0 0" | sudo tee -a /etc/fstab
fi
echo "Shared Memory gehärtet."

echo "--- Kernel Hardening ---"
sudo tee /etc/sysctl.d/99-hardened.conf <<EOF
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF

sudo sysctl -p /etc/sysctl.d/99-hardened.conf
echo "Kernel Hardening angewendet."

echo "=== System Cleanup ==="
sudo apt autoremove -y
sudo apt clean
sudo rm -f zabbix-release_latest_7.4+debian13_all.deb
sudo rm -rf /tmp/*
sudo rm -f webmin-setup-repo.sh

echo "=== Setup abgeschlossen ==="
echo "Die produktive Maschine wurde erfolgreich eingerichtet."