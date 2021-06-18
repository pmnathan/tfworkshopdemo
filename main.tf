provider "aws" {
  region = var.region
}

resource "aws_vpc" "hashi" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc-${var.region}"
    importid = "FN20210001"
  }
}

resource "aws_subnet" "hashi" {
   vpc_id     = aws_vpc.hashi.id
   cidr_block = var.subnet_prefix

   tags = {
     name = "${var.prefix}-subnet"
     importid = "FN20210001"
   }
 }

resource "aws_security_group" "hashi" {
   name = "${var.prefix}-security-group"

   vpc_id = aws_vpc.hashi.id

   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port       = 0
     to_port         = 0
     protocol        = "-1"
     cidr_blocks     = ["0.0.0.0/0"]
     prefix_list_ids = []
   }

   tags = {
     Name = "${var.prefix}-security-group"
     importid = "FN20210001"
   }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                     = data.aws_ami.ubuntu.id
  subnet_id               = aws_subnet.hashi.id
  vpc_security_group_ids  = [aws_security_group.hashi.id]
  instance_type           = "t2.2xlarge"
  count                   = 3

  tags = {
    Name = "demo_2021_${count.index}"
    Project = "workshop_Main"
    Environment = "Development"
    importid = "FN20210001"
  }
}

#module "s3_bucket" {
#  source = "terraform-aws-modules/s3-bucket/aws"
#  bucket = "my-s3-bucket-prakash-2021"
#  acl    = "private"
#
#  versioning = {
#    enabled = true
#  }
#}
