---
name: remote-compute
description: Use `$remote-compute user@host` to run all project execution on a session-scoped SSH worker while keeping the current local Git worktree authoritative.
---

# Remote compute

## Activate and scope

`$remote-compute user@host` activates remote-compute mode for the rest of the
current session and only for the current canonical local Git worktree. Treat
`user@host` as one quoted SSH destination. Ask only when the destination or
worktree is missing or ambiguous.

Resolve the canonical worktree path and derive a stable, collision-resistant
workspace identifier from it. Keep the active worker, canonical path, workspace
identifier, and exact remote child as the session's remote-compute context. Do
not apply that context to another worktree or persist or reuse it across
sessions.

Confirm SSH access and the tools needed for the intended work before using the
worker. Stop and report any failed check rather than changing the worker. A
later invocation with another destination switches workers after these checks.

Activation and worker switching do not stop, migrate, or restart existing work.
Report any attributable persistent work left on the previous worker.

Under the architect workflow, carry the active worker and remote-execution
constraint into the Task Brief. The architect runs no implementation commands;
the executing agent applies this workflow.

## Prepare and synchronize

Use only the isolated child for the active workspace beneath this fixed remote
base:

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

While mode is active, keep only authoritative source editing and inspection,
Git state, snapshot creation, synchronization, and lightweight coordination
local. Coordination includes deriving paths and identities, checking SSH and
tools, invoking commands on the worker, and reporting results; it must not run
the project locally.

Run every project execution command from the exact remote child. This includes
builds, tests, linting, formatting, type checks, package and dependency
operations, migrations, data processing, Docker and other container operations,
media or compute tools such as FFmpeg, and deployment commands. Do not run heavy
or project-runtime commands locally while mode is active.

The local worktree and its Git state remain authoritative. Never treat remote
source or Git changes as authoritative and never synchronize them back. When a
remote command proposes a source change, inspect its result and reproduce the
intended edit in the local worktree before creating a new snapshot.

Before creating a remote process, persistent workload, container, image,
volume, network, generated or deployment artifact, or other worker-local state,
associate it with the stable workspace identifier whenever the tool supports
labels, names, paths, metadata, or ownership records. Record exact resource
identities and inspection and removal details as they become available. Use
this attribution for targeted cleanup; the machine-wide Docker prune defined
below is the only exception. Also record known effects on external or shared
deployment systems without including secrets.

## Clean up intentionally

Run cleanup only when explicitly requested, including through
`/remote-compute-cleanup`. Use the active session context: the current canonical
worktree, its recomputed workspace identifier and exact remote child, and the
active worker. Refuse cleanup if that context is missing or ambiguous, if the
current worktree does not match it, or if the target cannot be verified as the
isolated child beneath the fixed remote base.

Remote-compute assumes each worker machine is dedicated to that worker. On the
verified active worker, machine-wide Docker pruning is therefore intentionally
allowed during explicit cleanup. This does not weaken boundaries around another
worker's files or external/shared systems.

Use established labels, names, paths, metadata, and ownership records to
identify attributable resources. Except for the required Docker prune below,
refuse ambiguous, host-wide, or unrelated deletion; preserve other worktrees,
another worker's files, and unrelated non-Docker worker state. Report anything
that cannot be attributed or safely removed instead of guessing.

In this order:

1. Stop attributable processes and persistent workloads.
2. Remove attributable containers, worktree-specific images, volumes, and
   networks.
3. Remove attributable generated and deployment artifacts and any other
   attributable worker-local state outside the remote child.
4. On the active worker, remove all unused Docker containers, images, networks,
   build cache, and volumes with this exact command, and record whether it
   succeeds:

   ```bash
   docker system prune -af --volumes
   ```

   This machine-wide prune is intentionally broader than workspace attribution,
   but it does not remove running Docker resources.
5. Remove only the verified isolated remote child, and remove it last.

Do not automatically roll back Kubernetes clusters, registries, cloud accounts,
shared deployment environments, or other external/shared systems. Report known
external effects that may need manual rollback.

## Report

Report failed access, tool, synchronization, and execution checks with enough
context for the user to act.

If a workload is intentionally left running, report the worker, workspace,
workload identity, and how to inspect its status or logs and stop it.

After cleanup, report the worker and workspace, what was stopped and removed,
whether the machine-wide Docker prune succeeded, anything that failed or could
not be safely removed, and known external effects requiring manual review or
rollback. Never imply cleanup completed successfully when the Docker prune
failed.
