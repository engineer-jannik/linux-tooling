#!/bin/bash
# Samba AD-DC Auto-Installer für Debian 13 (Trixie)
# Dieses Skript richtet automatisch einen Samba AD-Controller ein

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
echo "samba-ad-dc installation of primary domain controller (debian 13/trixie). v1"

# Eingaben abfragen
read -rp "Domain (z.B. EXAMPLE): " DOMAIN
read -rp "Realm (z.B. EXAMPLE.LAN): " REALM
read -rsp "Administrator-Passwort: " ADMINPASS
echo
read -rp "Externer DNS Forwarder (z.B. 8.8.8.8): " DNSFORWARD

echo
echo "=== Überprüfen der Eingaben ==="
echo "Domain: $DOMAIN"
echo "Realm: $REALM"
echo "DNS Forwarder: $DNSFORWARD"
echo "--------------------------------------"
read -rp "Fortfahren? (j/n): " CONFIRM
[[ "$CONFIRM" != "j" ]] && exit 1

echo "=== Pakete installieren ==="
sudo apt update
sudo apt install -y samba-ad-dc krb5-user smbclient ldb-tools dnsutils

echo "=== Alte Samba-Dienste deaktivieren ==="
sudo systemctl disable --now smbd nmbd winbind || true
sudo systemctl mask smbd nmbd winbind || true

echo "=== Samba-AD-DC aktivieren ==="
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc

echo "=== Vorhandene smb.conf sichern ==="
[ -f /etc/samba/smb.conf ] && sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.orig

echo "=== Domain Provisioning starten ==="
sudo samba-tool domain provision \
  --domain "$DOMAIN" \
  --realm "$REALM" \
  --adminpass "$ADMINPASS" \
  --server-role=dc \
  --use-rfc2307 \
  --dns-backend=SAMBA_INTERNAL

echo "=== DNS Forwarder in smb.conf setzen ==="
sudo sed -i "/\[global\]/a \ \ dns forwarder = $DNSFORWARD" /etc/samba/smb.conf

echo "=== Resolver konfigurieren ==="
sudo unlink /etc/resolv.conf || true
echo -e "nameserver 127.0.0.1\nsearch ${REALM,,}" | sudo tee /etc/resolv.conf
sudo systemctl disable --now systemd-resolved || true

echo "=== Kerberos konfigurieren ==="
sudo cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf

echo "=== Samba-AD-DC starten ==="
sudo systemctl start samba-ad-dc

echo "=== Fertig! ==="
echo "Du kannst jetzt testen mit:"
echo "  kinit Administrator"
echo "  klist"
echo "  dig @localhost _ldap._tcp.${REALM,,} SRV"