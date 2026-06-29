output "ec2_public_ip" {
  value       = aws_eip.vortex_eip.public_ip
  description = "Public Elastic IP address of the Vortex host server"
}

output "ssh_connection_string" {
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.vortex_eip.public_ip}"
  description = "Command to SSH directly into the EC2 instance"
}

output "api_endpoint" {
  value       = "http://${aws_eip.vortex_eip.public_ip}/api"
  description = "Public API Gateway endpoint"
}

output "private_key_pem" {
  value       = tls_private_key.deploy_key.private_key_pem
  description = "SSH Private Key to paste into GitHub Secrets EC2_SSH_KEY"
  sensitive   = true
}
