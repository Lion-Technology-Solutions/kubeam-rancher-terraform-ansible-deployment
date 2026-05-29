output "vpc_id" {
  description = "ID of the dedicated kubeadm VPC."
  value       = module.kubeadm_cluster.vpc_id
}

output "security_group_id" {
  description = "Security group attached to all kubeadm nodes."
  value       = module.kubeadm_cluster.security_group_id
}

output "master_nodes" {
  description = "Master node connection details."
  value       = module.kubeadm_cluster.master_nodes
}

output "worker_nodes" {
  description = "Worker node connection details."
  value       = module.kubeadm_cluster.worker_nodes
}

output "ansible_inventory" {
  description = "Generated Ansible inventory path."
  value       = local_file.ansible_inventory.filename
}
