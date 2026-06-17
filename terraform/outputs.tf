# Valeurs affichées par Terraform/OpenTofu à la fin du déploiement,
# pour récupérer facilement l'IP et la commande de connexion.

output "vm_public_ip" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
  description = "Commande prête à l'emploi pour se connecter en SSH"
  value       = "ssh -i ~/.ssh/tp_cloud ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}
