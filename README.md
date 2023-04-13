# The Lab

This project is for setting up and managing a lab environment to run full end-to-end business services including management and deployment of code. With minor modification and enhanced management of the default configuration, the services can be [used in a production setting](./docs/production.md). The following operating systems (with [identifiers](./docs/identifiers.md)) are supported:

* Armbian (`Debian_aarch64`)
* Arch Linux (`Archlinux_x86_64`)
* Debian Bullseye 11 (`Debian_11_x86_64`)
* Ubuntu Focal LTS 22.04 (`Debian_22_x86_64`)

The playbooks included within this project stem from how I configure my home environment. I have decided to make them public in order to support a new blog series about developers I am starting. Be sure to checkout [simonball.me](https://simonball.me) for more information and a more guided explanation of how to make best use of this project.

Summarized, these playbooks will assist you to:

* Configure your main workstation as a developer box, including virtualisation through [KVM](https://www.google.com/search?client=firefox-b-d&q=kvm) over [libvirt](https://libvirt.org/)
* Deploy and manage [Public Key Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) through a self deployed certificate authority
* deploy a self hosted [code repository](https://forgejo.org/) and [container registry](https://docs.docker.com/registry/)
* Deploy a [automation server](https://www.jenkins.io/) to automatically build, deploy and, manage your services
* Create [network ingress](https://www.nginx.com/) for delivery of your services
* Deploy and manage [MariaDB](https://mariadb.org/) / [PostgreSQL](https://www.postgresql.org/)
* Install support for various programming lanaguages: [NodeJS](https://nodejs.org/en) via NVM, [Go](https://go.dev/), [Python](https://www.python.org/) via Conda and [Rust](https://www.rust-lang.org/)
* Install [Home Assistant](https://www.home-assistant.io/) for interacting with and controlling Smart spaces

## Prerequisites

The only hard requirements to use this project are having [Ansible](https://www.ansible.com/) and an SSH client (most likely [OpenSSH](https://www.openssh.com/)) installed.

## Quickstart

If you are planning to use this as a development environment, there is a bootstrap script to help you get started which will prepare your main device as a virtualisation server, create the virtual machines on your behalf and, prepare an initial inventory.

Running the bootstrap script will:

* Provision your local machine using Ansible for hosting Virtual Machines
* Create some virtual machines on your behalf using Terraform
* Create a barebones inventory file for you to customize. Read [The Environment](#the-environment)

```shell
# Install extra Ansible modules
ansible-galaxy install -r requirements.yml

# Show full usage for the bootstrap script
./bootstrap.sh --help

# Create VM environment with defaults:
# 1 Arch Linux, 1 Debian 11, 1 Ubuntu 22.04 LTS
# 2 CPU per node, 4GB RAM 
./bootstrap.sh

# Create a VM environment with customisation
# 2 Arch Linux, 2 Debian 11, 2 Ubuntu 22.04 LTS
# 4 CPU per node, 8GB RAM
./bootstrap.sh -ncpu=4 -nram=8192 -nd=2 -na=2 -nu=2
```

**NOTE** If you need a password to run privileged actions on your system when running `sudo`, because the bootstrap script helps to install some packages locally, include the `-pw=*` or `--sudo-pw=*` flag. You will likely need this unless your user is in a sudo group with the `NOPASSWD:` option Extending the above example:

```shell
./bootstrap.sh -pw='my_system_password!' -ncpu=4 -nram=8192 -nd=2 -na=2 -nu=2
```

You can rerun the `bootstrap` script as many times as you like to autostart your VMs; it will only be destructive in the event you change configuration options. This means you can with one line boot up your environment fully after system restart. 

## The Environment

This section will assume you have used the bootstrap script, are familiar with the basics of [setting up an Ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) and understand how [Ansible manages secrets](https://docs.ansible.com/ansible/latest/vault_guide/index.html) so, will focus on the need-to-know information to setup a complete IT environment. For expanded information on each capability and configuration options, you are encouraged to [read the roles](./docs/roles.md) documentation.

For having run the bootstrap script, you should have an `inventory.yml` file in your project root that looks similar to the following:

```yaml
#
# Device Definitions
#
hosts:
  main_workstation:
    ansible_connection: local
    ansible_python_interpreter: "{{ ansible_playbook_python }}"
    common_user_create: false
  virt-arch-0:
    fqcdn: virt-arch-0.com
    ansible_host: 192.168.55.10
  virt-debian-0:
    fqcdn: virt-debian-0.com
    ansible_host: 192.168.55.20
    ansible_python_interpreter: /usr/bin/python3
  virt-ubu-0:
    fqcdn: virt-ubu-0.com
    ansible_host: 192.168.55.30   
#
# Role Assignment
#
children:
  ansible_controller:
    hosts:
  certificate_authority:
    hosts:
      virt-arch-0:
  desktop:
    hosts:
      main_workstation:
  developer:
    hosts:
      main_workstation:
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
      main_workstation:
  mariadb:
    hosts:
  nginx:
    hosts:
      virt-arch-0:
      virt-debian-0:
      virt-ubu-0:
  nvm:
    hosts:
  postgresql:
    hosts:
  python:
    hosts:
  rabbitmq:
    hosts:
  redis:
    hosts:
  terraform:
    hosts:
      main_workstation:
  vagrant:
    hosts:
  virtualbox:
    hosts:
```

Things to note about the above:

* Your main device is part of the inventory, here listed as `main_workstation` for clarity. This will reflect the value set within `/etc/hostname`
* Each class of VM operating system is assigned to a similar IP range, grouped by 10. For alphabetical reasons, Arch VMs start at `10`, Debian at `20` and, Ubuntu at `30`.
* The Ansible task `roles/common/tasks/set_inventory_hosts.yml` will have already mapped each address to the `fqcdn` defined in the inventory. Check your `/etc/hosts` file to see this.
* Each device has a `fqcdn` (fully qualified canonical domain name) var associated with it. When we deploy services to each device, by default, the nginx ingress services will use this value along with the service name for certificate generation and delivery. e.g. If we assign the `jenkins` role to `virt-ubu-0`, it will be available via `jenkins.virt-ubu-0.com`.
* Outside of `main_workstation`, only two services have been defined:
  * `certificate_authority`: Using openssl, creates a root and intermediate certificate authority for generating SSH certificates to be used during service deployment. Using `tasks/certificate_authority_trust_chain.yml`, the chain certificate is automatically deployed to each device within your inventory. In short, your system will trust your Ansible deployments; your browser won't require you to add any self-signed certificate exceptions
  * `nginx`: To act as an ingress / reverse proxy for your various services, it will run secure and as a low privilege user

## The CICD services

With your base environment defined, it's time to add some services. The premise behind this project is to get you hosting and running your own CICD system so  append the following roles to your inventory:

```yaml
#
# Role Assignment
#
children:
  docker:
    hosts:
      virt-arch-0:
  docker_container_registry:
    hosts:
      virt-arch-0:
  forgejo:
    hosts:
      virt-ubu-0:
  jenkins:
    hosts:
      virt-arch-0:
  postgresql:
    hosts:
      virt-ubu-0:
```

Now, go ahead and run `ansible-playbook -i ./inventory.yml main.yml`. It may take a while but, once finished, you should be able to visit:

* [forgejo.virt-ubu-0.com](https://forgejo.virt-ubu-0.com) to start hosting code on your self hosted alternative to github
* [jenkins.virt-arch-0.com](https://jenkins.virt-arch-0.com) to start automating your development and deployment workflows

**NOTE** The first time you run Jenkins, it will require you to input an autogenerated password in to the web interface to verify you have legitimate access to the device. This can be attained by running the following:

```shell
ssh -i $HOME/.ssh/thelab-master $(whoami)@virt-arch-0.com 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
```

## Controlling the workflow

If you run the playbooks with a full inventory defined, every role will be run; this might be both time consuminng and tedious if you just want to make changes to a particular service.

The way this repository has been created, there are a few ways to achieve this:

### Using tags

When you call Ansible from the command line, you can use the role name and the tags filter to limit plays which Ansible will even parse. For example, to only work with the `jenkins` role, we use the `--tags` argument and a comma separated list

```shell
ansible-playbook -i ./inventory.yml --tags "jenkins" main.yml
```

### Using the management variables

For a more detailed explanation of how plays are chosen, refer to the [architecture](./docs/architecture.md) page.

Whilst the CLI method works well for simpler roles, because Jenkins has a dependency on the `certificate_authority` and `nginx` role, it will actually fail. A simpler way to restrict Ansible behaviour whilst still functioning correct is to make use of the `include_XXX_management` variables that by default are defined in `group_vars/all.yml`.

```yaml
role_management_enabled: true
include_certificate_authority_management: "{{ role_management_enabled }}"
...
include_terraform_management: "{{ role_management_enabled }}"
```

From the above snippet, there is a boolean condition `role_management_enabled` that will be applied to all roles by default which is true by default. This value could be set to false at any level, either in the *group_vars* or on an individual device in the *inventory*.

For our case where we want to target just the Jenkins role, assuming Nginx and the certificate authority have been setup in advance, you would set `role_management_enabled` to `false` (which in effect means running Ansible won't change anything) and either:

* Change `include_jenkins_management` to `true`
* Or when calling `ansible-playbook` use the `extra-vars` argument and set Jenkins management to true. e.g. `ansible-playbook -i ./inventory.yml --extra-vars "include_jenkins_management=true" main.yml`

## TODO

* [ ] - PostgreSQL role. When SSL on, create key using CA
