resource "libvirt_network" "terraform-net" {
  name      = "terraform${terraform.workspace}-net"
  mode      = "nat"
  addresses = [var.ipv4, var.ipv6]
  autostart = true
}
