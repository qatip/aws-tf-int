### Task1 ###

### Task2 ###

### Task3 ###
#locals {
#  mime_types = jsondecode(file("${path.module}/mime.json"))
#}

#resource "aws_s3_object" "uploaded_files" {
# for_each = fileset("${path.module}/static_files", "**/*")
#
#  bucket       = aws_s3_bucket.bucket_1.id
#  key          = each.key
#  source       = "${path.module}/static_files/${each.key}"
#  etag         = filemd5("${path.module}/static_files/${each.key}")
#  content_type = lookup(
#    local.mime_types,
#    regex("\\.[^.]+$", each.key),
#    "application/octet-stream"
#  )
#}


### Task4 ###

### Task5 ###
