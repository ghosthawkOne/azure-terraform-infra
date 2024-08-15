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

resource "azurerm_linux_virtual_machine" "dev-box" {
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  network_interface_ids = [
    azurerm_network_interface.nif-dev-box.id
  ]
  admin_username = "farmer"
  admin_ssh_key {
    public_key = azurerm_ssh_public_key.ssh-pub-key.public_key
    username = "farmer"
  }
  name = "dev-box.servrfarm.tech"
  size = "Standard_B2ms"
  os_disk {
    disk_size_gb = 32
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "dev-box-storage" {
  name = "dev-box-storage"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 32
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach-dev-box-storage-to-dev-box" {
  managed_disk_id = azurerm_managed_disk.dev-box-storage.id
  virtual_machine_id = azurerm_linux_virtual_machine.dev-box.id
  lun = 10
  caching = "ReadWrite"
}

variable "cloudflare_zone_id" {
  type = string
  sensitive = true
  description = "Cloudflare Zone ID"
  nullable = false
}

resource "cloudflare_record" "dev-box-dns-record-cloudflare" {
  allow_overwrite = true
  comment = format("DNS record for %s", azurerm_linux_virtual_machine.dev-box.name)
  type = "A"
  name = azurerm_linux_virtual_machine.dev-box.name
  zone_id = var.cloudflare_zone_id
  ttl = 60
  content = azurerm_public_ip.ip-dev-box.ip_address
}

locals {
  vm_name = azurerm_linux_virtual_machine.dev-box.name
  vm_ipv4_address = azurerm_public_ip.ip-dev-box.ip_address
  vm_username = azurerm_linux_virtual_machine.dev-box.admin_username
}

output "ansible_inventory" {
  value = yamlencode({
    all = {
      hosts = {
        "${azurerm_linux_virtual_machine.dev-box.name}" = {
          ansible_host                  = azurerm_public_ip.ip-dev-box.ip_address
          ansible_user                  = azurerm_linux_virtual_machine.dev-box.admin_username
          ansible_port                  = 22
        }
      }
    }
  })
}
