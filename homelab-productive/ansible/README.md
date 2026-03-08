# 🚀 homelab-productive/ansbile

Automatisierte Playbooks für Deployment, Monitoring und Hardening von Maschinen in meinem produktiven Homelab.

---

## 🛠 Verfügbare Playbooks

### 1. `default-productive-install.yaml`

Das All-in-One Setup für neue Server. Installiert Tools, Monitoring und härtet das System ab.

* **Tools:** `curl`, `htop`, `vim`, `tree`, `unzip`, `wget`.
* **Management:** Installiert **Webmin** und **Zabbix Agent 2** (v7.4+).
* **Hardening:**
  * **SSH:** Deaktiviert Root-Login via Passwort.
  * **Sicherheit:** Installiert & aktiviert `Fail2Ban`.
  * **System:** Kernel-Hardening (`sysctl`) und Shared-Memory-Schutz (`fstab`).
* **Cleanup:** Bereinigt temporäre Files und APT-Cache nach Installation.

---

## 📋 Kurzinfos

| Feature | Details |
| --- | --- |
| **OS** | Debian 13 (Trixie) |
| **Rechte** | Sudo / Root erforderlich |
| **Status** | Stable (Homelab-Einsatz) |

> [!WARNING]
> Diese Playbooks nehmen tiefgreifende Änderungen an der Netzwerkkonfiguration und dem SSH-Zugang vor. Vor dem Einsatz in kritischen Umgebungen Code prüfen!

---
