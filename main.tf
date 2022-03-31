data "aws_region" "current" {
  provider = aws.cloudfront
}

module "assert_region" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~> 0.2.1"
  condition     = data.aws_region.current.name == "us-east-1"
  error_message = "The `aws.cloudfront` provider for the `domain-redirect` module must be in the 'us-east-1' region, where CloudFront distributions must be created. The given provider is in the '${data.aws_region.current.name}' region."
}

// A unique ID for this module
resource "random_id" "module_id" {
  byte_length = 8
}
