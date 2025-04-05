//==================================================
//     Outputs that match the input variables
//==================================================
output "domains_from" {
  description = "The value of the `domains_from` input variable."
  value       = var.domains_from
}
output "domain_to" {
  description = "The value of the `domain_to` input variable."
  value       = var.domain_to
}
output "redirect_to_https" {
  description = "The value of the `redirect_to_https` input variable, or the default value if the input was `null`."
  value       = var.redirect_to_https
}
output "redirect_type" {
  description = "The value of the `redirect_type` input variable, or the default value if the input was `null`."
  value       = var.redirect_type
}
output "redirect_static_path" {
  description = "The value of the `redirect_static_path` input variable, or the default value if the input was `null`."
  value       = var.redirect_static_path
}
output "redirect_path_prefix" {
  description = "The value of the `redirect_path_prefix` input variable, or the default value if the input was `null`."
  value       = var.redirect_path_prefix
}
output "redirect_code" {
  description = "The value of the `redirect_code` input variable, or the default value if the input was `null`."
  value       = var.redirect_code
}
output "logging_config" {
  description = "The value of the `logging_config` input variable."
  value       = var.logging_config
}
output "cache_duration_min" {
  description = "The value of the `cache_duration_min` input variable, or the default value if the input was `null`."
  value       = var.cache_duration_min
}
output "cache_duration_default" {
  description = "The value of the `cache_duration_default` input variable, or the default value if the input was `null`."
  value       = var.cache_duration_default
}
output "cache_duration_max" {
  description = "The value of the `cache_duration_max` input variable, or the default value if the input was `null`."
  value       = var.cache_duration_max
}
output "ssl_minimum_protocol_version" {
  description = "The value of the `ssl_minimum_protocol_version` input variable, or the default value if the input was `null`."
  value       = var.ssl_minimum_protocol_version
}
output "acm_certificate_arn" {
  description = "The value of the `acm_certificate_arn` input variable."
  value       = var.acm_certificate_arn
}


//==================================================
//       Outputs generated by this module
//==================================================
output "cloudfront_distribution" {
  description = "The `aws_cloudfront_distribution` resource that was created."
  value       = aws_cloudfront_distribution.redirect
}
