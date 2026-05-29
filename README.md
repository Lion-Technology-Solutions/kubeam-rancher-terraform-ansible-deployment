# LionTech Kubeadm Terraform and Ansible Deployment

This project deploys a kubeadm-based Kubernetes cluster on AWS.

Terraform owns the infrastructure:

- Dedicated VPC in `us-east-1`
- Public subnets, route table, internet gateway, and security group
- One Ubuntu 22.04 kubeadm control plane node
- Three Ubuntu 22.04 worker nodes named `liontech-worker-1` through `liontech-worker-3`
- `t2.medium` instance type by default
- Automatically generated Ansible inventory at `ansible/inventory.ini`

Ansible owns the server configuration:

- Installs Linux and Kubernetes dependencies
- Disables swap
- Configures kernel modules and sysctl values required by Kubernetes
- Installs and configures containerd
- Installs `kubeadm`, `kubelet`, and `kubectl`
- Initializes the kubeadm control plane
- Installs Calico CNI
- Joins all worker nodes
- Fetches the admin kubeconfig into `ansible/artifacts/admin.conf`

> The repository name includes Rancher, but this automation prepares a clean kubeadm Kubernetes cluster. Rancher can be installed afterward on top of this cluster with Helm if desired.

## Repository Layout

```text
.
|-- ansible/
|   |-- ansible.cfg
|   |-- group_vars/
|   |-- playbook.yml
|   `-- roles/
|-- scripts/
|   |-- run-ansible.ps1
|   `-- run-ansible.sh
`-- terraform/
    |-- main.tf
    |-- variables.tf
    |-- outputs.tf
    |-- inventory.tftpl
    |-- terraform.tfvars.example
    `-- modules/
        `-- kubeadm-cluster/
```

## Prerequisites

Install these tools on your workstation:

- Terraform `>= 1.5`
- Ansible `>= 2.14`
- AWS CLI configured with credentials that can create VPC, EC2, EBS, security group, and key pair attachments
- An existing AWS EC2 key pair named `rancher0529`
- The matching local private key file named `rancher0529.pem`

The default Ansible SSH private key path is:

```bash
~/.ssh/rancher0529.pem
```

Set private key permissions before running Ansible:

```bash
chmod 400 ~/.ssh/rancher0529.pem
```

On Windows, run Ansible from WSL or another Linux-compatible shell, and place the key where Ansible can read it.

## AWS Authentication

Configure AWS credentials before running Terraform:

```bash
aws configure
```

Or export environment variables:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

## Configure Terraform

Copy the example variables file:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

The default values already match the requested deployment:

```hcl
aws_region           = "us-east-1"
key_name             = "rancher0529"
ssh_private_key_path = "~/.ssh/rancher0529.pem"
instance_type        = "t2.medium"
control_plane_count  = 1
worker_count         = 3
master_name_prefix   = "liontech-master"
worker_name_prefix   = "liontech-worker"
```

For better security, restrict SSH, API, and NodePort access to your public IP:

```hcl
ssh_allowed_cidr      = "YOUR_PUBLIC_IP/32"
api_allowed_cidr      = "YOUR_PUBLIC_IP/32"
nodeport_allowed_cidr = "YOUR_PUBLIC_IP/32"
```

You can find your public IP with:

```bash
curl https://checkip.amazonaws.com
```

## Deploy Infrastructure

From the `terraform` directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After `terraform apply`, Terraform writes the Ansible inventory to:

```text
ansible/inventory.ini
```

The generated inventory contains:

- The control plane public IP
- The worker public IPs
- Private IP host variables
- SSH user `ubuntu`
- Private key path `~/.ssh/rancher0529.pem`
- Kubernetes version and pod CIDR variables

## Configure Kubernetes with Ansible

Run the playbook after Terraform finishes creating the instances:

```bash
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml
```

You can also use the helper script:

```bash
../scripts/run-ansible.sh
```

On PowerShell, if you have Ansible available in the current environment:

```powershell
..\scripts\run-ansible.ps1
```

## Use the Cluster

The playbook fetches the cluster admin kubeconfig to:

```text
ansible/artifacts/admin.conf
```

Use it locally:

```bash
export KUBECONFIG="$(pwd)/artifacts/admin.conf"
kubectl get nodes -o wide
kubectl get pods -A
```

If you are running the command from the repository root:

```bash
export KUBECONFIG="$PWD/ansible/artifacts/admin.conf"
kubectl get nodes -o wide
```

## Expected Nodes

The final cluster should contain:

```text
liontech-master-1
liontech-worker-1
liontech-worker-2
liontech-worker-3
```

All nodes should eventually report `Ready`.

## Kubernetes and CNI Defaults

The default Kubernetes package repository version is:

```yaml
kubernetes_version: "1.30"
```

The default pod network is:

```yaml
pod_network_cidr: "192.168.0.0/16"
```

The default CNI is Calico:

```yaml
calico_manifest_url: "https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml"
```

These settings live in:

```text
ansible/group_vars/all.yml
```

If you change `pod_network_cidr`, also use a CNI manifest compatible with that CIDR.

## Security Group Rules

Terraform creates one security group for all cluster nodes.

Inbound:

- TCP `22` from `ssh_allowed_cidr`
- TCP `6443` from `api_allowed_cidr`
- TCP `30000-32767` from `nodeport_allowed_cidr`
- All traffic between nodes in the same security group

Outbound:

- All traffic to the internet

For production, do not leave the public CIDR values at `0.0.0.0/0`.

## Idempotency

The Ansible playbook is written to be safely rerun:

- It does not rerun `kubeadm init` if `/etc/kubernetes/admin.conf` exists
- It does not rejoin a worker if `/etc/kubernetes/kubelet.conf` exists
- Package and system configuration tasks are repeatable
- Calico is applied with `kubectl apply`

## Troubleshooting

Check SSH connectivity:

```bash
ansible -i ansible/inventory.ini kube_cluster -m ping
```

Check kubelet status on a node:

```bash
ssh -i ~/.ssh/rancher0529.pem ubuntu@NODE_PUBLIC_IP
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 100 --no-pager
```

Check containerd:

```bash
sudo systemctl status containerd
sudo crictl ps
```

Check cluster state from the control plane:

```bash
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -A
```

If workers do not join, create a new join command on the master:

```bash
sudo kubeadm token create --print-join-command
```

Then rerun:

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## Teardown

Destroy the AWS infrastructure from the `terraform` directory:

```bash
terraform destroy
```

This removes the VPC, instances, EBS root volumes, security group, subnets, route table, and internet gateway created by this project.

## Notes

- The AWS EC2 key pair must already exist before `terraform apply`.
- The private key file itself is not committed.
- Generated inventory and fetched kubeconfig files are ignored by Git.
- This deployment uses public subnets so Ansible can connect directly over SSH.
- For private production clusters, add a bastion host, private subnets, NAT gateway, and tighter security group rules.
