---
description: Review a completed ticket for reusable development knowledge
---

Review the completed ticket for reusable knowledge.

Optional scope:

$ARGUMENTS

Use evidence from the session, ticket, diff, tests, history, and existing
project artifacts. State the selected scope and any evidence gaps. Do not
include unrelated working-tree changes or invent missing history.

Recommend at most three durable, recurring improvements. Zero is preferable to
weak or speculative recommendations. Check for existing guidance first and
prefer updating it over creating a duplicate.

Choose one destination per recommendation:

- `UPDATE_AGENTS_MD`: concise, broadly applicable project rules
- `UPDATE_PROJECT_DOCS`: explanatory material developers can look up
- `NEW_OR_UPDATE_SKILL`: contextual multi-step workflows
- `NEW_OR_UPDATE_COMMAND`: intentionally invoked workflows
- `NEW_OR_UPDATE_SNIPPET`: small reusable code or text patterns
- `NEW_OR_UPDATE_TEMPLATE`: recurring documents with a stable structure
- `TEST_LINTER_OR_AUTOMATION`: deterministic, mechanically enforceable rules
- `NO_ACTION`: obvious, ticket-specific, temporary, duplicated, or uncertain

Exclude secrets, customer data, temporary names, ticket-specific identifiers,
and details likely to become stale.

Start with:

## Verdict

- Recommendations: `<0-3>`
- Confidence: `<low|medium|high>`
- Evidence gaps: `<none or concise list>`
- Existing artifacts checked: `<concise list>`

For each recommendation include:

- Learning and evidence source (`SESSION`, `TICKET`, `DIFF`, `TEST_OUTPUT`, or
  `EXISTING_ARTIFACT`)
- Destination and confidence
- Expected recurrence
- Why this destination fits better than the likely alternatives
- Existing artifact to update, if any
- Proposed content or patch
- Validation and staleness risks

Make proposed content usable: identify the file/section for `AGENTS.md`;
name and specify invocation, inputs, workflow, output, and safety for commands;
include format, placeholders, content, example, and validation for snippets;
include scope, trigger, instructions, validation, and non-goals for skills.

Do not modify files or external systems.
