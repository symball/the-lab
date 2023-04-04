## Vagrant

The Terraform vagrant provider

There are two separate terraform projects to run when using Digital Ocean. The reason for this is that, Jenkins as the automation system will only change very rarely and might even be the device to manage the rest of the infrastructure so, the state kept separate.

### Setup

* Install support services

```
sudo apt-get install \
  virtualbox
```

* Install Virtualbox extensions package from the [Official Download Page](https://www.virtualbox.org/wiki/Downloads) for your version of Virtualbox.

* Install Vagrant on your machine

```
brew install --cask vagrant
```

At this point, the rest of the procedure can be run in a semi-automated fashion using `./dev.sh`; part of the instructions involve opening a web browser and configuring Jenkins which will actually go beyond the instructions shown below. See the main README for more information.