### Anejo – Lambda Functions ###

# Repo Sync
resource "aws_lambda_function" "anejo_repo_sync" {
  function_name = "anejo_repo_sync"
  description   = "Sync Anejo repo with Apple SUS"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_iam_role.arn}"
  handler       = "repo_sync.lambda_handler"
  runtime       = "python3.7"
  timeout       = 10

  environment {
    variables = {
      S3_BUCKET         = "${var.anejo_repo_bucket}",
      CATALOG_QUEUE_URL = "${aws_sqs_queue.anejo_catalog_sync_queue.id}"
    }
  }
}


# Catalog Sync
resource "aws_lambda_function" "anejo_catalog_sync" {
  function_name = "anejo_catalog_sync"
  description   = "Replicate Apple SUS catalog to Anejo repo"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_iam_role.arn}"
  handler       = "catalog_sync.lambda_handler"
  runtime       = "python3.7"
  timeout       = 600

  environment {
    variables = {
      S3_BUCKET               = "${var.anejo_repo_bucket}",
      PRODUCT_QUEUE_URL       = "${aws_sqs_queue.anejo_product_sync_queue.id}",
      WRITE_CATALOG_QUEUE_URL = "${aws_sqs_queue.anejo_write_local_catalog_queue.id}",
      WRITE_CATALOG_DELAY     = "${var.anejo_write_catalog_delay}"
    }
  }
}


# Product Sync
resource "aws_lambda_function" "anejo_product_sync" {
  function_name = "anejo_product_sync"
  description   = "Replicate Apple SUS product to Anejo repo"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_iam_role.arn}"
  handler       = "product_sync.lambda_handler"
  runtime       = "python3.7"
  timeout       = 300

  environment {
    variables = {
      PRODUCT_INFO_TABLE = "${aws_dynamodb_table.anejo_product_info_metadata.id}",
      S3_BUCKET          = "${var.anejo_repo_bucket}"
    }
  }
}


# Write Local Catalog
resource "aws_lambda_function" "anejo_write_local_catalog" {
  function_name = "anejo_write_local_catalog"
  description   = "Write local catalog and branches in Anejo repo"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_iam_role.arn}"
  handler       = "catalog_write.lambda_handler"
  runtime       = "python3.7"
  timeout       = 300

  environment {
    variables = {
      CATALOG_BRANCHES_TABLE = "${aws_dynamodb_table.anejo_catalog_branches_metadata.id}",
      S3_BUCKET              = "${var.anejo_repo_bucket}",
    }
  }
}


# Catalog Sync Trigger
resource "aws_lambda_event_source_mapping" "anejo_catalog_sync_trigger" {
  event_source_arn = "${aws_sqs_queue.anejo_catalog_sync_queue.arn}"
  function_name    = "${aws_lambda_function.anejo_catalog_sync.arn}"
  batch_size       = 1
}


# Catalog Sync Trigger
resource "aws_lambda_event_source_mapping" "anejo_write_local_catalog_trigger" {
  event_source_arn = "${aws_sqs_queue.anejo_write_local_catalog_queue.arn}"
  function_name    = "${aws_lambda_function.anejo_write_local_catalog.arn}"
  batch_size       = 1
}


# Products Sync Trigger
resource "aws_lambda_event_source_mapping" "anejo_product_sync_trigger" {
  event_source_arn = "${aws_sqs_queue.anejo_product_sync_queue.arn}"
  function_name    = "${aws_lambda_function.anejo_product_sync.arn}"
  batch_size       = 10
}