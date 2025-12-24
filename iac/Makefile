# Makefile for Terraform operations
# Usage: make <target>

.PHONY: help init plan apply deploy destroy clean eks-deploy eks-status certauth-deploy certauth-status kubectl-config

# Variables
CLUSTER_NAME := certauth-stg-eks-ew1
REGION := eu-west-1
NAMESPACE := certauth

# Default target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Terraform Operations:"
	@echo "  init              - Initialize Terraform"
	@echo "  plan              - Show Terraform plan"
	@echo "  apply             - Apply Terraform changes"
	@echo "  deploy            - Full deployment (init + plan + apply)"
	@echo "  destroy           - Destroy Terraform infrastructure"
	@echo "  clean             - Clean Terraform files"
	@echo ""
	@echo "EKS Operations:"
	@echo "  eks-deploy        - Deploy EKS cluster (init + plan + apply)"
	@echo "  eks-status        - Check EKS cluster status"
	@echo "  kubectl-config    - Configure kubectl for the cluster"
	@echo ""
	@echo "Application Deployment:"
	@echo "  certauth-deploy   - Deploy isbe-certauth to EKS"
	@echo "  certauth-status   - Check isbe-certauth deployment status"
	@echo "  certauth-logs     - View isbe-certauth logs"
	@echo ""
	@echo "Complete Workflow:"
	@echo "  all               - Deploy everything (EKS + Application)"

# Load environment variables
export AWS_PROFILE := in2-iac

# Initialize Terraform
init:
	@echo "Loading environment variables..."
	@echo "Initializing Terraform for resources..."
	terraform init -input=false -backend=true

# Show Terraform plan
plan: init
	@echo "Show Terraform plan"
	terraform plan --lock=false

# Apply Terraform changes
apply: plan
	@echo "Apply Terraform changes"
	terraform apply --lock=false -auto-approve

# Interactive deployment with confirmation
deploy: init
	@echo "Show Terraform plan"
	terraform plan --lock=false
	@echo ""
	@read -p " - Are these details correct, do you want to continue (y/n)? " answer; \
	case $$answer in \
		y|Y ) \
			echo "Apply Terraform changes"; \
			terraform apply --lock=false -auto-approve;; \
		* ) \
			echo "»»» 😲 Deployment canceled"; \
			exit 1;; \
	esac

# Destroy Terraform infrastructure with confirmation
destroy: init
	@echo "Show Terraform destroy plan"
	terraform plan -destroy --lock=false
	@echo ""
	@echo "⚠️  WARNING: This will destroy ALL infrastructure resources!"
	@read -p " - Are you sure you want to destroy everything (y/n)? " answer; \
	case $$answer in \
		y|Y ) \
			echo "Destroying Terraform infrastructure..."; \
			terraform destroy --lock=false -auto-approve;; \
		* ) \
			echo "»»» 😅 Destruction canceled"; \
			exit 1;; \
	esac

# Clean Terraform files
clean:
	@echo "Cleaning Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*

################################################################################
# EKS Specific Operations
################################################################################

# Deploy EKS cluster
eks-deploy: init
	@echo "═══════════════════════════════════════"
	@echo "  Deploying EKS Cluster"
	@echo "═══════════════════════════════════════"
	@terraform plan --lock=false
	@echo ""
	@read -p "Continue with EKS deployment (y/n)? " answer; \
	case $$answer in \
		y|Y ) \
			echo "Deploying EKS cluster..."; \
			terraform apply --lock=false -auto-approve; \
			echo ""; \
			echo "✓ EKS cluster deployed successfully!"; \
			echo ""; \
			echo "Run 'make kubectl-config' to configure kubectl";; \
		* ) \
			echo "»»» Deployment canceled"; \
			exit 1;; \
	esac

# Configure kubectl
kubectl-config:
	@echo "Configuring kubectl for cluster $(CLUSTER_NAME)..."
	@aws eks update-kubeconfig --region $(REGION) --name $(CLUSTER_NAME)
	@echo "✓ kubectl configured"
	@echo ""
	@echo "Testing cluster access..."
	@kubectl get nodes
	@echo ""
	@echo "Cluster is ready!"

# Check EKS cluster status
eks-status:
	@echo "═══════════════════════════════════════"
	@echo "  EKS Cluster Status"
	@echo "═══════════════════════════════════════"
	@echo ""
	@echo "Cluster Info:"
	@aws eks describe-cluster --name $(CLUSTER_NAME) --region $(REGION) --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table 2>/dev/null || echo "Cluster not found or AWS CLI not configured"
	@echo ""
	@echo "Nodes:"
	@kubectl get nodes 2>/dev/null || echo "kubectl not configured. Run 'make kubectl-config'"
	@echo ""
	@echo "Node Resources:"
	@kubectl top nodes 2>/dev/null || echo "Metrics server not available"
	@echo ""
	@echo "System Pods:"
	@kubectl get pods -n kube-system 2>/dev/null || echo "kubectl not configured"

