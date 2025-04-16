# ------------------------------------------------------------------------------
# Input Variable Definitions
# ------------------------------------------------------------------------------
variable "project_prefix" {
  description = "Prefix for all resource names (e.g., project or company name)"
  type        = string
  default     = "acme"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, stg, prd)"
  type        = string
  default     = "dev"
  validation {
    # Limit environment name to one of: dev, stg, prd (example)
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-northeast-1" # Example: Tokyo region
}

# ------------------------------------------------------------------------------
# Local Variable Definitions (derived values and common settings)
# ------------------------------------------------------------------------------
locals {
  # Short region name format (remove hyphens for use in naming conventions)
  # Example: ap-northeast-1 -> apne1
  aws_region_short_code = lower(replace(var.aws_region, "-", ""))

  # Common tags to apply to all resources
  common_tags = {
    Project     = var.project_prefix
    Environment = var.environment
    ManagedBy   = "Terraform"
    SourceRepo  = "github.com/mikieto/modern-data-architecture-code" # Example: include repo info in tags
  }

  # Define bucket names for each layer (referenced in main.tf)
  bucket_names = {
    bronze = "${var.project_prefix}-${var.environment}-bronze-data-${local.aws_region_short_code}"
    silver = "${var.project_prefix}-${var.environment}-silver-data-${local.aws_region_short_code}"
    gold   = "${var.project_prefix}-${var.environment}-gold-data-${local.aws_region_short_code}"
  }
}