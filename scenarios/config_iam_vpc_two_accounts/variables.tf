variable "bucket_prefix" {
  type        = string
  description = "The prefix attached to the AWS Config S3 bucket where evaluation results are stored"
  # The module default is "aws-config" so you don't necessarily need to specify this
  default = "my-aws-config-bucket"
}

variable "enable_lifecycle_management_for_s3" {
  type        = bool
  description = "Whether or not to enable lifecycle management for the created S3 buckets"
  # You should set this to true, or just delete the line (the default is "true"), if you're moving this into a production context
  default = false
}

variable "resource_tag" {
  type        = string
  description = "A common resource tag for all VPC resources that are created (for e.g. billing purposes)"
  default     = "my-awesome-project"
}
# This only works with setting up two CLI/SharedCredentials profiles, one of the first account ("users") and one for the second account ("resources") because otherwise you won't be able to pass two sets of credentials at the same time. That's why the provider definitions have a mandatory "profile" variable attached to them

variable "users_profile" {
  type        = string
  description = "The AWS CLI/SharedCredentials profile to provision the IAM users account with"
}

variable "resources_profile" {
  type        = string
  description = "The AWS CLI/SharedCredentials profile to provision the IAM resources account with"
}

variable "users_account_id" {
  type        = string
  description = "The AWS account ID for the account the users are going to live in"
}
variable "resources_account_id" {
  type        = string
  description = "The AWS account ID for the account the resources are going to live in"
}
