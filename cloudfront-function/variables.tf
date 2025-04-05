variable "module_id" {
  description = "A unique ID to use for this module. If not provided, it will create a new one."
  type        = string
  nullable    = true
  default     = null
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
