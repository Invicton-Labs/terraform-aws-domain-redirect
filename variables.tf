variable "domains_from" {
  description = "A map of domain/hosted zone ID pairs to be included in the redirect. A Route53 record will be created for each one."
  type        = map(string)
  validation {
    condition     = length(var.domains_from) > 0
    error_message = "The `domains_from` variable must include at least 1 element."
  }
  validation {
    condition     = var.domains_from != null
    error_message = "The `domains_from` variable must not be `null`."
  }
}
locals {
  var_domains_from = var.domains_from
}

variable "domain_to" {
  description = "The domain to redirect requests to."
  type        = string
  validation {
    condition     = var.domain_to != null
    error_message = "The `domain_to` variable must not be `null`."
  }
}
locals {
  var_domain_to = var.domain_to
}

variable "redirect_type" {
  description = "The type of redirect to perform. Options are `KEEP_PATH` or `STATIC_PATH`."
  type        = string
  default     = "KEEP_PATH"
  validation {
    condition     = contains(["KEEP_PATH", "STATIC_PATH"], var.redirect_type)
    error_message = "The `redirect_type` variable must be either `KEEP_PATH` or `STATIC_PATH`."
  }
}
locals {
  var_redirect_type = var.redirect_type != null ? var.redirect_type : "KEEP_PATH"
}

variable "redirect_static_path" {
  description = "The fixed, static path to redirect all requests to. It is only used if the `redirect_type` variable is set to `STATIC_PATH`."
  type        = string
  default     = "/"
}
locals {
  var_redirect_static_path = var.redirect_static_path != null ? var.redirect_static_path : "/"
}

variable "redirect_path_prefix" {
  description = <<EOF
The prefix to prepend to all paths when redirecting. It is only used if the `redirect_type` variable is set to `KEEP_PATH`.

For example, if you are redirecting `foo.com` to `bar.org`, and this variable is set to `myprefix/`, then a request to `foo.com/some/path?query=parameter` will be redirected to `bar.org/myprefix/some/path?query=parameter`.
EOF
  type        = string
  default     = ""
}
locals {
  var_redirect_path_prefix = var.redirect_path_prefix != null ? var.redirect_path_prefix : ""
}

variable "redirect_code" {
  description = "The HTTP code to use for the redirect. Options are `301` (moved permanently) or `302` (moved temporarily)."
  type        = number
  default     = 301
  validation {
    condition     = contains([301, 302], var.redirect_code)
    error_message = "The `redirect_code` variable must be either `301` or `302`."
  }
}
locals {
  var_redirect_code = var.redirect_code != null ? var.redirect_code : 301
}

variable "logging_config" {
  description = "Configuration for the CloudFront distribution logging. If none is provided, logging will not be enabled."
  type = object({
    include_cookies = bool
    bucket          = string
    prefix          = string
  })
  default = null
}
locals {
  var_logging_config = var.logging_config
}

variable "cache_duration_min" {
  description = "The minimum number of seconds to use for the CloudFront cache TTL."
  type        = number
  default     = 86400
}
locals {
  var_cache_duration_min = var.cache_duration_min != null ? var.cache_duration_min : 86400
}

variable "cache_duration_default" {
  description = "The default number of seconds to use for the CloudFront cache TTL."
  type        = number
  default     = 86400
}
locals {
  var_cache_duration_default = var.cache_duration_default != null ? var.cache_duration_default : 86400
}

variable "cache_duration_max" {
  description = "The maximum number of seconds to use for the CloudFront cache TTL."
  type        = number
  default     = 86400
}
locals {
  var_cache_duration_max = var.cache_duration_max != null ? var.cache_duration_max : 86400
}

variable "ssl_minimum_protocol_version" {
  description = "The minimum SSL version to support."
  type        = string
  default     = "TLSv1.2_2021"
}
locals {
  var_ssl_minimum_protocol_version = var.ssl_minimum_protocol_version != null ? var.ssl_minimum_protocol_version : "TLSv1.2_2021"
}
