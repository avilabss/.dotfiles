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
