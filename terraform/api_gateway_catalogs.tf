## API Resource - /catalogs ##

# API Gateway Resource - /catalogs
resource "aws_api_gateway_resource" "anejo_api_catalogs_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.anejo_api_gateway.root_resource_id}"
  path_part   = "catalogs"
}


# API Gateway Method - /catalogs
resource "aws_api_gateway_method" "anejo_api_catalogs_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}


# API Gateway Lambda Integration - /catalogs
resource "aws_api_gateway_integration" "anejo_api_catalogs_lambda_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id             = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method             = "${aws_api_gateway_method.anejo_api_catalogs_get.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.anejo_api_catalogs.arn}/invocations"

  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates    = {
    "application/json" = "${local.json_request_template}"
  }
}


# API Gateway Lambda Permission - /catalogs
resource "aws_lambda_permission" "anejo_api_catalogs_lambda_permission" {
  statement_id_prefix  = "AllowAPIGatewayInvoke"
  action               = "lambda:InvokeFunction"
  function_name        = "${aws_lambda_function.anejo_api_catalogs.arn}"
  principal            = "apigateway.amazonaws.com"
  source_arn           = "${aws_api_gateway_rest_api.anejo_api_gateway.execution_arn}/*/GET/catalogs"
}


# API Gateway Method Response (200) - /catalogs
resource "aws_api_gateway_method_response" "api_catalogs_http_200_response" {
  rest_api_id = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method = "${aws_api_gateway_method.anejo_api_catalogs_get.http_method}"
  status_code = "200"
}


# API Gateway Lambda Integration Response (200) - /catalogs
resource "aws_api_gateway_integration_response" "api_catalogs_http_200_lambda_response" {
  rest_api_id = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method = "${aws_api_gateway_method.anejo_api_catalogs_get.http_method}"
  status_code = "${aws_api_gateway_method_response.api_catalogs_http_200_response.status_code}"

  depends_on  = ["aws_api_gateway_integration.anejo_api_catalogs_lambda_integration"]
}


# API Gateway Method Response (500) - /catalogs
resource "aws_api_gateway_method_response" "api_catalogs_http_500_response" {
  rest_api_id = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method = "${aws_api_gateway_method.anejo_api_catalogs_get.http_method}"
  status_code = "500"
}


# API Gateway Lambda Integration Response (500) - /catalogs
resource "aws_api_gateway_integration_response" "api_catalogs_http_500_lambda_response" {
  rest_api_id = "${aws_api_gateway_rest_api.anejo_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.anejo_api_catalogs_resource.id}"
  http_method = "${aws_api_gateway_method.anejo_api_catalogs_get.http_method}"
  status_code = "${aws_api_gateway_method_response.api_catalogs_http_500_response.status_code}"

  selection_pattern = "${var.anejo_http_500_response_pattern}"

  depends_on  = ["aws_api_gateway_integration.anejo_api_catalogs_lambda_integration"]
}
