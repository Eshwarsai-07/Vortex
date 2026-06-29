variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS Region for infrastructure provisioning"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment name"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance hardware type (Free Tier eligible)"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "Existing SSH key pair name in AWS (optional)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC Classless Inter-Domain Routing block"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public subnet CIDR block"
}
