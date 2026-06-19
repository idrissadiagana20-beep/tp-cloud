# Récapitulatif affiché après le déploiement.

output "vm_ips" {
  description = "Adresses IP (privées) attribuées aux VM"
  value       = { for k, v in local.vms : k => v.ip }
}

output "ssh_users" {
  description = "Utilisateur SSH des VM"
  value       = var.vm_user
}
