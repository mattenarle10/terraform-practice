locals {
  # Set these values for your environment
  team_name           = "{{team-name}}"
  flask_github_repo   = "https://github.com/mattenarle10/flask-app-for-terraform-workshop.git"
  assigned_aws_region = "{{assigned-region}}"
  # Remove braces and spaces; convert to lowercase. Allowed chars per IAM/S3 name sets
  team_name_safe = lower(replace(replace(replace(trimspace(local.team_name), "{", ""), "}", ""), " ", "-"))
  # Simpler S3-safe name (letters, numbers, hyphens). Ensure your team_name already uses these.
  team_name_s3 = lower(replace(replace(trimspace(local.team_name), " ", "-"), "_", "-"))
}


