resource "azurerm_virtual_network" "puppetvirtualnetwork" {
  name                = "puppet-network"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.puppetrg.location
  resource_group_name = azurerm_resource_group.puppetrg.name
}

resource "azurerm_subnet" "puppetsubnet" {
  name                   = "internal"
  resource_group_name    = azurerm_resource_group.puppetrg.name
  virtual_network_name   = azurerm_virtual_network.puppetvirtualnetwork.name
  address_prefixes       = ["10.1.20.0/24"]
}
