# resource "aws_route53_record" "alb_dns" {  
#   zone_id = data.aws_route53_zone.public.zone_id  
#   name    = "api-${var.environment}"          
#   type    = "A"  
  
#   alias {  
#     name                   = module.alb_public.dns_name   
#     zone_id                = module.alb_public.zone_id
#     evaluate_target_health = true  
#   }  
# }  

# # wallet-stg.api.altia.eudistack.net
# resource "aws_route53_record" "aws_route53_record_wallet_stg_api_altia_eudistack_net" {  
#   zone_id = data.aws_route53_zone.public_zone_eudistack_net.zone_id  
#   name    = "wallet-${var.environment}.api.${var.tenant_name}.${var.domain_name}"          
#   type    = "A"  
  
#   alias {  
#     name                   = module.alb_public.dns_name   
#     zone_id                = module.alb_public.zone_id
#     evaluate_target_health = true  
#   }  
# }

# # issuer-stg.api.altia.eudistack.net
# resource "aws_route53_record" "aws_route53_record_issuer_stg_api_altia_eudistack_net" {  
#   zone_id = data.aws_route53_zone.public_zone_eudistack_net.zone_id  
#   name    = "issuer-${var.environment}.api.${var.tenant_name}.${var.domain_name}"          
#   type    = "A"  
  
#   alias {  
#     name                   = module.alb_public.dns_name   
#     zone_id                = module.alb_public.zone_id
#     evaluate_target_health = true  
#   }  
# }

# # verifier-stg.altia.eudistack.net
# resource "aws_route53_record" "aws_route53_record_verifier_stg_altia_eudistack_net" {  
#   zone_id = data.aws_route53_zone.public_zone_eudistack_net.zone_id  
#   name    = "verifier-${var.environment}.${var.tenant_name}.${var.domain_name}"          
#   type    = "A"  
  
#   alias {  
#     name                   = module.alb_public.dns_name   
#     zone_id                = module.alb_public.zone_id
#     evaluate_target_health = true  
#   }  
# }

# # iam-stg.altia.eudistack.net
# resource "aws_route53_record" "aws_route53_record_iam_stg_altia_eudistack_net" {  
#   zone_id = data.aws_route53_zone.public_zone_eudistack_net.zone_id  
#   name    = "iam-${var.environment}.${var.tenant_name}.${var.domain_name}"          
#   type    = "A"  
  
#   alias {  
#     name                   = module.alb_public.dns_name   
#     zone_id                = module.alb_public.zone_id
#     evaluate_target_health = true  
#   }      
# }






# Front:
# wallet-stg.altia.eudistack.net
# issuer-stg.altia.eudistack.net
# Back:
# wallet-stg.api.altia.eudistack.net
# issuer-stg.api.altia.eudistack.net
# verifier-stg.altia.eudistack.net
# iam-stg.altia.eudistack.net