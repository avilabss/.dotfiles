---
description: Explicitly tear down the active remote-compute worker
---

Invoke the `$remote-compute` skill's whole-worker teardown contract. This
command takes no arguments and uses only the skill's verified active worker and
canonical local Git worktree context. Do not infer a missing or ambiguous
target; follow the skill's external-system boundaries and reporting contract.
