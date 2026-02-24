#/bin/bash
# This script is used to install the default tools on a new productive machine.

# Install tools
echo "Installing default tools..."
sudo apt update
sudo apt install -y curl htop vim tree unzip wget
echo "Default tools installed."

# Install Zabbix Agent2
echo "Installing Zabbix Agent2..."
sudo wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
sudo dpkg -i zabbix-release_latest_7.4+debian13_all.deb

sudo apt update
sudo apt install zabbix-agent2
sudo systemctl enable zabbix-agent2

echo "Zabbix Agent2 installed and enabled."

# Configure Zabbix Agent2
echo "Configuring Zabbix Agent2 for zabbix.prod.hegemann-intern.de..."
sudo sed -i 's/Server=127.0.0.1/Server=zabbix.prod.hegemann-intern.de/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/Hostname=Zabbix server/Hostname=$(hostname)/g' /etc/zabbix/zabbix_agent2.conf
sudo echo "AllowKey=system.run[*]" >> /etc/zabbix/zabbix_agent2.conf

# Restart Zabbix Agent2
sudo systemctl restart zabbix-agent2
echo "Zabbix Agent2 configured and restarted."

# Hardening
echo "Hardening the system..."

# SSH Hardening
echo "Hardening SSH configuration..."
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
echo "SSH configuration hardened."

# Install Fail2Ban(brute-force protection)
echo "Installing Fail2Ban..."
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "Fail2Ban installed and started."

# Shared Memory Hardening (Preventing shared memory attacks)
echo "Hardening Shared Memory..."
if ! grep -q "/run/shm" /etc/fstab; then
    echo "none /run/shm tmpfs defaults,ro,nosuid,nodev,noexec 0 0" | sudo tee -a /etc/fstab
fi
echo "Shared memory hardened."

# Kernel Hardening (Network hardening)
echo "Applying Kernel hardening via sysctl..."
sudo tee /etc/sysctl.d/99-hardened.conf <<EOF
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF
sudo sysctl -p /etc/sysctl.d/99-hardened.conf
echo "Kernel hardening applied."

# Clean up
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
sudo rm zabbix-release_latest_7.4+debian13_all.deb
sudo rm -rf /tmp/*
echo "System cleaned up."

# Final message
echo "Default productive machine setup completed successfully!"