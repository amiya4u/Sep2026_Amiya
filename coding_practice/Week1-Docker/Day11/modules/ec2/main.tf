
resource "aws_instance" "ec2" {
    ami = var.ami
    instance_type = "t3.micro"
    tags = { 
        Name = "${var.region}_ec2"
    }
  
}
