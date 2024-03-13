terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "shehab" {
  ami           = "ami-03484a09b43a06725"
  instance_type = "t2.micro"
  security_groups = [ "allow_SSH" ]
  tags = {
    Name = "devops-project"
  }
}
resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH traffic"
 

  tags = {
    Name = "allow_SSH"
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}