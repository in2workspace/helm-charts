# Quick Start Guide - Cost-Optimized EKS Cluster

This guide will walk you through deploying a cost-optimized EKS cluster and the isbe-certauth application.

## Total Time: ~20-30 minutes

## Prerequisites Checklist

- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.5 installed
- [ ] kubectl installed
- [ ] Helm 3 installed
- [ ] AWS credentials with appropriate permissions
- [ ] ACM certificates created for `*.altia.eudistack.net` and `*.api.altia.eudistack.net`

## Step 1: Verify Prerequisites

```bash
# Check AWS CLI
aws --version
aws sts get-caller-identity

# Check Terraform
terraform version

# Check kubectl
kubectl version --client

# Check Helm
helm version
```

## Step 2: Review Configuration

```bash
cd iac

# Review variables (optional - edit if needed)
cat variables.tf

# Review VPC configuration
cat vpc.tf

# Review EKS configuration
cat eks.tf
```

## Step 3: Initialize Terraform

```bash
terraform init
```

Expected output: "Terraform has been successfully initialized!"

## Step 4: Plan the Infrastructure

```bash
terraform plan
```

Review the plan carefully. You should see:
- 1 EKS cluster
- 1 EKS managed node group (spot instances)
- 2-3 IAM roles
- Various security groups
- Storage class configuration

## Step 5: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**This step takes ~15-20 minutes** as AWS provisions:
1. EKS control plane (~10 min)
2. Node group (~5 min)
3. Add-ons installation (~5 min)

☕ Great time for a coffee break!

## Step 6: Configure kubectl

After Terraform completes:

```bash
# Configure kubectl (command is in Terraform output)
aws eks update-kubeconfig --region eu-west-1 --name certauth-stg-eks-ew1

# Verify cluster access
kubectl get nodes

# You should see 2 nodes in Ready state
```

## Step 7: Verify Cluster Components

```bash
# Check system pods
kubectl get pods -A

# Verify storage class
kubectl get storageclass

# Check node resources
kubectl top nodes
```

## Step 8: Deploy isbe-certauth

### Option A: Automated Deployment (Recommended)

```bash
# Run the deployment script
./deploy-certauth.sh
```

The script will:
- Configure kubectl
- Verify cluster health
- Check prerequisites
- Create namespace
- Deploy the Helm chart
- Show deployment status

### Option B: Manual Deployment

```bash
# Create namespace
kubectl create namespace certauth

# Deploy Helm chart
cd ../wip/isbe-certauth

helm upgrade --install isbe-certauth . \
  --namespace certauth \
  --create-namespace \
  --set persistence.storageClass=gp3 \
  --set serviceUrls.certauth=https://certauth.stg.altia.eudistack.net \
  --set serviceUrls.certsec=https://certsec.stg.altia.eudistack.net \
  --set serviceUrls.onboard=https://onboard.stg.altia.eudistack.net \
  --wait

# Check deployment
kubectl get pods -n certauth
```

## Step 9: Verify Deployment

```bash
# Check pods are running
kubectl get pods -n certauth

# Check services
kubectl get svc -n certauth

# Check ingress (ALB)
kubectl get ingress -n certauth

# View logs
kubectl logs -n certauth -l app.kubernetes.io/name=isbe-certauth
```

## Step 10: Configure DNS

Get the ALB DNS name:

```bash
kubectl get ingress -n certauth -o jsonpath='{.items[*].status.loadBalancer.ingress[0].hostname}'
```

Create CNAME records in Route53:
- `certauth.stg.altia.eudistack.net` → ALB DNS
- `certsec.stg.altia.eudistack.net` → ALB DNS
- `onboard.stg.altia.eudistack.net` → ALB DNS

Or use the provided script:

```bash
# This should already be configured in route53.tf
terraform apply -target=aws_route53_record.certauth
```

## Step 11: Test the Application

```bash
# Test health endpoint (once DNS propagates)
curl https://certauth.stg.altia.eudistack.net/health

# Or port-forward for immediate testing
kubectl port-forward -n certauth svc/isbe-certauth 8010:8010

# In another terminal
curl http://localhost:8010/health
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod -n certauth <pod-name>

# Check events
kubectl get events -n certauth --sort-by='.lastTimestamp'

# Check node resources
kubectl describe nodes
```

