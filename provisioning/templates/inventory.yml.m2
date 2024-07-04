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
      ansible_sudo_pass: '{{ SUDO_PASSWORD }}'
      {{/SUDO_PASSWORD}}
      common_user_create: false{{#ARCH_VMS_MAP}}
    virt-arch-{{.}}:
      fqcdn: virt-arch-{{.}}.com
      ansible_host: 192.168.55.1{{.}}{{/ARCH_VMS_MAP}}{{#DEBIAN_VMS_MAP}}
    virt-debian-{{.}}:
      fqcdn: virt-debian-{{.}}.com
      ansible_host: 192.168.55.2{{.}}
      ansible_python_interpreter: /usr/bin/python3{{/DEBIAN_VMS_MAP}}{{#UBUNTU_VMS_MAP}}
    virt-ubu-{{.}}:
      fqcdn: virt-ubu-{{.}}.com
      ansible_host: 192.168.55.3{{.}}{{/UBUNTU_VMS_MAP}}   
  #
  # Role Assignment
  #
  children:
    ansible_controller:
      hosts:
    certificate_authority:
      hosts:
        {{#ARCH_VMS}}virt-arch-0{{/ARCH_VMS}}{{^ARCH_VMS}}{{#DEBIAN_VMS}}virt-debian-0{{/DEBIAN_VMS}}{{^DEBIAN_VMS}}{{#UBUNTU_VMS}}virt-ubu-0{{/UBUNTU_VMS}}{{/DEBIAN_VMS}}{{/ARCH_VMS}}:
    desktop:
      hosts:
        {{ HOSTNAME }}:
    developer:
      hosts:
        {{ HOSTNAME }}:
    docker:
      hosts:
    docker_container_registry:
      hosts:
    forgejo:
      hosts:
    go:
      hosts:
    home_assistant:
      hosts:
    jenkins:
      hosts:
    kvm:
      hosts:
        {{ HOSTNAME }}:
    mariadb:
      hosts:
    nginx:
      hosts:{{#ARCH_VMS_MAP}}
        virt-arch-{{.}}:{{/ARCH_VMS_MAP}}{{#DEBIAN_VMS_MAP}}
        virt-debian-{{.}}:{{/DEBIAN_VMS_MAP}}{{#UBUNTU_VMS_MAP}}
        virt-ubu-{{.}}:{{/UBUNTU_VMS_MAP}}
    postgresql:
      hosts:
    rabbitmq:
      hosts:
    redis:
      hosts:
    terraform:
      hosts:
        {{ HOSTNAME }}:
    vagrant:
      hosts:
    virtualbox:
      hosts:
