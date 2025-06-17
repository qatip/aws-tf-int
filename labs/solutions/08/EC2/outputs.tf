
output "public_ip" {
  value = aws_eip.sql_eip.public_ip
}

output "rdp_command" {
  value = "mstsc /v:${aws_eip.sql_eip.public_ip}"
}
