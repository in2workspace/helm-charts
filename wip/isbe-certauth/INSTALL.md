# ISBE CertAuth - Installation Guide for AWS EKS

This guide provides step-by-step instructions for AWS EKS administrators to install the ISBE CertAuth Helm chart.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Installation Setup](#pre-installation-setup)
- [Creating Environment-Specific Values](#creating-environment-specific-values)
- [Installation](#installation)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. EKS Cluster Requirements

- **Kubernetes Version**: 1.19 or higher
- **Node Type**: Minimum t3.small instances (or equivalent)
- **Node Resources**: At least 1 GB RAM and 1 CPU core available per pod

### 2. Required Components in EKS Cluster

#### AWS Load Balancer Controller

The chart requires the AWS Load Balancer Controller to create Application Load Balancers (ALBs).

**Check if installed:**
```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

**If not installed**, follow the [official AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) or use the automated script:

```bash
# Set your cluster name and region
CLUSTER_NAME="your-cluster-name"
REGION="eu-west-1"

# Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION
```

> **Note**: The service account must have appropriate IAM permissions. See [AWS Load Balancer Controller installation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/).

#### Storage Class

The chart requires a `gp3` StorageClass for persistent volumes.

**Check if exists:**
```bash
kubectl get storageclass gp3
```

**If not present**, create it:

```yaml
# gp3-storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

Apply with:
```bash
kubectl apply -f gp3-storageclass.yaml
```

### 3. AWS Certificate Manager (ACM)

You need an ACM certificate that covers your domain(s). The certificate must be in the same region as your EKS cluster.

**Requirements:**
- Valid ACM certificate ARN
- Certificate must include all hostnames (or use wildcard):
  - `certauth.yourdomain.com`
  - `certsec.yourdomain.com`
  - `onboard.yourdomain.com`

**Example:** `arn:aws:acm:eu-west-1:123456789012:certificate/your-cert-id`

### 4. DNS Configuration

Ensure you have the ability to create DNS records pointing to ALB endpoints (Route53, CloudFlare, etc.).

### 5. Tools Required

- `kubectl` - configured to access your EKS cluster
- `helm` 3.0+
- `aws-cli` - configured with appropriate credentials

---

## Pre-Installation Setup

### 1. Configure kubectl Context

```bash
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name your-cluster-name \
  --profile your-aws-profile
```

### 2. Create Namespace

```bash
kubectl create namespace certauth
```

### 3. (Optional) Create Secrets for Sensitive Data

Instead of storing passwords in values files, create Kubernetes secrets:

```bash
# Admin password secret
kubectl create secret generic certauth-admin \
  --from-literal=password='your-secure-admin-password' \
  -n certauth

# TSA credentials secret
kubectl create secret generic certauth-tsa \
  --from-literal=username='tsa-user' \
  --from-literal=password='your-tsa-password' \
  -n certauth

# SMTP credentials secret
kubectl create secret generic certauth-smtp \
  --from-literal=username='smtp-user@example.com' \
  --from-literal=password='your-smtp-password' \
  -n certauth
```

---

## Creating Environment-Specific Values

Create a custom values file for your environment (e.g., `values-production.yaml` or `values-staging.yaml`).

### Minimal Configuration (values-myenv.yaml)

```yaml
# --- Basic Configuration ---
# Adjust replica count based on your needs
replicaCount: 2

# --- Service URLs ---
# REQUIRED: Update with your actual domain names
serviceUrls:
  certauth: "https://certauth.yourdomain.com"
  certsec: "https://certsec.yourdomain.com"
  onboard: "https://onboard.yourdomain.com"

# --- Credentials ---
# Option 1: Direct values (NOT recommended for production)
adminPassword:
  value: "change-me-in-production"

tsaCredentials:
  user: "tsa-user"
  password: "change-me-in-production"

smtpCredentials:
  username: "smtp-user@example.com"
  password: "change-me-in-production"

# Option 2: Use existing secrets (RECOMMENDED)
# adminPassword:
#   existingSecret:
#     enabled: true
#     name: "certauth-admin"
#     key: "password"
#
# tsaCredentials:
#   existingSecret:
#     enabled: true
#     name: "certauth-tsa"
#     userKey: "username"
#     passwordKey: "password"
#
# smtpCredentials:
#   existingSecret:
#     enabled: true
#     name: "certauth-smtp"
#     usernameKey: "username"
#     passwordKey: "password"

# --- Persistence ---
persistence:
  enabled: true
  storageClass: "gp3"
  size: 10Gi

# --- Ingress Configuration ---
ingress:
  # CertAuth service (main authentication endpoint)
  certauth:
    enabled: true
    hostname: "certauth.yourdomain.com"
    className: "alb"
    annotations:
      alb.ingress.kubernetes.io/scheme: "internet-facing"
      alb.ingress.kubernetes.io/target-type: "ip"
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
      # REQUIRED: Replace with your ACM certificate ARN
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERT_ID"
      alb.ingress.kubernetes.io/healthcheck-path: "/health"
      alb.ingress.kubernetes.io/healthcheck-port: "8012"
      alb.ingress.kubernetes.io/healthcheck-protocol: "HTTP"
      # Group multiple ingresses into single ALB
      alb.ingress.kubernetes.io/group.name: "grp-isbe-certauth"
      alb.ingress.kubernetes.io/group.order: "1"

  # CertSec service (mTLS endpoint)
  certsec:
    enabled: true
    hostname: "certsec.yourdomain.com"
    className: "alb"
    annotations:
      alb.ingress.kubernetes.io/scheme: "internet-facing"
      alb.ingress.kubernetes.io/target-type: "ip"
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
      # REQUIRED: Replace with your ACM certificate ARN
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERT_ID"
      alb.ingress.kubernetes.io/healthcheck-path: "/health"
      alb.ingress.kubernetes.io/healthcheck-port: "8012"
      alb.ingress.kubernetes.io/healthcheck-protocol: "HTTP"
      # Separate ALB for mTLS
      alb.ingress.kubernetes.io/group.name: "grp-isbe-certauth-mtls"
      alb.ingress.kubernetes.io/group.order: "1"
      # Optional: Enable mTLS (requires trust store configuration)
      # alb.ingress.kubernetes.io/mutual-authentication: '[{"port": 443, "mode": "verify", "trustStore": "arn:aws:elasticloadbalancing:REGION:ACCOUNT_ID:truststore/NAME/ID"}]'

  # Onboard service
  onboard:
    enabled: true
    hostname: "onboard.yourdomain.com"
    className: "alb"
    annotations:
      alb.ingress.kubernetes.io/scheme: "internet-facing"
      alb.ingress.kubernetes.io/target-type: "ip"
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
      # REQUIRED: Replace with your ACM certificate ARN
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERT_ID"
      alb.ingress.kubernetes.io/healthcheck-path: "/health"
      alb.ingress.kubernetes.io/healthcheck-port: "8012"
      alb.ingress.kubernetes.io/healthcheck-protocol: "HTTP"
      alb.ingress.kubernetes.io/group.name: "grp-isbe-certauth"
      alb.ingress.kubernetes.io/group.order: "3"

# --- Resource Limits ---
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# --- Observability (optional) ---
observability:
  enabled: false  # Set to true if you have Prometheus Operator installed
  scrapePath: /metrics
  dashboard:
    enabled: false  # Set to true if you have Grafana Operator installed
```

### Key Variables to Override

| Variable | Description | Required |
|----------|-------------|----------|
| `serviceUrls.certauth` | External URL for CertAuth service | **Yes** |
| `serviceUrls.certsec` | External URL for CertSec service | **Yes** |
| `serviceUrls.onboard` | External URL for Onboard service | **Yes** |
| `ingress.*.hostname` | Hostname for each ingress | **Yes** |
| `ingress.*.annotations.certificate-arn` | ACM certificate ARN | **Yes** |
| `adminPassword.value` | Admin password | **Yes** |
| `tsaCredentials.*` | TSA user and password | **Yes** |
| `smtpCredentials.*` | SMTP username and password | **Yes** |
| `replicaCount` | Number of pod replicas | No (default: 2) |
| `persistence.size` | Persistent volume size | No (default: 10Gi) |
| `resources.*` | CPU and memory limits | No (has defaults) |

---

## Installation

### 1. Download or Clone the Chart

```bash
# If from Git repository
git clone https://github.com/in2workspace/helm-charts.git
cd helm-charts/wip/isbe-certauth

# Or navigate to the chart directory if already cloned
cd /path/to/helm-charts/wip/isbe-certauth
```

### 2. Validate Your Values File

```bash
# Check if the values file is valid YAML
helm lint . -f values-myenv.yaml
```

### 3. Perform a Dry Run

```bash
helm install isbe-certauth . \
  --namespace certauth \
  --values values.yaml \
  --values values-myenv.yaml \
  --dry-run --debug
```

Review the output to ensure all values are correctly templated.

### 4. Install the Chart

```bash
helm install isbe-certauth . \
  --namespace certauth \
  --values values.yaml \
  --values values-myenv.yaml \
  --wait \
  --timeout 10m
```

**Parameters:**
- `isbe-certauth`: Release name
- `--namespace certauth`: Target namespace
- `--values values.yaml`: Base values file
- `--values values-myenv.yaml`: Environment-specific overrides
- `--wait`: Wait for all resources to be ready
- `--timeout 10m`: Maximum wait time

### 5. Upgrade (if already installed)

```bash
helm upgrade isbe-certauth . \
  --namespace certauth \
  --values values.yaml \
  --values values-myenv.yaml \
  --wait \
  --timeout 10m
```

Or use `helm upgrade --install` to install if not exists, upgrade otherwise:

```bash
helm upgrade --install isbe-certauth . \
  --namespace certauth \
  --values values.yaml \
  --values values-myenv.yaml \
  --wait \
  --timeout 10m
```

---

## Verification

### 1. Check Pod Status

```bash
kubectl get pods -n certauth
```

Expected output:
```
NAME                             READY   STATUS    RESTARTS   AGE
isbe-certauth-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
isbe-certauth-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

### 2. Check Services

```bash
kubectl get svc -n certauth
```

### 3. Check Ingress Resources

```bash
kubectl get ingress -n certauth
```

You should see 3 ingress resources (one for each endpoint).

### 4. Get ALB DNS Names

```bash
kubectl get ingress -n certauth -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.loadBalancer.ingress[0].hostname}{"\n"}{end}'
```

### 5. Configure DNS

Create DNS CNAME records pointing your hostnames to the ALB DNS names:

```
certauth.yourdomain.com  -> CNAME -> k8s-grpisbe-xxxxxxxx.region.elb.amazonaws.com
certsec.yourdomain.com   -> CNAME -> k8s-grpisbe-xxxxxxxx.region.elb.amazonaws.com
onboard.yourdomain.com   -> CNAME -> k8s-grpisbe-xxxxxxxx.region.elb.amazonaws.com
```

### 6. Test Endpoints

```bash
# Test CertAuth (should return 200 or 404 depending on implementation)
curl -I https://certauth.yourdomain.com/health

# Test CertSec
curl -I https://certsec.yourdomain.com/health

# Test Onboard
curl -I https://onboard.yourdomain.com/health
```

### 7. Check Logs

```bash
# View logs from all pods
kubectl logs -f -n certauth -l app.kubernetes.io/name=isbe-certauth

# View logs from specific pod
kubectl logs -f -n certauth <pod-name>
```

---

## Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod <pod-name> -n certauth

# Check if PVC is bound
kubectl get pvc -n certauth
```

**Common issues:**
- Storage class not available
- Insufficient node resources
- Image pull errors (check image repository and tag)

### Ingress/ALB Not Created

```bash
# Check ingress events
kubectl describe ingress <ingress-name> -n certauth

# Check AWS Load Balancer Controller logs
kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

**Common issues:**
- AWS Load Balancer Controller not installed
- Missing IAM permissions
- Invalid ACM certificate ARN
- Subnet tags missing (required: `kubernetes.io/role/elb=1`)

### Certificate Errors

**Issue:** ALB created but certificate not applied

**Solution:** Verify:
1. Certificate ARN is correct
2. Certificate is in the same region as EKS cluster
3. Certificate status is "Issued" in ACM

### DNS Not Resolving

**Issue:** Cannot reach services via hostname

**Solution:**
1. Verify DNS records are created and propagated
2. Check ALB is provisioned: `aws elbv2 describe-load-balancers`
3. Verify security groups allow inbound traffic on port 443

### Health Check Failures

```bash
# Port forward to test directly
kubectl port-forward -n certauth svc/isbe-certauth 8010:8010

# In another terminal, test locally
curl http://localhost:8010/health
```

### View All Events

```bash
kubectl get events -n certauth --sort-by='.lastTimestamp'
```

---

## Additional Commands

### Uninstall

```bash
helm uninstall isbe-certauth -n certauth
```

### List Installed Releases

```bash
helm list -n certauth
```

### Get Helm Values

```bash
# Show computed values
helm get values isbe-certauth -n certauth

# Show all values (including defaults)
helm get values isbe-certauth -n certauth --all
```

### Update with New Values

```bash
helm upgrade isbe-certauth . \
  --namespace certauth \
  --reuse-values \
  --set replicaCount=3
```

---

## Security Recommendations

1. **Use Kubernetes Secrets** for sensitive data instead of values files
2. **Enable Pod Security Standards** in the namespace
3. **Configure Network Policies** to restrict traffic
4. **Enable audit logging** for the cluster
5. **Rotate credentials regularly**
6. **Use private subnets** for nodes when possible
7. **Enable encryption at rest** for EBS volumes (gp3 with encryption)
8. **Review and restrict IAM permissions** for service accounts

---

## Support

For issues or questions:
- Check application logs: `kubectl logs -n certauth -l app.kubernetes.io/name=isbe-certauth`
- Review Kubernetes events: `kubectl get events -n certauth`
- Consult the main [README.md](./README.md) for detailed configuration options
