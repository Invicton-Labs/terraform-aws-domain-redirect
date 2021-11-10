terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.64"
    }
  }
}

// A unique ID for this module
resource "random_id" "module_id" {
  byte_length = 8
}
