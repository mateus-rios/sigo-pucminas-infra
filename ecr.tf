resource "aws_ecr_repository" "gestao_normas" {
  name                 = "gestao_normas"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

