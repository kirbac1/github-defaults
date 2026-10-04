# Repositories are adopted, not recreated: on the first plan Terraform imports
# each one as it already is, and the plan shows only what the defaults change.
import {
  for_each = var.repositories
  to       = module.repository[each.key].github_repository.this
  id       = each.key
}

module "repository" {
  source   = "./modules/repository-defaults"
  for_each = var.repositories

  name               = each.key
  description        = each.value.description
  topics             = each.value.topics
  homepage_url       = each.value.homepage_url
  required_checks    = each.value.required_checks
  required_approvals = each.value.required_approvals
  allowed_actions    = each.value.allowed_actions
}
