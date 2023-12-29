#!/usr/bin/env bash
set -euo pipefail

role="${1:?"Usage: ${0} <role> [base]"}"
base="${2:-ubuntu}"

if [[ -z "${ANSIBLE_VAULT_PASSWORD_FILE-}" ]]; then
  read -s -p "Ansible vault password: " vault_password
  temp_password_file="$(mktemp)"
  trap 'rm -rf -- "$temp_password_file"' EXIT
  chmod 0600 "${temp_password_file}"
  echo "${vault_password}" >"${temp_password_file}"

  ANSIBLE_VAULT_PASSWORD_FILE="${temp_password_file}"
fi

if [[ -z "${HCP_CLIENT_ID-}" ]]; then
  read -s -p "Hashicorp Cloud Platform client ID: " HCP_CLIENT_ID
  export HCP_CLIENT_ID
fi

if [[ -z "${HCP_CLIENT_SECRET-}" ]]; then
  read -s -p "Hashicorp Cloud Platform client secret: " HCP_CLIENT_SECRET
  export HCP_CLIENT_SECRET
fi

packer_source_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

sudo update-binfmts --import

# Assume that the ARM builder plugin is installed in the current user's homedir
pushd "${packer_source_dir}"
sudo -E env "PATH=${PATH}" PACKER_PLUGIN_PATH="${HOME}/.config/packer/plugins" packer \
  build \
  -var-file "${packer_source_dir}/params/${base}.pkrvars.hcl" \
  -var-file "${packer_source_dir}/params/${role}.pkrvars.hcl" \
  -var "vault_password_file=${ANSIBLE_VAULT_PASSWORD_FILE}" \
  "${packer_source_dir}"
popd
