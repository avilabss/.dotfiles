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

Inspect the actual change and relevant consumers before recommending anything.
Use the developer's existing [human-readability pass](../agents/developer.md#human-readability-pass)
across the whole approved review boundary. Look for unnecessary abstractions or
options, duplicated paths/tests/docs, dead scaffolding, temporary diagnostics and
artifacts, missing maintenance explanation, and MR-description clutter. Fewer
lines is not inherently simpler. Comments should explain useful why/invariants,
not syntax; no comment or deletion quotas.

Return concise, concrete recommendations with reasons and affected areas, or
explicitly report that no useful changes were found. Preserve behavior, safety
checks, useful regression tests, important failure evidence and unrelated work.
Recommend cleanup only for proven task-owned disposable files, never a broad
ignored-file wipe, worker teardown or deletion of shared data.

Wait for user approval of recommendations before any changes. Architect still
scopes, briefs and delegates approved corrections to developer; this command does
not authorize direct implementation or bypass role/phase boundaries. Subsequent
edits renew required reviews. No push or MR mutation authority is implied.
