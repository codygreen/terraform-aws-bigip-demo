output "bigip_mgmt_public_ips" {
  value = module.bigip.mgmt_public_ips
}

output "bigip_mgmt_port" {
  value = module.bigip.mgmt_port
}

output "bigip_password" {
  value = module.bigip.password
}

output "nginx_ips" {
  value = module.nginx-demo-app.private_ips
}
