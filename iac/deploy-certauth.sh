#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="certauth-stg-eks-ew1"
REGION="eu-west-1"
NAMESPACE="certauth"
CHART_PATH="../wip/isbe-certauth"
AWS_PROFILE="${AWS_PROFILE:-in2-iac}"

# Ensure AWS profile is set
export AWS_PROFILE

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}ISBE CertAuth Deployment Script${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "${YELLOW}Using AWS Profile: ${AWS_PROFILE}${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists aws; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command_exists helm; then
    echo -e "${RED}Error: Helm is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Verify AWS profile
echo -e "${YELLOW}Verifying AWS profile...${NC}"
if ! aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot authenticate with AWS profile: ${AWS_PROFILE}${NC}"
    echo -e "${YELLOW}Make sure you have valid credentials for the profile${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS profile verified${NC}"
echo ""

# Configure kubectl
echo -e "${YELLOW}Configuring kubectl...${NC}"
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME --profile $AWS_PROFILE
echo -e "${GREEN}✓ kubectl configured${NC}"
echo ""

# Verify cluster access
echo -e "${YELLOW}Verifying cluster access...${NC}"
if ! kubectl get nodes > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot access cluster${NC}"
    exit 1
fi

NODE_COUNT=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
echo -e "${GREEN}✓ Cluster accessible - $NODE_COUNT nodes found${NC}"
kubectl get nodes
echo ""

# Check if ALB controller is ready
echo -e "${YELLOW}Checking AWS Load Balancer Controller...${NC}"
if kubectl get deployment -n kube-system aws-load-balancer-controller > /dev/null 2>&1; then
    READY=$(kubectl get deployment -n kube-system aws-load-balancer-controller -o jsonpath='{.status.readyReplicas}')
    if [ "$READY" -ge 1 ]; then
        echo -e "${GREEN}✓ AWS Load Balancer Controller is ready${NC}"
    else
        echo -e "${YELLOW}⚠ AWS Load Balancer Controller is not ready yet. Waiting...${NC}"
        kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system
    fi
else
    echo -e "${YELLOW}⚠ AWS Load Balancer Controller not found. Installing...${NC}"
    
    # Install AWS Load Balancer Controller
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    # Get cluster VPC ID
    VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --profile $AWS_PROFILE --query "cluster.resourcesVpcConfig.vpcId" --output text)
    
    if [ -z "$VPC_ID" ]; then
        echo -e "${RED}Error: Could not retrieve VPC ID from cluster${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Retrieved VPC ID: $VPC_ID${NC}"
    
    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=$REGION \
        --set vpcId=$VPC_ID
    
    echo -e "${YELLOW}Waiting for AWS Load Balancer Controller to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system
    echo -e "${GREEN}✓ AWS Load Balancer Controller installed${NC}"
fi
echo ""

# Check storage class
echo -e "${YELLOW}Checking storage class...${NC}"
if kubectl get storageclass gp3 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ gp3 storage class exists${NC}"
else
    echo -e "${YELLOW}⚠ gp3 storage class not found - should be created by Terraform${NC}"
fi
echo ""

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace $NAMESPACE...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace $NAMESPACE ready${NC}"
echo ""

# Check if Altia values file exists
ALTIA_VALUES="$CHART_PATH/values-altia.yaml"
if [ ! -f "$ALTIA_VALUES" ]; then
    echo -e "${RED}Error: Altia values file not found at $ALTIA_VALUES${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Using Altia environment values${NC}"
echo ""

# Deploy or upgrade the Helm chart
echo -e "${YELLOW}Deploying isbe-certauth Helm chart...${NC}"

# Check if chart directory exists
if [ ! -d "$CHART_PATH" ]; then
    echo -e "${RED}Error: Chart directory not found at $CHART_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Installing/upgrading Helm chart...${NC}"
helm upgrade --install isbe-certauth $CHART_PATH \
    --namespace $NAMESPACE \
    --create-namespace \
    --values $CHART_PATH/values.yaml \
    --values $ALTIA_VALUES \
    --wait \
    --timeout 10m

echo -e "${GREEN}✓ Helm chart deployed${NC}"
echo ""

# Wait for pods to be ready
echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=isbe-certauth -n $NAMESPACE --timeout=300s

echo -e "${GREEN}✓ Pods are ready${NC}"
echo ""

# Show deployment status
echo -e "${YELLOW}Deployment Status:${NC}"
kubectl get pods -n $NAMESPACE
echo ""

# Get ALB information
echo -e "${YELLOW}Fetching ALB information...${NC}"
sleep 10  # Give ALB time to be created

INGRESSES=$(kubectl get ingress -n $NAMESPACE -o json)
if [ "$(echo $INGRESSES | jq '.items | length')" -gt 0 ]; then
    echo -e "${GREEN}✓ Ingress resources created${NC}"
    kubectl get ingress -n $NAMESPACE
    echo ""
    
    echo -e "${YELLOW}ALB DNS Names:${NC}"
    kubectl get ingress -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.loadBalancer.ingress[0].hostname}{"\n"}{end}'
    echo ""
    
    echo -e "${YELLOW}To access the services, add DNS records pointing to the ALB DNS names above${NC}"
else
    echo -e "${YELLOW}⚠ No ingress resources found yet - they may take a moment to appear${NC}"
fi
echo ""

# Show service endpoints
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Service URLs (once DNS is configured):${NC}"
echo "  CertAuth:  https://certauth.stg.altia.eudistack.net"
echo "  CertSec:   https://certsec.stg.altia.eudistack.net"
echo "  Onboard:   https://onboard.stg.altia.eudistack.net"
echo ""

echo -e "${YELLOW}Useful commands:${NC}"
echo "  View pods:        kubectl get pods -n $NAMESPACE"
echo "  View logs:        kubectl logs -f -n $NAMESPACE -l app.kubernetes.io/name=isbe-certauth"
echo "  View ingress:     kubectl get ingress -n $NAMESPACE"
echo "  Describe pod:     kubectl describe pod <pod-name> -n $NAMESPACE"
echo "  Port forward:     kubectl port-forward -n $NAMESPACE svc/isbe-certauth 8010:8010"
echo ""

echo -e "${YELLOW}Monitoring:${NC}"
echo "  CPU/Memory usage: kubectl top pods -n $NAMESPACE"
echo "  Node usage:       kubectl top nodes"
echo "  Events:           kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
echo ""

echo -e "${YELLOW}Service URLs (once DNS is configured):${NC}"
echo "  CertAuth:  https://certauth.altia.eudistack.net"
echo "  CertSec:   https://certsec.altia.eudistack.net"
echo "  Onboard:   https://onboard.altia.eudistack.net"
echo ""

echo -e "${GREEN}✓ All done!${NC}"
