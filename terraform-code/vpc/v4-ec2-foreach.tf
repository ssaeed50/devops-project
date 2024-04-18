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
  ami           = "ami-023adaba598e661ac"
  instance_type = "t2.micro"
  key_name = "ssh1"
  //security_groups = [ "allow_SSH" ]
  subnet_id = aws_subnet.dpw-public_subent_01.id
  vpc_security_group_ids = [ aws_security_group.allow_SSH.id ]
  for_each = toset(["master", "build-slave","ansible"])
   tags = {
     Name = "${each.key}"
   }
}
resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH traffic"
  vpc_id = aws_vpc.dpw-vpc.id
 

  tags = {
    Name = "allow_SSH"
  }

  ingress {
    description = "SSH port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
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
resource "aws_vpc" "dpw-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpw-vpc"
     }
   }
//Create a Subnet-01
resource "aws_subnet" "dpw-public_subent_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1a"
    tags = {
      Name = "dpw-public_subent_01"
    }
}   
//Create a Subnet-02
resource "aws_subnet" "dpw-public_subent_02" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "dpw-public_subent_02"
    }
}   
//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id
    tags = {
      Name = "dpw-igw"
    }
}
// Create a route table 
resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }
    tags = {
      Name = "dpw-public-rt"
    }
}

// Associate subnet with route table

resource "aws_route_table_association" "dpw-rta-public-subent-1" {
    subnet_id = aws_subnet.dpw-public_subent_01.id
    route_table_id = aws_route_table.dpw-public-rt.id
}
// Associate subnet2 with route table

resource "aws_route_table_association" "dpw-rta-public-subent-2" {
    subnet_id = aws_subnet.dpw-public_subent_02.id
    route_table_id = aws_route_table.dpw-public-rt.id
}