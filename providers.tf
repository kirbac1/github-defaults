# The token comes from the environment, never from a file:
#   export GITHUB_TOKEN=$(gh auth token)
provider "github" {
  owner = var.owner
}
