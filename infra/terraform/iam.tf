resource "aws_iam_role" "vortex_ec2_role" {
  name = "vortex-ec2-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "vortex-ec2-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy_attachment" "vortex_s3_access" {
  name       = "vortex-s3-access-attachment"
  roles      = [aws_iam_role.vortex_ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "vortex_instance_profile" {
  name = "vortex-instance-profile"
  role = aws_iam_role.vortex_ec2_role.name
}
