output "master_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker1_ip" {
  value = aws_instance.worker1.public_ip
}

output "worker1_private_ip" {
  value = aws_instance.worker1.private_ip
}

output "worker2_ip" {
  value = aws_instance.worker2.public_ip
}

output "worker2_private_ip" {
  value = aws_instance.worker2.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}