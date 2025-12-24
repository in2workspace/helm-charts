################################################################################
# EKS Cluster - Cost-Optimized Configuration
################################################################################

locals {
  cluster_name = "${var.project_name}-${var.environment}-eks-${var.region_code}"

  tags = merge(
    var.default_tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.32"

  # Cost optimization: Public endpoint only (no private endpoint charges)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  # Essential EKS add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    # EBS CSI Driver for persistent volumes
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  # Note: AWS Load Balancer Controller is installed via Helm in deploy-certauth.sh

  # Use existing VPC
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Control plane logging - disabled for cost savings (enable in production)
  cluster_enabled_log_types = []

  # Enable IRSA for service accounts
  enable_irsa = true

  # EKS Managed Node Group - Spot instances for maximum cost savings
  eks_managed_node_groups = {
    cost_optimized = {
      name            = "cost-optimized-spot"
      use_name_prefix = true

      # Use spot instances for up to 90% cost savings
      capacity_type = "SPOT"

      # Minimal instance types - t3a instances are cheaper than t3
      instance_types = ["t3a.small", "t3a.medium", "t3.small", "t3.medium"]

      # Minimal cluster size for the workload
      # isbe-certauth needs 2 replicas with 250m CPU each = ~500m total
      # t3a.small has 2vCPU (2000m), so 1 node can handle it + system pods
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Use latest Amazon Linux 2023 - optimized and lighter
      ami_type = "AL2023_x86_64_STANDARD"

      # Minimal disk size to reduce EBS costs
      disk_size = 20

      # Labels for scheduling
      labels = {
        Environment = var.environment
        Workload    = "general"
      }

      # Tags
      tags = merge(
        local.tags,
        {
          NodeGroupType = "spot-cost-optimized"
        }
      )

      # Update configuration
      update_config = {
        max_unavailable_percentage = 50
      }

      # Instance metadata options (security best practice)
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "disabled"
      }
    }
  }

  # Cluster access - allow current user
  enable_cluster_creator_admin_permissions = true

  # Security group tags for ALB controller to discover
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  tags = local.tags
}

################################################################################
# EBS CSI Driver IRSA
################################################################################

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${local.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

################################################################################
# AWS Load Balancer Controller IRSA
################################################################################

module "aws_load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${local.cluster_name}-aws-lb-ctrl-"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}

# Kubernetes Service Account for AWS Load Balancer Controller
resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  depends_on = [module.eks]

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

# Security group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${local.cluster_name}-alb-"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.cluster_name}-alb-sg"
    }
  )
}

# Storage class for gp3 volumes (cheaper than gp2)
resource "kubernetes_storage_class_v1" "gp3" {
  depends_on = [module.eks]

  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
    # gp3 allows you to provision IOPS independently of size for cost optimization
    iops       = "3000" # Minimum for gp3
    throughput = "125"  # Minimum for gp3
  }
}

################################################################################
# SSM Parameters - Store EKS cluster information
################################################################################

resource "aws_ssm_parameter" "eks_cluster_name_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/name"
  type  = "String"
  value = module.eks.cluster_name

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_cluster_arn_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/arn"
  type  = "SecureString"
  value = module.eks.cluster_arn

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_cluster_endpoint_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/endpoint"
  type  = "SecureString"
  value = module.eks.cluster_endpoint

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_cluster_certificate_authority_data_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/certificate_authority_data"
  type  = "SecureString"
  value = module.eks.cluster_certificate_authority_data

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_cluster_oidc_issuer_url_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/oidc_issuer_url"
  type  = "String"
  value = module.eks.cluster_oidc_issuer_url

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_oidc_provider_arn_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/oidc_provider_arn"
  type  = "SecureString"
  value = module.eks.oidc_provider_arn

  tags = local.tags
}

resource "aws_ssm_parameter" "eks_cluster_security_group_id_ssm" {
  name  = "/eudistack/${var.environment}/config/shared/eks/${local.cluster_name}/security_group_id"
  type  = "String"
  value = module.eks.cluster_security_group_id

  tags = local.tags
}

################################################################################
# Outputs
################################################################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
