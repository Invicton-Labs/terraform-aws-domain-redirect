terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.8"
      configuration_aliases = [aws.cloudfront, aws.route53]
    }
  }
}
