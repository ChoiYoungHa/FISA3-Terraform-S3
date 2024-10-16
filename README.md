# Terraform을 이용한 AWS S3 및 EC2 환경 구축 🚀

## 개요 📋
이 프로젝트는 Terraform을 사용하여 AWS 환경에 S3 버킷과 EC2 인스턴스를 생성하고, 웹 호스팅을 위한 `index.html` 파일을 업로드 및 업데이트하며 필요한 권한을 설정하는 과정을 다룹니다. 이를 통해 인프라를 코드로 관리하는 방법을 학습하고, AWS 리소스를 효율적으로 관리할 수 있는 능력을 키우는 것을 목표로 합니다.

## 팀구성 🧸
    
|<img src="https://avatars.githubusercontent.com/u/64997345?v=4" width="120" height="120"/>|<img src="https://avatars.githubusercontent.com/u/38968449?v=4" width="120" height="120"/>
|:-:|:-:|
|[@최영하](https://github.com/ChoiYoungha)|[@허예은](https://github.com/yyyeun)

## 학습목표 🎯
- Terraform을 사용하여 AWS S3 버킷과 EC2 인스턴스를 생성하는 방법 이해
- IAM 역할과 정책을 정의하고 연결하는 방법 습득
- S3 버킷에 정적 웹사이트를 호스팅하기 위한 설정 방법 학습
- Terraform을 통해 인프라를 코드로 관리하는 실습
- AWS 리소스의 권한 설정 및 보안 관리 방법 

## 사전작업 📝
프로젝트를 시작하기 전에 다음 사전 작업을 완료해야 합니다.

**AWS CLI 설치** 🛠️
AWS CLI 설치 가이드를 참고하여 AWS CLI를 설치합니다.
설치 후, aws configure 명령어를 사용하여 AWS 자격 증명을 설정합니다.
![2024-10-16 12 21 03](https://github.com/user-attachments/assets/c9d7e0cb-dc97-4ec1-9d38-64661acf7774)


**Terraform 설치** 🛠️
Terraform 다운로드 페이지를 방문하여 운영체제에 맞는 Terraform을 다운로드하고 설치합니다. 설치가 완료되면, 터미널에서 terraform --version 명령어를 실행하여 설치가 제대로 되었는지 확인합니다.

![2024-10-16 12 21 15](https://github.com/user-attachments/assets/48c92359-412a-44ae-a9c8-7abb507cb990)

**AWS CLI 권한 설정** 🔑
AWS CLI를 사용하기 위한 적절한 IAM 권한이 있다고 가정합니다.

![2024-10-16 12 21 39](https://github.com/user-attachments/assets/953f2206-80fc-4a80-886f-e63ab078f2cb)

## 작업순서 🛠️

### 1. 버킷 IAM 정책 정의 및 연결 (`bucket_role.tf`) 🔐

```hcl
resource "aws_iam_role" "s3_create_bucket_role" {
  name = "s3-create-bucket-role"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM 정책 정의 (S3에 대한 모든 권한 부여)
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "s3-full-access-policy"
  description = "Full access to S3 resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"  # 모든 S3 액세스 허용
        ]
        Resource = [
          "*"  # 모든 S3 리소스에 대한 권한
        ]
      }
    ]
  })
}

# IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3_create_bucket_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}
```
S3 버킷 생성과 관련된 IAM 역할과 정책을 정의하고 연결합니다.


### 2. 버킷 생성 (`create_s3_bucket.tf`) 🛢
```hcl
# S3 버킷 생성
resource "aws_s3_bucket" "bucket1" {
  bucket = "ce33-bucket"  # 생성하고자 하는 S3 버킷 이름
}

# S3 버킷의 public access block 설정
resource "aws_s3_bucket_public_access_block" "bucket1_public_access_block" {
  bucket = aws_s3_bucket.bucket1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```
S3 버킷을 생성하고, 퍼블릭 접근 설정을 구성합니다.

### 3. `index.html` 파일 업로드 및 웹호스팅 설정 (`index_s3_upload.tf`) 🌐

```hcl
# 이미 존재하는 S3 버킷에 index.html 파일을 업로드
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.bucket1.id  # 생성된 S3 버킷 이름 사용
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
}

# S3 버킷의 웹사이트 호스팅 설정
resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
  bucket = aws_s3_bucket.bucket1.id  # 생성된 S3 버킷 이름 사용

  index_document {
    suffix = "index.html"
  }
}

# S3 버킷의 public read 정책 설정
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.bucket1.id  # 생성된 S3 버킷 이름 사용

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [ "s3:GetObject" ],
      "Resource": [
        "arn:aws:s3:::ce33-bucket",
        "arn:aws:s3:::ce33-bucket/*"
      ]
    }
  ]
}
EOF
}
```
S3 버킷에 `index.html` 파일을 업로드하고, 웹사이트 호스팅을 설정합니다.

### 4. 엔드포인트 설정 (`s3_endpoint.tf`) 🌍

```hcl
output "website_endpoint" {
  value       = aws_s3_bucket.bucket1.website_endpoint
  description = "The endpoint for the S3 bucket website."
}
```
S3 버킷의 웹사이트 엔드포인트를 출력합니다.

### 5. `index.html` 수정 ✏️
```html
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>ce33</h1>
    <a href="https://ce33-bucket.s3.ap-northeast-2.amazonaws.com/main.html">main 이동</a>
</body>
</html>
```
`index.html` 파일을 수정하여 `main.html`로 이동하는 링크를 추가합니다.

### 6. `index.html` 재업로드 (`index_s3_upload_v2.tf`) 🔄

```hcl
# S3 버킷에 main.html 파일을 업로드
resource "aws_s3_object" "main" {
  bucket        = aws_s3_bucket.bucket1.id  # 기존 S3 버킷 이름 사용
  key           = "main.html"
  source        = "main.html"               # 로컬 파일 경로
  content_type  = "text/html"
}

# S3 버킷에 index.html 파일을 다시 업로드 (덮어쓰기)
resource "aws_s3_object" "index_html_update" {  # 리소스 이름 변경
  bucket        = aws_s3_bucket.bucket1.id  # 기존 S3 버킷 이름 사용
  key           = "index.html"
  source        = "index.html"               # 로컬 파일 경로
  content_type  = "text/html"
}
```
수정된 `index.html`과 새로운 `main.html` 파일을 S3 버킷에 업로드합니다.

### 7. EC2 생성 (`ec2_instance.tf`) 🖥️
```hcl
# AWS Provider 설정
provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

# VPC ID를 변수로 설정하거나, 기존 VPC를 사용
variable "vpc_id" {
  description = "The ID of the VPC"
  default     = "secret" 
}

# 기존 보안 그룹을 데이터 소스로 가져오기
data "aws_security_group" "ce33_sg" {
  name   = "ce33-sg"
  vpc_id = "secret"
}

resource "aws_instance" "ce33_ec2" {
  ami                    = "ubuntu version ami"
  instance_type          = "t2.micro"
  key_name               = "secret-key"
  
  subnet_id              = "secret" 
  
  vpc_security_group_ids = [data.aws_security_group.ce33_sg.id]
  
  associate_public_ip_address = true  # 퍼블릭 IP 자동 할당
  
  tags = {
    Name = "ce33-ec2"
  }
}
```
EC2 인스턴스를 생성하고, 필요한 네트워크 설정을 구성합니다.

## 트러블슈팅 🔥
![2024-10-16 13 48 58](https://github.com/user-attachments/assets/7bea40c8-efb3-4ed5-a403-07cf158554e5)
위 에러 메시지는 Terraform에서 동일한 리소스 이름을 중복으로 선언했음을 의미합니다.
aws_s3_object 리소스의 이름인 "index"가 이미 이전에 선언되었기 때문에, 리소스 이름이 중복되어 에러가 발생한 것입니다.
리소스 이름을 변경하여 설정을 다시 적용합니다.

**AS IS**
```
resource "aws_s3_object" "main" {
  bucket        = aws_s3_bucket.bucket1.id
  key           = "main.html"
  source        = "main.html"
  content_type  = "text/html"
}


# S3 버킷에 index.html 파일을 다시 업로드 (덮어쓰기)
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.bucket1.id
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
}
```

**TO BE**
```
resource "aws_s3_object" "main_html" {
  bucket        = aws_s3_bucket.bucket1.id  
  key           = "main.html"
  source        = "main.html"
  content_type  = "text/html"
}

resource "aws_s3_object" "index_html_update" {
  bucket        = aws_s3_bucket.bucket1.id
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
}
```

![2024-10-16 13 54 57](https://github.com/user-attachments/assets/4fe8a57d-544e-4586-896a-ca22c294d5a3)


## 결론 및 고찰 💡
이번 프로젝트를 통해 Terraform을 활용하여 AWS 인프라를 코드로 관리하는 방법을 실습하였습니다. <br>
S3 버킷과 EC2 인스턴스를 자동으로 생성하고, 필요한 권한을 설정함으로써 인프라 구축의 효율성과 일관성을 높일 수 있음을 확인하였습니다. <br>
<br>
또한, 정적 웹사이트 호스팅을 위한 설정 과정을 통해 S3의 다양한 기능을 이해하게 되었습니다. 향후에는 Terraform 모듈을 활용하여 더욱 재사용 가능하고 확장 가능한 인프라를 구축하는 방법을 탐구하고, AWS의 다양한 서비스와 연동하여 복잡한 인프라를 효율적으로 관리하는 능력을 향상시켰습니다.
