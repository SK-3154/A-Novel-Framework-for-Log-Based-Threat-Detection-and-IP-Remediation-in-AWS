# ================================
# STEP 2: S3 BUCKET FOR DATASET
# ================================

resource "aws_s3_bucket" "dataset_bucket" {
  bucket = "${var.project_name}-dataset"
}

# Optional but recommended: block public access
resource "aws_s3_bucket_public_access_block" "dataset_block" {
  bucket = aws_s3_bucket.dataset_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ================================
# STEP 3: DYNAMODB TABLE (THREAT IPs)
# ================================

resource "aws_dynamodb_table" "threat_table" {
  name         = "ThreatIPs"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "ip"
  range_key = "detected_at"

  attribute {
    name = "ip"
    type = "S"
  }

  attribute {
    name = "detected_at"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}



# ================================
# USE EXISTING LEARNER LAB ROLE
# ================================

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}


# ================================
# STEP 5: DETECTION LAMBDA
# ================================

resource "aws_lambda_function" "detection_lambda" {
  function_name = "offline_ids_detection"

  runtime = "python3.10"
  handler = "detection.lambda_handler"

  role = data.aws_iam_role.lab_role.arn

  filename         = "../lambdas/detection/detection.zip"
  source_code_hash = filebase64sha256("../lambdas/detection/detection.zip")

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.threat_table.name
    }
  }

  timeout = 300
  memory_size = 512
}


# ================================
# STEP 6: RESPONSE LAMBDA
# ================================

resource "aws_lambda_function" "response_lambda" {
  function_name = "offline_ids_response"

  runtime = "python3.10"
  handler = "response.lambda_handler"

  role = data.aws_iam_role.lab_role.arn

  filename         = "../lambdas/response/response.zip"
  source_code_hash = filebase64sha256("../lambdas/response/response.zip")

  timeout = 60
  memory_size = 128
}


resource "aws_lambda_event_source_mapping" "ddb_to_response" {
  event_source_arn  = aws_dynamodb_table.threat_table.stream_arn
  function_name     = aws_lambda_function.response_lambda.arn
  starting_position = "LATEST"
}
