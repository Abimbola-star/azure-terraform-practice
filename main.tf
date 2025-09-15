terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}
/*
terraform {
  required_providers {
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.7"
    }
  }
}
*/


provider "azurerm" {
  # Configuration options
  features {}
  resource_provider_registrations = "none"
}

