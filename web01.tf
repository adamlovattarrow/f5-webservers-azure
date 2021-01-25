resource "azurerm_network_interface" "web01" {
  name                = "web01"
  location            = azurerm_resource_group.puppetrg.location
  resource_group_name = azurerm_resource_group.puppetrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.11"
    primary                       = true
  }

    ip_configuration {
    name                          = "internal-12"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.12"
  }

    ip_configuration {
    name                          = "internal-13"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.13"
  }

    ip_configuration {
    name                          = "internal-14"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.14"
  }

    ip_configuration {
    name                          = "internal-15"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.15"
  }

    ip_configuration {
    name                          = "internal-16"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.16"
  }

    ip_configuration {
    name                          = "internal-17"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.17"
  }

    ip_configuration {
    name                          = "internal-18"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.18"
  }

    ip_configuration {
    name                          = "internal-19"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.19"
  }

}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("bootstrap-web.sh")
}


data "azurerm_network_interface" "web01-ip" {
  depends_on          = [azurerm_resource_group.puppetrg, azurerm_network_interface.web01]
  name                = azurerm_network_interface.web01.name
  resource_group_name = azurerm_resource_group.puppetrg.name
}

output "web01_private_ip_address" {
  value = data.azurerm_network_interface.web01-ip.private_ip_address
}

resource "azurerm_linux_virtual_machine" "web01" {
  name                  = "web01"
  resource_group_name   = azurerm_resource_group.puppetrg.name
  location              = azurerm_resource_group.puppetrg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  depends_on            = [azurerm_linux_virtual_machine.jumphost]
  network_interface_ids = [
    azurerm_network_interface.web01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("keys/id-control_repo.rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

}
