# =============================================================
#  Deux VM clonées depuis le template cloud-init (web + db).
#  On utilise for_each : une seule définition, deux machines.
#  Le cloud-init est fourni via un snippet explicite (plus fiable
#  que la directive user_account du provider sur Ubuntu).
# =============================================================

locals {
  vms = {
    web = {
      ip      = var.web_ip
      role    = "Serveur web Wiki.js"
      vm_id   = 100
    }
    db = {
      ip      = var.db_ip
      role    = "Base de donnees PostgreSQL"
      vm_id   = 101
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vms

  name        = "tpcloud-${each.key}"
  description = each.value.role
  node_name   = var.proxmox_node
  vm_id       = each.value.vm_id
  tags        = ["terraform", each.key]

  # Cloner le template préparé manuellement (ID 9000)
  clone {
    vm_id = var.template_id
    full  = true
  }

  # Le guest-agent sera installé par cloud-init
  agent {
    enabled = true
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  # Redimensionne le disque cloné à 20 Go
  disk {
    datastore_id = var.datastore
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = var.bridge
  }

  # On utilise un snippet cloud-init explicite (déposé sur le Proxmox)
  # plutôt que la directive user_account qui crée des conflits sur Ubuntu.
  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    # Référence au snippet cloud-init créé manuellement sur le Proxmox
    user_data_file_id = "local:snippets/tp-cloud-init.yaml"
  }

  started         = true
  stop_on_destroy = true
}
