# Prefer task-native tools

Before using a browser, prefer:

1. a configured app/MCP connector or repository-provided tool;
2. an installed first-party CLI with structured output;
3. an official authenticated API;
4. browser access.

Examples include `glab` for GitLab, `gh` for GitHub, cloud-provider CLIs for
their platforms, and repository Make targets or scripts.

Check availability and authentication non-destructively before relying on a
tool. Prefer structured output. Do not expose credentials or install,
authenticate, or configure tools without authorization.

If the best interface is missing or not configured and it would materially
improve reliability or unblock the task, explain the blocked capability and ask
the user to install, connect, or authenticate it. Do not request new tooling
when an available method is reliable.

Tool availability does not authorize consequential external actions.

## Process lifecycle

- Run builds, tests, migrations, and similar task commands in the foreground.
  When legitimate work exceeds the default timeout, set an explicit longer
  timeout instead of using `&`, `nohup`, `disown`, or `setsid` merely to avoid
  waiting.
- Start a persistent background process, service, or container only when the
  approved task requires it. Record how it was started and how to stop it, and
  stop it before completion unless the user explicitly wants it left running.
- After an interruption or timeout that may have spawned workers, check for and
  clean up owned leftovers before retrying.
