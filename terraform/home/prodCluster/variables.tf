variable "os_img_url" {
  description = "URL to the OS image"
  type        = string
  #default     = "https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img"
  default = "/home/images/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "worker_number" {
  description = "Number of workers"
  type        = number
  default = 2
}

variable "control_number" {
  description = "Number of controllers"
  type        = number
  default     = 1
}

variable "network_address" {
  type = string
}

variable "K3S_SECRET" {
  description = "K3s token"
  type        = string
  sensitive = true
}
variable "GITHUB_TOKEN" {
  type = string
  sensitive = true
}
variable "VAULT_TOKEN" {
  type = string
  sensitive = true
}
variable "TAILSCALE_TOKEN" {
  type = string
  sensitive = true
}
