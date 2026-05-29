output "vpc_id" {
  description = "ID of the dedicated kubeadm VPC."
  value       = aws_vpc.this.id
}

output "security_group_id" {
  description = "Security group attached to all kubeadm nodes."
  value       = aws_security_group.kubeadm.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the cluster."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "master_nodes" {
  description = "Control plane node connection details."
  value = [
    for instance in aws_instance.control_plane : {
      id         = instance.id
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

output "worker_nodes" {
  description = "Worker node connection details."
  value = [
    for instance in aws_instance.worker : {
      id         = instance.id
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}
