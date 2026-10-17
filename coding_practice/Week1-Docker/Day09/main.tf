provider "aws" {
  region = var.region
}

## Security Group
resource "aws_security_group" "sg_day09" {
  name        = "day09"
  description = "security group created on day 09"

}
## Inbound Rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg_day09.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

}
## Inbound Rule
resource "aws_vpc_security_group_ingress_rule" "name" {
  security_group_id = aws_security_group.sg_day09.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
## EC2
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_day09.id]
  tags = {
    Name = "day09"
  }
}

