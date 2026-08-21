---
description: Clean up resources owned by the active remote-compute workspace
---

Use the `$remote-compute` skill's cleanup workflow as the authoritative
procedure. This command takes no arguments and acts only on the active
remote-compute worker and current canonical local Git worktree.

Refuse to proceed if the active worker or worktree context is missing or
ambiguous. Do not infer a replacement target or broaden the cleanup scope.
Follow the skill's attribution, deletion-boundary, ordering, external-effects,
and reporting requirements, then report the result.
