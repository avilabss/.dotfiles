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

Restate the ticket link, branch name, and additional context. If the ticket link
or branch name is missing or ambiguous, ask for it.

Follow the complete `$whitebox-development` workflow and verify that relevant
local plugin worktrees and dependency setup are usable before implementation.
Do not push, create merge requests, or update the ticket unless requested.
