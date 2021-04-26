# Terraform Settings Block

terraform {
  # Terraform Version
  required_version = "0.13"
  
  required_providers {
    # AWS Provider

    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
}

# Provider Block

provider "aws" {
  region = var.region
  profile = "default" # Defining it for default profile is Optional
}

# Resource Block: Create Random Pet Name 

resource "random_pet" "petname" {
  length    = 3
  separator = "-"
}

resource "aws_iam_user" "new_user" {
  name = "new_user"
}

resource "aws_iam_policy" "policy" {
  name        = "${random_pet.petname.id}-policy"
  description = "My S3 policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.S3-bucket-daily.arn}","${aws_s3_bucket.S3-bucket-hourly.arn}"]
    }
  ]

}
EOT
}

data "aws_iam_policy_document" "s3-policy" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
    effect = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.S3-bucket-daily.arn}","${aws_s3_bucket.S3-bucket-hourly.arn}"]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}


