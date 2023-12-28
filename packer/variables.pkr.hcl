variable "base_image_url" {
  type = string
  description = "URL containing the base image to build from (may be a compressed archive)"
}

variable "base_image_checksum_url" {
  type = string
  description = "URL to the checksum file for the base image; must be SHA256."
}

variable "version" {
  type = string
  description = "The current version of the image"
}

variable "role" {
  type = string
  description = "K3s role of the image to build (valid values: 'server', 'agent')"
  validation {
    condition = (var.role == "server" || var.role == "agent")
    error_message = "Role must be either 'server' or 'agent'."
  }
}

variable "vault_password_file" {
  type = string
  description = "Path to file containing Ansible Vault password"
}
