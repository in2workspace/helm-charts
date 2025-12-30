variable "default_tags" {
    description = "Default tags for resources"
    type = map(string)
    default = {
        environment    = "STG"
        tenant         = "ALTIA"
        domain         = "EUDISTACK.NET"
        owner          = "ALTIA"
        project        = "certauth"
        cost_center    = "ALTIA-STG"
        business_unit  = "ALTIA"
        application    = "certauth"
        managed_by     = "Terraform"
        terraform      = "true"
        created_by     = "Terraform"
    }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default = "certauth"
}


variable "region" {
    description = "AWS region"
    type = string
    default = "eu-west-1"
}

variable "region_code" {
    description = "Region code"
    type = string
    default = "ew1"
}

variable "environment" {
  description = "Resource environment"
  type        = string
  default = "stg"
}

variable "tenant_name" {
    description = "Tenant name"
    type        = string
    default = "altia"
}

variable "domain_name" {
    description = "Domain name"
    type        = string
    default = "eudistack.net"
}


