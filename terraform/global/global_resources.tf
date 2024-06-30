resource "azurerm_resource_group" "dev-rg" {
  name     = "dev-rg"
  location = "Central India"
  tags = {
    "Environment" = "dev"
    "CreatedByTerraform" = "true"
    "OwningProjects" = "All"
  }
}


resource "azurerm_virtual_network" "vnet-dev" {
  name = "vnet-dev"
  address_space = [
    "192.168.0.0/16"
  ]
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  tags = azurerm_resource_group.dev-rg.tags
}

resource "azurerm_public_ip" "ip-dev" {
  allocation_method = "Static"
  resource_group_name = azurerm_resource_group.dev-rg.name
  name = "ip-dev"
  location = azurerm_resource_group.dev-rg.location
  tags = azurerm_resource_group.dev-rg.tags
  sku = "Standard"
}

resource "azurerm_nat_gateway" "ng-dev" {
  name = "ng-dev"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  tags = azurerm_resource_group.dev-rg.tags
}

resource "azurerm_nat_gateway_public_ip_association" "ng-dev-associate-public-ip" {
  nat_gateway_id = azurerm_nat_gateway.ng-dev.id
  public_ip_address_id = azurerm_public_ip.ip-dev.id
}

resource "azurerm_subnet" "subnet-pub-dev-01" {
  virtual_network_name = azurerm_virtual_network.vnet-dev.name
  address_prefixes = [
    "192.168.18.0/24"
  ]
  resource_group_name = azurerm_resource_group.dev-rg.name
  name = "subnet-pub-dev-01"
}

resource "azurerm_subnet_nat_gateway_association" "name" {
  subnet_id = azurerm_subnet.subnet-pub-dev-01.id
  nat_gateway_id = azurerm_nat_gateway.ng-dev.id
}
