---
all:
  vars:
    ansible_user: {{ MASTER_USER }}
    ansible_ssh_private_key_file: {{ SSH_KEY_MASTER_PATH }}
    ansible_ssh_common_args: -o StrictHostKeyChecking=no
  #
  # Device Definitions
  #
  hosts:
    {{ HOSTNAME }}:
      ansible_connection: local
      ansible_python_interpreter: "{{ OPEN }} ansible_playbook_python {{ CLOSE }}"
      {{#SUDO_PASSWORD}}
      ansible_sudo_pass: {{ SUDO_PASSWORD }}
      {{/SUDO_PASSWORD}}
      common_user_create: false
      include_certificate_authority_management: false
  #
  # Role Assignment
  #
  children:
    desktop:
      hosts:
        {{ HOSTNAME }}:
    kvm:
      hosts:
        {{ HOSTNAME }}:
    terraform:
      hosts:
        {{ HOSTNAME }}:
