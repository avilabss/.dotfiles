---
name: remote-compute
description: Use `$remote-compute user@host` to run all project execution on an exclusive disposable SSH worker while keeping the current local Git worktree authoritative.
---

# Remote compute

## Activate the worker

`$remote-compute user@host` activates remote-compute mode for the rest of the
current session and only for the current canonical local Git worktree. Treat
`user@host` as one quoted SSH destination. Ask only when the destination or
worktree is missing or ambiguous.

Resolve the canonical worktree path and derive a stable, collision-resistant
workspace identifier from it. Record the worker's identity, canonical path,
workspace identifier, and exact remote child as the session context. Do not
apply that context to another worktree or persist or reuse it across sessions.

Verify SSH access, the worker identity and allocation, and the capabilities
needed for the intended work. Report access, identity, allocation, or
unrecoverable capability failures. Repair or prepare the host when practical
instead of stopping merely because a tool is missing.

After verification, the entire worker is exclusively allocated to this session
and worktree. Treat all host-local state as an owned, disposable sandbox: there
are no other users, unrelated work, or worktrees to preserve. Without further
approval, take any task-relevant host-wide action, including installing or
removing packages, changing services, stopping processes, deleting host-local
state or stale remote-compute worktrees, resetting or pruning container state,
performing system-wide cleanup, and rebooting. This authority applies only to
host-local state on the verified active worker, not to external or shared
systems.

Under the architect workflow, carry the active worker and remote-execution
constraint into the Task Brief. The architect runs no implementation commands;
the executing agent follows this contract.

## Synchronize from local authority

Use this exact child beneath the fixed remote base:

```text
$HOME/.opencode-remote-compute/worktrees/<workspace-id>
```

Create a temporary local snapshot from tracked files and nonignored untracked
files. Exclude `.git`, likely secrets, submodules, and ignored nested
repositories unless a specific reviewed input is needed. Review that input
before narrowly including it; these exclusions are not exhaustive secret
detection.

Synchronize the snapshot to the verified exact remote child with ordinary
rsync. Normal synchronization may delete only within that child so local
deletions and renames are reflected; never point its deletion at the fixed
base, remote home, or another destination. This synchronization boundary does
not restrict task-relevant whole-host administration or explicit teardown on
the exclusive worker.

## Execute and administer remotely

Keep authoritative source editing and inspection, Git state and operations,
snapshot creation, synchronization, and lightweight coordination local. Run
every project execution command from the exact remote child, including builds,
tests, linting, formatting, type checks, dependency operations, migrations,
data processing, containers, media or compute tools, and deployments. Do not
run project-runtime commands locally while mode is active.

The canonical local worktree and its Git state remain authoritative. Never
treat remote source or Git changes as authoritative or synchronize them back.
If a remote command produces an intended source change, inspect it and
reproduce the change locally before creating the next snapshot.

Administer the whole worker as needed throughout execution. Record the identity
and inspection or stop commands for any persistent workload intentionally kept
running. Attribute and conservatively handle effects on cloud accounts,
registries, Kubernetes clusters, shared deployments, and every other external
or shared system; whole-worker authority never authorizes their automatic
destruction or rollback.

## Recover or switch workers

After a reboot, SSH interruption, or other disruption, reconnect and verify
that the recorded worker identity and allocation still match. Revalidate the
needed capabilities and repair them when practical. Verify or recreate the
exact remote child. Resynchronize it from the canonical local worktree whenever
its contents may be stale or uncertain, then continue execution there. Report
and stop on an identity, allocation, access, or unrecoverable capability
mismatch. Never recover source or Git state from the worker into the local
worktree.

A later invocation with another destination switches workers. Verify the new
worker before replacing the active context, then create and synchronize its
exact child from local authority. Do not silently migrate persistent workloads.
Report any workload or other state intentionally left on the previous worker,
including how to inspect and stop it.

## Tear down only when requested

Ordinary task completion does not tear down the worker. Preserve useful worker
state unless the user directly requests teardown or invokes
`/remote-compute-cleanup`.

For teardown, verify the active session's worker identity and allocation,
canonical local worktree, recomputed workspace identifier, and exact remote
child. Refuse an ambiguous or mismatched target. Then tear down the whole
disposable worker: stop all host-local processes and workloads that should not
survive, remove containers and container images, volumes, networks, and cache,
delete all remote-compute worktrees and other host-local task state, and perform
any needed system-wide cleanup. Nothing host-local needs preservation, and
teardown is not limited by workspace attribution. Remove the exact remote child
last so its context remains available during cleanup.

Do not automatically destroy or roll back external or shared systems. Report
their known effects for separate review. Teardown concerns the allocated
worker's host-local state; it does not provision, release, reimage, or
deallocate the machine.

## Report

Report access, identity, allocation, synchronization, recovery, administration,
and execution failures with enough context to act. At task completion, identify
the worker and exact remote child, summarize significant host-wide changes or
reboots, and give inspection and stop commands for intentionally retained
workloads. Report known external effects without secrets.

After teardown, report the verified worker, what was stopped and removed, any
failed or retained host-local state, and external effects needing separate
review. Never imply that teardown succeeded when required cleanup failed.
