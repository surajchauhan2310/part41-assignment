terraform {
  backend "s3" {
    bucket         = "tfstate-suraj-chauhan-20250716"   # ✅ must match your S3 bucket
    key            = "dev/terraform.tfstate"        # ✅ the file path in S3
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"              # ✅ name of the lock table
    encrypt        = true
    # use_lockfile   = true 
  }
}