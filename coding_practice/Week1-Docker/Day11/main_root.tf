provider "aws" {
  region = "us-east-1"
}

module "ec2_server" {
  source = "./modules/ec2/"
}
