module "kubeadm_cluster" {
  source = "./modules/kubeadm-cluster"

  project_name          = var.project_name
  environment           = var.environment
  key_name              = var.key_name
  instance_type         = var.instance_type
  control_plane_count   = var.control_plane_count
  worker_count          = var.worker_count
  master_name_prefix    = var.master_name_prefix
  worker_name_prefix    = var.worker_name_prefix
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  availability_zones    = var.availability_zones
  ssh_allowed_cidr      = var.ssh_allowed_cidr
  api_allowed_cidr      = var.api_allowed_cidr
  nodeport_allowed_cidr = var.nodeport_allowed_cidr
  root_volume_size      = var.root_volume_size
  tags                  = var.tags
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/inventory.tftpl", {
    master_nodes         = module.kubeadm_cluster.master_nodes
    worker_nodes         = module.kubeadm_cluster.worker_nodes
    ssh_private_key_path = var.ssh_private_key_path
    kubernetes_version   = var.kubernetes_version
    pod_network_cidr     = var.pod_network_cidr
  })
}
