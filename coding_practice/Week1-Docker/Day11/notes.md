## Day 11 — Terraform modules.

What is a module?
A module is a reusable block of Terraform code. Instead of copy-pasting the same EC2 config in every project, you write it once as a module and call it wherever needed.

Think of it like a function in programming — write once, use many times.

Structure:

Day11/
  ├── main.tf          ← calls the module
  └── modules/
      └── ec2/
          ├── main.tf       ← module code (the actual EC2 resource)
          ├── variables.tf  ← module inputs
          └── outputs.tf    ← module outputs

Your task:
Create the folder structure above
Inside modules/ec2/ — write the EC2 resource, variables, and outputs (you’ve done this before in Day 9)
Inside root main.tf — call the module using a module block

## Steps performed
Created above fodler sturcture. 
Inside moduels/ec2 - This the child folder where we have the defination of ec2. 
Indise Day 11 - This is the root fodler where module gets called. 
Provider should be part of root folder main.tf

##  Bugs I made
- var.ami.id → wrong, var.ami is already a string, just use var.ami
- provider block should not be inside module — only in root main.tf
- source = "modules/ec2" → needs ./ prefix for local modules: "./modules/ec2"

## Module structure
Module folder structure:

modules/
  ├── ec2/
  │   ├── main.tf       ← resource definition
  │   ├── variables.tf  ← inputs the module accepts
  │   └── outputs.tf    ← values the module exposes back
  └── s3/
      ├── main.tf
      ├── variables.tf
      └── outputs.tf

How root calls it:

hcl
module "web_server" {
  source        = "./modules/ec2"
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.micro"
}

module "db_server" {
  source        = "./modules/ec2"
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.large"     ← different value, same module
}

The key point — module defines variable blocks with just type (no default), root passes the actual values. This is how the same module gets reused with different values.

One thing to add to your understanding — outputs.tf in the module lets the root access values from inside the module:

hcl
# in modules/ec2/outputs.tf
output "instance_id" {
  value = aws_instance.ec2.id
}

# in root main.tf — access it like this
module.web_server.instance_id
