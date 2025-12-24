data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecr_authorization_token" "token" {}

################################################
# Import the certificates                      #
################################################

data "aws_acm_certificate" "acm_certificate_star_api_altia_eudistack_net" {
  domain   = "*.api.${var.tenant_name}.${var.domain_name}"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "acm_certificate_star_altia_eudistack_net" {
  domain   = "*.${var.tenant_name}.${var.domain_name}"
  statuses = ["ISSUED"]
}

################################################
# Import the Route53 zones                     #
################################################

data "aws_route53_zone" "public_zone_eudistack_net" {  
  name         = "${var.domain_name}"
  private_zone = false  
} 