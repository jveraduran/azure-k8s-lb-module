terraform {
  required_version = ">= 0.12"
}

data "azurerm_resource_group" "main" {
  name = var.resource-group
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.lb_type == "public" ? 1 : 0
  name                = "${var.cluster-name}-${var.environment}-${var.name-suffix}-pip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "load_balancer" {
  name                = "${var.cluster-name}-${var.environment}-${var.lb-type}-${var.name-suffix}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                          = "${var.cluster-name}-${var.environment}-${var.lb-type}-${var.name-suffix}-frontend"
    public_ip_address_id          = var.lb-type == "public" ? join("", azurerm_public_ip.public_ip.*.id) : ""
    subnet_id                     = var.subnet-id
    private_ip_address_allocation = var.frontend-private-ip-address-allocation
    private_ip_address            = var.frontend-private-ip-address-allocation == "Static" ? var.frontend-private-ip-address : ""
  }
}

resource "azurerm_lb_backend_address_pool" "address_pool" {
  name                = "${var.cluster-name}-${var.environment}-${var.lb-type}-${var.name-suffix}-workers"
  resource_group_name = data.azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.load_balancer.id
}

resource "azurerm_lb_rule" "lb_rule" {
  count                          = length(var.lb-ports)
  resource_group_name            = data.azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = element(keys(var.lb-ports), count.index)
  protocol                       = values(var.lb-ports)[count.index][1]
  frontend_port                  = values(var.lb-ports)[count.index][0]
  backend_port                   = values(var.lb-ports)[count.index][2]
  frontend_ip_configuration_name = "${var.cluster-name}-${var.environment}-${var.lb-type}-${var.name-suffix}-frontend"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.address_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = element(concat(azurerm_lb_probe.lb_probe.*.id, list("")), count.index)
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_probe" "lb_probe" {
  count               = length(var.lb-ports)
  resource_group_name = data.azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.load_balancer.id
  name                = element(keys(var.lb-ports), count.index)
  protocol            = values(var.lb-ports)[count.index][4] != "" ? "http" : "Tcp"
  port                = values(var.lb-ports)[count.index][3]
  interval_in_seconds = var.lb-probe-interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = values(var.lb-ports)[count.index][4] != "" ? values(var.lb-ports)[count.index][4] : ""
}