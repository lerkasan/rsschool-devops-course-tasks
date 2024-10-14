resource "aws_eip" "this" {
  tags = {
    Name        = "demo_nat_gw_eip"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_nat_gateway" "this" {
  connectivity_type = "public"
  subnet_id         = module.public_subnet[var.public_subnets[0]].id
  allocation_id     = aws_eip.this.id

  tags = {
    Name        = "demo_nat_gw"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "demo_private_rt"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

module "private_subnet" {
  for_each = toset(var.private_subnets)

  source         = "./modules/subnet"
  is_public      = false
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.private.id
  subnet_cidr    = each.value
  az             = local.availability_zones[index(var.private_subnets, each.value)]
}