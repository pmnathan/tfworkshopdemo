provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name        = "prakash-test"
      Environment = var.environment
      Owner       = "TFProviders - test"
      Project     = "Test"
      importid    = "FN202100012"
    }
  }
}

resource "aws_vpc" "hashi" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc-${var.region}"
  }
}

/**
resource "aws_flow_log" "example" {
  iam_role_arn    = "arn"
  log_destination = "log"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.hashi.id
}**/


resource "aws_subnet" "hashi" {
  vpc_id     = aws_vpc.hashi.id
  cidr_block = var.subnet_prefix

  tags = {
    Name = "${var.environment}-subnet"
  }
}

resource "aws_security_group" "hashi" {
  name = "${var.environment}-security-group"

  vpc_id = aws_vpc.hashi.id

  ingress {
    from_port   = 26
    to_port     = 26
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/22"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/22"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/22"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.environment}-security-group"
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
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.hashi.id
  vpc_security_group_ids = [aws_security_group.hashi.id]
  instance_type          = "t2.micro"
  #key_name               = "Prakash-demo"
  #associate_public_ip_address  = true
  count                  =  2

  tags = {
    Name     = "hashi-test"
    Customer = "hashicorp"
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
