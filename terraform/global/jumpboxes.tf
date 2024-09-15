resource "azurerm_public_ip" "ip-dev-box" {
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  allocation_method = "Static"
  name = "ip-address-dev-box"
  sku = "Standard"
}

resource "azurerm_network_interface" "nif-dev-box" {
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  name = "nif-dev-box"
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.ip-dev-box.id
    name = "nif-dev-box-public-ip-cfg"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  }
}

resource "azurerm_network_security_group" "nsg-dev-box" {
  name = "nsg-dev-box"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
}

resource "azurerm_network_security_rule" "nsg-dev-box-allow-ssh" {
  protocol = "Tcp"
  direction = "Inbound"
  name = "AllowAnyInboundSSH"
  access = "Allow"
  network_security_group_name = azurerm_network_security_group.nsg-dev-box.name
  resource_group_name = azurerm_resource_group.dev-rg.name
  priority = "999"
  destination_port_range = "22"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ngs-dev-box-allow-443" {
  access = "Allow"
  priority = "1000"
  name = "AllowAnyInbound443"
  resource_group_name = azurerm_resource_group.dev-rg.name
  protocol = "Tcp"
  direction = "Inbound"
  network_security_group_name = azurerm_network_security_group.nsg-dev-box.name
  destination_port_range = "443"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ngs-dev-box-allow-80" {
  access = "Allow"
  priority = "1001"
  name = "AllowAnyInbound80"
  resource_group_name = azurerm_resource_group.dev-rg.name
  protocol = "Tcp"
  direction = "Inbound"
  network_security_group_name = azurerm_network_security_group.nsg-dev-box.name
  destination_port_range = "80"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_interface_security_group_association" "assoc-nif-sg-dev-box" {
  network_interface_id = azurerm_network_interface.nif-dev-box.id
  network_security_group_id = azurerm_network_security_group.nsg-dev-box.id
}

resource "azurerm_subnet_network_security_group_association" "name" {
  subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  network_security_group_id = azurerm_network_security_group.nsg-dev-box.id
}
