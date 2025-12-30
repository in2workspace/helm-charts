# Cost-Optimized EKS Cluster for ISBE CertAuth

This Terraform configuration deploys the most cost-effective Amazon EKS cluster suitable for hosting the `isbe-certauth` Helm chart.

## Cost Optimization Strategies

### 1. **Spot Instances** (~90% savings)
- Uses EC2 Spot instances instead of On-Demand
- Instance types: `t3a.small`, `t3a.medium`, `t3.small`, `t3.medium`
- Spot provides significant cost savings with acceptable availability for non-critical workloads

### 2. **Minimal Instance Sizes**
- **t3a.small** (2 vCPU, 2GB RAM) - Primary choice
  - Cost: ~$0.0188/hour ($13.60/month)
  - Spot price: ~$0.0056/hour ($4/month)
- **t3a.medium** (2 vCPU, 4GB RAM) - Fallback
  - Cost: ~$0.0376/hour ($27/month)
  - Spot price: ~$0.0113/hour ($8/month)

### 3. **Right-Sized Cluster**
- **Min size**: 1 node (can handle the workload during low traffic)
- **Desired size**: 2 nodes (provides HA for the 2 replica deployment)
- **Max size**: 3 nodes (allows for growth)

### 4. **Efficient Storage**
- Uses **gp3** volumes instead of gp2 (20% cost savings)
- Minimal disk size: 20GB per node
- gp3 baseline: 3000 IOPS, 125 MB/s throughput

### 5. **Network Optimization**
- Public endpoint only (no private endpoint charges ~$0.10/hour)
- Single NAT Gateway (shared across AZs)
- Uses existing VPC infrastructure

### 6. **Disabled Features**
- Control plane logging disabled (saves CloudWatch costs)
- Minimal add-ons configuration
- No managed NAT Gateway per AZ

### 7. **Latest AL2023 AMI**
- Amazon Linux 2023 is lighter and more efficient
- Better performance with lower resource usage
- Free (no additional licensing costs)

## Cost Estimate

### Monthly Costs (Spot Instances):

| Resource | Unit Cost | Quantity | Monthly Cost |
|----------|-----------|----------|--------------|
| EKS Control Plane | $73/month | 1 | $73.00 |
| EC2 Spot (t3a.small) | ~$4/month | 2 | $8.00 |
| EBS gp3 (20GB) | $0.08/GB | 40GB | $3.20 |
| NAT Gateway | $32/month | 1 | $32.00 |
| NAT Data Transfer | $0.045/GB | ~100GB | $4.50 |
| ALB | $16.20/month | 1 | $16.20 |
| **Total** | | | **~$137/month** |

### Monthly Costs (On-Demand - for comparison):

| Resource | Unit Cost | Quantity | Monthly Cost |
|----------|-----------|----------|--------------|
| EKS Control Plane | $73/month | 1 | $73.00 |
| EC2 (t3a.small) | ~$13.60/month | 2 | $27.20 |
| EBS gp3 (20GB) | $0.08/GB | 40GB | $3.20 |
| NAT Gateway | $32/month | 1 | $32.00 |
| NAT Data Transfer | $0.045/GB | ~100GB | $4.50 |
| ALB | $16.20/month | 1 | $16.20 |
| **Total** | | | **~$156/month** |

### Potential Savings:
- **Using Spot**: ~$137/month
- **Using On-Demand**: ~$156/month
- **Savings**: ~$19/month (~12% on spot)

## Workload Capacity

The isbe-certauth chart requires:
- **2 replicas**
- **250m CPU request** per pod = 500m total
- **256Mi memory request** per pod = 512Mi total
- **10Gi persistent storage**

A **t3a.small** instance provides:
- **2 vCPU** (2000m)
- **2 GiB RAM**

**Capacity Analysis:**
- 2 nodes × 2000m CPU = 4000m available
- System pods (~300m) = 3700m usable
- App needs 500m = **13.5% CPU utilization**
- Plenty of headroom for bursts and additional workloads

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.5
3. kubectl installed
4. Existing VPC (configured in vpc.tf)

## Deployment

### 1. Initialize Terraform
```bash
cd iac
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

### 3. Apply the Configuration
```bash
terraform apply
```

### 4. Configure kubectl
```bash
aws eks update-kubeconfig --region eu-west-1 --name certauth-stg-eks-ew1
```

### 5. Verify Cluster
```bash
kubectl get nodes
kubectl get pods -A
```

### 6. Deploy isbe-certauth Chart
```bash
cd ../wip/isbe-certauth

