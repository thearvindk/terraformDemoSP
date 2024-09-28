resource "aws_s3_bucket" "transactionappbucket" {
    bucket = "myreactappdemoforsp"  # S3 bucket

    tags = {
        "env" = "dev"  # Environment tag
    }
}

resource "aws_s3_bucket_website_configuration" "index_config" {
  bucket = aws_s3_bucket.transactionappbucket.id  # Bucket configuration

  index_document {
    suffix = "index.html"  # Default document
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket-ownership" {
  bucket = aws_s3_bucket.transactionappbucket.id  # Ownership controls

  rule {
    object_ownership = "BucketOwnerPreferred"  # Object ownership
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access" {
    bucket = aws_s3_bucket.transactionappbucket.id  # Public access

    block_public_acls = false  # Block ACLs
    block_public_policy = false  # Block policies
    ignore_public_acls = false  # Ignore ACLs
    restrict_public_buckets = false  # Restrict buckets
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.transactionappbucket.id  # Bucket ACL

  acl = "public-read"  # Public read

  depends_on = [ aws_s3_bucket_ownership_controls.bucket-ownership, 
  aws_s3_bucket_public_access_block.bucket-public-access ]  # Dependency control
}

resource "aws_s3_bucket_policy" "public-access-policy" {
  bucket = aws_s3_bucket.transactionappbucket.id  # Bucket policy

   policy = jsonencode({  # JSON policy
    Version = "2012-10-17"  # Policy version
    Statement = [
      {
        Sid = "PublicReadGetObject"  # Statement ID
        Effect = "Allow"  # Allow effect
        Principal = "*"  # All principals
        Action = "s3:GetObject"  # Get object
        Resource = "${aws_s3_bucket.transactionappbucket.arn}/*"  # Bucket ARN
      }
    ]
  })
}
