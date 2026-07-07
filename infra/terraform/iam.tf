resource "aws_iam_role" "ec2_role" {
  name        = "${var.project_name}-ec2-role-${var.environment}"
  description = "IAM Role for Vortex EC2 Host Instance to access SSM"

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
    Name        = "${var.project_name}-ec2-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-ec2-profile-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}
