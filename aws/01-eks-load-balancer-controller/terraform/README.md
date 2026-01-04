# EKS Networking: Deploying AWS Load Balancer Controller with Terraform

Stop using outdated `type: LoadBalancer` (Classic Load Balancers). This project demonstrates the **"Right Way"** to expose applications on AWS EKS using the **AWS Load Balancer Controller**, Application Load Balancers (ALB), and Terraform Remote State.

## 🏗 Architecture Overview

The project is split into three decoupled layers to follow DevOps best practices:

1. **Network Layer**: Dedicated VPC, Public/Private subnets, and NAT Gateway.
2. **EKS Layer**: Private EKS cluster using cost-effective **Spot Instances** and EKS Access Entries.
3. **Application Layer**: AWS LB Controller (Helm), IAM Roles for Service Accounts (IRSA), and a demo Echo Server.

---

## 🚀 Getting Started

### 1. Prerequisites

* AWS CLI configured with Admin permissions.
* Terraform installed (v1.0+).
* An S3 bucket for remote state (e.g., `default-terraform-state-storage-a9f3c2`).

### 2. Initialize Remote State

Update the bucket name in all `providers.tf` and `data.tf` files:

```bash
find . -type f \( -name "providers.tf" -o -name "data.tf" \) \
  -exec sed -i '' 's/default-terraform-state-storage-a9f3c2/<YOUR-BUCKET-NAME>/g' {} +

```

### 3. Deployment Sequence

#### **Step A: Network**

Creates the foundational VPC and subnets with mandatory Kubernetes tags.

```bash
cd aws/01-eks-load-balancer-controller/terraform/network
terraform init && terraform apply -auto-approve

```

#### **Step B: EKS Cluster**

Provisions the cluster. **Note**: Update the IP allowlist in `main.tf` to your current IP.

```bash
cd ../eks
terraform init && terraform apply -auto-approve

```

#### **Step C: Load Balancer Controller & App**

Installs the controller and the demo application.

```bash
cd ../demo-app
terraform init && terraform apply -auto-approve

```

---

## 🛠 Access & Verification

### 1. Configure Kubectl

```bash
export AWS_CLI_AUTO_PROMPT=off
aws eks update-kubeconfig --region eu-west-3 --name main-cluster --kubeconfig main-cluster-config.yaml
export KUBECONFIG=main-cluster-config.yaml

```

### 2. Test the Application

Get the ALB DNS address and curl it:

```bash
ALB_URL=$(kubectl get ingress echo-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ALB_URL

```

---

## 🗑 Cleanup

To avoid unexpected AWS costs, destroy resources in this specific order:

```bash
# 1. App & Controller
cd demo-app && terraform destroy -auto-approve
# 2. EKS Cluster
cd ../eks && terraform destroy -auto-approve
# 3. Network
cd ../network && terraform destroy -auto-approve

```

---

**Author**: [Naima Amalou](https://github.com/amaloun)

**Full Guide**: [Read the detailed article on Medium](https://medium.com/@cloudwithnaima/eks-networking-deploying-aws-load-balancer-controller-with-terraform-4c3f35544ba8)
