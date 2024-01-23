resource "aws_vpc" "myVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "jaipur"
  }
}

locals {
  subnets = {
    "subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "ap-south-1a", tag_name = "vpc-1-private-subnet-1a" }
    "subnet-2" = { cidr_block = "10.0.2.0/24", availability_zone = "ap-south-1b", tag_name = "vpc-1-private-subnet-2b" }
    "subnet-3" = { cidr_block = "10.0.3.0/24", availability_zone = "ap-south-1c", tag_name = "vpc-1-private-subnet-3c" }
  }
}

resource "aws_subnet" "private-subnets" {
  for_each = local.subnets

  cidr_block        = each.value.cidr_block
  vpc_id            = aws_vpc.myVpc.id
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.tag_name
  }
}

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "IGW"
  }
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "RT"
  }
}

resource "aws_route_table_association" "rt-association-private" {
  for_each       = aws_subnet.private-subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "SG" {
  vpc_id = aws_vpc.myVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MySecurityGroup"
  }
}
