resource "azurerm_public_ip" "f5-pip" {
  name                = "f5-pip"
  resource_group_name = azurerm_resource_group.puppetrg.name
  location            = azurerm_resource_group.puppetrg.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "f5nic" {
  name                = "f5nic"
  location            = azurerm_resource_group.puppetrg.location
  resource_group_name = azurerm_resource_group.puppetrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.103"
    public_ip_address_id          = azurerm_public_ip.f5-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "f5nsgassoc" {
  network_interface_id      = azurerm_network_interface.f5nic.id
  network_security_group_id = azurerm_network_security_group.f5.id
  depends_on                = [azurerm_network_security_group.f5]
}


data "azurerm_network_interface" "data-f5-ip" {
  depends_on          = [azurerm_resource_group.puppetrg]
  name                = azurerm_network_interface.f5nic.name
  resource_group_name = azurerm_resource_group.puppetrg.name
}

output "f5_private_ip_address" {
  value = data.azurerm_network_interface.data-f5-ip.private_ip_address
}

data "azurerm_public_ip" "data-f5-pip" {
  depends_on          = [azurerm_resource_group.puppetrg]
  name                = azurerm_public_ip.f5-pip.name
  resource_group_name = azurerm_resource_group.puppetrg.name
}

output "f5_public_ip_address" {
  value = data.azurerm_public_ip.data-f5-pip.ip_address
}

resource "azurerm_linux_virtual_machine" "f5" {
  name                = "f5"
  resource_group_name = azurerm_resource_group.puppetrg.name
  location            = azurerm_resource_group.puppetrg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  depends_on          = [azurerm_marketplace_agreement.bigip,azurerm_linux_virtual_machine.jumphost]
  network_interface_ids = [
    azurerm_network_interface.f5nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("keys/id-control_repo.rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = "f5-big-ip-byol"
    sku       = "f5-big-all-1slot-byol"
    version   = "latest"
  }

  plan {
    name = "f5-big-all-1slot-byol"
    publisher = "f5-networks"
    product = "f5-big-ip-byol"
  }

 provisioner "remote-exec" {                                                                
  inline = [             
    "sudo chmod 400 /home/adminuser/id-control_repo.rsa",
    "sudo cat /home/adminuser/id-control_repo.rsa",                                                                  
    "echo 'sudo ssh -o StrictHostKeyChecking=no -v -i /home/adminuser/id-control_repo.rsa adminuser@${data.azurerm_network_interface.data-f5-ip.private_ip_address} 'modify auth user admin password ${random_password.adminpassword.result}'' > /home/adminuser/configuref5.sh",
    "echo 'sudo ssh -o StrictHostKeyChecking=no -v -i /home/adminuser/id-control_repo.rsa adminuser@${data.azurerm_network_interface.data-f5-ip.private_ip_address} \"bash -c \\\"SOAPLicenseClient --basekey \\\"${var.f5key}\\\"\\\"\"'  >> /home/adminuser/configuref5.sh",
    "echo 'sudo ssh -o StrictHostKeyChecking=no -v -i /home/adminuser/id-control_repo.rsa adminuser@${data.azurerm_network_interface.data-f5-ip.private_ip_address} 'revoke /sys license'' > /home/adminuser/revoke.sh",
    "sudo chmod +x /home/adminuser/configuref5.sh",         
    "sudo chmod +x /home/adminuser/revoke.sh",         
    "echo 'configuring f5'; sleep 300; sudo bash -c /home/adminuser/configuref5.sh",         
  ]                                                                                        
    connection {                                                                             
      type = "ssh"                                                                           
      host =  data.azurerm_public_ip.data-jumphost-pip.ip_address                            
      user =  "adminuser"                                                                    
      private_key = file("keys/id-control_repo.rsa")                                         
    } 
  }
}


resource "azurerm_marketplace_agreement" "bigip" {
  publisher = "f5-networks"
  offer     = "f5-big-ip-byol"
  plan      = "f5-big-all-1slot-byol"
}
