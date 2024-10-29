# Configuração do Provedor AWS
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.session_token
}

resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-imagens-12345"  # Substitua por um nome único

  tags = {
    Name        = "Meu Bucket de Imagens"
    Environment = "Dev"
  }
}

# Recurso de Versionamento
resource "aws_s3_bucket_versioning" "meu_bucket_versioning" {
  bucket = aws_s3_bucket.meu_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.meu_bucket.bucket
}

resource "aws_lambda_function" "processar_imagens" {
  function_name = "processarImagens"
  s3_bucket     = aws_s3_bucket.meu_bucket.bucket
  s3_key        = "lambda_code.zip"  # O código da função deve ser carregado no S3

  handler = "index.handler"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_role.arn
}

resource "aws_dynamodb_table" "monitoramento" {
  name         = "monitoramento"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"
}

resource "aws_iam_role" "lambda_role" {
  name = "#role_aws_88731"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}