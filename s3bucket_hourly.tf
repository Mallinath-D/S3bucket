# ---------------------------------------------------------------------------------------------------------------------
# CREATE A S3 BUCKET THAT IS SECURED BY DEFAULT
# - Bucket public access blocking all set to true
# - Server-Side-Encryption (SSE) at rest enabled by default (AES256),
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Set default values for the S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------

# Resource Block: Create AWS S3 Bucket for daily weather data storage

resource "aws_s3_bucket" "S3-bucket-hourly" {  
  bucket              = "${random_pet.petname.id}-hourly"
  acl                 = var.acl
  force_destroy       = var.force_destroy

  tags = {
  Name        = "Hourly bucket"
  Environment = "Dev"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

lifecycle_rule {
    id      = "archive"
    enabled = true

    prefix = "archive/"

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 120
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# Create the S3 Bucket Public Access Block Policy
# All public access should be blocked per default
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "s3-hourly-Public" {

  bucket = "${aws_s3_bucket.S3-bucket-hourly.id}"

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets 
  
} 
