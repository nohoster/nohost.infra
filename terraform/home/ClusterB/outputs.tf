output "ip_address-controller" {
  value = libvirt_domain.controller-kvm[*].network_interface[0].addresses[0]
}

output "ip_address-worker" {
  value = libvirt_domain.worker-kvm[*].network_interface[0].addresses[0]
}