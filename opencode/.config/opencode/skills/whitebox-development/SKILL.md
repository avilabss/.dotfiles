---
name: whitebox-development
description: Develop Whitebox.aero tickets across the core repository and plugin repositories using coordinated Git worktrees, branches, temporary Poetry plugin dependencies, validation, merge requests, and ticket cross-linking. Use when starting, continuing, preparing to push, or raising merge requests for Whitebox ticket implementation that may touch core or plugins.
---

# Whitebox ticket development

Coordinate a Whitebox ticket across core and every affected plugin without
mixing parent repositories, feature worktrees, branches, or dependency modes.

## Establish scope

1. Resolve the ticket, acceptance criteria, requested branch, and supplied
   context. Ask only for required information that cannot be discovered.
2. Inspect the current repository, worktree, branch, status, remotes, existing
   worktrees, and relevant plugin dependencies before changing anything.
3. Identify plugins as relevant from ticket requirements, code references,
   dependency configuration, or implementation evidence. Do not synchronize or
   create worktrees for every plugin by default.
4. State the core and plugin worktrees selected. Preserve unrelated user
   changes and stop if an existing worktree or branch creates an unsafe
   conflict.

Use the same requested feature branch name in core and every plugin touched,
unless the ticket explicitly requires a different branch.

## Repository layout

- Parent core worktree: `~/Code/Work/Whitebox/whitebox`
- Parent plugin repositories:
  `~/Code/Work/Whitebox/whitebox/plugins`
- Feature plugin worktrees: the active core feature worktree's `plugins`
  directory

Create or reuse each feature plugin worktree from its corresponding parent
plugin repository. Never treat another feature worktree as the canonical
parent repository.

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

Do this for every modified plugin. Verify that the container path resolves to
the intended feature plugin worktree and that the resulting Poetry
configuration and lockfile contain the expected dependency.

Keep editable dependencies while actively developing so core exercises the
local plugin changes. Implement and validate the complete cross-repository
behavior, not each repository in isolation.

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

If plugin commits change after a core push, push the plugins first and refresh
the core Git dependencies before the next core push.

If development continues after pushing, switch the dependencies back to
editable local paths. Repeat the plugin-first ordering and Git-ref conversion
before each later core push.

## Validate

- Run repository-provided focused tests, linting, and formatting for every
  changed repository.
- Validate core with the touched plugins installed through the dependency mode
  appropriate to the current phase.
- Confirm worktree paths, branches, plugin dependency entries, and lockfile
  changes before reporting readiness.
- Report commands run, results, and any validation that could not be performed.

## Merge requests and ticket

Before composing or changing merge requests or the ticket, read
[references/merge-request-workflow.md](references/merge-request-workflow.md).
Use that file as the canonical format for cross-links and descriptions.

Creating or updating branches, pushes, merge requests, and tickets changes
external state. Do it only when the user's request authorizes that phase; never
infer authorization merely from inspecting or setting up the ticket.

## Non-goals

- Do not review completed MRs with this skill; use `whitebox-review`.
- Do not encode ticket-specific URLs, branch names, or temporary worktree paths
  into persistent configuration.
- Do not move permanent plugin dependencies into `plugins-temporary`.
- Do not hide missing validation, unresolved dependency refs, or dirty
  worktrees.
