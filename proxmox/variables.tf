# Variables du déploiement Proxmox.

variable "proxmox_node" {
  description = "Nom du nœud Proxmox"
  type        = string
  default     = "pve"
}

variable "template_id" {
  description = "ID du template cloud-init à cloner"
  type        = number
  default     = 9000
}

variable "datastore" {
  description = "Stockage où placer les disques des VM"
  type        = string
  default     = "local-lvm"
}

variable "bridge" {
  description = "Pont réseau auquel rattacher les VM"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Passerelle réseau (accès Internet)"
  type        = string
  default     = "10.0.1.1"
}

variable "web_ip" {
  description = "IP statique de la VM web (avec masque CIDR)"
  type        = string
  default     = "10.0.50.50/8"
}

variable "db_ip" {
  description = "IP statique de la VM base de données (avec masque CIDR)"
  type        = string
  default     = "10.0.50.51/8"
}

variable "vm_user" {
  description = "Utilisateur créé sur les VM par cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique à installer sur les VM"
  type        = string
  default     = "~/.ssh/tp_cloud.pub"
}

variable "vm_cores" {
  description = "Nombre de cœurs CPU par VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Mémoire (Mo) par VM"
  type        = number
  default     = 2048
}
