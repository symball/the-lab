# Digital Ocean (production)

There are two separate terraform projects to run when using Digital Ocean. The reason for this is that, Jenkins as the automation system will only change very rarely and, with the device managed via Terraform so, cannot edit itself.

## Prerequisites

* [DO setup SSH Key](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/). Example will assume located at `$HOME/.ssh/digital_ocean`
* `SSH fingerprint` - Either get it through the Digital Ocean web interface when uploading the key or run the following. `ssh-keygen -E md5 -l -f ~/.ssh/digital_ocean.pub | awk '/ /{print $2}' | cut -c 5-`
* [DO Access token](https://www.digitalocean.com/docs/api/create-personal-access-token/). Replace `{DO_TOKEN}` with actual value

## Useful Links

* [Digital Ocean Region Matrix](https://www.digitalocean.com/docs/platform/availability-matrix/)
* [Digital Ocean Droplet Sizes](https://slugs.do-api.dev/)

## Quick Start

As a prerequisite to this task, it is necessary to have an SSH key present already within Digital Ocean. This guide will assume it is located at `$HOME/.ssh/pledgecamp_digital_ocean`. Where `SSH_FINGERPRINT` is used, it refers to the output from the following task.

```
ssh-keygen -E md5 -lf ~/.ssh/pledgecamp_digital_ocean.pub | awk '{print $2}' | cut -c 5-
# Example SSH_FINGERPRINT: e7:42:16:d7:e5:a0:43:29:82:7d:a0:59:cf:9e:92:f7
```

For using a Google bucket as state management storage, it is necessary to have Google credentials configured ([as described here](https://www.terraform.io/docs/backends/types/gcs.html#configuration-variables)). With a credentials file present on the device communicating with Terraform, have the following environment variable set:

```
export GOOGLE_APPLICATION_CREDENTIALS={PATH_TO_CREDENTIALS_FILE}
```


### Automation service

**Warning** - The following command will affect `jenkins-dev.pledgecamp.com` domain assignment from within the Digital Ocean Networking space.
```
# Boot up the Digital Ocean automation server
cd ~/pledgecamp/pledgecamp-infrastructure/terraform_digital_ocean/jenkins && \
terraform init && \
terraform apply -auto-approve \
  -var "do_token=DIGITAL_OCEAN_TOKEN" \
  -var "pub_key=$HOME/.ssh/pledgecamp_digital_ocean.pub" \
  -var "pvt_key=$HOME/.ssh/pledgecamp_digital_ocean" \
  -var "jenkins_domain=jenkins-dev.pledgecamp.com" \
  -var "ssh_fingerprint=SSH_FINGERPRINT"
```

The above creates a server to be used as the min controller for the rest of the architecture.

**NOTE** The following procedure will be edited once a backend provider for the Terraform state has been created

Once the above step is complete, login to the server and create a `/pledgecamp` path that belongs to the common user, in this case `jenkins` and checkout the [pledgecamp-infrastructure](https://github.com/pledgecamp/pledgecamp-infrastructure).

### Backend services

**Warning** - The following command will affect `api-dev.pledgecamp.com` and `tokenbridge-api-dev.pledgecamp.com` domain assignment from within the Digital Ocean Networking space.

```
# Boot up main Pledgecamp services
cd /pledgecamp/pledgecamp-infrastructure/terraform_digital_ocean/main && \
terraform init && \
terraform apply -auto-approve \
  -var "do_token=DIGITAL_OCEAN_TOKEN" \
  -var "pub_key=$HOME/.ssh/pledgecamp_digital_ocean.pub" \
  -var "pvt_key=$HOME/.ssh/pledgecamp_digital_ocean" \
  -var "api_domain=api-dev.pledgecamp.com" \
  -var "tokenbridge_api_domain=tokenbridge-api-dev.pledgecamp.com" \
  -var "ssh_fingerprint=SSH_FINGERPRINT"
```

## Commands

```
# (optional) Make Terraform output more verbose
export TF_LOG=1

# Go to path with Terraform files for staging
cd ~/pledgecamp/pledgecamp-infrastructure/terraform_jenkins

# Get the public key fingerprint
ssh-keygen -E md5 -lf ~/.ssh/digital_ocean.pub | awk '{print $2}'
# Example output: md5:e7:42:16:d7:e5:a0:43:29:82:7d:a0:59:cf:9e:92:f7
# Replace {SSH_FINGERPRINT} with values after md5 part
# Example SSH_FINGERPRINT: e7:42:16:d7:e5:a0:43:29:82:7d:a0:59:cf:9e:92:f7

# Create the Jenkins server. This is separate because is relatively permanent
# Check variables.tf for extra options
terraform init
terraform apply \
  -var "do_token={DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/digital_ocean.pub" \
  -var "pvt_key=$HOME/.ssh/digital_ocean" \
  -var "ssh_fingerprint={SSH_FINGERPRINT}"

# Create the worker nodes
# Check variables.tf for extra options
cd ~/pledgecamp/pledgecamp-infrastructure/terraform
terraform init
terraform apply \
  -var "do_token={DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/digital_ocean.pub" \
  -var "pvt_key=$HOME/.ssh/digital_ocean" \
  -var "ssh_fingerprint={SSH_FINGERPRINT}"
# Extra variables / default
-var jenkins_domain=jenkins.pledgecamp.com"
```
