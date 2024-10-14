resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  availability_zone       = var.az
  cidr_block              = var.subnet_cidr

  map_public_ip_on_launch = var.is_public ? true : false

  tags = {
    Name        = join("_", ["demo", var.is_public ? "public" : "private", "subnet"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table_association" "this" {
  subnet_id       = aws_subnet.this.id
  route_table_id  = var.route_table_id
}
