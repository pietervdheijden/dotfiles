---
name: commit
description: Stage, write a clear non-conventional commit message, GPG-sign, and push the current branch.
---

# /commit
1. Run git status and git diff to review changes
2. Stage relevant files (skip unrelated working tree changes)
3. Write a commit message — NEVER invent ticket references; do NOT use Conventional Commits (no `feat:`/`fix:`/`chore:` prefixes)
4. Commit with GPG signing — run outside the sandbox (GPG signing always fails in the sandbox)
5. Push to current branch — NEVER force push. If the push fails with an authorization error, switch GitHub account with `gh auth switch` and retry
