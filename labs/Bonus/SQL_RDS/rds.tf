data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "sql-subnet-group"
  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.vpc.id

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
}

resource "aws_db_option_group" "sql_restore_option" {
  name                     = "sqlserver-option-group"
  engine_name              = "sqlserver-se"
  major_engine_version     = "16.00"
  option_group_description = "Enable S3 integration for restore"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.rds_s3_role.arn
    }
  }
}

resource "aws_db_instance" "sql_rds" {
  identifier                    = "sql-rds-demo"
  engine                        = "sqlserver-se"
  engine_version                = "16.00.4085.2.v1"
  instance_class                = "db.m5d.large"
  license_model                 = "license-included"
  allocated_storage             = 100
  username                      = var.db_username
  password                      = var.db_password
  db_subnet_group_name          = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]
  publicly_accessible           = true
  skip_final_snapshot           = true
  iam_database_authentication_enabled = false
  option_group_name             = aws_db_option_group.sql_restore_option.name

  depends_on = [
    aws_iam_role.rds_s3_role,
    aws_iam_role_policy_attachment.s3_readonly
  ]

  tags = {
    Name = "sql-server-rds"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_a_assoc" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_b_assoc" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name          = "ec2.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
}
