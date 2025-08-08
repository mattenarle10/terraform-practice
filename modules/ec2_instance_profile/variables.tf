variable "iam_policies" {
  type = set(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}

variable "profile_name" {
  type        = string
  description = "This is the profile's name prefix"
}

variable "role_name" {
  type        = string
  description = "Optional explicit IAM role name to use (overrides default pattern)"
  default     = null
}

variable "instance_profile_name" {
  type        = string
  description = "Optional explicit IAM instance profile name to use (overrides default pattern)"
  default     = null
}

variable "policy_name" {
  type        = string
  description = "Optional explicit IAM role policy name to use (overrides default pattern)"
  default     = null
}


