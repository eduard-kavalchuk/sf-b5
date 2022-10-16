output "external_ip_address_lb" {
  value = tolist(tolist(yandex_lb_network_load_balancer.lb.listener)[0].external_address_spec)[0].address
}

output "external_ip_address_lemp" {
  value = module.lemp_server.external_ip_address_vm
}

output "external_ip_address_lamp" {
  value = module.lamp_server.external_ip_address_vm
}

output "access_key" {
  value     = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive = true
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}
