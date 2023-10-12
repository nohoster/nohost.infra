resource "libvirt_network" "terraform-net" {
  name = "terraformB-net"
  mode = "nat"
  addresses = ["192.168.140.0/24"]
  autostart =true
}