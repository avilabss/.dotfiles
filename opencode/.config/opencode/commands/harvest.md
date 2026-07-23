---
description: Review a completed ticket for reusable development knowledge
---

Perform a reusable-knowledge review for this completed ticket.

Optional scope or context supplied with the command:

$ARGUMENTS

Review:

- the original ticket and acceptance criteria,
- the final implementation and diff,
- tests and validation performed,
- investigation steps, mistakes, retries, and dead ends,
- existing `AGENTS.md` files and project documentation,
- existing commands, snippets, templates, and skills.

Use only evidence available in the current session, repository, ticket,
version-control history, and supplied references. Clearly label inferences. Do
not invent missing acceptance criteria, investigation history, mistakes,
retries, or validation.

If the implementation scope is not supplied, identify it from the session and
repository state and state what you selected. Do not silently include unrelated
working-tree changes. If required evidence is unavailable, identify the gap,
lower confidence as appropriate, and continue with the available evidence.

Do not assume that any new artifact is necessary. Zero recommendations is a
valid and preferable result when the evidence is weak. Do not fill the quota
with speculative or low-value learnings.

Identify up to 3 learnings that would materially improve future development
work. For each learning, recommend exactly one primary destination:

- `NO_ACTION`
- `UPDATE_AGENTS_MD`
- `UPDATE_PROJECT_DOCS`
- `NEW_OR_UPDATE_SKILL`
- `NEW_OR_UPDATE_COMMAND`
- `NEW_OR_UPDATE_SNIPPET`
- `NEW_OR_UPDATE_TEMPLATE`
- `TEST_LINTER_OR_AUTOMATION`

Choose the smallest and most maintainable destination.

Use these guidelines:

## `UPDATE_AGENTS_MD`

Use for stable, broadly applicable project instructions that agents should
know during most relevant work. Examples include repository-wide conventions,
required validation commands, architectural boundaries, and important rules.
Do not add ticket history, rare edge cases, temporary workarounds, or lengthy
tutorials. Keep `AGENTS.md` concise.

## `NEW_OR_UPDATE_SKILL`

Use for contextual, multi-step knowledge that should be loaded only when a
particular type of task is being performed. A skill must have a clear trigger,
repeatable procedure, validation criteria, and explicit non-goals.

## `NEW_OR_UPDATE_COMMAND`

Use for a repeatable workflow that a developer intentionally invokes, such as
a release review, migration preparation, debugging checklist, or ticket
handoff. Specify required inputs, steps, expected output, and safety checks.

## `NEW_OR_UPDATE_SNIPPET`

Use for a small reusable code, query, configuration, or text pattern. Specify
the language or format, placeholders that must be replaced, assumptions, usage
example, and validation steps. Do not propose snippets that would be unsafe to
copy without understanding.

## `NEW_OR_UPDATE_TEMPLATE`

Use for a recurring document or artifact with a stable structure, such as a
migration plan, incident summary, implementation proposal, or pull request
description.

## `UPDATE_PROJECT_DOCS`

Use for explanatory material that developers may need to look up, but which
does not need to be present in every agent session.

## `TEST_LINTER_OR_AUTOMATION`

Use when the learning describes a deterministic rule that can be enforced or
checked mechanically. Prefer enforcement over prose whenever practical.

## `NO_ACTION`

Use when the learning is obvious, ticket-specific, unlikely to recur,
temporary, already documented, or too uncertain to preserve.

Before proposing anything:

1. Check whether an equivalent instruction or artifact already exists.
2. Prefer updating an existing artifact over creating a new one.
3. Avoid duplicating the same knowledge across `AGENTS.md`, skills, commands,
   snippets, and documentation.
4. Exclude secrets, credentials, customer information, temporary filenames,
   branch names, ticket-specific identifiers, and accidental implementation
   details.
5. Consider how likely the recommendation is to become stale.
6. Require credible recurrence or unusually high impact; a learning is not
   durable merely because it occurred once.

Start with:

## Verdict

- Recommendations: `<0-3>`
- Overall confidence: `<low|medium|high>`
- Evidence gaps: `<none or concise list>`
- Artifacts checked for duplication: `<concise list>`

For each recommendation, return:

- Learning
- Recommended destination
- Confidence: low, medium, or high
- Evidence, labeled by source such as `SESSION`, `TICKET`, `DIFF`,
  `TEST_OUTPUT`, or `EXISTING_ARTIFACT`
- Expected recurrence
- Why this destination is appropriate
- Why the other likely destinations are less appropriate
- Existing artifact to update, if any
- Proposed content or patch
- Validation criteria
- Staleness and maintenance risks

Additional requirements by destination:

For an `AGENTS.md` update:

- exact file and section,
- concise proposed diff,
- tasks for which the instruction applies,
- evidence that it is broadly applicable.

For a command:

- proposed name,
- purpose,
- invocation examples,
- inputs,
- workflow,
- output format,
- failure and safety behavior.

For a snippet:

- proposed name,
- language or format,
- placeholders,
- assumptions,
- snippet content,
- usage example,
- validation steps.

For a skill:

- proposed name,
- project or personal scope,
- trigger description,
- instructions,
- validation checks,
- non-goals.

Do not modify files or external systems. Produce proposals only.
