variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name tag prefix used for all resources"
  type        = string
  default     = "vortex"
}

variable "environment" {
  description = "Target environment stage (e.g., development, staging, production)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "VPC classless inter-domain routing block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet classless inter-domain routing block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size type (minimum t3.large recommended due to ClickHouse/Kafka RAM usage)"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH authentication"
  type        = string
}

variable "ami_id" {
  description = "Optionally override the dynamically resolved Ubuntu AMI ID"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitted to establish SSH connections (port 22)"
  type        = string
  default     = "192.0.2.0/24" # Default to secure non-routable range, override in tfvars
}

variable "allowed_http_cidr" {
  description = "CIDR block permitted to establish HTTP/HTTPS connections (ports 80/443)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_app_ports_cidr" {
  description = "CIDR block permitted to reach databases and queue brokers externally (MongoDB, ClickHouse, Kafka, Redpanda)"
  type        = string
  default     = "192.0.2.0/24" # Default to secure non-routable range, override in tfvars
}

variable "availability_zone" {
  description = "Target Availability Zone for subnet placement"
  type        = string
  default     = "ap-south-1a"
}

