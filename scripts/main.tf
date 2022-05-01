# Create new resource group
resource "azurerm_resource_group" "dev-rg" {
  name     = var.rg-dev
  location = var.location
}

#Create Virtual Network
resource "azurerm_virtual_network" "dev-vnet" {
  name                = var.dev-vnet-name
  location            = var.location
  resource_group_name = var.rg-dev
  address_space       = [var.dev-vnet-prefix]
}

#Create Web Subnet
resource "azurerm_subnet" "dev-web-subnet" {
 name                 = var.dev-web-subnet-name
 resource_group_name  = var.rg-dev
 virtual_network_name = var.dev-vnet-name
 address_prefixes     = [var.dev-web-subnet-prefix]
}

#Create Virtual Network Interface
resource "azurerm_network_interface" "web-nic" {
  count               = var.node_count
  name                = "${var.resource_prefix-web}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.rg-dev

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.dev-web-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NSG
resource "azurerm_network_security_group" "web-nsg" {
    name = "WEB-TIER-NSG"
    location = var.location
    resource_group_name = var.rg-dev
    security_rule {
        name = "Inbound"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22-100"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

#Associate NSG to Web Subnet
resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.dev-web-subnet.id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}

#Create Multiple Azure VMs
resource "azurerm_virtual_machine" "webserver-dev" {
  count                 = var.node_count
  name                  = "${var.resource_prefix-web}-${count.index}"
  location              = var.location
  resource_group_name   = var.rg-dev
  network_interface_ids = [element(azurerm_network_interface.web-nic.*.id, count.index)]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.resource_prefix-web}-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.resource_prefix-web}-${count.index}"
    admin_username = "iqbal"
    admin_password = "MySecurePassword123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Development"
  }
}
