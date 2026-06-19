# TP Cloud — Déploiement automatisé d'une infrastructure Wiki.js

## Description

Ce projet déploie automatiquement une infrastructure de deux machines virtuelles hébergeant **Wiki.js** (serveur web) et **PostgreSQL** (base de données), en utilisant une chaîne IaC complète :

- **cloud-init** : amorçage des VM au premier démarrage
- **Terraform/OpenTofu** : provisionnement de l'infrastructure
- **Ansible** : configuration des middlewares
- **Git** : versionnement et traçabilité

L'infrastructure est déployée sur **Proxmox** (avec un code Azure conservé pour illustrer la portabilité entre fournisseurs).

---

## Architecture

```
Internet
    │
    ▼
Proxmox (82.64.141.52)
    │
    ├── tpcloud-web (10.0.50.50)  →  Wiki.js (port 3000)
    │
    └── tpcloud-db  (10.0.50.51)  →  PostgreSQL (port 5432)
```

- La VM **web** héberge Wiki.js sous Node.js 22, lancé comme service systemd.
- La VM **db** héberge PostgreSQL, accessible uniquement depuis la VM web (règle pg_hba).
- Les deux VM sont clonées depuis un template Ubuntu 24.04 cloud-init.

---

## Prérequis

### Outils à installer sur votre machine (Mac/Linux)

```bash
brew install opentofu ansible azure-cli
```

### Clé SSH du projet

```bash
ssh-keygen -t ed25519 -f ~/.ssh/tp_cloud -C "tp-cloud" -N ""
```

---

## Structure du projet

```
tp-cloud/
├── .gitignore
├── README.md
├── terraform/          # Code Terraform pour Azure (portabilité)
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── cloud-init.yaml
├── proxmox/            # Code Terraform pour Proxmox (déploiement principal)
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
└── ansible/            # Configuration des middlewares
    ├── ansible.cfg
    ├── inventory.ini
    ├── playbook.yml
    ├── requirements.yml
    ├── group_vars/
    │   └── all.yml
    └── roles/
        ├── postgresql/   # Installation et configuration de PostgreSQL
        └── wikijs/       # Installation et configuration de Wiki.js
```

---

## Déploiement

### Étape 1 — Préparer le template cloud-init sur Proxmox

Se connecter au nœud Proxmox et exécuter :

```bash
# Télécharger l'image Ubuntu 24.04 cloud
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

# Créer la VM template
qm create 9000 --name ubuntu-2404-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000

# Déposer le snippet cloud-init
pvesm set local --content snippets,iso,vztmpl,backup,images,rootdir
mkdir -p /var/lib/vz/snippets
# (copier le fichier tp-cloud-init.yaml dans /var/lib/vz/snippets/)
```

### Étape 2 — Déployer l'infrastructure avec OpenTofu

```bash
cd proxmox/

# Exporter les identifiants Proxmox
export PROXMOX_VE_ENDPOINT="https://PROXMOX_IP:PORT/"
export PROXMOX_VE_API_TOKEN='root@pam!terraform=SECRET'

# Déployer
tofu init
tofu plan
tofu apply
```

Les deux VM `tpcloud-web` (10.0.50.50) et `tpcloud-db` (10.0.50.51) sont créées et démarrées automatiquement.

### Étape 3 — Configurer les middlewares avec Ansible

```bash
cd ansible/

# Installer les collections requises
ansible-galaxy collection install -r requirements.yml

# Tester la connectivité
ansible all -m ping

# Lancer le playbook
ansible-playbook -i inventory.ini playbook.yml
```

Le playbook installe et configure PostgreSQL sur la VM db et Wiki.js sur la VM web. Il est **idempotent** : on peut le relancer sans risque.

### Vérification

```bash
# Vérifier que Wiki.js répond
curl -s -o /dev/null -w "%{http_code}" http://10.0.50.50:3000
# Attendu : 200
```

---

## Sécurité

- Connexion SSH par **clé uniquement** (pas de mot de passe)
- PostgreSQL n'accepte les connexions **que depuis la VM web** (règle pg_hba stricte)
- Les secrets (tokens API, mots de passe) sont passés par **variables d'environnement**, jamais committés
- Le fichier `.gitignore` exclut les fichiers sensibles (`.tfstate`, `.tfvars`, clés SSH)

---

## Portabilité entre fournisseurs

Le projet contient deux codes Terraform distincts :

| Dossier | Fournisseur | Statut |
|---------|-------------|--------|
| `terraform/` | Microsoft Azure | Code fonctionnel (bloqué par les quotas Azure for Students) |
| `proxmox/` | Proxmox VE | Déployé et fonctionnel |

Seul le `provider.tf` et le `main.tf` changent entre les deux — la logique cloud-init et Ansible reste identique.

---

## Difficultés rencontrées

- **Azure for Students** : quotas trop restrictifs (`SkuNotAvailable`, `RequestDisallowedByAzure`), ce qui a motivé le passage à Proxmox.
- **Dépôt Proxmox Enterprise** inaccessible (pas d'abonnement) : le guest-agent a été installé via cloud-init plutôt que via `virt-customize`.
- **Réseau privé** : les VM en `10.x` ne sont pas joignables directement → Ansible est exécuté depuis le nœud Proxmox (connexion directe au réseau `10.x`).
- **Conflit cloud-init** : le provider `bpg/proxmox` génère un conflit `user`/`users` sur les images Ubuntu → résolu en fournissant un snippet cloud-init explicite.

---

## Auteur

Mohamed Diagana — TP Cloud M1 — 2026
