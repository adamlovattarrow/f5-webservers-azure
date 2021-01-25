resource "azurerm_resource_group" "puppetrg" {
  name     = "puppet-resources"
  location = "West Europe"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-resources"
    storage_account_name = "terraformbackendarrow1"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
