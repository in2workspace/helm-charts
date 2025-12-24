# Cost-Optimized EKS Infrastructure for ISBE CertAuth

This directory contains Terraform configurations for deploying a cost-optimized Amazon EKS cluster designed to host the `isbe-certauth` application.

## 📋 Overview

- **Monthly Cost**: ~$137 USD (with spot instances)
- **Cluster Type**: EKS with managed node groups
- **Node Type**: t3a.small spot instances (2 nodes)
- **Region**: eu-west-1 (Ireland)
- **Kubernetes Version**: 1.31

## 🚀 Quick Start

### Prerequisites

```bash
# Validate all prerequisites
make validate
```

Required tools:
- AWS CLI (configured with credentials)
- Terraform >= 1.5
- kubectl
- Helm 3

### Deploy Everything

```bash
# Deploy EKS cluster and application in one command
make all
```

This will:
1. Initialize Terraform
2. Show infrastructure plan
3. Deploy EKS cluster (~15-20 min)
4. Configure kubectl
5. Deploy isbe-certauth application
6. Show deployment status

### Step-by-Step Deployment

If you prefer to deploy in stages:

```bash
# 1. Deploy EKS cluster
make eks-deploy

# 2. Configure kubectl
make kubectl-config

# 3. Deploy application
make certauth-deploy

# 4. Check status
make certauth-status
```

## 📖 Available Commands

### Infrastructure Management

| Command | Description |
|---------|-------------|
| `make init` | Initialize Terraform |
| `make plan` | Show Terraform plan |
| `make apply` | Apply Terraform changes |
| `make destroy` | Destroy all infrastructure |
| `make clean` | Clean Terraform files |

### EKS Operations

| Command | Description |
|---------|-------------|
| `make eks-deploy` | Deploy EKS cluster |
| `make eks-status` | Check cluster status |
| `make kubectl-config` | Configure kubectl |

### Application Operations

| Command | Description |
|---------|-------------|
| `make certauth-deploy` | Deploy isbe-certauth |
| `make certauth-status` | Check app status |
| `make certauth-logs` | View app logs |
| `make certauth-port-forward` | Port forward to app |

### Utilities

| Command | Description |
|---------|-------------|
| `make validate` | Validate prerequisites |
| `make costs` | Show cost estimate |
| `make help` | Show all commands |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│           Application Load Balancer          │
│  (certauth, certsec, onboard endpoints)     │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│              EKS Cluster                     │
│  ┌─────────────────────────────────────┐   │
│  │  Node Group (Spot Instances)        │   │
│  │  - 2x t3a.small                     │   │
│  │  - Auto-scaling: 1-3 nodes          │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  isbe-certauth (2 replicas)         │   │
│  │  - 250m CPU / 256Mi RAM each        │   │
│  │  - 10Gi persistent storage          │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## 💰 Cost Breakdown

| Resource | Monthly Cost |
|----------|--------------|
| EKS Control Plane | $73.00 |
| 2× t3a.small (spot) | $8.00 |
| EBS gp3 (40GB) | $3.20 |
| NAT Gateway | $32.00 |
| Data Transfer | $4.50 |
| ALB | $16.20 |
| **Total** | **~$137** |

View detailed cost analysis:
```bash
make costs
```

## 📁 Files

| File | Description |
|------|-------------|
| `eks.tf` | EKS cluster configuration |
| `vpc.tf` | VPC and networking |
| `data.tf` | Data sources (ACM certs, Route53) |
| `variables.tf` | Input variables |
| `locals.tf` | Local values and naming |
| `provider.tf` | AWS and Kubernetes providers |
| `backend.tf` | Terraform backend (S3) |
| `Makefile` | Deployment automation |
| `deploy-certauth.sh` | Application deployment script |
| `QUICKSTART.md` | Detailed deployment guide |
| `EKS_COST_OPTIMIZATION.md` | Cost optimization strategies |

## 🔍 Monitoring

### Cluster Status

```bash
# Overall cluster health
make eks-status

# Node resources
kubectl top nodes

# All pods across namespaces
kubectl get pods -A
```

### Application Status

```bash
# Application health
make certauth-status

# Live logs
make certauth-logs

# Pod resources
kubectl top pods -n certauth
```

### AWS Console

Navigate to:
- **EKS Console**: View cluster details, workloads, resources
- **EC2 Console**: View node instances, spot pricing
- **CloudWatch**: View logs (if enabled)
- **Cost Explorer**: Track actual costs

## 🔧 Customization

### Adjust Node Group Size

Edit `eks.tf`:

```terraform
min_size     = 1   # Minimum nodes
max_size     = 5   # Maximum nodes
desired_size = 2   # Initial nodes
```

### Change Instance Types

Edit `eks.tf`:

```terraform
instance_types = ["t3a.small", "t3a.medium", "t3.small"]
```

### Switch to On-Demand

Edit `eks.tf`:

```terraform
capacity_type = "ON_DEMAND"  # Instead of "SPOT"
```

### Adjust Resource Limits

Edit application values in `deploy-certauth.sh`:

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Check pod details
kubectl describe pod -n certauth <pod-name>

# Check events
kubectl get events -n certauth --sort-by='.lastTimestamp'

# Check logs
kubectl logs -n certauth <pod-name>
```

### Spot Instance Interruptions

Spot instances may be interrupted. The cluster automatically replaces them:

```bash
# Check node status
kubectl get nodes

# Check for interruption events
kubectl get events -A | grep -i spot
```

### ALB Not Created

```bash
# Check ALB controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check ingress status
kubectl describe ingress -n certauth
```

### Cannot Access Cluster

```bash
# Reconfigure kubectl
make kubectl-config

# Verify AWS credentials
aws sts get-caller-identity

# Check cluster status
aws eks describe-cluster --name certauth-stg-eks-ew1 --region eu-west-1
```

## 🧹 Cleanup

### Delete Application Only

```bash
helm uninstall isbe-certauth -n certauth
kubectl delete namespace certauth
```

### Delete Everything

```bash
# IMPORTANT: Delete Kubernetes resources first
kubectl delete ingress --all -n certauth
kubectl delete pvc --all -n certauth
helm uninstall isbe-certauth -n certauth

# Wait for ALB to be deleted (check AWS Console)

# Destroy infrastructure
make destroy
```

⚠️ **Warning**: This will delete all resources including persistent data!

## 📚 Documentation

- [QUICKSTART.md](QUICKSTART.md) - Step-by-step deployment guide
- [EKS_COST_OPTIMIZATION.md](EKS_COST_OPTIMIZATION.md) - Detailed cost analysis and optimization strategies

## 🔐 Security

- IMDSv2 required for EC2 instances
- Nodes deployed in private subnets
- Security groups with minimal necessary access
- IRSA (IAM Roles for Service Accounts) enabled
- EBS volumes encrypted at rest
- No SSH keys configured on nodes

## 📈 Scaling

### Horizontal Pod Autoscaler

```bash
kubectl autoscale deployment isbe-certauth -n certauth \
  --min=2 --max=5 --cpu-percent=70
```

### Cluster Autoscaler

Install cluster autoscaler:

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=certauth-stg-eks-ew1
```

## 🤝 Contributing

1. Create a feature branch
2. Make changes
3. Test with `make plan`
4. Submit pull request

## 📞 Support

For issues:
1. Check [troubleshooting section](#-troubleshooting)
2. Review AWS EKS documentation
3. Check application logs
4. Contact DevOps team

## 📝 License

Internal use only - ALTIA

---

**Last Updated**: December 24, 2025
**Maintained By**: DevOps Team
