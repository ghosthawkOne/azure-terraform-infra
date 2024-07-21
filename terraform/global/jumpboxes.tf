resource "azurerm_public_ip" "ip-jumpbox" {
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  allocation_method = "Static"
  name = "ip-address-jumpbox"
  sku = "Standard"
}

resource "azurerm_network_interface" "nif-jumpbox" {
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  name = "nif-jumpbox"
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.ip-jumpbox.id
    name = "nif-jumpbox-public-ip-cfg"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  admin_ssh_key {
    public_key = azurerm_ssh_public_key.ssh-pub-key.public_key
    username = "servrfarmer"
  }
  admin_username = "servrfarmer"
  computer_name = "jumpbox.servrfarm.tech"
  name = "jumpbox"
  disable_password_authentication = true
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  size = "Standard_B2ms"
  network_interface_ids = [azurerm_network_interface.nif-jumpbox.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "cloudflare_record" "jumpbox-dns" {
  type = "A"
  name = azurerm_linux_virtual_machine.jumpbox.name
  zone_id = "72b99a897ca7debf9e960abcbab1c124"
  proxied = false
  value = azurerm_public_ip.ip-jumpbox.ip_address
}

resource "azurerm_network_security_group" "nsg-jumpbox" {
  name = "nsg-jumpbox"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
}

resource "azurerm_network_security_rule" "nsg-jumpbox-allow-ssh" {
  protocol = "Tcp"
  direction = "Inbound"
  name = "Allow Incoming SSH"
  access = "Allow"
  network_security_group_name = azurerm_network_security_group.nsg-jumpbox.name
  resource_group_name = azurerm_resource_group.dev-rg.name
  priority = "101"
  destination_port_range = "22"
  source_port_range = "*"
}

resource "azurerm_network_interface_security_group_association" "assoc-nif-sg-jumpbox" {
  network_interface_id = azurerm_network_interface.nif-jumpbox.id
  network_security_group_id = azurerm_network_security_group.nsg-jumpbox.id
}

resource "azurerm_subnet_network_security_group_association" "name" {
  subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  network_security_group_id = azurerm_network_security_group.nsg-jumpbox.id
}
