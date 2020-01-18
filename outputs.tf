output "load_balancer_ip" {
  value = "${azurerm_public_ip.public_ip.ip_address}"
}

output "lb_address_pool_id" {
  value = "${azurerm_lb_backend_address_pool.address_pool.id}"
}

output "lb_id" {
  value = "${azurerm_lb.load_balancer.id}"
}

output "lb_frontend_ip_configuration_name" {
  value = "${azurerm_public_ip.public_ip.name}"
}

output "lb_probe_id" {
  value = "${azurerm_lb_probe.lb_probe.id}"
}
