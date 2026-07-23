# Whitebox merge request and ticket workflow

Read this reference when preparing, creating, or updating Whitebox merge
requests or their parent ticket.

## Ordering

1. Commit and push every touched plugin.
2. Create or update every plugin MR.
3. Point core `plugins-temporary` dependencies at the pushed plugin MR branches.
4. Commit and push core.
5. Create or update the core MR.
6. Cross-link the core MR, plugin MRs, and ticket.

Never publish a core ref to an unpushed plugin commit or branch.

## Plugin MR description

Use the default MR template, then keep the plugin-specific description short.
The required relationship block is:

```md
PARENT: https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx

___

KERNEL: #<branch-name>
```

Replace both placeholders. `PARENT:` points to the core MR. `KERNEL:` names the
core feature branch required by plugin CI. Keep the spelling and capitalization
exact.

Put the full ticket-level explanation in the core MR. Include details in a
plugin MR only when they are necessary to understand, validate, or safely
review that plugin's change.

## Core MR description

Use the core repository's `default` MR template and fill it with the relevant
ticket details. Keep it concise without omitting behavior, validation,
operational impact, or reviewer-critical context.

Immediately after the template's `What` section, add:

```md
## Related MRs

- https://gitlab.com/whitebox-aero/whitebox-plugin-name/-/merge_requests/xxx
```

List every plugin MR and omit the section when there are none. Do not duplicate
the same detailed explanation across core and plugin descriptions.

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

## Final checks

- Every plugin MR links to the correct core MR and kernel branch.
- The core MR lists every plugin MR under `Related MRs`.
- The ticket lists the core MR and all plugin MRs once.
- Core Git dependencies match the plugin MR repositories and pushed branches.
- No placeholder URLs, branch names, duplicated sections, or stale links
  remain.
