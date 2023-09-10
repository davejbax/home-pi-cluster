# Home Pi Cluster

An immutable infrastructure approach to a home Kubernetes cluster.

This repo contains a Packer image build configuration and Ansible Playbooks. These are used to produce a fully configured image which is flashed onto Raspberry Pi 4s, with the intention being that reconfigurations should be done by flashing new images.

## Prerequisites

* [QEMU](https://www.qemu.org/):

  ```console
  apt install -y \
    qemu-user-static \
    binfmt-support \
    qemu-utils
  ```

* [Packer](https://www.packer.io/)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pipx-install)
* [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm)

  ```console
  mkdir -p ~/.config/packer/plugins
  git clone https://github.com/mkaczanowski/packer-builder-arm
  cd packer-builder-arm
  go mod download
  go build -o ~/.config/packer/plugins/packer-builder-arm
  ```

## Building

```console
foo@bar:~$ cd packer
foo@bar:~$ ./build.sh
```
