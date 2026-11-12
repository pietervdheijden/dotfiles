---
name: ship-main
description: Validate and commit the current task's changes and push them directly to main without opening a pull request. Use when the user invokes $ship-main or requests the combined commit-and-push workflow directly to main. Requests for a PR, commit only, or push only retain their own scope.
---

# Ship Main

`$ship-main` is the user's shorthand for: **finish cleanup and validation, commit the current task's changes, and push directly to main**. Complete the workflow and report the published commit.

## Scope and authorization

- Explicit invocation for the current task authorizes task-owned commits and a normal push to `main`. Do not ask again when already authorized. Automatic skill selection alone does not grant authorization; follow the user's actual request and explicit restrictions.
- Target `main`; do not silently substitute another default branch. Do not create a PR or feature branch as part of this workflow.
- Determine task ownership from the conversation and diff. Preserve unrelated changes, staged work, and commits. Ask only when ambiguity prevents selecting the correct changes or remote safely.
- This shorthand does not authorize force-pushing, rewriting published history, deleting branches, changing protection rules, or deployment actions.

## Workflow

1. Read applicable `AGENTS.md` files and any repository delivery guidance for validation and commit conventions. Apply the user's direct-to-main instruction to the delivery route.
2. Inspect the current branch, staged and unstaged changes, recent commits, remotes, and upstream configuration. Select the intended remote and fetch its `main` before deciding what will be published. Inspect all local commits absent from remote `main`, including already committed task work.
3. Prepare the task on local `main`. When switching branches is safe, switch without discarding work; create a tracking local `main` from remote `main` if needed. Carry over only task-owned changes or unpublished task commits. Never merge an entire task branch merely to move a few changes. If unrelated work prevents a safe switch, use an isolated temporary worktree based on remote `main` and preserve the original checkout. Do not reset, clean, or stash unrelated work automatically.
4. Review task changes for correctness, secrets, accidental files, and unnecessary edits. Fix safe cleanup issues, run repository-required checks relevant to the change, and run `git diff --check`. Reuse passing checks when the relevant content has not changed. Fix task-caused failures before publication and disclose unrelated failures accurately.
5. Stage only reviewed task changes, preserving unrelated staged work. Follow repository commit conventions; otherwise use atomic, unscoped Conventional Commit subjects (`fix: ...`, `feat: ...`, etc.), imperative and without bodies, footers, attribution, or ticket references. Skip empty commits when the task is already committed.
6. Before pushing, verify that fetched remote `main` is an ancestor of the prepared commit and review the complete outgoing commit list and diff. Every outgoing commit must belong to the authorized task. If remote changes require integration, preserve local work, reconcile only unpublished task commits onto the latest remote `main`, and rerun affected checks. Stop if ownership or conflict resolution needs user input.
7. Push normally with an explicit destination, such as `git push <remote> HEAD:refs/heads/main`, from the prepared checkout. Never force-push or bypass hooks or branch protections. If a concurrent update rejects the push, fetch and reconcile once when safe, then retry normally; stop after another rejection.
8. Verify that the published commit is present on remote `main`. Report the remote, branch, commit, validation results, and any material remaining work concisely. If an isolated worktree was used, explain where the work ended up and preserve any uncommitted work when cleaning up.

## Stop conditions

If no task changes or unpublished task commits exist, report that there is nothing to ship. If `main` is missing, checks fail, authentication or permissions block access, or branch protection requires a PR, preserve the work and report the exact blocker. Do not silently switch to a PR workflow or claim an unverified success.
