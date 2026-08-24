---
description: Explicitly clean up the active remote-compute worker
---

Use the `$remote-compute` skill's cleanup workflow as the authoritative
procedure. This command takes no arguments. It uses the active remote-compute
worker and current canonical local Git worktree as the verified context for the
skill's cleanup.

Refuse to proceed if the active worker or worktree context is missing or
ambiguous. Do not infer a replacement target. Follow the skill's attribution,
deletion-boundary, ordering, external-effects, and reporting requirements, then
report the result.
