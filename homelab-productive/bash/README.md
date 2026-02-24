# homelab-productive / bash

Sammlung von Bash-Skripten für mein Homelab / productive Linux-Setup.

Ziel:
- schnelle Grundinstallation auf frischen VMs / Servern
- wiederholbare Standardkonfiguration
- Platz für weitere Setup-, Hardening- und Maintenance-Skripte

## Enthaltene Skripte

### `default-productive-install.sh`

Installiert ein produktives Basis-Setup auf einer neuen Debian-Maschine (APT-basiert) und fuehrt zusätzliches Hardening aus.

Das Skript fuehrt aktuell folgende Schritte aus:

1. Installiert Basis-Tools:
   - `curl`, `htop`, `vim`, `tree`, `unzip`, `wget`
2. Installiert Zabbix Agent2:
   - lädt `zabbix-release_latest_7.4+debian13_all.deb` herunter
   - installiert das Zabbix-Repository per `dpkg -i`
   - installiert `zabbix-agent2`
   - aktiviert den Dienst mit `systemctl enable`
3. Konfiguriert Zabbix Agent2:
   - setzt `Server=zabbix.prod.hegemann-intern.de`
   - setzt `Hostname=$hostname`
   - hängt `AllowKey=system.run[*]` an `/etc/zabbix/zabbix_agent2.conf` an
   - startet den Agent neu
4. Hardening:
   - SSH-Hardening (`PermitRootLogin no`, `PasswordAuthentication no`)
   - installiert und aktiviert `fail2ban`
   - Shared-Memory-Eintrag für `/run/shm` in `/etc/fstab`
   - Kernel-/Netzwerk-Hardening per `/etc/sysctl.d/99-hardened.conf`
5. Cleanup:
   - `apt autoremove`, `apt clean`
   - entfernt heruntergeladene Zabbix-Repo-Datei
   - leert `/tmp/*`

## Voraussetzungen

- Debian (das Skript nutzt aktuell explizit das Zabbix-Paket für `debian13`)
- Internetzugang (Zabbix-Repo-Datei wird per `wget` geladen)
- `sudo`-Rechte (das Skript ruft viele Kommandos mit `sudo` auf)
- System mit `systemd` / `systemctl`

## Nutzung

```bash
./default-productive-install.sh
```

Hinweis: Im Skript sind mehrere Werte fest hinterlegt (z.B. Zabbix-Server und Hostname). Es gibt aktuell keine Konfiguration über Environment-Variablen.

## Hinweise

- Das Skript führt produktive Änderungen direkt auf dem System aus (SSH, sysctl, fstab, Zabbix-Konfig).
- Das Skript ist aktuell nur eingeschraenkt idempotent:
  - `AllowKey=system.run[*]` wird bei mehrfacher Ausführung erneut angehaengt
  - `/tmp/*` wird beim Cleanup gelöscht (vorsichtig auf laufenden Systemen)
