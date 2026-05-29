variable "aws_region" {
  description = "AWS region where the kubeadm cluster will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for AWS resource names and tags."
  type        = string
  default     = "liontech-kubeadm"
}

variable "environment" {
  description = "Environment tag for the deployment."
  type        = string
  default     = "dev"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name. For rancher0529.pem this is usually rancher0529."
  type        = string
  default     = "rancher0529"
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key used by Ansible."
  type        = string
  default     = "~/.ssh/rancher0529.pem"
}

variable "instance_type" {
  description = "EC2 instance type used by the master and worker nodes."
  type        = string
  default     = "t2.medium"
}

variable "control_plane_count" {
  description = "Number of kubeadm control plane nodes. This module is configured for one by default."
  type        = number
  default     = 1

  validation {
    condition     = var.control_plane_count == 1
    error_message = "This deployment currently supports exactly one control plane node."
  }
}

variable "worker_count" {
  description = "Number of kubeadm worker nodes."
  type        = number
  default     = 3
}

variable "master_name_prefix" {
  description = "Name prefix for the kubeadm master node."
  type        = string
  default     = "liontech-master"
}

variable "worker_name_prefix" {
  description = "Name prefix for kubeadm worker nodes."
  type        = string
  default     = "liontech-worker"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated kubeadm VPC."
  type        = string
  default     = "10.52.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs used for the cluster nodes."
  type        = list(string)
  default     = ["10.52.1.0/24", "10.52.2.0/24"]
}

variable "availability_zones" {
  description = "Optional list of availability zones. Defaults to the first available zones in the region."
  type        = list(string)
  default     = []
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the nodes. Replace the default with your public IP /32 for production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "api_allowed_cidr" {
  description = "CIDR allowed to access the Kubernetes API server on port 6443."
  type        = string
  default     = "0.0.0.0/0"
}

variable "nodeport_allowed_cidr" {
  description = "CIDR allowed to access Kubernetes NodePort services."
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB for each node."
  type        = number
  default     = 30
}

variable "kubernetes_version" {
  description = "Kubernetes minor version used by Ansible package repositories, for example 1.30."
  type        = string
  default     = "1.30"
}

variable "pod_network_cidr" {
  description = "Pod network CIDR passed to kubeadm init. Must match the CNI manifest."
  type        = string
  default     = "192.168.0.0/16"
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
