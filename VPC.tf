# Declare provider
provider "aws" {
  region = "ap-south-1"
}

# VPC creation
resource "aws_vpc" "vpc1" {
  cidr_block = "10.10.0.0/16"
}

# Internet Gateway Creation
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}

# Public Subnet Creation
resource "aws_subnet" "public_sub" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
}

# Private Subnet Creation
resource "aws_subnet" "private_sub" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.10.2.0/24"
}

# Main Route Table Creation
resource "aws_route_table" "MRT" {
  vpc_id = aws_vpc.vpc1.id
}

# Create route for public subnet to Internet Gateway
resource "aws_route" "public_sub_igw_route" {
  route_table_id         = aws_route_table.MRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_igw.id
}

# Main Route Table Association
resource "aws_route_table_association" "MRT_assoc" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.MRT.id
}

# Custom Route Table Creation
resource "aws_route_table" "CRT" {
  vpc_id = aws_vpc.vpc1.id
}

# NAT Gateway Creation
resource "aws_nat_gateway" "vpc1_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sub.id
}

# Create EIP
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Creating route for private subnet to NAT gateway
resource "aws_route" "private_sub_ngw_route" {
  route_table_id         = aws_route_table.CRT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc1_nat.id
}

# Custom Routing Table Association
resource "aws_route_table_association" "CRT_assoc" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.CRT.id
}

# Create EC2 instance in Public Subnet
resource "aws_instance" "public_instance" {
  ami           = "ami-0e670eb768a5fc3d4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_sub.id
}

# Create EC2 instance in Private Subnet
resource "aws_instance" "private_instance" {
  ami           = "ami-0e670eb768a5fc3d4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_sub.id
}
