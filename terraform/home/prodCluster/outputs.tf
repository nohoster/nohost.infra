output "ip_address-controller" {
  value = [for d in data.libvirt_domain_interface_addresses.controller : d.interfaces[0].addrs[0].addr]
}

output "ip_address-worker" {
  value = [for d in data.libvirt_domain_interface_addresses.worker : d.interfaces[0].addrs[0].addr]
}