### Anejo – IAM Roles and Policies ###

## IAM Roles ##

# Anejo IAM Lambda Role
resource "aws_iam_role" "anejo_iam_role" {
  name               = "anejo-lambda-role${local.name_extension}"
  description        = "Anejo Lambda role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Anejo IAM Lambda@Edge Role
resource "aws_iam_role" "anejo_iam_lambda_edge_role" {
  name               = "anejo-lambda-edge-role${local.name_extension}"
  description        = "Anejo Lambda@Edge role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


## IAM Policies ##

# IAM Policy (Edge) – CloudWatch
resource "aws_iam_role_policy" "anejo_cloudwatch_edge_iam_policy" {
  name   = "AnejoCloudWatchPolicyEdge${local.name_extension}"
  role   = "${aws_iam_role.anejo_iam_lambda_edge_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
} 
EOF
}

# IAM Policy – CloudWatch
resource "aws_iam_role_policy" "anejo_cloudwatch_iam_policy" {
  name   = "AnejoCloudWatchPolicy${local.name_extension}"
  role   = "${aws_iam_role.anejo_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
} 
EOF
}


# IAM Policy – DynamoDB
resource "aws_iam_role_policy" "anejo_dynamodb_iam_policy" {
  name   = "AnejoDynamoDBPolicy${local.name_extension}"
  role   = "${aws_iam_role.anejo_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"
            ],
            "Resource": [
                "${aws_dynamodb_table.anejo_product_info_metadata.arn}",
                "${aws_dynamodb_table.anejo_catalog_branches_metadata.arn}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "dynamodb:ListTables",
            "Resource": "*"
        }
    ]
}
EOF
}


# IAM Policy – S3
resource "aws_iam_role_policy" "anejo_s3_iam_policy" {
  name   = "AnejoS3Policy${local.name_extension}"
  role   = "${aws_iam_role.anejo_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.anejo_repo_bucket.arn}",
                "arn:aws:s3:::*/*"
            ]
        }
    ]
}
EOF
}


# IAM Policy – SQS
resource "aws_iam_role_policy" "anejo_sqs_iam_policy" {
  name   = "AnejoSQSPolicy${local.name_extension}"
  role   = "${aws_iam_role.anejo_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:GetQueueUrl",
                "sqs:ChangeMessageVisibility",
                "sqs:SendMessageBatch",
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sqs:GetQueueAttributes",
                "sqs:ListQueueTags",
                "sqs:TagQueue",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:DeleteMessageBatch",
                "sqs:PurgeQueue",
                "sqs:ChangeMessageVisibilityBatch"
            ],
            "Resource": [
                "${aws_sqs_queue.anejo_catalog_sync_queue.arn}",
                "${aws_sqs_queue.anejo_product_sync_queue.arn}",
                "${aws_sqs_queue.anejo_product_sync_download_queue.arn}",
                "${aws_sqs_queue.anejo_product_sync_failed_queue.arn}",
                "${aws_sqs_queue.anejo_write_local_catalog_queue.arn}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "sqs:ListQueues",
            "Resource": "*"
        }
    ]
}
EOF
}


## IAM Policy Documents ##

# Anejo S3 Bucket Policy Document
data "aws_iam_policy_document" "anejo_s3_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.anejo_repo_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.anejo_distribution_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.anejo_repo_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.anejo_distribution_identity.iam_arn}"]
    }
  }
}
