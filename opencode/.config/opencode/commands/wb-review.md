---
description: Review one Whitebox effort from work-item or MR URLs locally
---

This command owns OpenCode input handling and resolution of discovery seeds
into one implementation effort. Use the `$whitebox-review` skill as the
authoritative source for portable ReviewBundle rules and Whitebox
architecture-aware analysis; do not duplicate its architecture procedure here.

Invocation:

```text
/wb-review <work-item-url>
/wb-review <work-item-url> <work-item-url> [...]
/wb-review <merge-request-url>
/wb-review <work-item-url> <merge-request-url> [...]
```

Arguments:

$ARGUMENTS

Treat each supplied URL as a discovery seed. Require at least one unambiguous
Whitebox ticket/work-item or merge-request URL. Work-item URLs are the primary
input; direct merge-request URLs remain supported. Ticket and merge-request
URLs may be mixed. Normalize equivalent duplicate URLs and retain each unique
seed once without changing its project or resource identity.

If no supported URL is present, or any argument is unsupported or ambiguous,
ask for clarification and stop. Do not guess a URL, project, resource type, or
relationship from a bare ID, title, branch, or surrounding text.

Before detailed review, resolve the complete ReviewBundle in this order:

1. Read every supplied ticket's scope, ticket-specific acceptance criteria,
   branch or implementation references, and linked MRs. Read every supplied
   MR's project and source/target branches, metadata, description, and
   relationship evidence.
2. Build a combined review scope that identifies every seed. Retain each
   ticket's acceptance criteria separately. Reconcile the seeds into one
   implementation effort and verify that every supplied ticket and MR belongs
   to it.
3. If the seeds resolve to unrelated efforts, incompatible implementation
   branches, or different canonical core MRs, stop before detailed review. Give
   a clear conflict report mapping each conflicting seed to the evidence; do
   not silently drop a seed or combine the efforts.
4. Resolve the canonical core MR in `whitebox-aero/whitebox`. Then discover
   associated plugin/library MRs from every ticket's `MRs` section, the core
   MR's `Related MRs` section, plugin `PARENT:` and `KERNEL:` blocks,
   `backend/pyproject.toml` `plugins-temporary` dependency refs, branch
   correlation, and reverse links plus work-item context when explicit links
   are incomplete. Follow newly discovered evidence in both directions,
   normalize duplicates, and retain the evidence source for each relationship.
5. Validate that ticket references, the core and plugin branches, plugin
   parents, `KERNEL:` values, temporary dependency refs, and all discovered MRs
   agree. Missing or contradictory links are ReviewBundle/readiness findings;
   make them visible rather than inventing a relationship or excluding the
   conflicting evidence.
6. If exhaustive discovery finds no core MR, use the skill's existing core
   `main` fallback only when appropriate. State clearly that no complete parent
   MR was found. Do not use the fallback to hide conflicting effort or branch
   evidence.

Finish the complete ReviewBundle before detailed review. It must identify the
combined ticket scope and per-ticket acceptance criteria. Required contents
also include the canonical core MR or explicit core-`main` fallback, all
deduplicated plugin/library MRs, relevant branches and temporary dependency
refs, relationship evidence, and unresolved readiness findings. Then apply
`$whitebox-review` for the architecture-aware analysis.

This workflow is read-only. It may inspect the merge request, related merge
requests, repositories, work-item context, diffs, and other evidence needed by
the skill. Do not edit reviewed source files, mutate Git working trees or
branches, or change dependencies. Do not create or repair links; post comments
or discussions; approve, merge, label, or assign; update tickets; or otherwise
mutate GitLab or any external system.

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
`Residual risks and validation gaps`. Include meaningful remaining risks or
gaps, or `None identified` when there are none.
