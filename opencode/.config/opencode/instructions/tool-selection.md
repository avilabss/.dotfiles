# Prefer task-native tools

Before using a browser or scraping a human-facing page, check the project
instructions and the local environment for a task-native interface. Prefer, in
order of relevance:

1. a configured app/MCP connector or repository-provided tool;
2. an installed first-party CLI with structured output;
3. an official authenticated API;
4. browser or page access when it is genuinely the appropriate interface.

Examples include `glab` for GitLab, `gh` for GitHub, cloud-provider CLIs for
their platforms, and project Make targets or scripts for repository workflows.
Choose based on the actual service and task; do not assume a named tool exists.

Check availability and authentication non-destructively before relying on a
tool. Prefer structured output such as JSON when supported. Never expose
credentials or start installation, authentication, or configuration flows
without the user's authorization.

If the best interface is missing or not configured and it would materially
improve reliability or unblock the task:

- stop repeated browser, scraping, or anti-bot failures;
- name the tool or integration and the capability currently blocked;
- explain the concrete benefit, such as authenticated access to tickets, merge
  requests, diffs, discussions, pipelines, or machine-readable results;
- ask the user to install, connect, or authenticate it, giving the smallest
  appropriate setup or verification step;
- continue with another safe method only when it remains reliable and within
  scope.

Do not request new tooling merely for convenience when an available method is
already reliable. Tool availability does not broaden authorization: continue
to ask before consequential external actions when the user's request has not
already authorized them.
