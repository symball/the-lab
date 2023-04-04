#!/usr/bin/env bash
#!/
#!/# Author Simon Ball <open-source@simonball.me>
# A short shell script used to bootstrap services

#
# DEFAULTS.
#
MASTER_USER="$(whoami)"
SSH_KEY_MASTER_PATH="$HOME/.ssh/thelab-master"
COMMON_USER="jeeves"
SSH_KEY_COMMON_PATH="$HOME/.ssh/thelab-common"
SUDO_PASSWORD=''
ARCH_NODES=1
DEBIAN_NODES=1
UBUNTU_NODES=1
CPU_PER_NODE=2
RAM_PER_NODE=4096

VERBOSE=true
WORKING_PATH=$(pwd)
ARTIFACTS_PATH="${WORKING_PATH}/provisioning/artifacts"
HOSTNAME=$(cat /etc/hostname)

red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`
#
# ENVIRONMENT SPECIFIC. This is the section you will want to change
#
REQUIRED_PROGRAMS="ansible ssh"
REQUIRED_PORTS="3000 5432"

echo "${green}--=== VM Bootstrap Script ===--${reset}"
echo ""
set -e
set -o pipefail
#
# HALT
#
# Safe method for stopping dev environment. If running the main
# process in foreground, will also shutdown services
#
halt() {
  echo "${red}--=== HALTING ===--${reset}"
  echo ""
  echo "${green}$1${reset}"
  exit 1
}

trap halt SIGHUP SIGINT SIGTERM

# Function to check whether command exists or not
exists()
{
  if command -v $1 &>/dev/null
    then return 0
    else return 1
  fi
}

path_exists() {
  if [ -d $1 ]
    then return 0
    else return 1
  fi
}

ok() {
  echo -e " ${green}OK${reset}"
}

# Command help
display_usage() {
  echo "Prepare your battlestation and some Virtual machines to use as a lab"
  echo ""
  echo " -h --help                         Show this message"
  echo " -mu=* --master-user=*             The username of your super user. Defaults to current user"
  echo " -mussh=* --master-user-ssh-path=* Path to use for admin level SSH key"
  echo " -cu=* --common-user=*             Username of regular user to be created on devices"
  echo " -cussh=* --common-user-ssh-path=* Path to use for common level SSH key"
  echo " -na=* --nodes-arch=*              Number of VMs based on Arch Linux to create"
  echo " -nd=* --nodes-debian=*            Number of VMs based on Debian 11 Linux to create"
  echo " -nu=* --nodes-ubuntu=*            Number of VMs based on Ubuntu 22.04 Linux to create"
  echo " -ncpu=* --nodes-cpu=*             Number of CPUs to assign to each VM. Can be overprovisioned"
  echo " -nram=* --nodes-ram=*             Amount of RAM (MB) to assign to each VM. Can be overprovisioned"
  echo " -pw=* --sudo-pw=*                 If password required to use sudo on your main workstation, set this"
  echo ""
  echo "Example: ./bootstrap.sh -pw='mypassword' -ncpu=4 -nram=8192 -nd=1 -na=1 -nu=1"
  echo ""
  halt
}

# Parameter parsing
for argument in "$@"; do
  case "$argument" in
    --help|-h)
      display_usage
      ;;
    --master-user=*|-mu=*)
      MASTER_USER="${argument#*=}"
      ;;
    --master-user-ssh-path=*|mussh=*)
      SSH_KEY_MASTER_PATH="${argument#*=}"
      ;;
    --common-user=*|-cu=*)
      COMMON_USER="${argument#*=}"
      ;;
    --comon-user-ssh-path=*|-cussh=*)
      SSH_KEY_COMMON_PATH="${argument#*=}"
      ;;
    --nodes-arch=*|-na=*)
      ARCH_NODES="${argument#*=}"
      ;;
    --nodes-debian=*|-nd=*)
      DEBIAN_NODES="${argument#*=}"
      ;;
    --nodes-ubuntu=*|nu=*)
      UBUNTU_NODES="${argument#*=}"
      ;;
    --nodes-cpu=*|ncpu=*)
      CPU_PER_NODE="${argument#*=}"
      ;;
    --nodes-ram=*|nram=*)
      RAM_PER_NODE="${argument#*=}"
      ;;
    --sudo-pw=*|-pw=*)
      SUDO_PASSWORD="${argument#*=}"
      ;;
  esac
  shift
done

# Check whether the required programs installed
[ "$VERBOSE" = true ] && echo "---=== Checking required programs ===---"
for PROGRAM in $REQUIRED_PROGRAMS; do
  if exists $PROGRAM; then
    [ "$VERBOSE" = true ] && echo -ne "$PROGRAM" && ok
  else halt "$PROGRAM Required"
  fi
done

#
# Prelim
#
USER_GROUPS=$(id)
if [[ $USER_GROUPS == *"libvirt"* ]]; then
  USER_IN_LIBVIRT=true
else
  USER_IN_LIBVIRT=false
fi
#
# INITIAL PREPARATION
#
echo ""
echo Creating an initial inventory file to prepare your device
if [[ -n $SUDO_PASSWORD ]]; then
OPEN="{{" CLOSE="}}" HOSTNAME=${HOSTNAME} \
SUDO_PASSWORD=$SUDO_PASSWORD \
MASTER_USER=$MASTER_USER \
SSH_KEY_MASTER_PATH=$SSH_KEY_MASTER_PATH \
${ARTIFACTS_PATH}/mo ${ARTIFACTS_PATH}/initial_inventory.yml.m2 > inventory.yml
else
OPEN="{{" CLOSE="}}" HOSTNAME=${HOSTNAME} \
MASTER_USER=$MASTER_USER \
SSH_KEY_MASTER_PATH=$SSH_KEY_MASTER_PATH \
${ARTIFACTS_PATH}/mo ${ARTIFACTS_PATH}/initial_inventory.yml.m2 > inventory.yml
fi

echo ""
echo -ne "Checking SSH master key exists"
if test -f "$SSH_KEY_MASTER_PATH"; then
    ok
else
  echo ""
  echo "Creating SSH file at ${SSH_KEY_MASTER_PATH}"
  ssh-keygen -t rsa -b 4096 -f $SSH_KEY_MASTER_PATH -N ""
fi
SSH_PUBLIC_MASTER_KEY=$(cat ${SSH_KEY_MASTER_PATH}.pub)

echo ""
echo -ne "Checking SSH common key exists"
if test -f "$SSH_KEY_COMMON_PATH"; then
    ok
else
  echo ""
  echo "Creating SSH file at ${SSH_KEY_COMMON_PATH}"
  ssh-keygen -t rsa -b 4096 -f $SSH_KEY_COMMON_PATH -N ""
fi
SSH_PUBLIC_COMMON_KEY=$(cat ${SSH_KEY_COMMON_PATH}.pub)

echo ""
echo "Setting up group_vars/all.yml"
OPEN="{{" CLOSE="}}" \
HOSTNAME=${HOSTNAME} \
MASTER_USER=${MASTER_USER} \
COMMON_USER=${COMMON_USER} \
SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH} \
SSH_KEY_COMMON_PATH=${SSH_KEY_COMMON_PATH} \
${ARTIFACTS_PATH}/mo ${ARTIFACTS_PATH}/group_vars.yml.m2 > group_vars/all.yml

echo ""
echo "Provisioning THIS device"
ansible-playbook -i ./inventory.yml main.yml

if [[ $USER_IN_LIBVIRT == false ]]; then
  echo "${red}Intervention possibly required${reset}"
  echo "This seems to be your first run, you didn't seem to be in the libvirt"
  echo "Ansible just setup KVM/QEMU on your device and this would have"
  echo "modified your user groups"
  halt "Please logout and back in to allow the changes to take effect"
fi

echo ""
echo "Creating cloud config for VMs"
OPEN="{{" CLOSE="}}" \
MASTER_USER=${MASTER_USER} \
SSH_PUBLIC_MASTER_KEY=${SSH_PUBLIC_MASTER_KEY} \
${ARTIFACTS_PATH}/mo ${ARTIFACTS_PATH}/cloud_init.cfg.m2 > ${WORKING_PATH}/provisioning/terraform_libvirt/cloud_init.cfg

 echo ""
 echo "Creating virtual machines"
 cd ${WORKING_PATH}/provisioning/terraform_libvirt
 terraform init
 terraform apply --auto-approve \
   -var "arch_node_count=$ARCH_NODES" \
   -var "debian_node_count=$DEBIAN_NODES" \
   -var "ubuntu_node_count=$UBUNTU_NODES" \
   -var "cpu_per_node=$CPU_PER_NODE" \
   -var "ram_per_node=$RAM_PER_NODE"
 cd $WORKING_PATH

echo ""
echo "Creating inventory for all devices"
# Turn the number of devices in to a list for mustache
ARCH_VMS='( '
for ((x=0; x<$ARCH_NODES; x++))
do
ARCH_VMS="$ARCH_VMS"$x","
done
ARCH_VMS="${ARCH_VMS%,} )"
DEBIAN_VMS='( '
for ((x=0; x<$DEBIAN_NODES; x++))
do
DEBIAN_VMS="$DEBIAN_VMS"$x","
done
DEBIAN_VMS="${DEBIAN_VMS%,} )"
UBUNTU_VMS='( '
for ((x=0; x<$UBUNTU_NODES; x++))
do
UBUNTU_VMS="$UBUNTU_VMS"$x","
done
UBUNTU_VMS="${UBUNTU_VMS%,} )"

if [[ -n $SUDO_PASSWORD ]]; then
echo """export OPEN="{{"
export CLOSE="}}"
export HOSTNAME=${HOSTNAME}
export MASTER_USER=${MASTER_USER}
export SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH}
export SUDO_PASSWORD=$SUDO_PASSWORD
export ARCH_VMS=${ARCH_VMS}
export DEBIAN_VMS=${DEBIAN_VMS}
export UBUNTU_VMS=${UBUNTU_VMS}
""" > temp
else
echo """export OPEN="{{"
export CLOSE="}}"
export HOSTNAME=${HOSTNAME}
export MASTER_USER=${MASTER_USER}
export SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH}
export ARCH_VMS=${ARCH_VMS}
export DEBIAN_VMS=${DEBIAN_VMS}
export UBUNTU_VMS=${UBUNTU_VMS}
""" > temp
fi
${ARTIFACTS_PATH}/mo --source=temp ${ARTIFACTS_PATH}/inventory.yml.m2 > inventory.yml
rm temp

echo ""
echo "Install Ansible Galaxy requirementss"
ansible-galaxy install -r requirements.yml

echo ""
echo "${green}--=== Environment Ready! ===--${reset}"
echo ""
echo "Go forth and be awesome"
echo ""
echo "Now customize your roles inventory: ./inventory.yml "
echo ""
echo "${red}If you are planning to use the deployed services in production!${reset}"
echo "Don't forget to also customize your variables and create secrets!"
echo "See README.md for more information"
echo ""
echo "Once ready, run ansible-playbook -i ./inventory.yml"