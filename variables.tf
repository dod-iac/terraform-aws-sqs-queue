variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used to encrypt messages at-rest."
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the SQS queue."
}

variable "policy" {
  type        = string
  description = "The JSON policy for the SQS queue."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the SQS queue."
  default     = {}
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)."
  default     = 30
}
