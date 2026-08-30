# Remote S3 Backend Configuration for Staging Environment
# To enable remote state, replace BUCKET_NAME and DYNAMODB_TABLE with your actual S3 bucket and DynamoDB table.
/*
terraform {
  backend "s3" {
    bucket         = "octabyte-tf-state-staging"
    key            = "terraform/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "octabyte-tf-locks-staging"
    encrypt        = true
  }
}
*/
