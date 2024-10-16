# 04-upload-main.tf

resource "aws_s3_object" "main" {
  bucket        = aws_s3_bucket.website_bucket.bucket
  key           = "main.html"              # 업로드할 파일 이름 (버킷 내 경로)
  source        = "main.html"              # 로컬의 main.html 파일 경로
  content_type  = "text/html"
}
