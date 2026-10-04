output "repositories" {
  description = "Each managed repository's URL."
  value       = { for name, repo in module.repository : name => repo.url }
}
