# 01-bucket.tf

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "ce34-bucket"
}

resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}
