# ------------------------------------------------------------------------------
# Create S3 buckets for Medallion Architecture (Bronze, Silver, Gold)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "bronze" {
  bucket = local.bucket_names.bronze
  tags   = local.common_tags

  lifecycle {
    # Allows deleting the bucket with terraform destroy even if objects exist (for hands-on labs)
    # Warning: Consider setting to false in production to prevent accidental data loss
    prevent_destroy = false # Typically, true is safer
  }
}

resource "aws_s3_bucket_versioning" "bronze_versioning" {
  bucket = aws_s3_bucket.bronze.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bronze_sse" {
  bucket = aws_s3_bucket.bronze.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Silver Bucket ---
resource "aws_s3_bucket" "silver" {
  bucket = local.bucket_names.silver
  tags   = local.common_tags
  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_s3_bucket_versioning" "silver_versioning" {
  bucket = aws_s3_bucket.silver.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "silver_sse" {
  bucket = aws_s3_bucket.silver.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Gold Bucket ---
resource "aws_s3_bucket" "gold" {
  bucket = local.bucket_names.gold
  tags   = local.common_tags
  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_s3_bucket_versioning" "gold_versioning" {
  bucket = aws_s3_bucket.gold.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "gold_sse" {
  bucket = aws_s3_bucket.gold.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Policy Definitions (access permissions for each layer)
# ------------------------------------------------------------------------------

# --- Bronze bucket write policy ---
data "aws_iam_policy_document" "bronze_write_policy_doc" {
  statement {
    sid    = "AllowBronzeWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",      # May be needed for write confirmation or some operations
      "s3:ListBucket",     # Required for writing to specific prefixes
      "s3:DeleteObject"    # May be needed for reruns or corrections
    ]
    resources = [
      aws_s3_bucket.bronze.arn,
      "${aws_s3_bucket.bronze.arn}/*", # All objects within the bucket
    ]
  }
}
resource "aws_iam_policy" "bronze_write_policy" {
  name   = "${var.project_prefix}-${var.environment}-bronze-write-policy"
  policy = data.aws_iam_policy_document.bronze_write_policy_doc.json
  tags   = local.common_tags
}

# --- Silver bucket read/write policy ---
data "aws_iam_policy_document" "silver_read_write_policy_doc" {
  statement {
    sid    = "AllowSilverReadWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
      # Table formats like Delta Lake might require additional permissions (e.g., for Glue Catalog integration)
      # If integrating with Glue Catalog, add relevant Glue permissions here
    ]
    resources = [
      aws_s3_bucket.silver.arn,
      "${aws_s3_bucket.silver.arn}/*",
    ]
  }
}
resource "aws_iam_policy" "silver_read_write_policy" {
  name   = "${var.project_prefix}-${var.environment}-silver-read-write-policy"
  policy = data.aws_iam_policy_document.silver_read_write_policy_doc.json
  tags   = local.common_tags
}

# --- Gold bucket read policy ---
data "aws_iam_policy_document" "gold_read_policy_doc" {
  statement {
    sid    = "AllowGoldRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.gold.arn,
      "${aws_s3_bucket.gold.arn}/*",
    ]
  }
}
resource "aws_iam_policy" "gold_read_policy" {
  name   = "${var.project_prefix}-${var.environment}-gold-read-policy"
  policy = data.aws_iam_policy_document.gold_read_policy_doc.json
  tags   = local.common_tags
}

# --- Bronze bucket read policy (for Transformation role) ---
data "aws_iam_policy_document" "bronze_read_policy_doc" {
  statement {
    sid    = "AllowBronzeRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.bronze.arn,
      "${aws_s3_bucket.bronze.arn}/*",
    ]
  }
}
resource "aws_iam_policy" "bronze_read_policy" {
  name   = "${var.project_prefix}-${var.environment}-bronze-read-policy"
  policy = data.aws_iam_policy_document.bronze_read_policy_doc.json
  tags   = local.common_tags
}


# ------------------------------------------------------------------------------
# IAM Role Definitions (for pipeline components)
# ------------------------------------------------------------------------------

# --- Role for data ingestion (e.g., used by Kafka Connect, Lambda) ---
data "aws_iam_policy_document" "ingestion_assume_role_policy" {
  # Define which services can assume this role
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      # Allow EC2 and Lambda as examples (adjust based on actual services used in later chapters)
      identifiers = ["ec2.amazonaws.com", "lambda.amazonaws.com", "glue.amazonaws.com", "sagemaker.amazonaws.com", "ecs-tasks.amazonaws.com", "eks.amazonaws.com"] # Added more potential services
    }
  }
}
resource "aws_iam_role" "ingestion_role" {
  name               = "${var.project_prefix}-${var.environment}-data-ingestion-role"
  assume_role_policy = data.aws_iam_policy_document.ingestion_assume_role_policy.json
  tags               = local.common_tags
}

# --- Role for data transformation (e.g., used by dbt on EC2/ECS, Glue Job) ---
data "aws_iam_policy_document" "transformation_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      # Allow EC2, Glue, SageMaker, ECS, EKS as examples (depends on where dbt or other transformations run)
      identifiers = ["ec2.amazonaws.com", "glue.amazonaws.com", "sagemaker.amazonaws.com", "ecs-tasks.amazonaws.com", "eks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "transformation_role" {
  name               = "${var.project_prefix}-${var.environment}-data-transformation-role"
  assume_role_policy = data.aws_iam_policy_document.transformation_assume_role_policy.json
  tags               = local.common_tags
}

# --- (Optional) Analytics Role (e.g., for BI tools, data scientists) ---
# Define similarly if needed, perhaps allowing SageMaker, QuickSight, or EC2 principals

# ------------------------------------------------------------------------------
# Attach Policies to IAM Roles
# ------------------------------------------------------------------------------

# Grant Bronze write permissions to the ingestion role
resource "aws_iam_role_policy_attachment" "ingestion_bronze_write" {
  role       = aws_iam_role.ingestion_role.name
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

# Grant Silver read/write permissions to the transformation role
resource "aws_iam_role_policy_attachment" "transformation_silver_read_write" {
  role       = aws_iam_role.transformation_role.name
  policy_arn = aws_iam_policy.silver_read_write_policy.arn
}

# Grant Bronze read permissions to the transformation role
resource "aws_iam_role_policy_attachment" "transformation_bronze_read" {
  role       = aws_iam_role.transformation_role.name
  policy_arn = aws_iam_policy.bronze_read_policy.arn
}

# If transformation role needs to write to Gold, attach a Gold write policy (not defined here for simplicity)

# Grant Gold read permissions to the analytics role (if defined)
# resource "aws_iam_role_policy_attachment" "analytics_gold_read" {
#   role       = aws_iam_role.analytics_role.name # If analytics_role is defined
#   policy_arn = aws_iam_policy.gold_read_policy.arn
# }