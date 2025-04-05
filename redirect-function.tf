module "redirect_function" {
  source               = "./cloudfront-function"
  module_id            = random_id.module_id.hex
  domain_to            = var.domain_to
  redirect_static_path = var.redirect_static_path
  redirect_code        = var.redirect_code
  redirect_path_prefix = var.redirect_path_prefix
  redirect_type        = var.redirect_type
}
