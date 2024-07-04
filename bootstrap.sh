#!/usr/bin/env bash

WORKING_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#!/
#!/# Author Simon Ball <open-source@simonball.me>
# A short shell script used to bootstrap services
. ${WORKING_PATH}/provisioning/utils/bash_functions.sh

echo "${green}--=== Environment Bootstrap Script ===--${reset}"
echo ""
echo "Working Path: ${WORKING_PATH}"

set -e
set -o pipefail

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OPERATING_SYSTEM=linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
        OPERATING_SYSTEM=mac
else
        halt "Unsupported Operating system"
fi
#
# DEFAULTS.
#
BOOTSTRAP_CONFIG="${WORKING_PATH}/.bootstrap_config"

echo ""
echo Checking for existing state
if test -f $BOOTSTRAP_CONFIG; then
  ALREADY_RUN=true
  echo Existing file found
else
 echo Copying from develop template
 cp "${BOOTSTRAP_CONFIG}.develop" ${BOOTSTRAP_CONFIG}
fi
source ${BOOTSTRAP_CONFIG}
MASTER_USER="$(whoami)"
SSH_KEY_MASTER_PATH="$HOME/.ssh/${WORKSPACE_NAME}-master"
SSH_KEY_COMMON_PATH="$HOME/.ssh/${WORKSPACE_NAME}-common"
PROVISIONING_PATH="${WORKING_PATH}/provisioning"
TEMPLATE_PATH="${PROVISIONING_PATH}/templates"
UTILS_PATH="${PROVISIONING_PATH}/utils"
HOSTNAME=$(cat /etc/hostname)
ALREADY_RUN=false
ok
#
# ENVIRONMENT SPECIFIC. This is the section you will want to change
#
REQUIRED_PROGRAMS="ansible ssh"

echo "${green}--=== Environment Bootstrap Script ===--${reset}"
echo ""

# Command help
display_usage() {
  echo "Prepare your device and environment to use as a lab"
  echo ""
  echo " -h --help                         Show this message"
  echo " -mu=* --master-user=*             The username of your super user. Defaults to current user"
  echo " -mussh=* --master-user-ssh-path=* Path to use for admin level SSH key"
  echo " -cu=* --common-user=*             Username of regular user to be created on devices"
  echo " -cussh=* --common-user-ssh-path=* Path to use for common level SSH key"
  echo " -na=* --nodes-arch=*              Number of VMs based on Arch Linux to create"
  echo " -nd=* --nodes-debian=*            Number of VMs based on Debian 11 Linux to create"
  echo " -nu=* --nodes-ubuntu=*            Number of VMs based on Ubuntu 22.04 Linux to create"
  echo " -ncpu=* --nodes-cpu=*             Number of CPUs to assign to each VM. Can be over-provisioned"
  echo " -nram=* --nodes-ram=*             Amount of RAM (MB) to assign to each VM. Can be over-provisioned"
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
  if command_exists $PROGRAM; then
    [ "$VERBOSE" = true ] && echo -ne "$PROGRAM" && ok
  else halt "$PROGRAM Required"
  fi
done

if [ "$ALREADY_RUN" = false ]; then
  spacer "Install Ansible Galaxy requirements"
  ansible-galaxy install -r requirements.yml
fi

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
if [ "$ALREADY_RUN" = false ]; then
  echo ""
  echo Creating an initial inventory file to prepare your device
  if [[ -n $SUDO_PASSWORD ]]; then
  OPEN="{{" CLOSE="}}" HOSTNAME=${HOSTNAME} \
  SUDO_PASSWORD=$SUDO_PASSWORD \
  MASTER_USER=$MASTER_USER \
  SSH_KEY_MASTER_PATH=$SSH_KEY_MASTER_PATH \
  ${UTILS_PATH}/mo --source=./.bootstrap_config ${TEMPLATE_PATH}/initial_inventory.yml.m2 > ${WORKSPACE_NAME}-inventory.yml
  else
  OPEN="{{" CLOSE="}}" HOSTNAME=${HOSTNAME} \
  MASTER_USER=$MASTER_USER \
  SSH_KEY_MASTER_PATH=$SSH_KEY_MASTER_PATH \
  ${UTILS_PATH}/mo --source=./.bootstrap_config ${TEMPLATE_PATH}/initial_inventory.yml.m2 > ${WORKSPACE_NAME}-inventory.yml
  fi
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

if [ "$ALREADY_RUN" = false ]; then
  echo ""
  echo "Setting up group_vars/all.yml"
  OPEN="{{" CLOSE="}}" \
  HOSTNAME=${HOSTNAME} \
  MASTER_USER=${MASTER_USER} \
  COMMON_USER=${COMMON_USER} \
  SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH} \
  SSH_KEY_COMMON_PATH=${SSH_KEY_COMMON_PATH} \
  ${UTILS_PATH}/mo --source=./.bootstrap_config ${TEMPLATE_PATH}/group_vars.yml.m2 > group_vars/all.yml
fi

if [ "$ALREADY_RUN" = false ]; then
  spacer "Provisioning THIS device"
  ansible-playbook -i ./${WORKSPACE_NAME}-inventory.yml main.yml
