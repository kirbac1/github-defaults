# github-defaults

GitHub repository defaults as Terraform. Every repository listed in
[`defaults.auto.tfvars`](defaults.auto.tfvars) gets the same rules, and
`terraform apply` puts them back if someone changes one by hand.

| Default | Why |
|---|---|
| Squash is the only merge, titled after the pull request; branches deleted after merging | One readable line per change on `main` |
| No auto-merge | A person presses merge |
| `main` can't be deleted or force-pushed; history stays linear | What happened stays what happened |
| `main` changes only through a pull request; stale approvals are dismissed; review threads must be resolved | Review happens on the code that merges |
| Required status checks, up to date with `main`, and only from GitHub Actions | A red build can't merge, and no other app can post a green check with the same name |
| No bypass actors | The rules hold for the owner too, and so for an agent using the owner's token |
| Workflow tokens are read-only by default, and no workflow can approve a pull request | Approval stays with people |
| Only GitHub's own actions and the listed ones run, each pinned to a commit SHA | A tag can be moved, or never have existed |
| Vulnerability alerts on | |
| `terraform destroy` archives instead of deleting | Undoable |

For a team, set `required_approvals = 1`. With it, the last push to a pull
request needs an approval from someone other than whoever pushed it, so
nobody, person or agent, approves their own change.

## What it can't do for one person

With one account, GitHub can't tell your pushes from an agent's using your
token, and there is nobody else to approve. So approvals default to 0: every
change still goes through a pull request with green checks, but the decision
to merge is held by habit and by
[devloop-gateway](https://github.com/kirbac1/devloop-gateway), which offers
agents no merge tool, rather than by GitHub. In an organisation the agent gets
its own identity, a GitHub App with no bypass, and `required_approvals = 1`
makes the gate real.

## Use it

```bash
export GITHUB_TOKEN=$(gh auth token)
terraform init
terraform plan    # the first plan imports each repository as it is, and shows only what changes
terraform apply
```

Repositories are adopted, not created: [`main.tf`](main.tf) imports each one
on the first plan, so the plan reads as a diff of settings. Adding a
repository is one entry in `defaults.auto.tfvars`; its `required_checks` are
the job names in its CI workflow.

## Tested

`terraform test` checks the module against a mocked provider, with no token
and no network: one way into `main`, no bypass, required checks from GitHub
Actions only, read-only and SHA-pinned workflows, a fresh approval for teams,
and that a branch without required checks is refused. Breaking a default
turns its test red with the reason; that was tried before trusting them.

CI runs `fmt`, `validate` and `test` on every pull request. It doesn't apply:
that needs an admin token, and stays a person's step.

## State

Local and ignored by git, because it holds the provider's view of every
repository. A team would keep it in a remote backend with locking.

## Not built yet

- **Organisation rulesets.** One ruleset for every repository in an
  organisation instead of one per repository; needs an organisation.
- **Apply from CI.** Plan on the pull request, apply on merge, through a
  GitHub App instead of a person's token.
- **Drift detection.** A scheduled plan that fails when a setting was changed
  by hand.
- **CODEOWNERS** managed alongside the rules, so the right reviewers are asked.
