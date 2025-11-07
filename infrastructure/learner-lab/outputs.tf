output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_eip.app.public_ip
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_eip.app.public_ip}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.app.public_ip}:3001"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.app.public_ip}"
}
