# Create default VPC if one does not exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Use data source to get all availability zones in the region
data "aws_availability_zones" "available_zones" {}

# Create a default subnet in the first AZ if one does not exist
resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

# Create a default subnet in the second AZ if one does not exist
resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

# Create security group for the web server
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver_security_group"
  description = "Enable HTTP access on port 80"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver_security_group"
  }
}

# Create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database_security_group"
  description = "Enable PostgreSQL/Aurora access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "PostgreSQL/Aurora access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    # Allow access from your local IP. Replace X.X.X.X/32 with your actual IP.
    cidr_blocks      = ["0.0.0.0/0"]
    # Alternatively, to allow access from the web server:
    # security_groups  = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_security_group"
  }
}

# Create the subnet group for the RDS instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "database_subnet"
  subnet_ids  = [aws_default_subnet.subnet_az1.id, aws_default_subnet.subnet_az2.id]
  description = "Subnets for database instances"

  tags = {
    Name = "database_subnet"
  }
}

# Create an Aurora PostgreSQL RDS Cluster
resource "aws_rds_cluster" "aurora_pg_cluster" {
  engine                  = "aurora-postgresql"
  engine_version          = "16.1"  # Compatible with PostgreSQL 16.1
  cluster_identifier      = "aurora-pg-cluster"
  master_username         = "test_master"
  master_password         = "admin123"  # **Important:** Use secure methods for handling passwords
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id]  # Associate with DB SG
  availability_zones      = [
    data.aws_availability_zones.available_zones.names[0],
    data.aws_availability_zones.available_zones.names[1]
  ]
  database_name           = "microservice"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  tags = {
    Name = "aurora_pg_cluster"
  }
}

# Create an Aurora PostgreSQL RDS Cluster Instance (Primary Instance)
resource "aws_rds_cluster_instance" "aurora_pg_instance" {
  cluster_identifier      = aws_rds_cluster.aurora_pg_cluster.id
  instance_class          = "db.serverless"  # Ensure this is valid for Aurora Serverless
  engine                  = aws_rds_cluster.aurora_pg_cluster.engine
  engine_version          = aws_rds_cluster.aurora_pg_cluster.engine_version
  identifier              = "aurora-pg-instance"
  publicly_accessible     = true
  availability_zone       = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "aurora_pg_instance"
  }
}
