# homelab-productive / bash

Sammlung von Bash-Skripten für mein Homelab / produktives Linux-Setup.

## Ziel

- schnelle Grundinstallation auf frischen VMs / Servern
- wiederholbare Standardkonfiguration
- Platz für weitere Setup-, Hardening- und Maintenance-Skripte

---

# Enthaltene Skripte

---

# `default-productive-install.sh`

Installiert ein produktives Basis-Setup auf einer neuen Debian-Maschine (APT-basiert) und führt zusätzliches Hardening aus.

## Funktionsumfang

Das Skript führt aktuell folgende Schritte aus:

### 1. Installation von Basis-Tools

Installiert:

- `curl`
- `htop`
- `vim`
- `tree`
- `unzip`
- `wget`

### 2. Installation von Zabbix Agent2

- lädt `zabbix-release_latest_7.4+debian13_all.deb` herunter
- installiert das Repository mit `dpkg -i`
- installiert `zabbix-agent2`
- aktiviert den Dienst mit `systemctl enable`

### 3. Konfiguration des Zabbix Agent2

Das Skript:

- setzt `Server=zabbix.prod.hegemann-intern.de`
- setzt `Hostname=$Hostname`
- hängt folgende Option an:

```
AllowKey=system.run[*]
```

in:

```
/etc/zabbix/zabbix_agent2.conf
```

Danach wird der Agent neu gestartet.

### 4. System Hardening

Folgende Maßnahmen werden durchgeführt:

#### SSH Hardening

```
PermitRootLogin no
```

#### Fail2Ban

- Installation
- Aktivierung des Dienstes

#### Shared Memory Mount

Eintrag für:

```
/run/shm
```

in `/etc/fstab`.

#### Kernel / Netzwerk Hardening

Konfiguration über:

```
/etc/sysctl.d/99-hardened.conf
```

### 5. Cleanup

Das Skript führt aus:

```
apt autoremove
apt clean
```

und entfernt zusätzlich:

- heruntergeladene Zabbix Repo Datei
- Webmin Setup Script

Außerdem wird geleert:

```
/tmp/*
```

---

## Voraussetzungen

- Debian System (APT basiert)
- aktuell ist das Zabbix Paket für **Debian 13** hinterlegt
- Internetzugang
- `sudo` Rechte
- System mit `systemd` / `systemctl`

---

## Nutzung

```bash
./default-productive-install.sh
```

---

## Hinweise

Das Skript führt produktive Änderungen direkt auf dem System aus:

- SSH Konfiguration
- sysctl Einstellungen
- fstab Änderungen
- Zabbix Agent Konfiguration

Aktuell ist das Skript **nur eingeschränkt idempotent**.

Beispiele:

- `AllowKey=system.run[*]` wird bei mehrfacher Ausführung erneut angehängt
- `/tmp/*` wird beim Cleanup gelöscht

---

# `samba-ad-dc-auto-installer.sh`

Automatisches Setup eines **Samba Active Directory Domain Controllers** auf **Debian 13 (Trixie)**.

Das Skript richtet einen **Primary Domain Controller (PDC)** inklusive DNS und Kerberos ein.

---

# Funktionsumfang

## 1. Interaktive Eingaben

Beim Start fragt das Skript folgende Werte ab:

- NetBIOS Domain  
  Beispiel:

```
EXAMPLE
```

- Kerberos Realm  

```
EXAMPLE.LAN
```

- Administrator Passwort

- externer DNS Forwarder  

Beispiel:

```
8.8.8.8
```

Vor der Installation erfolgt eine Bestätigung der Eingaben.

---

# 2. Installation der benötigten Pakete

Installiert werden:

```
samba-ad-dc
krb5-user
smbclient
ldb-tools
dnsutils
```

---

# 3. Deaktivieren klassischer Samba Dienste

Die folgenden Dienste werden deaktiviert und maskiert:

```
smbd
nmbd
winbind
```

Da der AD Controller ausschließlich über `samba-ad-dc` läuft.

---

# 4. Aktivierung des AD-DC Dienstes

Folgender Dienst wird aktiviert:

```
samba-ad-dc
```

---

# 5. Backup vorhandener Samba Konfiguration

Falls vorhanden wird:

```
/etc/samba/smb.conf
```

verschoben nach:

```
/etc/samba/smb.conf.orig
```

---

# 6. Domain Provisioning

Das Skript führt aus:

```bash
samba-tool domain provision \
--domain "$DOMAIN" \
--realm "$REALM" \
--adminpass "$ADMINPASS" \
--server-role=dc \
--use-rfc2307 \
--dns-backend=SAMBA_INTERNAL
```

Dabei wird:

- Domain erstellt
- Kerberos Realm eingerichtet
- interner DNS Server konfiguriert
- Administrator Account erstellt

---

# 7. DNS Forwarder konfigurieren

In der Samba Konfiguration wird ergänzt:

```
dns forwarder = <DNS-IP>
```

---

# 8. Resolver Konfiguration

Die lokale Namensauflösung wird angepasst.

`/etc/resolv.conf` wird ersetzt durch:

```
nameserver 127.0.0.1
search <realm>
```

Zusätzlich wird deaktiviert:

```
systemd-resolved
```

---

# 9. Kerberos Konfiguration

Die automatisch generierte Kerberos Konfiguration wird übernommen:

```
/var/lib/samba/private/krb5.conf
```

→

```
/etc/krb5.conf
```

---

# 10. Start des Domain Controllers

Der Dienst wird gestartet:

```
systemctl start samba-ad-dc
```

---

# Nutzung

```bash
./samba-ad-dc-auto-installer.sh
```

Das Skript läuft interaktiv und fragt alle benötigten Werte ab.

---

# Beispielwerte

```
Domain: EXAMPLE
Realm: EXAMPLE.LAN
DNS Forwarder: 8.8.8.8
```

---

# Funktionstest nach Installation

Nach erfolgreicher Installation können folgende Tests durchgeführt werden:

```bash
kinit Administrator
```

```bash
klist
```

```bash
dig @localhost _ldap._tcp.example.lan SRV
```

Hinweis:

`example.lan` muss durch den tatsächlich verwendeten Realm ersetzt werden.

---

# Wichtige Hinweise

Dieses Skript führt **tiefgreifende Änderungen am System** durch:

- Samba wird als AD Domain Controller eingerichtet
- `/etc/resolv.conf` wird ersetzt
- `systemd-resolved` wird deaktiviert
- `/etc/krb5.conf` wird überschrieben

Das Skript ist **nicht für wiederholte Ausführung auf bestehenden Domain Controllern geeignet**.

Eine vorhandene Samba Konfiguration wird nur nach `.orig` verschoben.

---

# Projektstatus

Die Skripte sind für den Einsatz im **Homelab / produktiven Self-Hosting Umfeld** gedacht.

Weitere geplante Skripte:

- Server Hardening
- Docker / Podman Setup
- Backup Automatisierung
- Monitoring Integration
- Maintenance / Update Automatisierung