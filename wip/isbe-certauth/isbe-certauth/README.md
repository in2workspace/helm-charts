# ISBE CertAuth Helm Chart

Helm chart for deploying ISBE CertAuth - a certificate authentication service with three separate endpoints.

## Overview

CertAuth is a Go-based application that provides three services in a single deployment:

- **CertAuth** (port 8010): Main certificate authentication service
- **CertSec** (port 8011): Certificate security service with mTLS client certificate authentication
- **Onboard** (port 8012): Onboarding service

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- AWS Load Balancer Controller installed in the cluster
- ACM certificates for HTTPS endpoints
- (Optional) Prometheus Operator for observability
- (Optional) Grafana Operator for dashboards

## Installation

### Basic Installation

```bash
helm install isbe-certauth ./isbe-certauth \
  --namespace certauth \
  --create-namespace
```

### Installation with Custom Values

```bash
helm install isbe-certauth ./isbe-certauth \
  --namespace certauth \
  --create-namespace \
  --values custom-values.yaml
```

## Configuration

### Key Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Docker image repository | `flai/isbe-certauth` |
| `image.tag` | Docker image tag | `latest` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Size of persistent volume | `10Gi` |
| `persistence.storageClass` | StorageClass for PVC | `gp3` |

### Service URLs

Configure the external URLs for each service:

```yaml
serviceUrls:
  certauth: "https://certauth.example.com"
  certsec: "https://certsec.example.com"
  onboard: "https://onboard.example.com"
```

### Credentials

#### Using Default Values (Not Recommended for Production)

```yaml
adminPassword:
  value: "your-secure-password"

tsaCredentials:
  user: "tsa-user"
  password: "tsa-password"

smtpCredentials:
  username: "smtp-username"
  password: "smtp-password"
```

#### Using Existing Secrets (Recommended)

```yaml
adminPassword:
  existingSecret:
    enabled: true
    name: "my-admin-secret"
    key: "password"

tsaCredentials:
  existingSecret:
    enabled: true
    name: "my-tsa-secret"
    userKey: "username"
    passwordKey: "password"

smtpCredentials:
  existingSecret:
    enabled: true
    name: "my-smtp-secret"
    usernameKey: "username"
    passwordKey: "password"
```

### Ingress Configuration

#### AWS ALB with ACM Certificates

Update the certificate ARNs for each ingress:

```yaml
ingress:
  certauth:
    enabled: true
    hostname: "certauth.example.com"
    annotations:
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT:certificate/CERT_ID"
  
  certsec:
    enabled: true
    hostname: "certsec.example.com"
    annotations:
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT:certificate/CERT_ID"
      # mTLS passthrough mode - client certificates forwarded to backend
      alb.ingress.kubernetes.io/mutual-authentication: '[{"port": 443, "mode": "passthrough"}]'
      alb.ingress.kubernetes.io/backend-protocol: "HTTPS"
  
  onboard:
    enabled: true
    hostname: "onboard.example.com"
    annotations:
      alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:REGION:ACCOUNT:certificate/CERT_ID"
```

### mTLS Configuration for CertSec Endpoint

The CertSec service uses mTLS with **passthrough mode**:

- AWS ALB forwards client certificates to the backend application
- The application must handle TLS termination and certificate validation
- Ensure your application is configured with:
  - Server TLS certificate
  - CA bundle for client certificate verification

**Important**: The application must listen on HTTPS and validate client certificates itself when using passthrough mode.

### Persistence

The application uses SQLite database stored in `/data` directory:

```yaml
persistence:
  enabled: true
  storageClass: "gp3"        # or "gp3-retain" for retain policy
  size: 10Gi
  accessMode: ReadWriteOnce
  mountPath: /data
```

### Observability

Enable Prometheus monitoring and Grafana dashboards:

```yaml
observability:
  enabled: true
  scrapePath: /metrics
  dashboard:
    enabled: true
```

## Upgrading

```bash
helm upgrade isbe-certauth ./isbe-certauth \
  --namespace certauth \
  --values custom-values.yaml
```

## Uninstalling

```bash
helm uninstall isbe-certauth --namespace certauth
```

**Note**: If using `gp3-retain` StorageClass, the PVC will not be automatically deleted.

## Architecture

```
                    AWS ALB (Internet-facing)
                            |
        +-------------------+-------------------+
        |                   |                   |
    Port 8010           Port 8011           Port 8012
    (CertAuth)       (CertSec - mTLS)      (Onboard)
        |                   |                   |
        +-------------------+-------------------+
                            |
                    Kubernetes Service
                            |
                       Deployment
                  (isbe-certauth pods)
                            |
                     PersistentVolume
                    (SQLite database)
```

## Monitoring

The chart includes:

1. **ServiceMonitor**: Prometheus scrapes metrics from `/metrics`
2. **PrometheusRule**: Alerts for:
   - Service down
   - No pods available
3. **Grafana Dashboard**: Displays:
   - Service uptime
   - Available pods
   - Pod restarts
   - Memory usage

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n certauth -l app.kubernetes.io/name=isbe-certauth
```

### View Logs

```bash
kubectl logs -n certauth -l app.kubernetes.io/name=isbe-certauth --tail=100 -f
```

### Check Ingress Status

```bash
kubectl get ingress -n certauth
kubectl describe ingress -n certauth <ingress-name>
```

### Check PVC Status

```bash
kubectl get pvc -n certauth
kubectl describe pvc -n certauth <pvc-name>
```

### Verify Secrets

```bash
kubectl get secrets -n certauth
```

## Security Considerations

1. **Always use strong passwords** in production
2. **Use existingSecret** for sensitive credentials
3. **Enable mTLS** for production CertSec endpoints
4. **Update ACM certificate ARNs** before deployment
5. **Use RBAC** to restrict access to secrets
6. **Enable Pod Security Policies** if available
7. **Use gp3-retain** StorageClass for important data

## Support

For issues and questions:
- GitHub Issues: https://github.com/in2workspace/helm-charts/issues
- Documentation: https://github.com/in2workspace/helm-charts

## License

See LICENSE file in the repository root.
