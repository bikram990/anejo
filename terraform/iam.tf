### Anejo – IAM Roles and Policies ###

# Anejo IAM Role
resource "aws_iam_role" "anejo_iam_role" {
  name               = "anejo-lambda-role"
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


# IAM Policy – CloudWatch
resource "aws_iam_role_policy" "anejo_cloudwatch_iam_policy" {
  name   = "AnejoCloudWatchPolicy"
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
  name   = "AnejoDynamoDBPolicy"
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
  name   = "AnejoS3Policy"
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
  name   = "AnejoSQSPolicy"
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
                "${aws_sqs_queue.anejo_write_local_catalog_queue.arn}",
                "${aws_sqs_queue.anejo_product_sync_queue.arn}"
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
