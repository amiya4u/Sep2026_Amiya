# Day 09 - Terraform Variables, Outputs, Security Groups & Tags

## What I built
- Terraform config with variables, outputs, security group, and EC2 instance
- EC2 instance with Name tag visible in AWS console
- Security group with 2 ingress rules (SSH port 22, HTTP port 80)

## Files created
- `variables.tf` — defines input variables (region, ami, instance_type)
- `main.tf` — provider + security group + ingress rules + EC2 instance
- `output.tf` — prints public IP after apply
- `.gitignore` — excludes .terraform/, tfstate files

## Key concepts learned

### Variables
- Defined in `variables.tf` with `variable` block
- Has `type` and `default`
- Referenced in main.tf as `var.variable_name`
- Makes config reusable — change one place, updates everywhere

### Outputs
- Defined with `output` block in `output.tf`
- Prints values to terminal after `terraform apply`
- Useful for getting IP, ARN, IDs of created resources

### Security Groups
- Like a virtual firewall for EC2
- **Ingress** = incoming traffic rules (who can reach my server)
- **Egress** = outgoing traffic rules (what my server can reach)
- Modern AWS approach: create `aws_security_group` first, then add rules as separate `aws_vpc_security_group_ingress_rule` resources
- Attach to EC2 via `vpc_security_group_ids` — must be a **list** `[]`

### Tags
- `Name` key (capital N) = display name shown in AWS console
- `tags = { Name = "day09" }` — lowercase `name` won't show as the instance name

## Bugs I made in main.tf
1. `va.region` → should be `var.region` (typo)
2. `vpc_security_group_ids = aws_security_group.sg_day09.id` → needs list: `[aws_security_group.sg_day09.id]`
3. `name = "day09"` → should be `Name = "day09"` (capital N for AWS display name)

## Commands used
terraform init # download AWS provider plugin (once per folder)
terraform fmt # auto-format .tf files
terraform plan # preview changes without applying
terraform apply # create infrastructure (type ‘yes’ to confirm)
terraform destroy # tear down everything (type ‘yes’ to confirm)

## Important files
- `.terraform/` → provider plugins — DO NOT commit (add to .gitignore)
- `terraform.tfstate` → tracks live infra state — DO NOT commit
- `.terraform.lock.hcl` → locks provider version — DO commit

## What I verified in AWS console
- EC2 instance showed Name tag "day09"
- Security group "day09" had 2 inbound rules: port 22 and port 80

.gitignore - Created at root level. 
