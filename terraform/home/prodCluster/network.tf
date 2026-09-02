resource "libvirt_network" "terraform-net" {
  name      = "terraform${terraform.workspace}-net"
  autostart = true

  forward = {
    mode = "nat"
  }

  ips = [
    {
      address = cidrhost(var.network_address[terraform.workspace], 1)
      prefix  = tonumber(split("/", var.network_address[terraform.workspace])[1])
      dhcp = {
        ranges = [{
          start = cidrhost(var.network_address[terraform.workspace], 2)
          end   = cidrhost(var.network_address[terraform.workspace], -2)
        }]
      }
    }
  ]

  dns = {
    enable = "yes"
  }
}
