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
