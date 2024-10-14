resource "aws_vpc" "this" {
  cidr_block = var.cidr

  tags = {
    Name        = "demo_vpc"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }

  tags = {
    Name        = "demo_main_rt"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.main.id
}