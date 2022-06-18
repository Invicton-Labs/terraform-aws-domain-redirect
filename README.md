# Terraform AWS Domain Redirect

This module is used for redirecting all requests from one or more `from` domains to a single `to` domain. It can redirect either with the path and query string as was initially given, or with a static path.

*Note:* If you change any of the parameters for this module, you'll probably want to invalidate the cache of the CloudFront distribution that this module creates.

### Usage:
```
// Must have Route53 zones for each domain to redirect from. Subdomains that get 
// redirected can use the same zones as parent domains that get redirected.
resource "aws_route53_zone" "from_domain_1" {
  provider = aws.route53
  name     = "my-old-domain.com"
}

resource "aws_route53_zone" "from_domain_2" {
  provider = aws.route53
  name     = "my-other-old-domain.com"
}

module "domain_redirect" {
  source = "Invicton-Labs/domain-redirect/aws"

  providers = {
    // This is the provider used for the CloudFront distribution and ACM certificate for the "to" domain.
    // It must always be in us-east-1, since that's where CloudFront gets deployed.
    aws.cloudfront = aws.us-east-1

    // This is the provider that will be used for creating DNS records in the hosted zone(s) for the "from" domains.
    // It can be in any region and any AWS account, as long as it's in the same account/region as the hosted zones.
    // It creates Alias records that point to the CloudFront distribution, and creates validation records
    // for the ACM certificate that is used by CloudFront.
    aws.route53 = aws.route53
  }

  // This is a map of domain names to Route53 zone IDs. The Route53 
  // zone must be able to host records for the given domain. Requests to
  // ANY of these domains will all get redirected to the "to" domain.
  domains_from = {
    // Since these first two have the same root domain, they can use the same hosted zone
    "my-old-domain.com" = aws_route53_zone.from_domain_1.zone_id
    "subdomain.my-old-domain.com" = aws_route53_zone.from_domain_1.zone_id

    // This one has a different root domain, so uses its own hosted zone
    "my-other-old-domain.com" = aws_route53_zone.from_domain_2.zone_id
  }

  // This is the domain to redirect all of the "from" domains to
  domain_to                = "my-new-domain.com"

  // Keep the path and query string of the original request when redirecting
  redirect_type            = "KEEP_PATH"

  // Redirect with a 302 (Found) instead of the default 301 (Moved Permanently)
  redirect_code            = 301
}
```
