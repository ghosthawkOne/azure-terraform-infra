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

resource "azurerm_network_security_group" "nsg-jumpbox" {
  name = "nsg-jumpbox"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
}

resource "azurerm_network_security_rule" "nsg-jumpbox-allow-ssh" {
  protocol = "Tcp"
  direction = "Inbound"
  name = "AllowAnyInboundSSH"
  access = "Allow"
  network_security_group_name = azurerm_network_security_group.nsg-jumpbox.name
  resource_group_name = azurerm_resource_group.dev-rg.name
  priority = "999"
  destination_port_range = "22"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ngs-jumpbox-allow-443" {
  access = "Allow"
  priority = "1000"
  name = "AllowAnyInbound443"
  resource_group_name = azurerm_resource_group.dev-rg.name
  protocol = "Tcp"
  direction = "Inbound"
  network_security_group_name = azurerm_network_security_group.nsg-jumpbox.name
  destination_port_range = "443"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ngs-jumpbox-allow-80" {
  access = "Allow"
  priority = "1001"
  name = "AllowAnyInbound80"
  resource_group_name = azurerm_resource_group.dev-rg.name
  protocol = "Tcp"
  direction = "Inbound"
  network_security_group_name = azurerm_network_security_group.nsg-jumpbox.name
  destination_port_range = "80"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_interface_security_group_association" "assoc-nif-sg-jumpbox" {
  network_interface_id = azurerm_network_interface.nif-jumpbox.id
  network_security_group_id = azurerm_network_security_group.nsg-jumpbox.id
}

resource "azurerm_subnet_network_security_group_association" "name" {
  subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  network_security_group_id = azurerm_network_security_group.nsg-jumpbox.id
}
