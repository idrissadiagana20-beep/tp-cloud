# Configuration de Terraform/OpenTofu et du provider Proxmox (bpg/proxmox).
terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  # L'endpoint et le token sont lus depuis les variables d'environnement :
  #   PROXMOX_VE_ENDPOINT   = "https://82.64.141.52:5006/"
  #   PROXMOX_VE_API_TOKEN  = "root@pam!terraform=LE_SECRET"
  insecure = true # le Proxmox utilise un certificat auto-signé
}
