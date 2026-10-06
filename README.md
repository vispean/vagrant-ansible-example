# Musterlösung Vagrant II – Provisioning mit Ansible

Baut die Umgebung der Use Case Study in einer **Grundversion** auf:
drei VMs, Pflichtdienste per Infrastruktur als Code, noch ohne Härtung.

## Voraussetzungen

- VirtualBox und Vagrant (getestet mit Vagrant 2.4.9)
- Internetzugang der VMs (für apt und den WordPress-Download)
- amd64-Host. Auf Apple Silicon: andere Box/Provider nötig (siehe Vagrant I).
- Kein Ansible auf dem Host – Vagrant installiert es in den VMs (`ansible_local`).

## Start

```bash
cp ansible/vars/secrets.yml.example ansible/vars/secrets.yml   # Passwörter setzen
vagrant up
./smoke-test.sh
```

Für die Definition of Done:

```bash
vagrant destroy -f && vagrant up && ./smoke-test.sh
```

## Zielarchitektur

| Host      | IP             | Pflichtdienst                        |
|-----------|----------------|--------------------------------------|
| web01     | 192.168.56.11  | nginx + PHP-FPM + WordPress          |
| db01      | 192.168.56.12  | MariaDB (nur von web01 erreichbar)   |
| bastion01 | 192.168.56.13  | SSH-Admin-Konto + Samba-Freigabe     |

## Secrets

Passwörter stehen ausschliesslich in `ansible/vars/secrets.yml`
(in `.gitignore`). Fehlt die Datei, bricht das Provisioning mit einem
Hinweis ab. Nächster Schritt: `ansible-vault encrypt ansible/vars/secrets.yml`.

## Bewusst noch NICHT enthalten (kommt ab Hardening I)

- Firewall, SSH-Härtung, Entfernen von Default-Zugängen
- WordPress-Installation abgeschlossen (Setup-Assistent noch offen)
- TLS/HTTPS
