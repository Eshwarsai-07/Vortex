data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vortex_host" {
  ami                  = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public.id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.vortex.id
  ]

  user_data = file("${path.module}/user_data.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Ensure root block device has sufficient space for multiple Docker containers
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-host-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    ignore_changes = [
      ami, # prevent replacement if a new daily Ubuntu build is released
    ]
  }
}

resource "aws_eip" "vortex_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-eip-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.vortex_host.id
  allocation_id = aws_eip.vortex_eip.id
}
