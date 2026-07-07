resource "aws_security_group" "vortex" {
  name        = "${var.project_name}-sg-${var.environment}"
  description = "Security Group for Vortex Host EC2 Instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- SSH Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound SSH traffic for system administrators"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.allowed_ssh_cidr
}

# --- HTTP Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound HTTP web traffic to Nginx"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.allowed_http_cidr
}

# --- HTTPS Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound HTTPS secure web traffic to Nginx"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.allowed_http_cidr
}

# --- React Frontend Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "frontend" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection directly to frontend server"
  ip_protocol       = "tcp"
  from_port         = 3005
  to_port           = 3005
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- Express Backend Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "backend_api" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection directly to backend API"
  ip_protocol       = "tcp"
  from_port         = 5005
  to_port           = 5005
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- Redpanda Console Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "redpanda_console" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to Redpanda Kafka Console UI"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- Kafka Broker Ingress Rules ---
resource "aws_vpc_security_group_ingress_rule" "kafka_1" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to Kafka Broker 1"
  ip_protocol       = "tcp"
  from_port         = 19092
  to_port           = 19092
  cidr_ipv4         = var.allowed_app_ports_cidr
}

resource "aws_vpc_security_group_ingress_rule" "kafka_2" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to Kafka Broker 2"
  ip_protocol       = "tcp"
  from_port         = 29092
  to_port           = 29092
  cidr_ipv4         = var.allowed_app_ports_cidr
}

resource "aws_vpc_security_group_ingress_rule" "kafka_3" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to Kafka Broker 3"
  ip_protocol       = "tcp"
  from_port         = 39092
  to_port           = 39092
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- ClickHouse Ingress Rules ---
resource "aws_vpc_security_group_ingress_rule" "clickhouse_http" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to ClickHouse HTTP interface"
  ip_protocol       = "tcp"
  from_port         = 8123
  to_port           = 8123
  cidr_ipv4         = var.allowed_app_ports_cidr
}

resource "aws_vpc_security_group_ingress_rule" "clickhouse_native" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to ClickHouse TCP native interface"
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- MongoDB Ingress Rule ---
resource "aws_vpc_security_group_ingress_rule" "mongodb" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow inbound connection to MongoDB Database"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  cidr_ipv4         = var.allowed_app_ports_cidr
}

# --- VPC Internal Ingress Rules ---
# These rules allow internal communication within the VPC CIDR for database and broker services

resource "aws_vpc_security_group_ingress_rule" "frontend_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection directly to frontend server"
  ip_protocol       = "tcp"
  from_port         = 3005
  to_port           = 3005
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "backend_api_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection directly to backend API"
  ip_protocol       = "tcp"
  from_port         = 5005
  to_port           = 5005
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "redpanda_console_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to Redpanda Kafka Console UI"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "kafka_1_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to Kafka Broker 1"
  ip_protocol       = "tcp"
  from_port         = 19092
  to_port           = 19092
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "kafka_2_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to Kafka Broker 2"
  ip_protocol       = "tcp"
  from_port         = 29092
  to_port           = 29092
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "kafka_3_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to Kafka Broker 3"
  ip_protocol       = "tcp"
  from_port         = 39092
  to_port           = 39092
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "clickhouse_http_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to ClickHouse HTTP interface"
  ip_protocol       = "tcp"
  from_port         = 8123
  to_port           = 8123
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "clickhouse_native_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to ClickHouse TCP native interface"
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_ipv4         = aws_vpc.main.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "mongodb_vpc" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow VPC internal connection to MongoDB Database"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  cidr_ipv4         = aws_vpc.main.cidr_block
}

# --- Full Outbound Egress Rule ---
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.vortex.id
  description       = "Allow all egress traffic outbound to the internet"
  ip_protocol       = "-1" # matches all protocols
  cidr_ipv4         = "0.0.0.0/0"
}
