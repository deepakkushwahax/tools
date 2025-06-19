terraform {
  backend "s3" {
    bucket         = "my-sonarqube-tfstate-bucket" # Replace with your bucket
    key            = "sonarqube/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}