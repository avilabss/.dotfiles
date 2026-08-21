---
description: Review one Whitebox merge request and report findings locally
---

Use the `$whitebox-review` skill as the authoritative source for Whitebox
ReviewBundle discovery and architecture-aware analysis.

Invocation:

```text
/wb-review <merge-request-url>
```

Arguments:

$ARGUMENTS

Require one unambiguous Whitebox merge-request URL. If it is missing, is not
clearly a Whitebox merge-request URL, or the arguments could identify more than
one merge request, ask the user for the one URL and stop. Do not guess.

This workflow is read-only. It may inspect the merge request, related merge
requests, repositories, issue context, diffs, and other evidence needed by the
skill. Do not edit reviewed source files or mutate Git working trees. Do not
post comments or discussions, approve, merge, label, assign, update tickets, or
otherwise mutate GitLab or any external system.

Return the report only in the current OpenCode session. Do not state or imply
that any feedback was posted externally.

Begin with concise `Review scope` and `ReviewBundle and readiness` sections.
Then include only actionable findings, sorted by severity in this exact order:
`critical`, `high`, `medium`, `low`. Omit empty severity sections and omit
speculative, non-actionable, or purely stylistic findings.

For every finding, include:

- the lowercase severity and a short descriptive title;
- the repository-relative file path and exact line number or narrow line range;
- a plain-language comment explaining the defect and why it matters; and
- reproduction evidence or a concrete theoretical failure scenario.

When useful, give specific commands, code, API actions, or UI steps for the
reproduction. Use short, understandable sentences rather than compressing the
comment into a complicated one-liner.

If there are no actionable findings, say so clearly. Always end with
`Residual risks and validation gaps`, including meaningful remaining risks or
gaps, or `None identified` when there are none.
