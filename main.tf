provider "aws" {
  region = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
 }

# Create Subnet
resource "aws_subnet" "project_subnet" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

# Create Internet Gateway
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id
}

# Create Route Table
resource "aws_route_table" "project_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "project_rta" {
  subnet_id      = aws_subnet.project_subnet.id
  route_table_id = aws_route_table.project_route_table.id
}

# Create Security Group that allows all traffic
resource "aws_security_group" "project_sg" {
  vpc_id      = aws_vpc.project_vpc.id
  name        = "project_security"
  description = "Allow all traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "one" {
  count                  = var.instance_count
  ami                    = "ami-022ce6f32988af5fa"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.project_subnet.id
  vpc_security_group_ids = [aws_security_group.project_sg.id]

  tags = {
    Name = var.instance_name
  }
}
