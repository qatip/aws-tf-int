# QATIPINT AWS Lab 07 student starter
# Complete Tasks 1 and 2 before uncommenting Task 3.

# Task 1 - provider, bucket and bucket_name output
# Add Task 1 code here.

# Task 2 - private access, versioning, encryption and HTTPS-only policy
# Add Task 2 code here.

# Task 3 - file uploads
# Uncomment the code below when instructed.
# locals {
#   mime_types = jsondecode(file("${path.module}/mime.json"))
# }
#
# resource "aws_s3_object" "upload_files" {
#   for_each = fileset("${path.module}/static_files", "**/*")
#
#   bucket      = aws_s3_bucket.storage.id
#   key         = each.key
#   source      = "${path.module}/static_files/${each.key}"
#   source_hash = filemd5("${path.module}/static_files/${each.key}")
#
#   content_type = lookup(
#     local.mime_types,
#     lower(try(regex("\\.[^.]+$", each.key), "")),
#     "application/octet-stream"
#   )
#
#   depends_on = [
#     aws_s3_bucket_versioning.storage,
#     aws_s3_bucket_server_side_encryption_configuration.storage
#   ]
# }

# Task 4 - lifecycle configuration
# Add Task 4 code here.

# Task 5 - object address outputs
# Add Task 5 code here.
