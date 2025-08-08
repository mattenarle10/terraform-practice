output "table_name" {
  value       = aws_dynamodb_table.table.name
  description = "DynamoDB table name"
}

output "table_arn" {
  value       = aws_dynamodb_table.table.arn
  description = "DynamoDB table ARN"
}


