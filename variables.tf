variable "api_url" {
  description = "URL to the API of Proxmox"
  type        = string
  default     = "https://192.168.1.101:8006/api2/json"
}

variable "user" {
  description = "Name of the admin account to use"
  type        = string
  default     = "terraform-prov@pve"
}

variable "passwd" {
  description = "Password for the Terraform user - defined in the file terraform.tfvars"
  type        = string
  sensitive   = true
}

variable "target_host" {
  description = "Hostname to deploy to"
  default     = "dantooine"
  type        = string
}

variable "lxc_passwd" {
  description = "Password for the root user on containers"
  type        = string
  sensitive   = true
}

variable "storage_name" {
  description = "Storage name on Proxmox server"
  default     = "vm-data"
  type        = string
}

variable "image" {
  description = "Name of the template to clone"
  type        = string
  default     = "local:iso/talos-metal-amd64.iso"
}

variable "pool" {
  type        = string
  description = "In what pool is this deployed ?"
  default     = "talos-dev"
}

variable "ansible_password" {
  type        = string
  description = "Password for the ansible user"
  sensitive   = true
}
variable "ansible_public_ssh_key" {
  type        = string
  description = "Private SSH key for the user ansible"
  sensitive   = true

}
