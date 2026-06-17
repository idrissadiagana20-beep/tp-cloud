# Variables du projet : on centralise ici tout ce qui peut changer
# (région, taille de VM, etc.) pour ne pas le coder en dur ailleurs.

variable "prefix" {
  description = "Préfixe utilisé pour nommer toutes les ressources"
  type        = string
  default     = "tpcloud"
}

variable "location" {
  description = "Région Azure où déployer les ressources"
  type        = string
  default     = "westeurope"
}

variable "vm_size" {
  description = "Taille (gabarit) de la VM"
  type        = string
  default     = "Standard_B2ts_v2" # taille disponible et économique à West Europe
}

variable "admin_username" {
  description = "Nom de l'utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique à installer sur la VM"
  type        = string
  default     = "~/.ssh/tp_cloud.pub"
}

variable "my_ip" {
  description = "Ton adresse IP publique en notation CIDR (ex: 88.x.x.x/32) pour restreindre l'accès SSH"
  type        = string
}
