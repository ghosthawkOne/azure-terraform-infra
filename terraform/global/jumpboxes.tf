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
