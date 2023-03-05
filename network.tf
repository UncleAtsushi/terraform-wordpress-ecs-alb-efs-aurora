# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.param.cidr_block
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  for_each          = var.param.zone
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.param.zone[each.key].public_cidr
  availability_zone = var.param.zone[each.key].az
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-public-subnet-${each.key}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  for_each          = var.param.zone
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.param.zone[each.key].private_cidr
  availability_zone = var.param.zone[each.key].az
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-private-subnet-${each.key}"
  }
}

# Database Subnet
resource "aws_subnet" "database_subnet" {
  for_each          = var.param.zone
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.param.zone[each.key].database_cidr
  availability_zone = var.param.zone[each.key].az
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-database-subnet-${each.key}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# EIP
resource "aws_eip" "eip" {
  for_each = var.param.zone
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-eip-${each.key}"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat_gateway" {
  for_each      = var.param.zone
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-nat-gateway-${each.key}"
  }
}

# Route Table(Public)
resource "aws_route_table" "public_route_table" {
  for_each = var.param.zone
  vpc_id   = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-public-route-table-${each.key}"
  }
}

# Route(Public)
resource "aws_route" "public_route" {
  for_each               = var.param.zone
  route_table_id         = aws_route_table.public_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Route Table Association(Public)
resource "aws_route_table_association" "public_route_table_assoc" {
  for_each       = var.param.zone
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_route_table[each.key].id
}

# Route Table(Private)
resource "aws_route_table" "private_route_table" {
  for_each = var.param.zone
  vpc_id   = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-private-route-table-${each.key}"
  }
}

# Route(Private)
resource "aws_route" "private_route" {
  for_each               = var.param.zone
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[each.key].id
}

# Route Table Association(Private)
resource "aws_route_table_association" "private_route_table_assoc" {
  for_each       = var.param.zone
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

# Route Table(Database)
resource "aws_route_table" "database_route_table" {
  for_each = var.param.zone
  vpc_id   = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-database-route-table-${each.key}"
  }
}

# Route Table Association(Database)
resource "aws_route_table_association" "database_route_table_assoc" {
  for_each       = var.param.zone
  subnet_id      = aws_subnet.database_subnet[each.key].id
  route_table_id = aws_route_table.database_route_table[each.key].id
}

