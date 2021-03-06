### Anejo – API Module – Lambda Functions ###

## Lambda Functions ##

# API Catalogs Function
resource "aws_lambda_function" "anejo_api_catalogs" {
  function_name = "anejo_api_catalogs${local.name_extension}"
  description   = "API Catalogs response"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_api_iam_role.arn}"
  handler       = "anejo_api_catalogs.lambda_handler"
  runtime       = "python3.7"
  timeout       = 30

  environment {
    variables = {
      CATALOG_BRANCHES_TABLE = "${aws_dynamodb_table.anejo_catalog_branches_metadata.id}",
      PRODUCT_INFO_TABLE     = "${aws_dynamodb_table.anejo_product_info_metadata.id}",
      S3_BUCKET              = "${aws_s3_bucket.anejo_repo_bucket.id}"
    }
  }

  tags = "${local.tags_map}"
}

# API Prefs Function
resource "aws_lambda_function" "anejo_api_prefs" {
  function_name = "anejo_api_prefs${local.name_extension}"
  description   = "API Prefs response"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_api_iam_role.arn}"
  handler       = "anejo_api_prefs.lambda_handler"
  runtime       = "python3.7"
  timeout       = 30

  environment {
    variables = {
      S3_BUCKET = "${aws_s3_bucket.anejo_repo_bucket.id}"
    }
  }

  tags = "${local.tags_map}"
}


# API Products Function
resource "aws_lambda_function" "anejo_api_products" {
  function_name = "anejo_api_products${local.name_extension}"
  description   = "API Products response"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_api_iam_role.arn}"
  handler       = "anejo_api_products.lambda_handler"
  runtime       = "python3.7"
  timeout       = 30

  environment {
    variables = {
      CATALOG_BRANCHES_TABLE = "${aws_dynamodb_table.anejo_catalog_branches_metadata.id}",
      PRODUCT_INFO_TABLE     = "${aws_dynamodb_table.anejo_product_info_metadata.id}",
      S3_BUCKET              = "${aws_s3_bucket.anejo_repo_bucket.id}"
    }
  }

  tags = "${local.tags_map}"
}


# API Sync Function
resource "aws_lambda_function" "anejo_api_sync" {
  function_name = "anejo_api_sync${local.name_extension}"
  description   = "API function to begin Anejo sync"
  filename      = "${var.zip_file_path}"
  role          = "${aws_iam_role.anejo_api_iam_role.arn}"
  handler       = "anejo_api_sync.lambda_handler"
  runtime       = "python3.7"
  timeout       = 30

  environment {
    variables = {
      REPO_SYNC_FUNCTION = "${aws_lambda_function.anejo_repo_sync.id}"
    }
  }

  tags = "${local.tags_map}"
}
