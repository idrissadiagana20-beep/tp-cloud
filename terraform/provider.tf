# Configuration de Terraform/OpenTofu et du provider Azure
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # Le subscription_id est lu automatiquement depuis la
  # variable d'environnement ARM_SUBSCRIPTION_ID (export fait au préalable).
  features {}

  # Compte Azure for Students : on n'a pas les droits pour enregistrer
  # les resource providers, on désactive donc cette tentative automatique.
  resource_provider_registrations = "none"
}
