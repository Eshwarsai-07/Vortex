resource "aws_vpc" "vortex_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vortex-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "vortex_igw" {
  vpc_id = aws_vpc.vortex_vpc.id

  tags = {
    Name        = "vortex-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "vortex_public_subnet" {
  vpc_id                  = aws_vpc.vortex_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name        = "vortex-public-subnet"
    Environment = var.environment
  }
}

resource "aws_route_table" "vortex_public_rt" {
  vpc_id = aws_vpc.vortex_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vortex_igw.id
  }

  tags = {
    Name        = "vortex-public-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "vortex_public_rt_assoc" {
  subnet_id      = aws_subnet.vortex_public_subnet.id
  route_table_id = aws_route_table.vortex_public_rt.id
}
