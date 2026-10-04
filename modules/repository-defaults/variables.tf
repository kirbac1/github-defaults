variable "name" {
  description = "Repository name."
  type        = string
}

variable "description" {
  description = "One line about the repository."
  type        = string
}

variable "topics" {
  description = "Repository topics."
  type        = list(string)
  default     = []
}

variable "homepage_url" {
  description = "A link shown beside the description."
  type        = string
  default     = null
}

variable "required_checks" {
  description = "Status checks that must pass before anything merges into the default branch: the CI job names."
  type        = list(string)

  validation {
    condition     = length(var.required_checks) > 0
    error_message = "A default branch needs at least one required check; otherwise a red build can merge."
  }
}

variable "required_approvals" {
  description = "Approving reviews a pull request needs. 0 for one person, 1 or more for a team."
  type        = number
  default     = 0

  validation {
    condition     = var.required_approvals >= 0 && var.required_approvals <= 6
    error_message = "required_approvals must be between 0 and 6."
  }
}

variable "allowed_actions" {
  description = "Third-party actions workflows may use, as owner/repo@ref patterns."
  type        = list(string)
  default     = []
}
