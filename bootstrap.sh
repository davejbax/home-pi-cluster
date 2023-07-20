#!/usr/bin/env bash
# Run this with:
# apt install -y wget && wget https://raw.githubusercontent.com/davejbax/home-pi-cluster/main/bootstrap.sh && ./bootstrap.sh <server|agent>
set -euo pipefail

col_bold="\e[1m"
col_reset="\e[0m"
col_white="\e[1;37m"
emoji_key="\xF0\x9F\x94\x91"
emoji_disc="\xF0\x9F\x92\xBE"
emoji_robot="\xF0\x9F\xA4\x96"
emoji_package="\xF0\x9F\x93\xA6"
emoji_clone="\xF0\x9F\x90\x91"
emoji_apple="\xF0\x9F\x8D\x8E"

is_root() {
  [[ "${EUID}" -eq 0 ]]
}

install_ssh_key() {
  local dir=${1}
  echo -e "${emoji_key} ${col_white}Adding SSH key into '${dir}'...${col_reset}"
  mkdir -p "${dir}/.ssh"
  cat <<EOF >>~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDxaRkhRcTsRRCTPPWyTExN6i2IXAalN8bXXTYCM2z3/cGN23jc6iQB8q3wPsqEnAWAJD2fY8o6fvTmTfx2Oc5g33qmvWLSXR8XpWDIpoMpLdjPDVnc3WaYd7aIc0elm3XgI3S8kpPT7drWdIuZJnoOsdAAU4C/CPOb6BGCmhJtnzuWQJH/2pPktlQLhow1r5XcoOCKSeBVTEfMik3tJrVh+4WNABJJDMBe4M/PVXHsrHLSXD9KFE+2o+BRnEk8DXQgRBgfL07b7alesXcYTk+JNSs0nvCbUGuQpXOcxGHrbN24jx8g8pVNfTnNaWkIWfrFxW3BlXuF+6BVyKtt+7j7u4+6Ig3+a2/xua8jVaCmkJuVasWCP0/485h9VX41SeC8WChcE1V8eOtrieMXtuYAMODxiQ7pW6lSg+DeqklFa8EyJbEhBLJxkAyRCYkTi2ZBmcxpYV0Iw4btuOukUMaKmVMJ2z4pU46kHdNCKBNMIFyDbZuhAGjItLqjWroQHQab8gxOB2udFUxhYOliOVmROtBeN7lMLqS5f27u/DxEeYexW5VtoUu0eKzt8AZEzFMEB9T1OnogrllaLVZL+xx5M6/OrXHwRfQ1d0Yb5Fta0WzfxsQZrtbFudVZ12Ltyj3yf8NjG9e3rGmtICQESKjiT6i3cVyH1xX794cE1oEIQ== davejbax@gmail.com
EOF
}

install_server_deps() {
  echo -e "${emoji_disc} ${col_white}Installing Git, pipx, and sudo...${col_reset}"
  apt install -y git pipx sudo
}

install_ansible() {
  echo -e "${emoji_robot} ${col_white}Installing Ansible...${col_reset}"
  pipx install --include-deps ansible
  pipx ensurepath
}

update_apt() {
  echo -e "${emoji_package} ${col_white}Updating/upgrading apt packages...${col_reset}"
  apt update
  apt -y full-upgrade
}

clone_repo() {
  echo -e "${emoji_clone} ${col_white}Cloning home-pi-cluster repo...${col_reset}"

  local checkout_dir="${HOME}/home-pi-cluster"

  if [[ -d "${checkout_dir}" ]]; then
    pushd "${checkout_dir}"
    git pull origin main
    popd
  else
    git clone https://github.com/davejbax/home-pi-cluster.git ~/home-pi-cluster
  fi
}

create_user() {
  local user=${1}
  useradd -m "${user}" ||:
  adduser "${user}" sudo ||:
  install_ssh_key "/home/${user}"
}

user_main() {
  install_ansible
  clone_repo
}

main() {
  local type=${1:-agent}
  local user=${2:-dave}

  if [[ "${type}" != "user" ]]; then
    if ! is_root; then
      echo "This script must be run as root." >&2
      exit 1
    fi

    echo -e "Bootstrapping Pi ${col_bold}${type}${col_reset} node"

    install_ssh_key /root
    update_apt

    if [[ "${type}" == "server" ]]; then
      install_server_deps
      create_user "${user}"

      # Hack: work out script path, as the user will be in their home directory
      local script_path
      script_path="$(realpath "${0}")"
      cp "${script_path}" /tmp/bootstrap.sh
      sudo -i -u "${user}" /tmp/bootstrap.sh user
    fi
  else
    user_main
  fi
}

main "$@"
