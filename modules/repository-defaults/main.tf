# GitHub Actions' app id. A required check from any other app doesn't count,
# so nothing else can turn a check green by posting a status with its name.
locals {
  github_actions_app_id = 15368
}

resource "github_repository" "this" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  topics       = var.topics
  visibility   = "public"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  # One way into main: a squash merge titled after the pull request, and the
  # branch deleted afterwards. No auto-merge: a person presses the button.
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  delete_branch_on_merge      = true
  allow_auto_merge            = false
  allow_update_branch         = true

  # terraform destroy archives a repository instead of deleting it.
  archive_on_destroy = true
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
  enabled    = true
}

resource "github_repository_ruleset" "default_branch" {
  name        = "default-branch"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # No bypass_actors: the rules hold for the owner too, and so for anything
  # that acts with the owner's token, an agent included.
  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true

    pull_request {
      required_approving_review_count   = var.required_approvals
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = var.required_approvals > 0
      required_review_thread_resolution = true
    }

    required_status_checks {
      strict_required_status_checks_policy = true

      dynamic "required_check" {
        for_each = var.required_checks
        content {
          context        = required_check.value
          integration_id = local.github_actions_app_id
        }
      }
    }
  }
}

# Only GitHub's own actions and the listed ones run, and every action must be
# pinned to a full commit SHA. A tag can be moved, or never have existed.
resource "github_actions_repository_permissions" "this" {
  repository           = github_repository.this.name
  enabled              = true
  allowed_actions      = "selected"
  sha_pinning_required = true

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = false
    patterns_allowed     = var.allowed_actions
  }
}

# Workflows get a read-only token unless one asks for more, and no workflow
# can approve a pull request: approval stays with people.
resource "github_workflow_repository_permissions" "this" {
  repository                       = github_repository.this.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}
