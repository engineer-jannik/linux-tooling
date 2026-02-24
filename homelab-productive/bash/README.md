# homelab-productive / bash

Sammlung von Bash-Skripten fuer mein Homelab / productive Linux-Setup.

Ziel:
- schnelle Grundinstallation auf frischen VMs / Servern
- wiederholbare Standardkonfiguration
- Platz fuer weitere Setup-, Hardening- und Maintenance-Skripte

## Enthaltene Skripte

### `default-productive-install.sh`

Installiert ein produktives Basis-Setup auf einer neuen Debian-Maschine (APT-basiert) und fuehrt zusaetzliches Hardening aus.

Das Skript fuehrt aktuell folgende Schritte aus:

1. Installiert Basis-Tools:
   - `curl`, `htop`, `vim`, `tree`, `unzip`, `wget`
2. Installiert Zabbix Agent2:
   - laedt `zabbix-release_latest_7.4+debian13_all.deb` herunter
   - installiert das Zabbix-Repository per `dpkg -i`
   - installiert `zabbix-agent2`
   - aktiviert den Dienst mit `systemctl enable`
3. Konfiguriert Zabbix Agent2:
   - setzt `Server=zabbix.prod.hegemann-intern.de`
   - setzt `Hostname=productive-machine`
   - haengt `AllowKey=system.run[*]` an `/etc/zabbix/zabbix_agent2.conf` an
   - startet den Agent neu
4. Hardening:
   - SSH-Hardening (`PermitRootLogin no`, `PasswordAuthentication no`)
   - installiert und aktiviert `fail2ban`
   - Shared-Memory-Eintrag fuer `/run/shm` in `/etc/fstab`
   - Kernel-/Netzwerk-Hardening per `/etc/sysctl.d/99-hardened.conf`
5. Cleanup:
   - `apt autoremove`, `apt clean`
   - entfernt heruntergeladene Zabbix-Repo-Datei
   - leert `/tmp/*`

## Voraussetzungen

- Debian (das Skript nutzt aktuell explizit das Zabbix-Paket fuer `debian13`)
- Internetzugang (Zabbix-Repo-Datei wird per `wget` geladen)
- `sudo`-Rechte (das Skript ruft viele Kommandos mit `sudo` auf)
- System mit `systemd` / `systemctl`

## Nutzung

```bash
./default-productive-install.sh
```

Hinweis: Im Skript sind mehrere Werte fest hinterlegt (z. B. Zabbix-Server und Hostname). Es gibt aktuell keine Konfiguration ueber Environment-Variablen.

## Fest eingebaute Defaults im aktuellen Skript

Folgende Werte sind im Skript aktuell hardcoded:

- Zabbix Repo: `7.4` fuer `debian13`
- Zabbix Server: `zabbix.prod.hegemann-intern.de`
- Zabbix Hostname: `productive-machine`
- Zabbix AllowKey: `AllowKey=system.run[*]`

Wenn du das Skript fuer andere Hosts verwenden willst, diese Werte im Skript vorher anpassen.

## Geplante / kommende Skripte

Hier koennen spaeter weitere Skripte dokumentiert werden, z. B.:

- User-Setup (`create-admin-user.sh`, SSH-Key, Gruppen, sudoers)
- Base-Hardening (SSH, Fail2ban, Firewall/UFW)
- Docker / Container Runtime Setup
- Backup / Restore Helpers
- Monitoring / Logging Zusatzskripte
- Update / Patch Maintenance

## Hinweise

- Das Skript fuehrt produktive Aenderungen direkt auf dem System aus (SSH, sysctl, fstab, Zabbix-Konfig).
- Das Skript ist aktuell nur eingeschraenkt idempotent:
  - `AllowKey=system.run[*]` wird bei mehrfacher Ausfuehrung erneut angehaengt
  - `/tmp/*` wird beim Cleanup geloescht (vorsichtig auf laufenden Systemen)
- Bei neuen Skripten hier kurz dokumentieren: Zweck, Voraussetzungen, Nutzung, feste Defaults / Variablen.
