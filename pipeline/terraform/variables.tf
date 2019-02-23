variable "droplet_name" {}
variable "droplet_region" {}
variable "droplet_size" {}
variable "do_token" {}
variable "pub_key" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}



-var "do_token=${DO_PAT}" \
-var "pub_key=$HOME/.ssh/id_rsa.pub" \
-var "ssh_fingerprint=e7:42:16:d7:e5:a0:43:29:82:7d:a0:59:cf:9e:92:f7"


variable "do_token": your DigitalOcean Personal Access Token
variable "pub_key": public key location, so it can be installed into new droplets
variable "ssh_fingerprint": fingerprint of SSH key




DIGITAL_OCEAN_API_TOKEN=your-digital-ocean-api-token
PUB_KEY=${HOME}/.ssh/id_rsa.pub
PVT_KEY=${HOME}/.ssh/id_rsa
SSH_FINGERPRINT=your-ssh-fingerprint
DROPLET_NAME=staging
DROPLET_REGION=nyc1
DROPLET_SIZE=s-1vcpu-1gb

#
# TERRAFORM SPECIFIC ENV VARS - EQUAL TO THE ONES ABOVE, JUST NAMED DIFFERENTLY

TF_VAR_digital_ocean_api_token=${DIGITAL_OCEAN_API_TOKEN}
TF_VAR_pub_key=${PUB_KEY}
TF_VAR_pvt_key=${PVT_KEY}
TF_VAR_ssh_fingerprint=${SSH_FINGERPRINT}
TF_VAR_droplet_name=${DROPLET_NAME}
TF_VAR_droplet_region=${DROPLET_REGION}
TF_VAR_droplet_size=${DROPLET_SIZE}






Docs

Run Terraform

First, initialize Terraform for your project. This will read your configuration files and install the plugins for your provider:

terraform init

Next, run the following terraform plan command to see what Terraform will attempt to do to build the infrastructure you described (i.e. see the execution plan). You will have to specify the values of all of the variables listed below:

terraform plan \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"

Run the following terraform apply command to execute the current plan. Again, specify all the values for the variables below:

terraform apply \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"

At this point, Terraform has created a new droplet.


Show State
Terraform updates the state file every time it executes a plan or "refreshes" its state. Note that if you modify your infrastructure outside of Terraform, your state file will be out of date.

To view the current state of your environment, use the following command:

terraform show terraform.tfstate

Refresh State
If your resources are modified outside of Terraform, you may refresh the state file to bring it up to date. This command will pull the updated resource information from your provider(s):

terraform refresh \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"

Destroy Infrastructure
Although not commonly used in production environments, Terraform can also destroy infrastructures that it creates. This is mainly useful in development environments that are built and destroyed multiple times. It is a two-step process and is described below.

1. Create an execution plan to destroy the infrastructure:
terraform plan -destroy -out=terraform.tfplan \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"
Terraform will output a plan with resources marked in red, and prefixed with a minus sign, indicating that it will delete the resources in your infrastructure.

2. Apply destroy:
terraform apply terraform.tfplan

Terraform will destroy the resources, as indicated in the destroy plan.

