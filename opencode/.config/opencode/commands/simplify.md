---
description: Audit an effort for useful simplification before approving changes
agent: architect
---

Audit this effort for useful simplification. This invocation authorizes read-only
inspection and recommendations only, not edits or cleanup.

Optional scope:

$ARGUMENTS

Use that scope, or resolve the active approved effort, its original comparison
bases, all affected repositories and task-owned delta, including uncommitted and
untracked work. State the selected scope and evidence gaps. Ask only if scope is
genuinely ambiguous; do not discover unrelated MRs automatically.

Read and apply developer's [human-readability pass](../agents/developer.md#human-readability-pass)
and [product/tooling/experiment criteria](../agents/developer.md#scope-and-freedom-to-change-code)
to the actual change and relevant consumers across the whole approved boundary.
Explain concrete comprehension or maintenance costs, not a line-count preference.

Return concise, concrete recommendations with reasons and affected areas, or
explicitly report that no useful changes were found. Preserve behavior, safety
checks, useful regression tests, important failure evidence and unrelated work.
Recommend cleanup only for proven task-owned disposable files, never a broad
ignored-file wipe, worker teardown or deletion of shared data.

Wait for user approval before corrections. Architect then scopes, briefs and
delegates them to developer. This audit does not authorize direct implementation,
role/phase bypass, pushes or MR mutations; later edits renew required reviews.
