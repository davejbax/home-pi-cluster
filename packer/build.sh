#!/usr/bin/env bash
set -euo pipefail

sudo update-binfmts --import

# Assume that the ARM builder plugin is installed in the current user's homedir
sudo PACKER_PLUGIN_PATH="${HOME}/.config/packer/plugins" packer build .
