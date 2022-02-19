// Create an S3 bucket to be a "fake" origin for the CloudFront distribution. 
// Even though it won't be used, CloudFront still requires it.
resource "aws_s3_bucket" "origin" {
  bucket = "domain-redirect-${random_id.module_id.hex}"
}

// A policy document that allows CloudFront to access it
data "aws_iam_policy_document" "origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin.iam_arn]
    }
  }
}

// Apply the policy
resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.origin.json
}

// Don't allow any public access to the bucket
// (shouldn't matter since nothing will be in it, but just in case)
resource "aws_s3_bucket_public_access_block" "origin" {
  bucket                  = aws_s3_bucket_policy.origin.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Set a best-practices rule to switch everything in this bucket
// to this account's ownership (shouldn't matter since nothing will be in it, but just in case)
resource "aws_s3_bucket_ownership_controls" "origin" {
  bucket = aws_s3_bucket_public_access_block.origin.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
