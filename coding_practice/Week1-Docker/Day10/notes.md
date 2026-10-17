## Day 10 — Terraform remote state with S3.

Until now our terraform.tfstate lives locally. Problem: if you lose it, Terraform doesn’t know what it created. In teams, multiple people need the same state. Two people can use same state file if file is saved in github.
Solution: store state in S3.

## What you’ll do today:

Create an S3 bucket manually (AWS console) to store state
Write Day10/main.tf — same EC2 as Day 8 but with a backend "s3" block
Run terraform init (it will ask to migrate state)
Apply, verify, destroy

Your task — write Day10/main.tf:

terraform block with backend "s3" — needs: bucket, key, region

## Steps
- Create s3 bucket where state file will be saves manually first in AWS. Creating S3 bucket manually from console means Terraform doesn’t manage them. They exist outside your Terraform state.
This is actually intentional and correct practice.
Think about it — if you stored the backend config inside Terraform, you’d have a chicken-and-egg problem:
Terraform needs the S3 bucket to store state But Terraform needs state to create the S3 bucket
So the bucket and DynamoDB table are always created outside of the project’s Terraform — either manually or by a separate “bootstrap” Terraform config.
In real companies, a platform/ops team creates the S3 bucket and DynamoDB table once, and all other teams just point their backend config to it
- add terraform block in the main.tf - > The terraform block is where you configure Terraform itself — not AWS resources, but how Terraform behaves.
bacnend block expects 'key' that is the path/filename. 

## Commands
terraform show	Full details of current state
terraform state list	Just lists all resources Terraform is tracking
terraform state show aws_instance.ec2	Details of one specific resource
terraform plan	Compares state vs your config — shows what would change

## Terraform blocks
Data block : In Terraform, a data block is used to read existing resources — things already created in AWS (not created by your current Terraform).
resource block → creates something new
data block → fetches info about something that already exists

## Changes in backend s3
use_lockfile = true — newer replacement for dynamodb_table. Stores lock as .tflock file directly in S3, no DynamoDB needed.

## Variable file
terraform.tfvars vs variables.tf — declare in variables.tf, assign values in terraform.tfvars. Priority: CLI flag > tfvars > default.
