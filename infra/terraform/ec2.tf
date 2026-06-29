data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vortex_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = aws_subnet.vortex_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vortex_sg.id]
  iam_instance_profile = aws_iam_instance_profile.vortex_instance_profile.name

  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "vortex-ec2-host"
    Environment = var.environment
  }
}

resource "aws_eip" "vortex_eip" {
  instance = aws_instance.vortex_server.id
  domain   = "vpc"

  tags = {
    Name        = "vortex-eip"
    Environment = var.environment
  }
}
