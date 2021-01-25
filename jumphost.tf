resource "random_password" "adminpassword" {
  length = 16
  special = false
  override_special = "_%@"
}

output "jumphost_password" {
  value = random_password.adminpassword.result
}

resource "azurerm_public_ip" "jumphost-pip" {
  name                = "jumphost-pip"
  resource_group_name = azurerm_resource_group.puppetrg.name
  location            = azurerm_resource_group.puppetrg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jumphostnic" {
  name                = "jumphostnic"
  location            = azurerm_resource_group.puppetrg.location
  resource_group_name = azurerm_resource_group.puppetrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.puppetsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.20.102"
    public_ip_address_id          = azurerm_public_ip.jumphost-pip.id 
  }
}

resource "azurerm_network_interface_security_group_association" "jumphostnsgassoc" {
  network_interface_id      = azurerm_network_interface.jumphostnic.id
  network_security_group_id = azurerm_network_security_group.jumphost.id
  depends_on                = [azurerm_network_security_group.jumphost]
}

data "azurerm_network_interface" "data-jumphost-ip" {
  depends_on          = [azurerm_resource_group.puppetrg]
  name                = azurerm_network_interface.jumphostnic.name
  resource_group_name = azurerm_resource_group.puppetrg.name
}

output "jumphost_private_ip_address" {
  value = data.azurerm_network_interface.data-jumphost-ip.private_ip_address
}


data "azurerm_public_ip" "data-jumphost-pip" {
  depends_on          = [azurerm_resource_group.puppetrg]
  name                = azurerm_public_ip.jumphost-pip.name
  resource_group_name = azurerm_resource_group.puppetrg.name
}

output "jumphost_public_ip_address" {
  value = data.azurerm_public_ip.data-jumphost-pip.ip_address
}

resource "azurerm_linux_virtual_machine" "jumphost" {
  name                = "jumphost"
  resource_group_name = azurerm_resource_group.puppetrg.name
  location            = azurerm_resource_group.puppetrg.location
  size                = "Standard_F1"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jumphostnic.id,
  ]
  depends_on = [azurerm_public_ip.jumphost-pip,random_password.adminpassword]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("keys/id-control_repo.rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.7"
    version   = "latest"
  }
 

  provisioner "file" {
    content     = "[bigip]\ntype f5\nurl https://admin:${random_password.adminpassword.result}@${data.azurerm_network_interface.data-f5-ip.private_ip_address}:8443"
    destination = "/home/adminuser/device.conf"
    connection {
      type = "ssh"
      host =  data.azurerm_public_ip.data-jumphost-pip.ip_address
      user =  "adminuser"
      private_key = file("keys/id-control_repo.rsa")
    }
  } 

  provisioner "remote-exec" {
    inline = [
      "sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
  #    "sudo yum update -y",
      "sudo yum -y groups install 'GNOME Desktop'",
      "sudo yum -y install tigervnc-server xrdp",
      "sudo systemctl start xrdp",
      "sudo systemctl enable xrdp",
      "sudo chcon --type=bin_t /usr/sbin/xrdp",
      "sudo chcon --type=bin_t /usr/sbin/xrdp-sesman",
      "sudo echo ${random_password.adminpassword.result} | sudo passwd --stdin adminuser",
    ]
    connection {
      type = "ssh"
      host =  data.azurerm_public_ip.data-jumphost-pip.ip_address
      user =  "adminuser"
      private_key = file("keys/id-control_repo.rsa")
    }
  }

  provisioner "file" {
    source      = "keys/id-control_repo.rsa"
    destination = "/home/adminuser/id-control_repo.rsa"
    connection {
      type = "ssh"
      host =  data.azurerm_public_ip.data-jumphost-pip.ip_address
      user =  "adminuser"
      private_key = file("keys/id-control_repo.rsa")
      }
    }

}
