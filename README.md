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

If you are planning to use this as a development environment, there is a bootstrap script to help you get started which will prepare your main device as a virtualisation server, create the virtual machines on your behalf and, prepare an initial inventory 

```
# Install extra Ansible modules
ansible-galaxy install -r requirements.yml

# Show full usage for the bootstrap script
./bootstrap.sh --help

# Create a VM environment with one of each supported operating system. Each device will
# have 4 cores and 8GB or RAM
./bootstrap.sh -ncpu=4 -nram=8192 -nd=1 -na=1 -nu=1
```

**NOTE** If you need to use a password for sudo access on your main workstation (good practise dictates you should), because the bootstrap script helps to install some packages, include the `-pw=* --sudo-pw=*` flag. Extending the above example:

```
./bootstrap.sh -pw='my_password!' -ncpu=4 -nram=8192 -nd=1 -na=1 -nu=1
```

You can rerun the `bootstrap` script as many times as you like to autostart your VMs; it will only be destructive in the event you change configuration options. This means you can with one line boot up your environment fully after system restart. 

## Configuring your business environment

This section will assume you have used the bootstrap script, are familiar with the basics of [setting up an Ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) and understand how [Ansible manages secrets](https://docs.ansible.com/ansible/latest/vault_guide/index.html) so, will focus on the need-to-know information to setup a complete IT environment

For expanded information on each capability and configuration options, you are encouraged to [read the roles](./docs/roles.md) documentation.

### Common

Preparing base packages and services to be present on all devices:

* Container runtime - Docker (soon to include podman option)
* Version control - GIT
* System auditing - Lynis
* Rich shell - ZSH preconfigured

#### Variables designed for customisation

```

```

## Preparing your devices

### Arch Linux



### Ubuntu

### Windows 11

If going to be using Armbian, you will need to manually download USBImager; don't use echer. https://gitlab.com/bztsrc/usbimager

### Orange Pi5 - Armbian

Setting up to boot from NVM drive

```
 Clear disk in case there are partitions already.

 

dd if=/dev/zero of=/dev/nvme0n1 bs=1M count=1
dd if=/dev/zero of=/dev/mtdblock0 bs=1M count=1

 

Create partitions, format them and set labels.
 

# create partitions
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart primary fat16 17m 285m
parted -s /dev/nvme0n1 name 1 '"bootfs"'
parted -s /dev/nvme0n1 set 1 bls_boot on
parted -s /dev/nvme0n1 mkpart primary ext4 285m 100%
parted -s /dev/nvme0n1 name 2 '" "'

# format partitions
mkfs.fat /dev/nvme0n1p1
mkfs.ext4 -F /dev/nvme0n1p2

# create labels
dosfslabel /dev/nvme0n1p1 armbi_boot
tune2fs -L armbi_root /dev/nvme0n1p2

 

Install the existing system onto the NVMe.

    Select "Boot from MTD Flash, system on SATA, USB or NVMe"
    Select the partition "/dev/nvme0n1p2" for rootfs and format as EXT4
    Then it installs bootloader to SPI (mtdblock0)
    Select "Exit" instead of "Power off"

Since the armbian-install command does not copy data to the dedicated /boot partition and also does not update all files, we prepare the bootfs manually.

 

mkdir /mnt/boot /mnt/root
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p2 /mnt/root
    
rsync -av /boot/* /mnt/boot/
rsync -av /boot/* /mnt/root/boot/

# The set command is "fish" shell syntax
set UUID (blkid -o export /dev/nvme0n1p2 | grep -E '(^UUID=)' | cut -d '=' -f 2)
sed -i "s#rootdev=UUID=[A-Fa-f0-9-]*#rootdev=UUID=$UUID#" /mnt/boot/armbianEnv.txt
sed -i "s#rootdev=UUID=[A-Fa-f0-9-]*#rootdev=UUID=$UUID#" /mnt/root/boot/armbianEnv.txt

# not needed, installer updated to the correct UUID already
#sed -i "s#UUID=[A-Fa-f0-9-]* / ext4#UUID=$UUID / ext4#" /mnt/root/etc/fstab
    
# Works without the next 2 steps.
# /dev/nvme0n1p1 is not mounted as /boot partition and the armbian-install installed all /boot files into the /boot folder on the rootfs partition
# Not sure which way is better. With or without /boot partition
set UUID (blkid -o export /dev/nvme0n1p1 | grep -E '(^UUID=)' | cut -d '=' -f 2)
echo "UUID=$UUID /boot vfat defaults 0 2" >> /mnt/root/etc/fstab

    Power off
    Remove SD card
    Boot from NVMe
```


## Inventory Management {#inventory-management}

## Security - keeping things safe and maintaining secrets

## BONUS - Virtual Machines

# Summary

This project contains formula for setting up a new batch of devices either via Vagrant and Virtualbox, through Terraform and qemu, or through Terraform and Digital Ocean.

You should read this document fully before any of the provider specific instructions below in order to orient yourself. Note that github webhooks will only work using the `jenkins.pledgecamp.com` domain.

* [Digital Ocean](https://www.digitalocean.com/) - [**DOCS**](docs/terraform_digital_ocean.md)
* [Libvirt (QEMU)](https://qemu.org/drvqemu.html) - [**DOCS**](docs/terraform_qemu)
* [Virtualbox](https://www.virtualbox.org/) / [Vagrant](https://www.vagrantup.com/) - [**DOCS**](docs/terraform_vagrant.md)

## Prerequisites

The following tools / pieces of information are required before proceeding:

* [Terraform](https://www.terraform.io/) - If you are going to be setting up devices / virtual machines from scratch
* [Ansible](https://www.ansible.com/) - The python task runner which all these playbooks run on
* `Vault Password` - For unlocking the secrets file, it should be placed in the project root in a file titled `vault_pass`
* `Jenkins Backup` (recommended) - If intending to bootstrap the Jenkins instance with Jobs, leaving only credentials configuration up to you, you should obtain a copy of the jobs backup from the Google Drive. This archive should be placed in the root of this project with the `jenkins-backup.tar.gz` file name.

## Getting Started

You can run the `dev.sh` script within the project root to get a base set of nodes setup and ready to be worked on. This will create three nodes for you

* Jenkins master at `192.168.55.5` which is used for managing devices / software
* Two Nodes with `192.168.55.10` and `192.168.55.11` used for running all Pledgecamp services on. See the `inventory.yml` file for more information

For addresses / services to work properly, you should start by having the following rules present in your `/etc/hosts` file

```
# Jenkins
192.168.55.5 automation.vmdev.com
# Node1
192.168.55.10 db.vmdev.com
192.168.55.10 frontend.vmdev.com
192.168.55.10 kibana.vmdev.com
192.168.55.10 tokenbridge.vmdev.com
192.168.55.10 tokenbridge-backend.vmdev.com
# Node2
192.168.55.11 backend.vmdev.com
192.168.55.11 shortener.vmdev.com
```
### Linux

```
# Box setup
cd terraform_qemu
terraform init
terraform apply -auto-approve -var="deploy_type=jenkins"
# This is the Jenkins admin pass you'll need
cat jenkinspass
```

### Mac OSX

```
# Box setup
cd vagrant
CREATE_JENKINS=1 vagrant up
# Jenkins setup
ansible-playbook --vault-password-file=../vault_pass -i ../development/jenkins_inventory.yml --extra-vars "ansible_ssh_private_key_file=../development/ansible_ssh_development ansible_ssh_user=lordy" ../jenkins.yml
# Retrieve Jenkins secret
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../development/ansible_ssh_development lordy@192.168.55.5 sudo cp /var/lib/jenkins/secrets/initialAdminPassword /tmp/jenkinspass
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../development/ansible_ssh_development lordy@192.168.55.5 sudo chmod 777 /tmp/jenkinspass
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../development/ansible_ssh_development lordy@192.168.55.5:/tmp/jenkinspass ./jenkinspass
# This is the Jenkins admin pass you'll need
cat jenkinspass
# Base setup of Nodes
ansible-playbook --vault-password-file=../vault_pass -i ../development/inventory.yml --extra-vars "ansible_ssh_private_key_file=../development/ansible_ssh_development ansible_ssh_user=lordy" ../main.yml --tags maintenance
# Copy across Ansible inventory for Jenkins usage
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/ansible_pledgecamp_jenkins ../development/inventory.yml jenkins@192.168.55.5:/opt/pledgecamp/inventory.yml
```

**SPECIAL NOTE** - When using self signed certificates for domains, OSX will not allow the user to proceed unless a special rule has been created. To create this rule, from within the browser (assuming Chrome):

* Bring up the certificate by clicked the `Not Secure` section to the left of your URL bar and choosing certificate
* Click and drag the certificate to your desktop (or any folder)
* Open up the `Keychain Access` program and select the `Certificates` category.
* click and drag the certificate in to the window. IT should appear on the list of certificates
* Double click the certificate to bring up details and expand the `Trust` section
* From the "When using this certificate" dropdown, choose select all
* Close the window, OSX should ask you for authorisation in order to proceed
* With the certificate now trusted, you will be able to proceed from within the browser

### Jenkins Configuration

If you used the `dev.sh` script to initialize the machines, you should be at the point of needing to setup a set of credentials for Jenkins to utilize.

The values are as follows:

* **ANSIBLE_VAULT_PASS** - Contents of the `vault_pass` file
in your chosen terraform provider path
* **DOCKER_HUB_CREDENTIALS** - Username and password for access to container registry, both push and pull rights required
* **GITHUB_KEY** - Username / SSH key for accessing Pledgecamp projects
* **GITHUB_WEBHOOK_TOKEN** - A common suffix string used for `Github -> Jenkins` calls
* **INVENTORY_COMMON_KEY** - Username `jeeves` and contents of `$HOME/.ssh/ansible_pledgecamp_jeeves`
* **INVENTORY_SUDO_KEY** - If Digital Ocean, `root` as username and contents of `$HOME/.ssh/pledgecamp_digital_ocean`. If using VMs `lordy` as username and contents of `$HOME/pledgecamp/pledgecamp-inventory/development/ansible_ssh_development`

# Ansible

There is a single playbook covering all aspects of device / service management in the root of the project `main.yml`. Aside from following the [standard Ansible best practises](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html), the following design decisions / patterns have been implemented.

* No concept of SSH user connection is defined within the playbooks themselves. It is up to the user to define these as process arguments from within `--extra-vars`.
* The default variable values are defined for usage within a development environment. Real world values should be defined in the inventory / group_vars definitions as overrides.
* A low privilege user is created on each device for actions to be carried out beyond initial setup for security sake. In theory, the super user is removable once a device has been setup.
* Depending on the SSH user being used to access devices, operations to be performed will branch in to either `super or regular`. If the SSH username matches the `common_user`, the `regular` plays are used; `super` (assuming privilege escalation) will be used otherwise.
* The `super` plays are used to prepare a device for running a service whereas, the `regular` plays are used for ensuring a service is operational / deployed. Because of this `super` should always be run in advance.
* All roles are launched by default; [Ansible Tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html) should primarily be used to control application of roles in any given run.
* Management of roles on a per device basis can be further limited (for fine grain control) using the `bypass_<ROLE_NAME>_management` (boolean) variable within inventory definitions. The main reason for including this control is so that, for example, a Database server can be setup manually which we don't want Ansible to change in any way but, will be used in plays.
* When it comes to deploying inhouse applications, files to be deployed are taken from pre-created containers and packed in to an archive used for distribution named after the service reference and container tag taken from. e.g. if deploying The pledgecamp backend service from `master` (which by default has a reference of `pledgecamp_backend`), the deployment artifact will be stored at `<ansible_working_path>/pledgecamp_backend/pledgecamp_backend-distribution-develop.tar.gz`.
* The deployment artifact will only be generated (or regenerated) if, in the above case, `<ansible_control_flags_path>/pledgecamp_tokenbridge_backend-backend_develop` is not present. In the case where the control flag is present, Ansible will try to reuse the artifact if possible. This saves time when deploying the same service multiple times or to multiple devices.
* SystemD is used to manage services on the remote devices. Where sensitive information is required for a given service, an environment file is created within `/etc/<ansible_project_name>/<sevice_reference>` (which is only readable by root) which SystemmD injects in to the process environment. For less sensitive environment variables, they are defined within the SystemD unit file itself which the common user can access. 
* The common user is able to control services using SystemD due to having sudoers files present within `/etc/sudoers.d/<service_reference>` 

## Usage Guide

If choosing to use Ansible from the command line, typical calls could look like the following. 
ansible-playbook \
  -i ./inventory.yml \
  --extra-vars "ansible_ssh_private_key_file=$HOME/.ssh/personal_internal" \
  main.yml
```
# Super user operation to perform maintenance on all devices in inventory
ansible-playbook -i development/inventory.yml \
  --extra-vars "ansible_user=lordy" \
  --extra-vars "ansible_ssh_private_key_file=development/ansible_ssh_development" \
  --vault-password-file vault_pass \
  main.yml

# Regular user operation
ansible-playbook -i development/inventory.yml \
  --extra-vars "ansible_user=jeeves" \
  --extra-vars "ansible_ssh_private_key_file=$HOME/.ssh/ansible_pledgecamp_jeeves" \
  --vault-password-file vault_pass \
  main.yml

# Live infra super setup
ansible-playbook -i staging/inventory.yml \
  --vault-password-file vault_pass \
  --extra-vars "ansible_ssh_private_key_file=$HOME/.ssh/pledgecamp_digital_ocean ansible_user=root" \
  main.yml

# Live infra regular setup
ansible-playbook -i staging/inventory.yml \
  --extra-vars "ansible_user=jeeves ansible_ssh_private_key_file=$HOME/.ssh/ansible_pledgecamp_jeeves" \
  --vault-password-file vault_pass \
  main.yml \
  --extra-vars "build_all=1"
```

* `-i` - Path to the inventory file
* `--extra-vars` - Injects extra variables in to the ansible process. In this case, it is primarily used to define connection information. To keep track of when Ansible managed a device operation, in some cases, it may create a `<service_refererence>.ver` file within the common working path on the remote device that uses a `setup_job_number` variable that would also be used as an extra variables

Extra options you may be likely to include on any given run include:

* `--tags` - Limits activity that Ansible will perform. Tag names used are the same as the role definitions
* `--limit`- Using a pattern, restrict inventory selection 

## Project Structure

File layout follows [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#directory-layout) but in terms of things specific to Pledgecamp, the following are true.

* When roles support both setup (through super user access) and regular operations (project rollouts), the setup part will always be within `initial-setup.yml`. The common user operations will be part of `main.yml` for simpler role / variable inclusion.
* Where a task should only ever be run rarely, or the results cached (e.g. project distribution archive), there is a Control Flags (more information belwow) path which uses file presence check to determine whether any given operation should run.
* Software packaging tasks will always use the `build.yml` task, using the GIT branch built from as a control flag suffix.

For a complete listing of all possible tasks that each of the playbooks perform, please see [this page](docs/ansible_tasks.md).

## Secret management

Sensitive information is encrypted within the `group_vars/<workspace>.yml` file as `vault encrypted strings` following best practises when working across multiple environments.

Rather than entering a password to unlock the vault each time, it is recommended to have a copy of the password in a plain text file called `vault_pass` within the project root; this is then used as an argument `--vault-password-file vault_pass` when making ansible calls.

In the case of changing the secrets [ansible-vault encrypt_string](https://docs.ansible.com/ansible/latest/user_guide/vault.html#creating-encrypted-variables) is used as shown below:

```
ansible-vault encrypt_string \
    --vault-password-file vault_pass \
    'SECRET_VALUE' \
    --name 'SECRET_KEY'
```

For debugging purposes, there is a `vault_reader` bash script within the scripts path that will parse a yaml file and then attempt to decrypt any secrets using the `vault_pass` as key. Please note that this script is flaky (it was just a very quick attempt to get secret values conveniently for development) and, if not working properly, try switching the `KEY_OR_VALUE` to initially be `value`.

# Direct Tasks

This section defines some of the out of band operations that Ansible is capable of performing. In this section, the `<super_config> and <common_config>` snippets refer to level of SSH user. Use of the [`--limit`](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html) pattern to restrict devices operated on. e.g. Running reboot, you most likely don't want to reboot the entire infrastructure at the same time.

## Admin

* `clean_disk_space` -  Clear unused docker images and cleanup packages
* `disk_lvm_claim` - For use on LVM systems to claim all available space in to root
* `fix_apt` - Try to fix broken installed packages and run Debian package configure
* `network_internal_routing` - Whether or not to create references in `/etc/hosts` that would allow each device to communicate with all others in the inventory via the host name
* `reboot` - Have you tried switching it off and on again?
* `toggle_state_switch` - For use on the Ansible controller as defined in previous section

## Nginx Facade

* `define_reverse_proxy` - Setup Nginx rules for acting as a service facade. Uses `generate_certificate`
* `define_static_site` - Setup Nginx rules for delivering static files. Uses `generate_certificate` 
* `generate_certificate` - Configures Nginx for a specific domain to either use a self-signed certificate or letsencrypt
* `restart` - Reload Nginx process using systemd

## PostgreSQL

* `backup_schema` - Takes `schema_name` and (defaulting to `{{ schema_name }}__{{ ansible_date_time.epoch }}`) `backup_name` and copies to Ansible device within `common_backup_path`

```
ansible-playbook \
  -i ./inventory.yml \
   --vault-password-file vault_pass \
  main.yml
```

## Jenkins

### Plugins to install

* Gitea - Integration with forgejo (Gitea fork) version control