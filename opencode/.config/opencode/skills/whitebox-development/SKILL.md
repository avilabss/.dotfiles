---
name: whitebox-development
description: Develop Whitebox.aero tickets across the core repository and plugin repositories using coordinated Git worktrees, branches, temporary Poetry plugin dependencies, validation, merge requests, and ticket cross-linking. Use when starting, continuing, preparing to push, or raising merge requests for Whitebox ticket implementation that may touch core or plugins.
---

# Whitebox ticket development

## Establish scope

1. Resolve the ticket, acceptance criteria, and requested branch.
2. Inspect the current repository, worktree, branch, status, remotes, existing
   worktrees, and relevant plugin dependencies before changing anything.
3. Identify affected plugins; do not prepare every plugin by default.
4. Preserve unrelated changes and stop on unsafe worktree or branch conflicts.

If this skill is used outside the architect workflow, present the agreed scope
and get approval before changing code.

Use the same requested feature branch name in core and every plugin touched,
unless the ticket explicitly requires a different branch.

## Repository layout

- Parent core worktree: `~/Code/Work/Whitebox/whitebox`
- Parent plugin repositories:
  `~/Code/Work/Whitebox/whitebox/plugins`
- Feature plugin worktrees: the active core feature worktree's `plugins`
  directory

Create plugin worktrees from their corresponding parent repositories. Never use
another feature worktree as the canonical parent.

## Synchronize and prepare worktrees

Before creating or switching feature branches or worktrees:

1. Fetch the latest remote state for the parent core repository.
2. Update the parent core repository's local `main` without discarding changes
   or rewriting history.
3. For each relevant plugin, run `make sync-main` from the parent plugin
   repository.
4. Create feature worktrees from the updated `main`, unless the ticket
   explicitly names another base.
5. Verify every selected worktree is on the requested branch and has the
   expected upstream/base.

Do not overwrite dirty worktrees, delete worktrees, force branches, or repair
divergent history without explicit authorization.

## Develop with local plugin dependencies

When a plugin is modified, add it to the backend
`plugins-temporary` dependency group from inside the backend development
container as an editable local path:

```bash
poetry add -e --group plugins-temporary /plugins/whitebox-plugin-name
```

Do this for every modified plugin. Verify the path and resulting Poetry
configuration and lockfile. Keep editable dependencies during development and
validate cross-repository behavior.

## Prepare a push

Before pushing core changes:

1. Commit and push every touched plugin first.
2. Raise or update each plugin merge request.
3. Replace every editable plugin dependency in core with a Git dependency that
   targets the corresponding plugin MR branch:

   ```bash
   poetry add --group plugins-temporary git+https://gitlab.com/whitebox-aero/whitebox-plugin-name.git#feature/whitebox-1337
   ```

4. Run the command inside the backend development container and verify every
   Git ref names the actual pushed plugin branch.
5. Validate the resulting Poetry configuration and lockfile, then commit and
   push core.

If a plugin changes after a core push, push it first and refresh the core Git
dependency before pushing core again.

If development continues after pushing, switch the dependencies back to
editable local paths. Repeat this push preparation before later core pushes.

## Validate

- Run repository-provided focused tests, linting, and formatting for every
  changed repository.
- Validate core with the touched plugins installed through the dependency mode
  appropriate to the current phase.
- Confirm worktrees, branches, dependency entries, and lockfile changes.
- Report commands run, results, and any validation that could not be performed.

## Merge requests and ticket

Use [references/merge-request-workflow.md](references/merge-request-workflow.md)
as the canonical MR and ticket format.

Creating or updating branches, pushes, merge requests, and tickets changes
external state. Do it only when the user's request authorizes that phase; never
infer authorization merely from inspecting or setting up the ticket.

Do not put ticket-specific refs or paths in persistent configuration, or
permanent dependencies in `plugins-temporary`.
