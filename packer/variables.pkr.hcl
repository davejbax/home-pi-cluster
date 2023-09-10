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
