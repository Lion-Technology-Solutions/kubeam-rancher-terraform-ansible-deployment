variable "project_name" {
  description = "Name prefix used for AWS resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment tag for the deployment."
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the master and worker nodes."
  type        = string
}

variable "control_plane_count" {
  description = "Number of kubeadm control plane nodes."
  type        = number
}

variable "worker_count" {
  description = "Number of kubeadm worker nodes."
  type        = number
}

variable "master_name_prefix" {
  description = "Name prefix for the kubeadm master node."
  type        = string
}

variable "worker_name_prefix" {
  description = "Name prefix for kubeadm worker nodes."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated kubeadm VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs used for the cluster nodes."
  type        = list(string)
}

variable "availability_zones" {
  description = "Optional list of availability zones. Defaults to the first available zones in the region."
  type        = list(string)
  default     = []
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the nodes."
  type        = string
}

variable "api_allowed_cidr" {
  description = "CIDR allowed to access the Kubernetes API server on port 6443."
  type        = string
}

variable "nodeport_allowed_cidr" {
  description = "CIDR allowed to access Kubernetes NodePort services."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB for each node."
  type        = number
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