### No Nodes Available

```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name certauth-stg-eks-ew1 \
  --nodegroup-name <nodegroup-name>

# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(Tags[?Key=='eks:cluster-name'].Value, 'certauth')]"
```

### ALB Not Created

```bash
# Check ALB controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Verify IRSA configuration
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml
```

### Spot Instance Interruption

Spot instances may be interrupted. If this happens:

```bash
# Check node status
kubectl get nodes

# The node group will automatically replace interrupted instances
# Your pods will be rescheduled to healthy nodes
```

## Monitoring

### Resource Usage

```bash
# Overall cluster resources
kubectl top nodes

# Pod resources
kubectl top pods -n certauth

# Detailed pod metrics
kubectl describe pod -n certauth <pod-name>
```

### Application Logs

```bash
# Stream logs
kubectl logs -f -n certauth -l app.kubernetes.io/name=isbe-certauth

# Last 100 lines
kubectl logs --tail=100 -n certauth <pod-name>

# Logs from previous container (if restarted)
kubectl logs --previous -n certauth <pod-name>
```

### AWS Console Monitoring

1. Navigate to EKS console
2. Select cluster `certauth-stg-eks-ew1`
3. View:
   - Overview
   - Workloads
   - Resources
   - Add-ons

## Cost Monitoring

### View Current Costs

```bash
# EKS cluster costs (last 30 days)
aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d '30 days ago' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE \
  --filter file://<(echo '{"Tags":{"Key":"kubernetes.io/cluster/certauth-stg-eks-ew1","Values":["owned","shared"]}}')
```

### Expected Monthly Costs

| Component | Cost |
|-----------|------|
| EKS Control Plane | ~$73 |
| 2x t3a.small (spot) | ~$8 |
| EBS (40GB gp3) | ~$3 |
| NAT Gateway | ~$32 |
| ALB | ~$16 |
| Data Transfer | ~$5 |
| **Total** | **~$137/month** |

## Scaling

### Manual Scaling

```bash
# Scale deployment
kubectl scale deployment isbe-certauth -n certauth --replicas=3

# Scale node group (via AWS CLI)
aws eks update-nodegroup-config \
  --cluster-name certauth-stg-eks-ew1 \
  --nodegroup-name <nodegroup-name> \
  --scaling-config minSize=2,maxSize=5,desiredSize=3
```

### Auto Scaling

The cluster is configured to auto-scale based on resource usage. The node group will:
- Scale down to 1 node when idle
- Scale up to 3 nodes under load

## Cleanup

### To Delete the Application

```bash
# Uninstall Helm chart
helm uninstall isbe-certauth -n certauth

# Delete namespace
kubectl delete namespace certauth
```

### To Delete the Entire Infrastructure

```bash
# IMPORTANT: Delete all Kubernetes resources first
kubectl delete ingress --all -n certauth
kubectl delete pvc --all -n certauth
helm uninstall isbe-certauth -n certauth

# Wait for ALB to be deleted (check in AWS Console)
# Then destroy Terraform resources
terraform destroy
```

Type `yes` when prompted. This takes ~10-15 minutes.

## Next Steps

- [ ] Set up monitoring (CloudWatch, Prometheus, Grafana)
- [ ] Configure backup strategy for persistent volumes
- [ ] Implement CI/CD pipeline
- [ ] Set up log aggregation
- [ ] Configure alerting
- [ ] Review and adjust resource limits
- [ ] Implement pod disruption budgets
- [ ] Set up network policies
- [ ] Configure secrets management (AWS Secrets Manager)

## Support Resources

- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)

## Cost Optimization Checklist

- [x] Using Spot instances
- [x] Minimal instance sizes (t3a.small)
- [x] gp3 storage instead of gp2
- [x] Single NAT Gateway
- [x] Latest AL2023 AMI
- [ ] Set up cluster autoscaler
- [ ] Configure resource quotas
- [ ] Implement pod disruption budgets
- [ ] Set up cost alerts
- [ ] Regular cost reviews

---

**Questions or Issues?** Check the [EKS_COST_OPTIMIZATION.md](EKS_COST_OPTIMIZATION.md) for detailed information.
