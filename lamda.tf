provider "aws" {
  version    = "~> 2.0"
  region     = "us-east-1"
  access_key = "${var.credential_username}"
  secret_key = "${var.credential_key}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.

#Each Lambda function must have an associated IAM role which dictates what access it has to other AWS services. The above configuration specifies a role with no access policy, effectively giving the function no access to any AWS services, since our example application requires no such access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

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

resource "aws_lambda_function" "example" {
  function_name = "Serverless_Example"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "terraform-serverless-example-moxing"
  s3_key    = "v${var.app_version}/example.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"

  runtime = "nodejs10.x"

  role = "${aws_iam_role.lambda_exec.arn}"
}
