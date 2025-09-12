variable "contact_email" {
  description = "Contact form recipient email"
  type        = string
}

# variable "domain_name" {
#   description = "Website domain name"
#   type        = string
# }

variable "github_repo" {
  description = "GitHub repository for CI/CD"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner for CI/CD"
  type        = string
}

variable "github_branch" {
  description = "GitHub repository branch for CI/CD"
  type        = string
}

variable "github_token" {
  description = "GitHub token for CI/CD"
  type        = string
  sensitive   = true
}