locals {
  default_root_object = "domain-redirect-${random_id.module_id.hex}"
}

// Create the CloudFront distribution
resource "aws_cloudfront_distribution" "redirect" {
  provider = aws.cloudfront

  origin {
    connection_attempts = 1
    connection_timeout  = 1
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    domain_name = "dummy.local"
    origin_id   = "dummy"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for redirecting domains."
  default_root_object = local.default_root_object

  // Configure the CloudFront logging to use the specified S3 bucket
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [1] : []
    content {
      include_cookies = var.logging_config.include_cookies
      bucket          = var.logging_config.bucket
      prefix          = var.logging_config.prefix
    }
  }

  // Set the domain names for the distribution
  aliases = keys(var.domains_from)

  // Cache everything as long as possible, since they all get a redirect
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]
    //target_origin_id       = "S3-Origin"
    target_origin_id       = "dummy"
    viewer_protocol_policy = "allow-all"
    min_ttl                = var.cache_duration
    default_ttl            = var.cache_duration
    max_ttl                = var.cache_duration
    compress               = false

    forwarded_values {
      // Allow caching based on protocol (http vs https)
      headers      = ["CloudFront-Forwarded-Proto"]
      query_string = true
      cookies {
        forward = "none"
      }
    }

    // Link a CloudFront Function to return redirects for everything
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Use the TLS certificate provisioned in acm.tf
  viewer_certificate {
    acm_certificate_arn      = module.cloudfront_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.ssl_minimum_protocol_version
  }
}
