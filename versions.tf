terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.81"
      configuration_aliases = [aws.cloudfront, aws.route53]
    }
  }
}
