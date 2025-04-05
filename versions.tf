terraform {
  required_version = "~> 1.11.3"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.81"
      configuration_aliases = [aws.cloudfront, aws.route53]
    }
  }
}
