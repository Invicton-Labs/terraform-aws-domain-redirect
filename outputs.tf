output "cloudfront_distribution" {
  description = "The `aws_cloudfront_distribution` resource that was created."
  value       = aws_cloudfront_distribution.redirect
}
