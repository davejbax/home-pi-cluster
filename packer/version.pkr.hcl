packer {
  required_plugins {
    git = {
      version = ">= 0.5.0"
      source  = "github.com/ethanmdavidson/git"
    }
  }
}

data "git-commit" "cwd" { }

locals {
  current_git_hash = substr(data.git-commit.cwd.hash, 0, 8)

  version = coalesce(var.version, local.current_git_hash)
}