#!/usr/bin/env bash
# Simple script to generate a CA, and encrypt the key with ansible-vault.
# 
# Usage: ./generate-ca.sh [cn-prefix ...]
set -euo pipefail

create_key() {
  local name="${1}"
  openssl genrsa -out "${name}.key" 4096
  created_keys+=("${name}.key")
}

org=${CA_ORG:-davejbax}
root_cn=${CA_CN:-pi.davejbax.co.uk}

created_keys=()

for service in "${@}"; do
  cn="${service}.${root_cn}"
  create_key "${cn}"

  openssl req -new \
    -days 1825 \
    -nodes \
    -x509 \
    -addext basicConstraints=critical,CA:TRUE \
    -subj "/C=GB/ST=England/L=Manchester/O=${org}/CN=${cn}" \
    -key "${cn}.key" \
    -out "${cn}.pem"
done

read -s -p "Vault password: " vault_pass
echo

for key_file in "${created_keys[@]}"; do
  ansible-vault encrypt \
    --vault-password-file <(cat <<<"${vault_pass}") \
    "${key_file}" \
    --out "${key_file}.enc" 2>/dev/null
  rm -rf "${key_file}"
done

echo "Successfully created certificates and key files for the following CNs:"
for key_file in "${created_keys[@]}"; do
  echo "- ${key_file%.key}"
done
