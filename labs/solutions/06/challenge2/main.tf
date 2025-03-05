locals {
  json_data   = jsondecode(file(var.json_file))
  stages      = ["dev", "test", "prod", "infra", "sales"]
  projects    = ["finance", "appserver", "db", "web", "storage"]
  regex_stage = join("|", local.stages)
  regex_proj  = join("|", local.projects)
}

# Process Names
output "standardized_names" {
  value = {
    for name in local.json_data :
    name => join("-", [
      try(regex("(${local.regex_stage})", name)[0], "UNKNOWN"),
      try(regex("(${local.regex_proj})", name)[0], "UNKNOWN"),
      try(regex("([a-zA-Z0-9]+)$", name)[0], "UNKNOWN")
    ])
  }
}