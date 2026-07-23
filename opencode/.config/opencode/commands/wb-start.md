---
description: Start or continue a Whitebox ticket across core and plugins
---

Use the `$whitebox-development` skill to start or continue this Whitebox
ticket.

The command arguments must provide:

- the ticket link,
- the branch name to use for core and every plugin touched,
- optional additional context.

Arguments:

$ARGUMENTS

Parse and restate the ticket link, branch name, and additional context before
acting. If the ticket link or branch name is missing or ambiguous, ask for it.
Do not invent either value.

Inspect the current repository and worktree state, resolve the ticket and
acceptance criteria, identify the relevant core/plugin repositories, and
follow the complete `$whitebox-development` workflow. Ensure the development
environment works with local plugin changes before implementation.

Preserve unrelated changes. Do not delete or overwrite worktrees, force
branches, rewrite history, push, create merge requests, or update the ticket
unless the user's request authorizes that action.
