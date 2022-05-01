variable "location" {
  description = "Lokasi untuk menyimpan resource"
  default = "Southeast Asia"
}

variable "rg-dev" {
  description = "Resource Group untuk Dev Environment"
  default = "terraform-lab"
}

variable "tags-dev" {
  default = "Development"
}

variable "dev-vnet-name" {
  default = "dev-vnet"
  description = "Development VNET Name"
}

variable "dev-web-subnet-name" {
  default = "dev-web-subnet"
  description = "Development Web Subnet Name"
}

variable "dev-vnet-prefix" {
  description = "preifix ip untuk development vnet"
  default = "192.168.180.0/22"
}

variable "dev-web-subnet-prefix" {
  description = "prefix ip untuk subnet web dev"
  default = "192.168.182.0/24"
}

#Change it to number of VMs you want 
variable "node_count" {
  default = "10"
}

variable "resource_prefix-web" {
  default = "web-server"
}
