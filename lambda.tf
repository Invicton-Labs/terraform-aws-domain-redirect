// Create an archive of the templatefile
data "archive_file" "lambda" {
  type = "zip"
  source_content = templatefile("${path.module}/lambdas/origin-request/main.py", {
    redirect_path        = var.static_path
    redirect_domain      = var.domain_to
    redirect_code        = var.redirect_code
    redirect_description = var.redirect_code == 301 ? "Moved Permanently" : "Found"
    use_existing_url     = var.redirect_type == "KEEP_PATH" ? "True" : "False"
    default_uri          = local.default_root_object
  })
  source_content_filename = "main.py"
  output_path             = "${var.lambda_zip_output_directory != null ? var.lambda_zip_output_directory : "${path.root}/archives"}/domain-redirect-${random_id.module_id.hex}.zip"
}

// Create a "fake" origin for the CloudFront distribution. Even though it won't be used, it's still necessary
resource "aws_s3_bucket" "origin" {
  bucket = "domain-redirect-${random_id.module_id.hex}"
  acl    = "private"
}

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

resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.origin.json
}

resource "aws_s3_bucket_public_access_block" "origin" {
  bucket                  = aws_s3_bucket.origin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "origin" {
  comment = "Origin access identity for domain redirect ${random_id.module_id.hex}"
}

// The Pre-Sign-Up trigger function
module "lambda_origin_request" {
  source  = "Invicton-Labs/lambda-set/aws"
  version = "~> 0.4.1"
  edge    = true
  lambda_config = {
    function_name = "domain-redirect-${random_id.module_id.hex}"
    filename      = data.archive_file.lambda.output_path
    timeout       = 5
    memory_size   = 128
    handler       = "main.lambda_handler"
    runtime       = "python3.9"
    publish       = true
  }
}
