terraform {
  backend "s3" {
    bucket = "apps-terraform"
    key    = "eks-migration-workflow/terraform.tfstate"
    region = "eu-central-1"
  }
}
