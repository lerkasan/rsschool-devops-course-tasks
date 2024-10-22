resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "demo_ig"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "demo_public_rt"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

module "public_subnet" {
  for_each = toset(var.public_subnets)

  source         = "./modules/subnet"
  is_public      = true
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.public.id
  subnet_cidr    = each.value
  az             = local.availability_zones[index(var.public_subnets, each.value)]
}