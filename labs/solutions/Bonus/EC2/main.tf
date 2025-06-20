provider "aws" {
  region = var.region
}

data "aws_ami" "sql2022" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-SQL_2022_Standard*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Microsoft
}

# Custom VPC
resource "aws_vpc" "vpc_sql" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "vpc-sql" }
}

# Public Subnet
resource "aws_subnet" "subnet_sql" {
  vpc_id     = aws_vpc.vpc_sql.id
  cidr_block = "10.0.1.0/24"
  tags = { Name = "subnet-sql" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_sql.id
  tags = { Name = "sql-igw" }
}

# Route Table with default route
resource "aws_route_table" "sql_rt" {
  vpc_id = aws_vpc.vpc_sql.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "sql-rt" }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "sql_rt_assoc" {
  subnet_id      = aws_subnet.subnet_sql.id
  route_table_id = aws_route_table.sql_rt.id
}

# Security Group to allow RDP and SQL access
resource "aws_security_group" "sql_sg" {
  name   = "sql-sg"
  vpc_id = aws_vpc.vpc_sql.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sql-sg" }
}

# Elastic IP for the instance
resource "aws_eip" "sql_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# Network Interface in the subnet with the security group
resource "aws_network_interface" "sql_eni" {
  subnet_id       = aws_subnet.subnet_sql.id
  private_ips     = ["10.0.1.100"]
  security_groups = [aws_security_group.sql_sg.id]
}

# Associate the Elastic IP with the ENI
resource "aws_eip_association" "sql_eip_assoc" {
  allocation_id        = aws_eip.sql_eip.id
  network_interface_id = aws_network_interface.sql_eni.id
}

# SQL Server EC2 Instance
resource "aws_instance" "sql_server" {
  ami               = data.aws_ami.sql2022.id
  instance_type     = var.instance_type
  key_name          = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.sql_eni.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
  }

  tags = {
    Name = "SQL-Server-EC2"
  }
}
