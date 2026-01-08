data "aws_region" "current" {
  provider = aws.cloudfront
}

// A unique ID for this module
resource "random_id" "module_id" {
  byte_length = 8
}

locals {
  is_static_redirect = var.redirect_type == "STATIC_PATH"
}
