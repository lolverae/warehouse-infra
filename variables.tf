variable "resource_group_name" {
  description = "warehouse-service"
}

variable "vnet_name" {
    description = "Name of the virtual network to create"
    default     = "warehouse-vnet"
}

variable "vm_name" {
    description = "Name of the virtual machine to create"
    default     = "warehouse-vm"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "westus2"
}
