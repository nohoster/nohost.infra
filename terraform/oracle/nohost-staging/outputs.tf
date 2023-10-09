output "control_nodes_public_IPs" {
  value = [oci_core_instance.control[*].public_ip]
}

output "worker_nodes_public_IPs" {
  value = [oci_core_instance.worker[*].public_ip]
}
