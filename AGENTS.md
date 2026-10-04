# Working in this repository

- Before opening a pull request, run `terraform fmt -recursive`,
  `terraform validate` and `terraform test`. CI runs the same three.
- Never run `terraform apply`. It changes live GitHub settings; a person
  reviews the plan and applies.
- Every default in `modules/repository-defaults/main.tf` has an assertion in
  `tests/repository_defaults.tftest.hcl`. A new default gets one too.
- Actions in workflows are pinned to a full commit SHA, with the tag as a
  comment. The repository's settings refuse anything else.
