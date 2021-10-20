# network.tf
# this is a bunch of boilerplate to create a VPC and all the wonderful things it needs
# I'm keeping it really generic. if we needed to connect VPCs we would have to make sure that 
# CIDR blocks don't overlap and such, but I don't think we're there yet
# So let's be as boring as possible
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet2a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet2b" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_route_table" "subnet2a" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "subnet2b" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table_association" "subnet2a" {
  subnet_id      = aws_subnet.subnet2a.id
  route_table_id = aws_route_table.subnet2a.id
}

resource "aws_route_table_association" "subnet2b" {
  subnet_id      = aws_subnet.subnet2b.id
  route_table_id = aws_route_table.subnet2b.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route" "subnet2a" {
  route_table_id         = aws_route_table.subnet2a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "subnet2b" {
  route_table_id         = aws_route_table.subnet2b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.igw.id
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_unicorns" {
  name        = "ingress-unicorns"
  description = "Allow ingress to Unicorns"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "subnet2a_id" {
  value = aws_subnet.subnet2a.id
}

output "subnet2b_id" {
  value = aws_subnet.subnet2b.id
}
