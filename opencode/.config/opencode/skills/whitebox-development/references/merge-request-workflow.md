# Whitebox merge request and ticket workflow

Read this reference when preparing, creating, or updating Whitebox merge
requests or their parent ticket.

## Preparation and authority

Prepare the complete repository/ref inventory and review evidence using
[the development skill](../SKILL.md) before publication. For existing MRs, resolve
the [ReviewBundle](../../whitebox-review/SKILL.md#resolve-the-reviewbundle-first)
rather than assuming proposed links are real. Record original comparison bases
and exact reviewed revisions/state across the effort, including relevant
unchanged providers/consumers. Individual repository or task approvals do not
replace cumulative review.

A local draft or readiness report authorizes no external action. Pushes, MR
creation/updates, feedback posting, ticket edits, and approvals each remain
subject to the user's authorized scope. An explicitly authorized early/draft
submission is allowed with incomplete readiness clearly labeled and missing
checks identified; do not represent it as final approval. `/wb-review` remains
strictly read-only even when it produces a report suitable for later publication.

## Ordering

1. Commit and push every touched plugin.
2. Create or update every plugin MR.
3. Point core `plugins-temporary` dependencies at the pushed plugin MR branches.
4. Commit and push core.
5. Create or update the core MR.
6. Cross-link the core MR, plugin MRs, and ticket.

Never publish a core ref to an unpushed plugin commit or branch.

## Plugin MR description

Use only this relationship block as the plugin MR description:

```md
PARENT: https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx

___

KERNEL: #<branch-name>
```

Replace both placeholders. `PARENT:` points to the core MR. `KERNEL:` names the
core feature branch required by plugin CI. Keep the spelling and capitalization
exact.

## Core MR description

Read the current core `.gitlab/merge_request_templates/default.md` and consolidate
the ticket's core, plugin, and library changes there. Use its existing sections,
not a second readiness form:

- **What**: concrete affected behavior and contracts, with per-repository scope.
- **Why / How**: the problem, chosen approach, compatibility expectations and
  tradeoffs, and links to tracked decisions/contracts. For substantial changes,
  give a reading order across repositories and identify the risky paths. The MR
  summarizes durable rationale rather than being its only home.
- **Testing**: put reproducible setup and commands in Developer Testing
  Instructions, with prerequisites, working directories, dependency mode,
  revisions/lock state and artifact identities. Include expected outcomes and
  actual evidence, distinguishing execution from inspection. Use Sandbox Testing
  Instructions for applicable product-review steps and Common Testing
  Instructions to avoid repetition. Do not manually edit the auto-managed
  Sandbox Hosting section.
- **Anything Else?**: missing checks with owners/next actions, known risks,
  unsupported combinations and recovery limits, and the current readiness state.
  Required missing evidence is a blocker, not a passed check.

Update the existing `Related MRs` section immediately after `What`; add it there
only if absent:

```md
## Related MRs

- https://gitlab.com/whitebox-aero/whitebox-plugin-name/-/merge_requests/xxx
```

List every related plugin/library MR once and omit the section when there are
none. Keep all consolidated explanation and per-repository reading/testing
guidance here, not in relationship-only plugin descriptions.

Preserve the project's Before Merge Checklist: testing, documentation where
applicable, two code reviews with no outstanding comment, product review for
user-facing changes, and internal dependency version bumps where applicable.
Do not check review boxes merely because internal AI reviews passed. Report
author understanding only after explicit human confirmation; AI review neither
certifies that understanding nor replaces project code/product review.

## Ticket

Add an `MRs` section at the top of the original ticket and list the core MR
followed by every related plugin MR:

```md
## MRs

- https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx
- https://gitlab.com/whitebox-aero/whitebox-plugin-name/-/merge_requests/xxx
```

Preserve the rest of the ticket exactly unless another change is explicitly
requested. Check for an existing `MRs` section and update it instead of adding
a duplicate.

Before finishing, check the links, branch names, dependency refs, and duplicate
sections.
