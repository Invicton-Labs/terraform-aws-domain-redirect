// Create a Route53 record for each domain
resource "aws_route53_record" "cloudfront" {
  provider        = aws.route53
  for_each        = local.var_domains_from
  zone_id         = each.value
  name            = each.key
  type            = "A"
  allow_overwrite = false

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
