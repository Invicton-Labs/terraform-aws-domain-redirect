module "module_id_provided" {
  source  = "Invicton-Labs/input-provided/null"
  version = ">=0.2.0"
  input   = var.module_id
}

// A unique ID for this module
resource "random_id" "module_id" {
  // Only create this resource if a module ID was NOT provided as an input variable
  count       = module.module_id_provided.one_if_not_provided
  byte_length = 8
}

locals {
  is_static_redirect = var.redirect_type == "STATIC_PATH"
  module_id          = module.module_id_provided.provided ? var.module_id : random_id.module_id[0].hex
}
