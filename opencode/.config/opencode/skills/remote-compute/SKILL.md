---
name: remote-compute
description: Use `$remote-compute user@host` to activate a session-wide SSH worker for subsequent resource-heavy commands while keeping the local Git worktree authoritative.
---

# Remote compute

## Activate and delegate

`$remote-compute user@host` activates remote-compute mode for the rest of the
current session. Treat `user@host` as one quoted SSH destination. Ask only when
the destination is missing or ambiguous.

Confirm SSH access and the tools needed for the intended work before using the
worker. Stop and report any failed check rather than changing the worker. A
later invocation with another destination switches workers after these checks.

Never persist or reuse a worker across sessions. Activation does not stop,
migrate, or restart work already running locally.

Under the architect workflow, carry the active worker and remote-execution
constraint into the Task Brief. The architect runs no implementation commands;
the executing agent applies this workflow.

## Prepare and synchronize

Resolve the canonical local Git worktree and derive a stable identifier from
its canonical path. Use only the resulting isolated child beneath this fixed
remote base:

```text
$HOME/.opencode-remote-compute/worktrees/<workspace-id>
```

Create a temporary local snapshot from existing tracked files and nonignored
untracked files. Exclude `.git`, likely secrets, submodules, and ignored nested
repositories unless a specific input is explicitly needed. Review any such
input before narrowly including it. These exclusions reduce exposure but are
not exhaustive secret detection.

Synchronize the snapshot to the computed child with ordinary rsync. Deletion is
allowed only against that child so local deletions and renames are reflected;
never use deletion against the fixed base, remote home, or another destination.

## Execute

Keep edits, source inspection, and Git state in the local worktree. Refresh the
snapshot as needed, then run applicable builds, tests, Docker, FFmpeg, and
similar resource-heavy commands from the remote child. Do not treat remote
source changes as authoritative.

Do not automatically clean up the remote child or stop persistent work.

## Report

Report failed access, tool, synchronization, and execution checks with enough
context for the user to act.

If a workload is intentionally left running, report the worker, workspace,
workload identity, and how to inspect its status or logs and stop it.
