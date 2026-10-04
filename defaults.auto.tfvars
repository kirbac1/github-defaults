owner = "kirbac1"

repositories = {
  "devloop-gateway" = {
    description     = "An MCP server and CLI that give people and coding agents one checked path through the development loop."
    topics          = ["mcp", "developer-experience", "ci", "ai-agents"]
    required_checks = ["test"]
    allowed_actions = ["astral-sh/setup-uv@*"]
  }

  "github-defaults" = {
    description     = "GitHub repository defaults as Terraform: one way into main, required checks, read-only workflow tokens."
    topics          = ["terraform", "github", "developer-experience"]
    required_checks = ["terraform"]
    allowed_actions = ["hashicorp/setup-terraform@*"]
  }

  # Adding a repository is one entry. Its required_checks are the job names in
  # its CI workflow, and from then on main changes only through a pull request.
}
