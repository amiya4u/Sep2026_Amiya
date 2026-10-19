provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_local_exec" {
  ami = var.ami
  instance_type = var.instance_type
  provisioner "local-exec" {
    command = "echo The server IP is ${self.public_ip} >> ip.txt"
  }
}
