provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "server" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.micro"
}
