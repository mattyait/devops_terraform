resource "azurerm_resource_group" "resource-grp" {
  name     = "matty-tf-resources"
  location = "Australia Southeast"
}

resource "azurerm_network_security_group" "virtual-network-sg" {
  name                = "matty-tf-security-group"
  location            = azurerm_resource_group.resource-grp.location
  resource_group_name = azurerm_resource_group.resource-grp.name
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

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "virtual-network" {
  name                = "matty-virtual-network"
  location            = azurerm_resource_group.resource-grp.location
  resource_group_name = azurerm_resource_group.resource-grp.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.virtual-network-sg.id
  }

  tags = {
    environment = "test"
    Created_By = "Terraform"
  }
}
