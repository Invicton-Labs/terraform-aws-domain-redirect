// We use this module as a convenient tool for escaping quotes in strings
module "jsonencoded_static_redirect_path" {
  source  = "Invicton-Labs/jsonencode-no-replacements/null"
  version = "~> 0.1.1"
  // This trims all leading forward slashes
  object = regex("^/*(.*)$", var.redirect_static_path == null ? "/" : var.redirect_static_path)[0]
}
module "jsonencoded_redirect_path_prefix" {
  source  = "Invicton-Labs/jsonencode-no-replacements/null"
  version = "~> 0.1.1"
  // This trims all leading forward slashes
  object = regex("^/*(.*)$", var.redirect_path_prefix == null ? "" : var.redirect_path_prefix)[0]
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect-${local.module_id}"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect all requests"
  publish = true
  // Replace all carriage returns so it doesn't treat it as a different string when switching between OS
  code = replace(replace(<<EOF
function trimLeft(string, charToRemove) {
    while(string.charAt(0)==charToRemove) {
        string = string.substring(1);
    }
    return string;
}

function handler(event) {    
    ${local.is_static_redirect ? <<EOF2
    var new_uri = "${var.domain_to}/" + ${module.jsonencoded_static_redirect_path.encoded};
EOF2
    : <<EOF2
var query_string = Object.keys(event.request.querystring).map(key => key + '=' + event.request.querystring[key]['value']).join('&');
    var new_uri = "${var.domain_to}/" + ${module.jsonencoded_redirect_path_prefix.encoded} + trimLeft(event.request.uri, "/");
    if (query_string.length > 0) {
        new_uri += "?" + query_string;
    }
EOF2
    }

    var protocol = event.request.headers['cloudfront-forwarded-proto']['value'];
    new_uri = protocol + "://" + new_uri;

    return {
        statusCode: ${var.redirect_code},
        statusDescription: "${var.redirect_code == 301 ? "Moved Permanently" : "Found"}",
        headers: { 
            "location": {
                "value": new_uri
            }
        }
    };
}
EOF
, "\r", ""), "\r\n", "\n")
}
