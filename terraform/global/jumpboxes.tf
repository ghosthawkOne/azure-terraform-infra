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
    private_ip_address_allocation = "Static"
  }
}
