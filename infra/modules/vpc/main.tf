
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "vpc-${var.region}-${var.env_code}-bloodbank-stack"
  }
}
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_cidr_blocks)
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  cidr_block              = element(var.public_cidr_blocks, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "subnet-${var.region}-${element(data.aws_availability_zones.available.zone_ids, count.index)}-public-${var.env_code}-bloodbank-stack"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "subnet-${var.region}-${element(data.aws_availability_zones.available.zone_ids, count.index)}-private-${var.env_code}-bloodbank-stack"
  }
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "IGW-${var.env_code}-bloodbank"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "RT-${var.env_code}-bloodbank"
  }
}

resource "aws_route_table_association" "this" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.this.id
}
