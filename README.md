# linux-tooling

Dieses Repository dient als **zentrale Referenzsammlung** für Skripte, Automatisierungsansätze und Infrastruktur-Helper, die ich im Rahmen meiner **Einzelunternehmung für IT-Beratung** einsetze.

Der Fokus liegt auf **Linux-Servern** und **Linux-Desktoplandschaften**, mit praxisnahen Lösungen für wiederkehrende technische Herausforderungen, stabile Betriebsabläufe und effiziente Administration.

---

## Ziel des Repositories

- Wiederverwendbare Lösungen für Kundenprojekte  
- Dokumentation bewährter Vorgehensweisen  
- Schnell einsetzbare Automatisierung für neue Umgebungen  
- Persönliche Wissensbasis für Consulting, Betrieb und Troubleshooting  

---

## Struktur des Repositories

Die Inhalte sind nach **Einsatzgebiet**, **Tooling** und **konkreten Dateien** gegliedert, um eine schnelle Orientierung und Wiederverwendung zu ermöglichen.
```
linux-tooling/
├── einsatzgebiet/
│   ├── tool/
│   │   ├── skript_oder_playbook
│   │   └── README.md
│   └── ...
└── README.md
```

---

### 1. Einsatzgebiet

Ordnet die Inhalte nach dem **konkreten Umfeld**, in dem sie eingesetzt werden.

Beispiele:
- `arztpraxis` – Kleine bis mittlere Praxisumgebungen  
- `industrie` – Produktionsnahe Systeme, OT/IT-Übergänge  
- `homelab` – Testumgebungen, Prototypen, persönliche Infrastruktur  
- `kunde_xyz` – Kundenspezifische (anonymisierte) Setups  

Ziel: **Kontext schaffen**, warum und wo ein Tool eingesetzt wird.

---

### 2. Tool / Technologie

Innerhalb eines Einsatzgebiets erfolgt die Unterteilung nach dem verwendeten **Werkzeug oder Ansatz**.

Beispiele:
- `ansible` – Konfigurationsmanagement & Automatisierung  
- `bash` – Shell-Skripte für Administration & Wartung  
- `systemd` – Service-Definitionen & Timer  
- `docker` – Containerisierte Dienste  
- `terraform` – Infrastruktur-Provisionierung  

---

### 3. Skripte / Playbooks / Dateien

Die eigentlichen Inhalte dieses Repositories:

- Skripte (`.sh`)  
- Ansible-Playbooks & Rollen  
- Konfigurationsdateien  
- Dokumentation zur Nutzung  

Empfehlungen:
- Jede relevante Sammlung enthält eine eigene `README.md`  
- Klare und sprechende Dateinamen  
- Kommentare im Code für Wartbarkeit und Nachvollziehbarkeit  

---

## Grundsätze

- **Praxisorientiert** statt theoretisch  
- **Minimal, stabil, nachvollziehbar**  
- Fokus auf **Linux-Standards** und langfristige Wartbarkeit  
- Keine sensiblen oder kundenspezifischen Daten im Repository  

---

## Hinweis

Dieses Repository ist als **Arbeits- und Wissensbasis** gedacht. Inhalte können sich weiterentwickeln, unvollständig sein oder an spezifische Umgebungen angepasst werden müssen.
