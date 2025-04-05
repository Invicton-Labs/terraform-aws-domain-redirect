locals {
  first_from_domain = keys(var.domains_from)[0]
}

module "cert_provided" {
  source  = "Invicton-Labs/input-provided/null"
  version = ">=0.2.0"
  input   = var.acm_certificate_arn
}

module "cloudfront_cert" {
  source  = "Invicton-Labs/validated-acm-certificate/aws"
  version = "~> 0.1.3"
  count   = module.cert_provided.one_if_not_provided
  providers = {
    aws.hosted_zones = aws.route53
    aws.certificate  = aws.cloudfront
  }
  depends_on = [
    module.assert_region
  ]
  // The primary domain on the certificate is the first "from" domain
  primary_domain                = local.first_from_domain
  primary_domain_hosted_zone_id = var.domains_from[local.first_from_domain]
  // All other "from" domains are SANs
  subject_alternative_names = {
    for domain, zone_id in var.domains_from :
    domain => zone_id
    if domain != local.first_from_domain
  }
}
