# Home Infra

This project is for setting up and managing my home infrastructure and lab

* Configure your main workstation as a developer box, including virtualisation through [KVM](https://www.google.com/search?client=firefox-b-d&q=kvm) over [libvirt](https://libvirt.org/)
* Deploy and manage [Public Key Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) through a self deployed certificate authority
* Create [network ingress](https://www.nginx.com/) for delivery of your services
* Deploy and manage [PostgreSQL](https://www.postgresql.org/)
* Install support for various programming lanaguages: [NodeJS](https://nodejs.org/en) via NVM, [Go](https://go.dev/), [Python](https://www.python.org/) via Conda and [Rust](https://www.rust-lang.org/)

## Prerequisites

The only hard requirements to use this project are having [Ansible](https://www.ansible.com/) and openssh.

## Getting Started

There is a bootstrap script to help you get started which will prepare your main device as a virtualisation server, create the virtual machines on your behalf and, prepare an initial inventory.

Running the bootstrap script will:

* Provision your local machine using Ansible for hosting Virtual Machines
* Create some virtual machines on your behalf using Terraform
* Create a barebones inventory file for you to customize. Read [The Environment](#the-environment)

```shell
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

When the bootstrap script completes, a `.bootstrap_config` file is created in your project root saving chosen options related to your Virtual Machines. This allows you to rerun the bootstrap script without any options to bring up your environment quickly. If you would like to reset your environment, delete the file. 

## Environment Configuration

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

## Application services

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

* [git.virt-ubu-0.com](https://git.virt-ubu-0.com) to start hosting code on your self hosted alternative to github
* [jenkins.virt-arch-0.com](https://jenkins.virt-arch-0.com) to start automating your development and deployment workflows. Plugins are automatically installed and an admin user created as part of the Ansible deployment using `jenkins_admin_user_name` (default: admin) and `jenkins_admin_user_pass` (default: development) variables from the role 

## A CICD workflow

In this section, we're going to leverage [Jenkins](https://www.jenkins.io/) and [Forgejo](https://forgejo.org/) to create your first gitops CICD workflow to deploy a full stack project. The tasks we'll perform are:

### Preparing GIT

As this will be your first run of the application services, you'll first need to create an account for [git.virt-ubu-0.com](https://git.virt-ubu-0.com).

We will also use SSH instead of https when interacting with GIT for better security and simplified management. Let's go ahead and create two keys on our `main_workstation`: one for us as a developer and one for Jenkins to use during automation which we'll create in just a moment

```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/personal-infra-forgejo-developer -N ""
ssh-keygen -t rsa -b 4096 -f ~/.ssh/personal-infra-forgejo-jenkins -N ""
```

Configure SSH so that GIT will automatically use our developer key when interacting with forgejo, place the following lines exist in `~/.ssh/config`:

```text
Host git.virt-ubu-0.com
    IdentityFile ~/.ssh/personal-infra-forgejo-developer
```

Next, we're going to configure SSH access from forgejo. Copy the contents of the public key (`~/.ssh/personal-infra-forgejo-developer.pub`) to your clipboard; either manually or using xclip `xclip -sel c < ~/.ssh/personal-infra-forgejo-developer.pub`. From within the web interface, go to your user settings -> SSH / GPG Keys page ([git.virt-ubu-0.com/user/settings/keys](https://git.virt-ubu-0.com/user/settings/keys)), paste the key in to the content box, and click save.

We can test the key has been created by generating a trust signature. Clicking the Verify button from the keys management page which should now show our newly created key. Follow the given instructions on your main_workstation where the keys were created. Note that there is a time limit for the challenge so, if you get an error message about invalid key, try again and complete the signature challenge faster.

With our development user configured, Sign out of forgejo and create  

next we'll create organisation within forgejo to host our repositories; this step is optional but makes management much simpler. Click the New button in the top right toolbar (indicated by `+`) and select organisation. For this guide, I'll call the organisation `symbolic`.

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

## Debugging and Troubleshooting

When managing infrastructure remotely there are a lot of things that can go wrong and, unless you are already an infrastructure engineer, sometimes finding the root cause of the issue can be troublesome. This section aims to provide some guidance for known issues that may crop up related to operations within this repository and ways of investigating; it is not going to be comprehensive though, remember the point of this project is to help you get familiar with running operations!

### Bootstrap script related issues

#### Ansible can't provision my device asking for a sudo password

Running the bootstrap script will install some desktop packages (primarily from the [KDE suite](https://kde.org/), virtualisation software, and Terraform. For this reason, it needs to have elevated privileges.

Include your password when calling bootstrap using either the `-pw` or `--sudo-pw` flag. For example: `./bootstrap.sh -pw='my_password'`

#### Creating machines results in `/dev/tun/tap` issue

It is likely that during system update, part of the VM system (libvirt and KVM/QEMU) was updated. Either restart the service to pickup changes using `systemctl restart libvirtd` or simply restart your device. To manually test the VM system is working, start a [`virsh`](https://libvirt.org/manpages/virsh.html) management shell from your terminal using the following command `virsh -c qemu:///system`.

#### The bootstrap script seems to freeze when creating the machines even though they have been created

Part of the setup for your main device installs [virt-manager](https://virt-manager.org/), a GUI for managing libvirt. Check the status of your machines from within that interface. It is possible your machines are properly being assigned and IP address. To check this case:

* Open a window for the virtual machine in question
* Go to the information tab (second icon along the toolbar)
* View the NIC (Network Interface Card) entry

If your devices are not being designated an IP address, the problem is likely to do with systemd networking (see [this post](https://github.com/systemd/systemd/issues/18761)) being unable to detect the dynamically created libvirt virtual virbr0 interface because it is not present at boot time. The linked post does offer solutions but, the author of this repository prefers to just stop using systemd for handling the network (it is supposed to be an init system after all) and instead use [NetworkManager](https://networkmanager.dev/)

