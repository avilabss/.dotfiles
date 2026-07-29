---
description: Write a concise handoff for continuing in a fresh session
agent: architect
---

Create one handoff for a fresh session. Treat the optional arguments as the
intended focus:

$ARGUMENTS

Write exactly one Markdown file under
`~/.local/state/opencode/handoffs/`. Name it
`YYYY-MM-DD-<short-name>.md`, where `<short-name>` is concise, lowercase,
hyphen-separated, and contains only filesystem-safe ASCII letters and digits.
Derive the name from the focus or objective. Inspect candidate paths first and
never overwrite. Check each exact `.md` candidate in sequence without listing
or globbing the directory. If the preferred path exists, append `-2`, then
`-3`, and so on before `.md` until the path is unused.

Include only what a fresh session needs:

- intended objective;
- current state;
- resolved decisions;
- open decisions, blockers, and unknowns;
- recommended next action;
- references to relevant Task Briefs, issues or tickets, branches, commits,
  diffs, ADRs, documentation, and files; and
- suggested installed commands or skills.

Reference existing artifacts by path or URL instead of reproducing them. Omit
irrelevant sections. Redact credentials, tokens, secrets, customer information,
personally identifiable information, and similarly sensitive data.

Do not modify the active repository or any external system. The single handoff
file is the only permitted write. After writing it, report its absolute path
and tell the user to start a fresh session and reference that path.
