#!/usr/bin/env bash
set -euo pipefail

readonly mountpoint="/mnt/raspi-hostname"
readonly image=${1-}
readonly hostname=${2-}

if [[ -z "${image}" ]] || [[ -z "${hostname}" ]]; then
    echo >&2 "Usage: $0 <image> <hostname>"
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo >&2 "This script can only be run as root"
    exit 2
fi

mkdir -p "${mountpoint}"
losetup -o 269484032 /dev/loop0 "${image}"
mount /dev/loop0 "${mountpoint}"
echo "${hostname}" > "${mountpoint}/etc/hostname"
echo "127.0.0.1 ${hostname}" >> "${mountpoint}/etc/hosts"
echo "::1 ${hostname}" >> "${mountpoint}/etc/hosts"
umount "${mountpoint}"
losetup -d /dev/loop0
rm -d "${mountpoint}"

mv "${image}" "${hostname}.${image}"
