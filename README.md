# Home Pi Cluster

Ansible configuration for my home Raspberry Pi cluster.

## Installation

Clone the repo, and install Ansible Galaxy dependencies:

```shell
ansible-galaxy install -r requirements.yml
```

## Deployment

Deploy the `site.yml` playbook as follows:

```shell
ansible-playbook -i inventory.ini --ask-vault-pass site.yml
