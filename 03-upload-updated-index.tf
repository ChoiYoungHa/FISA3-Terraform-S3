# 03-upload-updated-index.tf

resource "aws_s3_object" "updated_index" {
  bucket        = aws_s3_bucket.website_bucket.bucket
  key           = "index.html"             # 업로드할 파일 이름 (버킷 내 경로)
  source        = "index.html"             # 로컬의 수정된 index.html 파일 경로
  content_type  = "text/html"
}