fi

if [[ $USER_IN_LIBVIRT == false ]]; then
  spacer "${red}Intervention required${reset}"
  echo "This seems to be your first run, you didn't seem to be in the libvirt"
  echo "Ansible just setup KVM/QEMU on your device and this would have"
  echo "modified your user groups"
  halt "Please logout and back in to allow the changes to take effect"
fi

if [ "$ALREADY_RUN" = false ]; then
  echo ""
  echo "Creating cloud config for VMs"
  OPEN="{{" CLOSE="}}" \
  MASTER_USER=${MASTER_USER} \
  SSH_PUBLIC_MASTER_KEY=${SSH_PUBLIC_MASTER_KEY} \
  ${UTILS_PATH}/mo --source=./.bootstrap_config ${TEMPLATE_PATH}/cloud_init.cfg.m2 > ${WORKING_PATH}/provisioning/terraform_libvirt/cloud_init.cfg
fi

spacer "Virtual machines"
cd ${WORKING_PATH}/provisioning/terraform_libvirt
if [ "$ALREADY_RUN" = false ]; then
  terraform init
fi

terraform apply --auto-approve \
 -var "arch_node_count=$ARCH_NODES" \
 -var "debian_node_count=$DEBIAN_NODES" \
 -var "ubuntu_node_count=$UBUNTU_NODES" \
 -var "cpu_per_node=$CPU_PER_NODE" \
 -var "ram_per_node=$RAM_PER_NODE" \
 -var "disk_per_node=$DISK_PER_NODE" \
 -var "workspace_name=$WORKSPACE_NAME"
cd $WORKING_PATH

if [ "$ALREADY_RUN" = false ]; then
  echo ""
  echo "Creating inventory for all devices"
  # Turn the number of devices in to a list for mustache
  ARCH_VMS='( '
  for ((x=0; x<$ARCH_NODES; x++))
  do
  ARCH_VMS="$ARCH_VMS"$x" "
  done
  ARCH_VMS="${ARCH_VMS%,} )"
  DEBIAN_VMS='( '
  for ((x=0; x<$DEBIAN_NODES; x++))
  do
  DEBIAN_VMS="$DEBIAN_VMS"$x" "
  done
  DEBIAN_VMS="${DEBIAN_VMS%,} )"
  UBUNTU_VMS='( '
  for ((x=0; x<$UBUNTU_NODES; x++))
  do
  UBUNTU_VMS="$UBUNTU_VMS"$x" "
  done
  UBUNTU_VMS="${UBUNTU_VMS%,} )"

  if [[ -n $SUDO_PASSWORD ]]; then
  echo """export OPEN="{{"
  export CLOSE="}}"
  export HOSTNAME=${HOSTNAME}
  export MASTER_USER=${MASTER_USER}
  export SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH}
  export SUDO_PASSWORD='$SUDO_PASSWORD'
  export ARCH_VMS=$([[ $ARCH_NODES -ne 0 ]] && echo $ARCH_NODES || echo "")
  export DEBIAN_VMS=$([[ $DEBIAN_NODES -ne 0 ]] && echo $DEBIAN_NODES || echo "")
  export UBUNTU_VMS=$([[ $UBUNTU_NODES -ne 0 ]] && echo $UBUNTU_NODES || echo "")
  export ARCH_VMS_MAP=${ARCH_VMS}
  export DEBIAN_VMS_MAP=${DEBIAN_VMS}
  export UBUNTU_VMS_MAP=${UBUNTU_VMS}
  """ > temp
  else
  echo """export OPEN="{{"
  export CLOSE="}}"
  export HOSTNAME=${HOSTNAME}
  export MASTER_USER=${MASTER_USER}
  export SSH_KEY_MASTER_PATH=${SSH_KEY_MASTER_PATH}
  export ARCH_VMS=$([[ $ARCH_NODES -ne 0 ]] && echo $ARCH_NODES || echo "")
  export DEBIAN_VMS=$([[ $DEBIAN_NODES -ne 0 ]] && echo $DEBIAN_NODES || echo "")
  export UBUNTU_VMS=$([[ $UBUNTU_NODES -ne 0 ]] && echo $UBUNTU_NODES || echo "")
  export ARCH_VMS_MAP=${ARCH_VMS}
  export DEBIAN_VMS_MAP=${DEBIAN_VMS}
  export UBUNTU_VMS_MAP=${UBUNTU_VMS}
  """ > temp
  fi
  ${UTILS_PATH}/mo --source=temp ${TEMPLATE_PATH}/inventory.yml.m2 > ${WORKSPACE_NAME}-inventory.yml
  rm temp
fi

spacer "${green}--=== Environment Ready! ===--${reset}"
echo "Go forth and be awesome! Don't forget to customize your inventory"
echo ""
echo "${red}If you are planning to use the deployed services in production!${reset}"
echo "Don't forget to also customize your variables and create secrets!"
echo "See README.md for more information"
echo ""
echo "Run ${green}ansible-playbook -i ./${WORKSPACE_NAME}-inventory.yml main.yml${reset}"
