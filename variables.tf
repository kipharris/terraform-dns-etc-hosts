variable "bastion_ip_address" {
  default = ""
}

variable "node_ips" {
  type = "list"
  default = []
}

variable "node_hostnames" {
  type = "list"
  default = []
}

variable "domain" {
  type = "string"
}

variable "ssh_private_key" {
}

variable "ssh_user" {
  default = "root"
}

variable "ssh_password" {
  default = ""
}
