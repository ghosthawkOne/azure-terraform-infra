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
  sku_name = "Standard"
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

resource "azurerm_ssh_public_key" "ssh-pub-key" {
  location = azurerm_resource_group.dev-rg.location
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDx03S3hclm8TvkSDGkKUt5zh28vUXDKJVRcN5pIkOyRuAw6CeihNt3iaNBx0QpSg9PU3IMK6qx5cEPAIT2lbbaPFsXEs7clzLfn1nyrtZlKt2B+0ntVYMS/LiR17QW+CkVmXnuV5PPODesTvswrziRYriRsQCRvMup3Foem0ym6ZLUb5KFYECWuC+Vh2iZqlj2PmpoqmgDcDVnBqyAyURPgqQCKzlnsRLtGAf/6/pVvgLrZhHcVLMvkrkzPHzK344S5XM1fCweGgXyjD+t1EBRe1BpK1aOYYKKXJ3I3z5Mbm2T+m/ttSpCYaX+vfjNH1bh/+r7+9+/vVNJ5YT9j9UgXU1PAfVA5Hft+64u78iAAMdRIR6KRFzAaB/IX1avVhbdN3d8DB731Hc1xXESiGUUVD6S1AoN8x0sJwG8QVLmVmmx5N+7wbD9VgXwMUJJgqPatJADbUVpyZpAFZje1S40ywOBesA+6xblmmFT30MIjnVQFdZex7YJJI6EepZBl20= warri@EchelonVI-W11"
  name = "global-ssh-key"
  resource_group_name = azurerm_resource_group.dev-rg.name
}
