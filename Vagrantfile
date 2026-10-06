# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Musterlösung Gruppenarbeit Vagrant II
# Synthesemodul Attack Simulation – Kurstag 2
#
# Ziel (Definition of Done, Folie Vagrant II):
#   > vagrant destroy -f && vagrant up baut die ganze Umgebung ohne manuellen Eingriff auf
#   > Der Smoke-Test meldet alle Pflichtdienste als OK
#   > Passwörter/Schlüssel nie im Klartext im Repository
#
# Umfang: drei VMs, Provisioning mit Ansible (ansible_local), Pflichtdienste
# in einer Grundversion. NOCH KEINE Härtung – das kommt ab Hardening I.
#
# Reihenfolge ist wichtig: db01 wird vor web01 definiert, damit die Datenbank
# steht, bevor web01 das CMS dagegen konfiguriert.

BOX    = "bento/debian-13"   # Debian 13 "Trixie", 64-bit
NETZ   = "192.168.56"        # privates Host-only-Netz (VirtualBox-Standardbereich)

MASCHINEN = {
  "db01"      => { ip: 12, ram: 1024 },
  "web01"     => { ip: 11, ram: 1536 },
  "bastion01" => { ip: 13, ram: 1024 },
}

Vagrant.configure("2") do |config|
  config.vm.box = BOX

  MASCHINEN.each do |name, cfg|
    config.vm.define name do |maschine|
      maschine.vm.hostname = name
      maschine.vm.network "private_network", ip: "#{NETZ}.#{cfg[:ip]}"

      maschine.vm.provider "virtualbox" do |vb|
        vb.name   = "attacksim_#{name}"
        vb.memory = cfg[:ram]
        vb.cpus   = 1
      end

      # /etc/hosts aller Maschinen eintragen (für ping/Service-Zugriff per Name)
      MASCHINEN.each do |ziel, zcfg|
        next if ziel == name
        maschine.vm.provision "shell", inline:
          "grep -q ' #{ziel}$' /etc/hosts || echo '#{NETZ}.#{zcfg[:ip]} #{ziel}' >> /etc/hosts"
      end

      # Provisioning mit Ansible, ausgeführt IN der jeweiligen VM.
      # Vagrant installiert Ansible im Gast automatisch; kein Ansible auf dem
      # Host nötig (läuft daher auch unter Windows).
      maschine.vm.provision "ansible_local" do |ansible|
        ansible.playbook         = "ansible/playbook.yml"
        ansible.provisioning_path = "/vagrant"
        ansible.limit            = name
        # Secrets liegen in einer gitignorierten Datei; ohne sie bricht das
        # Provisioning bewusst mit einer klaren Meldung ab (siehe playbook.yml).
      end

      # Kleiner Selbsttest nur auf web01: erreicht es db01?
      if name == "web01"
        maschine.vm.provision "shell", inline: <<-SHELL
          echo "[web01] Teste Verbindung zu db01 ..."
          if ping -c 2 db01 >/dev/null 2>&1; then
            echo "[web01] OK: db01 ist erreichbar."
          else
            echo "[web01] FEHLER: db01 nicht erreichbar!" >&2
            exit 1
          fi
        SHELL
      end

      # Zweiter kleiner Selbsttest nur auf bastion01: erreicht es db01 und web01?
      if name == "bastion01"
        maschine.vm.provision "shell", inline: <<-SHELL
          echo "[bastion01] Teste Verbindung zu db01 ..."
          if ping -c 2 db01 >/dev/null 2>&1; then
            echo "[bastion01] OK: db01 ist erreichbar."
          else
            echo "[bastion01] FEHLER: db01 nicht erreichbar!" >&2
            exit 1
          fi
          echo "[bastion01] Teste Verbindung zu web01 ..."
          if ping -c 2 web01 >/dev/null 2>&1; then
            echo "[bastion01] OK: web01 ist erreichbar."
          else
            echo "[bastion01] FEHLER: web01 nicht erreichbar!" >&2
            exit 1
          fi
        SHELL
      end
    end
  end
end