# Update values.yaml with appropriate hostnames and secrets
helm upgrade --install isbe-certauth . \
  --namespace certauth \
  --create-namespace \
  --values values.yaml
```

## Post-Deployment Configuration

### 1. Verify Storage Class
```bash
kubectl get storageclass
```

### 2. Check ALB Ingress Controller
```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### 3. Monitor Workload
```bash
kubectl get pods -n certauth
kubectl top nodes
kubectl top pods -n certauth
```

## Cost Optimization Tips

### Further Savings:

1. **Use AWS Savings Plans**
   - Commit to 1-3 year compute usage for up to 72% savings
   - Applies to EC2 and Fargate

2. **Schedule Downtime**
   - Scale nodes to 0 during non-business hours
   - Use Karpenter for advanced scheduling

3. **Use Fargate Spot (Alternative)**
   - EKS on Fargate eliminates node management
   - Pay only for pod runtime
   - Consider for truly variable workloads

4. **Enable Cluster Autoscaler**
   - Scale down to min_size during low traffic
   - Automatically scale up during peak hours

5. **Monitor and Right-Size**
   - Use Container Insights to monitor actual usage
   - Adjust instance types based on metrics
   - Consider even smaller instances if usage permits

## Monitoring Costs

### AWS Cost Explorer
```bash
# View EKS costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://eks-cost-filter.json
```

### Kubernetes Resource Monitoring
```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check resource usage
kubectl top nodes
kubectl top pods -A
```

## Scaling Strategies

### Manual Scaling
```bash
# Scale node group
aws eks update-nodegroup-config \
  --cluster-name certauth-stg-eks-ew1 \
  --nodegroup-name cost-optimized-spot-xxxxx \
  --scaling-config minSize=0,maxSize=3,desiredSize=1
```

### Automatic Scaling with Cluster Autoscaler
```bash
# Install cluster autoscaler
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=certauth-stg-eks-ew1 \
  --set awsRegion=eu-west-1
```

## Troubleshooting

### Spot Instance Interruptions
```bash
# Check for spot interruption warnings
kubectl get events -A --sort-by='.lastTimestamp' | grep -i spot
```

If spot instances are frequently interrupted:
1. Add more instance types to the node group
2. Consider using a mix of spot and on-demand (e.g., 50/50)
3. Implement proper pod disruption budgets

### Insufficient Capacity
```bash
# Check pending pods
kubectl get pods -A | grep Pending

# Describe pending pods for details
kubectl describe pod <pod-name> -n <namespace>
```

## Security Considerations

1. **IMDSv2 Required**: Enabled by default
2. **Private Subnets**: Nodes in private subnets with NAT gateway
3. **Security Groups**: Properly configured for minimum necessary access
4. **IRSA**: IAM Roles for Service Accounts enabled
5. **Encryption**: EBS volumes encrypted by default
6. **No SSH Access**: Nodes have no SSH keys configured

## Upgrade Path

When scaling up:
1. Increase `max_size` in node group configuration
2. Add more diverse instance types for better spot availability
3. Consider adding an on-demand node group for critical pods
4. Enable cluster autoscaler
5. Implement pod disruption budgets
6. Add monitoring and alerting

## Alternative Architectures

### Even Lower Cost Options:

1. **EKS on Fargate Spot**
   - No node management
   - Pay only for pod vCPU and memory
   - Good for variable workloads

2. **Self-Managed Nodes with Karpenter**
   - More instance type flexibility
   - Better bin-packing
   - Faster scaling

3. **ECS with Fargate**
   - No Kubernetes overhead
   - Simpler for single-service workloads
   - Potentially lower cost for this specific use case

## Cleanup

To destroy all resources:
```bash
# Delete Helm releases first
helm uninstall isbe-certauth -n certauth

# Destroy Terraform resources
terraform destroy
```

## Support

For issues or questions:
1. Check AWS EKS documentation
2. Review Terraform module documentation
3. Check application logs: `kubectl logs -n certauth <pod-name>`
4. Review AWS CloudWatch (if enabled)

## References

- [AWS EKS Pricing](https://aws.amazon.com/eks/pricing/)
- [EC2 Spot Instances](https://aws.amazon.com/ec2/spot/)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
