// terraform Config Block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

// Provider
provider "azurerm" {
  features {}
}

// Resource Group
resource "azurerm_resource_group" "AZP-Dev" {
  name     = var.rg_name
  location = var.location
}


// Virtual Network
resource "azurerm_virtual_network" "AZP-Dev" {
  name = "${var.project_name}-network"
  resource_group_name = var.rg_name
  location = var.location
  address_space = ["10.0.0.0/16"]
}

// Subnet
resource "azurerm_subnet" "AZP-Dev" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.AZP-Dev.name
  address_prefixes     = ["10.0.2.0/24"]
}

// Public IP
resource "azurerm_public_ip" "AZP-Dev" {
  name                = "${var.project_name}-pub-ip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
}

// Network Security Group

resource "azurerm_network_security_group" "AZP-Dev" {
  name                = "${var.project_name}-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Network Interface/NSG Group Association

resource "azurerm_network_interface_security_group_association" "AZP-Dev" {
  network_interface_id      = azurerm_network_interface.AZP-Dev.id
  network_security_group_id = azurerm_network_security_group.AZP-Dev.id
}

// Network Interface

resource "azurerm_network_interface" "AZP-Dev" {
  name                = "${var.project_name}-nic"
  location = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.project_name}-nic-ip"
    subnet_id                     = azurerm_subnet.AZP-Dev.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.AZP-Dev.id
  }
}

// Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "AZP-Dev" {
  name                = "${var.project_name}-vm"
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_name
  network_interface_ids = [
    azurerm_network_interface.AZP-Dev.id,
  ]

  admin_ssh_key {
    username   = var.admin_name
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
