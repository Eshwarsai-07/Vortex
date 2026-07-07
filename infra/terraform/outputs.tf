output "instance_id" {
  description = "The ID of the EC2 host instance"
  value       = aws_instance.vortex_host.id
}

output "ec2_public_ip" {
  description = "The raw public IP address of the EC2 instance (before EIP association)"
  value       = aws_instance.vortex_host.public_ip
}

output "elastic_ip" {
  description = "The permanent Elastic IP associated with the host"
  value       = aws_eip.vortex_eip.public_ip
}

output "public_dns" {
  description = "The public DNS name assigned to the EC2 host"
  value       = aws_instance.vortex_host.public_dns
}

output "ssh_command" {
  description = "Command template to establish an SSH connection to the host"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.vortex_eip.public_ip}"
}
