# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-backend-bucket-suraj2310"
#     key            = "state/terraform.tfstate"
#     region         = "ap-south-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
