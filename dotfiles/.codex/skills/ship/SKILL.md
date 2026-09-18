---
name: ship
description: Create or reuse a task branch, validate and commit the current task's changes, push, and open or update a GitHub pull request. Use when the user invokes $ship, says "ship this", or requests the combined branch/commit/push/PR workflow. A standalone review, commit-only, or push-only request retains its narrower scope.
---

# Ship

`$ship` is the user's shorthand for: **create a branch if needed, finish cleanup and validation, commit, push, and open a PR**. Complete the workflow and return the PR link.

## Scope and authorization

- Explicit invocation for the current task authorizes branch creation, task-owned commits, a normal push, and PR creation or updates. Do not ask for those permissions again when already authorized. Automatic skill selection alone does not grant authorization; follow the user's actual request.
- Honor explicit restrictions and overrides, such as "draft", a chosen branch name, or "commit only".
- This shorthand does not authorize merging, deployment, force-pushing, rewriting history, deleting branches, or pushing directly to the default branch.
- Determine task ownership from the conversation and diff. Preserve unrelated changes and staged work. Ask only when ambiguity prevents selecting the correct changes or remote safely.

## Workflow

1. Read applicable `AGENTS.md` files. If the repository supplies a `git-delivery` skill, read and use it for cleanup, validation, commit conventions, and PR writing. Otherwise use the fallback below.
2. Inspect the current branch, staged and unstaged changes, recent commits, remotes, default/base branch, and any existing PR. Include already committed task work in the proposed PR scope.
3. Reuse the current branch when it belongs to this task. On the default branch, create and switch to a short descriptive feature branch in the current checkout, retaining the task's changes and commits. Respect repository branch naming rules. If the branch belongs to another task, avoid carrying unrelated commits into the PR; resolve scope before publishing. Do not create a worktree unless requested.
4. Review and validate task-owned changes. Fix safe cleanup issues directly. Stage only reviewed task changes and commit when needed; skip an empty commit if the work is already committed. Reinspect the complete base-to-head diff before publication.
5. Push the task branch normally, setting upstream when needed. Use the repository's GitHub tooling; in Halo, run `gh` outside the sandbox as instructed by the repository guide.
6. Reuse an existing PR for the branch, updating its description when the final scope changed. Otherwise open a ready-for-review PR against the appropriate base, unless the user requested a draft. Inspect any PR template and write multiline bodies through a structured tool argument or `gh --body-file`.
7. Verify the remote branch and PR URL. Report the PR link, branch, commit, validation results, and any material blocker or remaining task work concisely.

## Fallback when no repository delivery skill exists

- Review the final diff for correctness, secrets, local environment files, accidental changes, and unnecessary comments or tests. Preserve meaningful behavior coverage; do not delete tests just to make checks pass.
- Run relevant package formatters and narrow lint, typecheck, and tests required by repository guides and manifests, plus `git diff --check`. Reuse passing checks from this session when no relevant changes have occurred since. Fix task-caused failures before publishing; disclose unrelated failures accurately.
- Follow repository commit conventions. When unspecified, use atomic, unscoped Conventional Commit subjects (`fix: ...`, `feat: ...`, etc.), imperative and without bodies, footers, attribution, or ticket references.
- Describe the concrete problem, resulting behavior, and verification in the PR. For fixes, explain the rationale, give before/after examples where useful, and state compatibility impact. Include issue links and UI evidence when relevant.

## Stop conditions

If no task changes or unpublished task commits exist, report that there is nothing to ship. If checks, permissions, authentication, or a rejected push block completion, preserve the work, complete safe preparation, and report the exact blocker. Never bypass hooks or protection rules, force-push, or claim an unverified success to finish the workflow.
