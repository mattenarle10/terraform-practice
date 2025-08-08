resource "aws_dynamodb_table" "table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "product_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = var.table_name
    Environment = "production"
  }
}


