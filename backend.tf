terraform {
  backend "s3" {
    bucket = "apps-terraform"
    key    = "eks-logs-aggregation/terraform.tfstate"
    region = "eu-west-1"
  }
}
