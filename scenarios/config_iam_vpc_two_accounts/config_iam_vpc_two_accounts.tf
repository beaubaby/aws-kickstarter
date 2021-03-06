provider "aws" {
  alias = "users"

  profile = var.cli_profile_users
}

provider "aws" {
  alias = "resources"

  profile = var.cli_profile_resources
}

module "iam_users" {
  source = "git::https://github.com/moritzheiber/terraform-aws-core-modules.git//iam-users?ref=v0.3.14"
  providers = {
    aws = aws.users
  }

  # This includes some random bits here purely for demonstrational purposes. Please use a distinct unique identifier otherwise!
  iam_account_alias    = "my-aws-account-users-${substr(sha256(file("variables.tf")), 0, 20)}"
  resources_account_id = var.resources_account_id
  iam_users            = var.iam_users
}

module "iam_resources" {
  source = "git::https://github.com/moritzheiber/terraform-aws-core-modules.git//iam-resources?ref=v0.3.14"
  providers = {
    aws = aws.resources
  }

  # This includes some random bits here purely for demonstrational purposes. Please use a distinct unique identifier otherwise!
  iam_account_alias = "my-aws-account-resources-${substr(sha256(file("variables.tf")), 0, 20)}"
  users_account_id  = var.users_account_id
}
module "config" {
  source = "git::https://github.com/moritzheiber/terraform-aws-core-modules.git//config?ref=v0.3.14"
  providers = {
    aws = aws.resources
  }

  bucket_prefix                      = var.bucket_prefix
  enable_lifecycle_management_for_s3 = var.enable_lifecycle_management_for_s3
}

module "core_vpc" {
  source = "git::https://github.com/moritzheiber/terraform-aws-core-modules.git//vpc?ref=v0.3.14"
  providers = {
    aws = aws.resources
  }

  tags = var.tags
}
