locals {
  schema = jsondecode(file("${path.module}/schema.json"))
}
resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = local.schema["attributes"]
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  global_secondary_index {
    name               = "OrderByIndex"
    hash_key           = "owner_id"
    range_key          = "logged_at"
    projection_type    = "ALL"
  }
}
