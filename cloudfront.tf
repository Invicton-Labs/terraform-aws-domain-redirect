locals {
  default_root_object = "domain-redirect-${random_id.module_id.hex}"
}

// Create the CloudFront distribution
resource "aws_cloudfront_distribution" "redirect" {
  // Depend on completion of the lambda so the function version is correct
  depends_on = [
    module.lambda_origin_request
  ]

  // We don't actually use this origin, since all requests are redirected at the Lambda@Edge level
  // CloudFront still requires one to be configured though
  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "S3-Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin.cloudfront_access_identity_path
    }
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
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = false

    forwarded_values {
      // Allow caching based on protocol (http vs https)
      headers      = ["CloudFront-Forwarded-Proto"]
      query_string = true
      cookies {
        forward = "none"
      }
    }

    // Link a Lambda@Edge function to return redirects for everything
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.lambda_origin_request.lambda.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Use the TLS certificate provisioned in domain.tf
  viewer_certificate {
    acm_certificate_arn      = module.cloudfront_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
}
