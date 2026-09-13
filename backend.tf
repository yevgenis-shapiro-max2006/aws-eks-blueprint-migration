terraform {
  backend "s3" {
    bucket = "apps-terraform"
    key    = "eks-migration/terraform.tfstate"
    region = "eu-west-1"
  }
}
