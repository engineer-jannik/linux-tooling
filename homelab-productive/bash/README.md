# 🚀 homelab-productive/bash

Automatisierte Skripte für Deployment, Monitoring und Hardening von Maschinen in meinem produktiven Homelab.

---

## 🛠 Verfügbare Skripte

### 1. `install-samba-ad-pdc.sh`

Richtet einen **Samba Active Directory Domain Controller (PDC)** ein.

* **Interaktiv:** Fragt Domain (NetBIOS), Realm (DNS) und DNS-Forwarder ab.
* **Automatisierung:** Deaktiviert Standard-Samba-Dienste und `systemd-resolved`.
* **Provisioning:** Erstellt die Domain via `samba-tool` inkl. RFC2307 & internem DNS.
* **Konfiguration:** Automatische Einrichtung von Kerberos und `/etc/resolv.conf`.

---

## 📋 Kurzinfos

| Feature | Details |
| --- | --- |
| **OS** | Debian 13 (Trixie) |
| **Rechte** | Sudo / Root erforderlich |
| **Status** | Stable (Homelab-Einsatz) |

> [!WARNING]
> Diese Skripte nehmen tiefgreifende Änderungen an der Netzwerkkonfiguration vor. Vor dem Einsatz in kritischen Umgebungen Code prüfen!

---
