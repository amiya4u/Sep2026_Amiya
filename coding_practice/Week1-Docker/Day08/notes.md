## Day 08 - Terraform Basics - Provision EC2 on AWS

## What I did:
Wrote Terraform code to create an EC2 instance on AWS and destroy it. No clicking in AWS console — just code.

## What is Terraform:
Infrastructure as Code (IaC) tool. Instead of clicking around AWS console to create resources, you write code that describes what you want. Terraform reads it and creates/manages the infrastructure on AWS.

## Files:
- main.tf — main configuration file (.tf is Terraform's file extension, HCL is the syntax)

## Blocks in main.tf:
- provider block — tells Terraform which cloud to use (AWS, GCP, Azure) and which region
- resource block — defines what to create. Format: resource "resource_type" "local_name"
  - resource_type: aws_instance (EC2), aws_s3_bucket, aws_vpc etc.
  - local_name: just a name you give it to reference within Terraform, not the actual AWS name

## Commands:
- terraform fmt — auto-formats .tf files to standard style. Run before anything.
- terraform init — downloads the provider plugin (like npm install). Run once per folder.
- terraform plan — shows what Terraform WILL do, without doing it. Always read this before apply.
- terraform apply — actually creates the infrastructure on AWS. Asks for 'yes' confirmation.
- terraform destroy — tears everything down. Asks for 'yes' confirmation.

## Terraform files 
## terraform init creates:
.terraform/ folder — contains the downloaded provider plugin (AWS provider in your case). Large folder, don’t commit this.
.terraform.lock.hcl — records the exact provider version used. Do commit this — it ensures everyone uses the same version.

## And after apply:
terraform.tfstate — records the current state of your infrastructure. Don’t commit this — it can contain sensitive info like IPs, passwords.
terraform.tfstate.backup — backup of previous state.

All following files .gitignore
.terraform/
terraform.tfstate
terraform.tfstate.backup


## Key concepts:
- (known after apply) — values Terraform can't know until AWS creates the resource (like IP address, instance ID)
- terraform.tfstate — file Terraform creates to track what it has built. Never edit manually.
- Always run terraform destroy after practice — running EC2 instances cost money.

## Pass condition:
EC2 instance visible in AWS console after apply → terraform destroy → instance shows Terminated ✅
