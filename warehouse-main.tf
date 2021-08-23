provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "warehouse-service" {
#   name     = "warehouse-service-resources"
#   location = "westus2"
# }

# resource "azurerm_virtual_network" "warehouse-service" {
#   name                = "warehouse-service-network"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.warehouse-service.location
#   resource_group_name = azurerm_resource_group.warehouse-service.name
# }

# resource "azurerm_subnet" "warehouse-service" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.warehouse-service.name
#   virtual_network_name = azurerm_virtual_network.warehouse-service.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# resource "azurerm_network_interface" "warehouse-service" {
#   name                = "warehouse-service-nic"
#   location            = azurerm_resource_group.warehouse-service.location
#   resource_group_name = azurerm_resource_group.warehouse-service.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.warehouse-service.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_public_ip" "warehouse-service" {
#     name                         = "warehouse IP"
#     location                     = "westus2"
#     resource_group_name          = azurerm_resource_group.warehouse-service.name
#     allocation_method            = "Static"
# }



resource "azurerm_resource_group" "warehouse-rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.warehouse-rg.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.warehouse-rg.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.warehouse-rg.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic-${count.index}"
  location            = "${azurerm_resource_group.warehouse-rg.location}"
  resource_group_name = "${azurerm_resource_group.warehouse-rg.name}"
  tags                = "${var.tags}"
  count               = "3"

  ip_configuration {
    name                          = "testconfiguration${count.index}"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
  }
}