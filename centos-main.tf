terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "warehouse-rg" {
  name     = "warehouse-project"
  location = "westus2"
}

resource "azurerm_virtual_network" "warehouse-vnet" {
    name                = "warehouse-net"
    address_space       = ["10.0.0.0/16"]
    location            = "westus2"
    resource_group_name = azurerm_resource_group.warehouse-rg.name
}
resource "azurerm_network_interface" "warehouse-nic" {
  name                = "warehouse-interface"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.warehouse-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "ansible-node" {
    name                  = "ansible-node1"
    location              = "westus2"
    resource_group_name   = azurerm_resource_group.warehouse-rg.name
    network_interface_ids = [azurerm_network_interface.warehouse-vnet.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "ansible-node-disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7_8-gen2"
        version   = "latest"
    }

    computer_name  = "ansible-node1"
    admin_username = "ansadmin"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "ansadmin"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    tags = {
        environment = ""
    }
}
