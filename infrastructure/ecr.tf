resource "aws_ecr_repository" "api" {
  name = local.name
}