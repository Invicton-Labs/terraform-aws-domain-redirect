variable "domains_from" {
  description = "A map of domain/hosted zone ID pairs to be included in the redirect. A Route53 record will be created for each one."
  type        = map(string)
  nullable    = false
  validation {
    condition     = length(var.domains_from) > 0
    error_message = "The `domains_from` variable must include at least 1 element."
  }
  validation {
    condition = length(flatten([
      for d in var.domains_from :
      d
      if strcontains(var.domain_to, "/") || strcontains(var.domain_to, "\\")
    ])) == 0
    error_message = "The `domains_from` variable should only contain domain names, and should not include protocols (e.g. `https://`) or URIs/paths."
  }
}

variable "domain_to" {
  description = "The domain to redirect requests to."
  type        = string
  nullable    = false
  validation {
    condition     = !strcontains(var.domain_to, "/") && !strcontains(var.domain_to, "\\")
    error_message = "The `domains_to` variable should only be the domain name, and should not include a protocol (e.g. `https://`) or a URI/path. To redirect to a specific path, use the `redirect_static_path` or `redirect_path_prefix` variables."
  }
}

variable "redirect_to_https" {
  description = "Whether to redirect all HTTP requests to HTTPS."
  type        = bool
  nullable    = false
  default     = false
}

variable "redirect_type" {
  description = "The type of redirect to perform. Options are `KEEP_PATH` or `STATIC_PATH`."
  type        = string
  nullable    = false
  default     = "KEEP_PATH"
  validation {
    condition     = contains(["KEEP_PATH", "STATIC_PATH"], var.redirect_type)
    error_message = "The `redirect_type` variable must be either `KEEP_PATH` or `STATIC_PATH`."
  }
}

variable "redirect_static_path" {
  description = "The fixed, static path to redirect all requests to. It is only used if the `redirect_type` variable is set to `STATIC_PATH`."
  type        = string
  nullable    = false
  default     = "/"
}

variable "redirect_path_prefix" {
  description = <<EOF
The prefix to prepend to all paths when redirecting. It is only used if the `redirect_type` variable is set to `KEEP_PATH`.

For example, if you are redirecting `foo.com` to `bar.org`, and this variable is set to `myprefix/`, then a request to `foo.com/some/path?query=parameter` will be redirected to `bar.org/myprefix/some/path?query=parameter`.
EOF
  type        = string
  nullable    = false
  default     = ""
}

variable "redirect_code" {
  description = "The HTTP code to use for the redirect. Options are `301` (moved permanently) or `302` (moved temporarily)."
  type        = number
  nullable    = false
  default     = 301
  validation {
    condition     = contains([301, 302], var.redirect_code)
    error_message = "The `redirect_code` variable must be either `301` or `302`."
  }
}

variable "logging_config" {
  description = "Configuration for the CloudFront distribution logging. If none is provided, logging will not be enabled."
  type = object({
    include_cookies = bool
    bucket          = string
    prefix          = string
  })
  nullable = true
  default  = null
}

variable "cache_duration_min" {
  description = "The minimum number of seconds to use for the CloudFront cache TTL."
  type        = number
  nullable    = false
  default     = 86400
}

variable "cache_duration_default" {
  description = "The default number of seconds to use for the CloudFront cache TTL."
  type        = number
  nullable    = false
  default     = 86400
}

variable "cache_duration_max" {
  description = "The maximum number of seconds to use for the CloudFront cache TTL."
  type        = number
  nullable    = false
  default     = 86400
}

variable "ssl_minimum_protocol_version" {
  description = "The minimum SSL version to support."
  type        = string
  nullable    = false
  default     = "TLSv1.2_2021"
}
