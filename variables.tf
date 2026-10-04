variable "owner" {
  description = "The GitHub user or organisation that owns the repositories."
  type        = string
}

variable "repositories" {
  description = "The repositories that get the defaults, keyed by name. Each one must already exist; it is imported on the first plan."
  type = map(object({
    description     = string
    topics          = optional(list(string), [])
    homepage_url    = optional(string)
    required_checks = list(string)
    # 0 suits one person: changes still go through a pull request with green
    # checks, but there is nobody else to approve. A team sets 1 or more.
    required_approvals = optional(number, 0)
    # Third-party actions workflows may use. GitHub's own are always allowed.
    allowed_actions = optional(list(string), [])
  }))
}