################################################################################
# Application Deployment Operations
################################################################################

# Deploy isbe-certauth application
certauth-deploy: kubectl-config
	@echo "═══════════════════════════════════════"
	@echo "  Deploying isbe-certauth Application"
	@echo "═══════════════════════════════════════"
	@echo ""
	@if [ ! -f ./deploy-certauth.sh ]; then \
		echo "Error: deploy-certauth.sh not found"; \
		exit 1; \
	fi
	@chmod +x ./deploy-certauth.sh
	@./deploy-certauth.sh

# Check application status
certauth-status:
	@echo "═══════════════════════════════════════"
	@echo "  isbe-certauth Status"
	@echo "═══════════════════════════════════════"
	@echo ""
	@echo "Namespace:"
	@kubectl get namespace $(NAMESPACE) 2>/dev/null || echo "Namespace not found"
	@echo ""
	@echo "Pods:"
	@kubectl get pods -n $(NAMESPACE) 2>/dev/null || echo "No pods found"
	@echo ""
	@echo "Services:"
	@kubectl get svc -n $(NAMESPACE) 2>/dev/null || echo "No services found"
	@echo ""
	@echo "Ingress:"
	@kubectl get ingress -n $(NAMESPACE) 2>/dev/null || echo "No ingress found"
	@echo ""
	@echo "Pod Resources:"
	@kubectl top pods -n $(NAMESPACE) 2>/dev/null || echo "Metrics not available"

# View application logs
certauth-logs:
	@echo "Streaming logs from isbe-certauth..."
	@kubectl logs -f -n $(NAMESPACE) -l app.kubernetes.io/name=isbe-certauth

# Port forward to application
certauth-port-forward:
	@echo "Port forwarding to isbe-certauth on http://localhost:8010"
	@kubectl port-forward -n $(NAMESPACE) svc/isbe-certauth 8010:8010

################################################################################
# Complete Workflow
################################################################################

# Deploy everything
all: eks-deploy certauth-deploy
	@echo ""
	@echo "═══════════════════════════════════════"
	@echo "  ✓ Complete Deployment Finished!"
	@echo "═══════════════════════════════════════"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Configure DNS (see output above)"
	@echo "  2. Test endpoints:"
	@echo "     - https://certauth.stg.altia.eudistack.net"
	@echo "     - https://certsec.stg.altia.eudistack.net"
	@echo "     - https://onboard.stg.altia.eudistack.net"
	@echo ""
	@echo "Useful commands:"
	@echo "  make certauth-status       - Check application status"
	@echo "  make certauth-logs         - View application logs"
	@echo "  make eks-status            - Check cluster status"
	@echo ""

################################################################################
# Validation and Testing
################################################################################

# Validate prerequisites
validate:
	@echo "Validating prerequisites..."
	@command -v aws >/dev/null 2>&1 || { echo "✗ AWS CLI not installed"; exit 1; }
	@echo "✓ AWS CLI installed"
	@command -v terraform >/dev/null 2>&1 || { echo "✗ Terraform not installed"; exit 1; }
	@echo "✓ Terraform installed"
	@command -v kubectl >/dev/null 2>&1 || { echo "✗ kubectl not installed"; exit 1; }
	@echo "✓ kubectl installed"
	@command -v helm >/dev/null 2>&1 || { echo "✗ Helm not installed"; exit 1; }
	@echo "✓ Helm installed"
	@echo ""
	@echo "AWS Identity:"
	@aws sts get-caller-identity || { echo "✗ AWS credentials not configured"; exit 1; }
	@echo ""
	@echo "✓ All prerequisites met"

# Show cluster costs estimate
costs:
	@echo "═══════════════════════════════════════"
	@echo "  Estimated Monthly Costs"
	@echo "═══════════════════════════════════════"
	@echo ""
	@echo "EKS Control Plane:        ~$$73.00"
	@echo "2x t3a.small (spot):      ~$$8.00"
	@echo "EBS (40GB gp3):           ~$$3.20"
	@echo "NAT Gateway:              ~$$32.00"
	@echo "NAT Data Transfer:        ~$$4.50"
	@echo "ALB:                      ~$$16.20"
	@echo "──────────────────────────────────────"
	@echo "Total (estimated):        ~$$137/month"
	@echo ""
	@echo "Note: Actual costs may vary based on:"
	@echo "  - Data transfer volume"
	@echo "  - Spot instance availability"
	@echo "  - Additional services used"
