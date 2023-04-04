* Libvirt \ QEMU Setup

This procedure will assume you are running [Ubuntu 20.04 LTS Server image](http://releases.ubuntu.com/20.04/) and have a sudo account that already has grant access or doesn't require password.

In order to run Virtual Machines with QEMU, it is necessary for your devices BIOS to have hardware virtualization enabled. A simple utility `cpu-checker` is available from the default repository that, should output the following if all is ready.

```
$ sudo kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

Once you have verified your device can run virtualized machines.

```
sudo apt-get install -y \
  bridge-utils \
  libvirt-bin \
  libvirt-clients \
  libvirt-daemon-system \
  qemu \
  qemu-kvm \
  virt-manager

# Put your user in the libvirt group YOUR_USER
sudo usermod -aG libvirt YOUR_USER

# Logout and login for changes to take effect
```

At this point, the rest of the procedure can be run in a semi-automated fashion using `./dev.sh`; part of the instructions involve opening a web browser and configuring Jenkins which will actually go beyond the instructions shown below. See the main README for more information.
