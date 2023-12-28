# TODO:
# - document the SSH port somewhere
# - set default shell to bash
# - apt-get upgrade everything in ansible first

packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "arm" "debian" {
  file_urls = [var.base_image_url]
  file_checksum_url = var.base_image_checksum_url
  file_checksum_type = "sha256"
  file_target_extension = "img.xz"
  file_unarchive_cmd = ["xz", "--keep", "--decompress", "$ARCHIVE_PATH"]

  image_build_method = "resize"
  image_path = "raspi-4-impi-${var.version}-${var.role}.img"
  image_size = "7G"

  # We need to use MBR as the Pi uses an MBR scheme
  image_type = "dos"

  image_partitions {
    filesystem = "vfat"
    mountpoint = "/boot"
    name = "boot"
    size = "256M"
    type = "c"
    start_sector = "2048"
  }

  image_partitions {
    filesystem = "ext4"
    mountpoint = "/"
    name = "root"
    size = "0"
    type = "83"
    start_sector = "526336"
  }

  image_mount_path = "/mnt/raspi-build"

  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.arm.debian"]

  provisioner "shell" {
    inline = [
      "unlink /etc/resolv.conf", # Remove systemd stub
      "echo nameserver 1.1.1.1 >/etc/resolv.conf",
      "apt-get update -y",
      "apt-get install -y python3",
    ]
    inline_shebang = "/usr/bin/sh -e"
  }

  provisioner "ansible" {
    extra_arguments = [
      "--connection=chroot",
      "-e", "ansible_host=/mnt/raspi-build",
      "-e", "k3s_role=${var.role}",
      "--vault-password-file=${var.vault_password_file}",
    ]
    inventory_file = "../ansible/inventory.ini"
    playbook_file = "../ansible/site.yml"
    groups = ["pis", var.role] # XXX: don't think this does anything
    galaxy_file = "../ansible/requirements.yml"
  }
}
