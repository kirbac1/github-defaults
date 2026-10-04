# The defaults are tested like code: a mocked provider, so no token and no
# network, and assertions on what the module would ask GitHub for.

mock_provider "github" {}

variables {
  name            = "example"
  description     = "An example repository"
  required_checks = ["test"]
}

run "one_way_into_main" {
  command = plan
  module {
    source = "./modules/repository-defaults"
  }

  assert {
    condition = (github_repository.this.allow_squash_merge
      && !github_repository.this.allow_merge_commit
    && !github_repository.this.allow_rebase_merge)
    error_message = "Squash should be the only way to merge."
  }
  assert {
    condition     = !github_repository.this.allow_auto_merge
    error_message = "A person presses merge; auto-merge stays off."
  }
  assert {
    condition     = length(github_repository_ruleset.default_branch.bypass_actors) == 0
    error_message = "Nobody bypasses the default branch rules, the owner included."
  }
  assert {
    condition = (github_repository_ruleset.default_branch.rules[0].deletion
    && github_repository_ruleset.default_branch.rules[0].non_fast_forward)
    error_message = "The default branch can be neither deleted nor force-pushed."
  }
}

run "checks_must_pass_and_come_from_github_actions" {
  command = plan
  module {
    source = "./modules/repository-defaults"
  }

  assert {
    condition     = one(github_repository_ruleset.default_branch.rules[0].required_status_checks[0].required_check).context == "test"
    error_message = "The CI job named in required_checks must be required."
  }
  assert {
    condition     = one(github_repository_ruleset.default_branch.rules[0].required_status_checks[0].required_check).integration_id == 15368
    error_message = "Only GitHub Actions can satisfy a required check."
  }
}

run "workflows_are_read_only_and_pinned" {
  command = plan
  module {
    source = "./modules/repository-defaults"
  }

  assert {
    condition     = github_workflow_repository_permissions.this.default_workflow_permissions == "read"
    error_message = "Workflow tokens should be read-only by default."
  }
  assert {
    condition     = !github_workflow_repository_permissions.this.can_approve_pull_request_reviews
    error_message = "No workflow may approve a pull request."
  }
  assert {
    condition     = github_actions_repository_permissions.this.sha_pinning_required
    error_message = "Actions must be pinned to a commit SHA."
  }
}

run "a_team_needs_a_fresh_approval" {
  command = plan
  module {
    source = "./modules/repository-defaults"
  }
  variables {
    required_approvals = 1
  }

  assert {
    condition = (github_repository_ruleset.default_branch.rules[0].pull_request[0].required_approving_review_count == 1
    && github_repository_ruleset.default_branch.rules[0].pull_request[0].require_last_push_approval)
    error_message = "With reviewers, the last push needs an approval from someone else."
  }
}

run "a_default_branch_without_checks_is_refused" {
  command = plan
  module {
    source = "./modules/repository-defaults"
  }
  variables {
    required_checks = []
  }

  expect_failures = [var.required_checks]
}
