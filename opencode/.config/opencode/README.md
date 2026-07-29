# OpenCode configuration and workflow

This directory is stowed to `~/.config/opencode/` by the optional `opencode`
Ansible role. The files in this repository are the source of truth. Stow reports
existing-file conflicts rather than adopting them.

## Provider and runtime

OpenCode is restricted to the OpenAI provider. Run `/connect`, select
**OpenAI (ChatGPT Plus/Pro)**, and complete browser OAuth. Credentials are stored
at `~/.local/share/opencode/auth.json` and are not managed by dotfiles.

| Use | Model | Reasoning | Verbosity |
|-----|-------|-----------|-----------|
| Default, architect, developer, repo-scouter, reviewer 1 | `openai/gpt-5.6-sol` | high for agents | agent-specific |
| Reviewer 2 | `openai/gpt-5.6-terra` | high | low |
| Lightweight internal work such as titles | `openai/gpt-5.6-luna` | runtime default | runtime default |

The OpenAI response-header timeout is 60 seconds. Session sharing is disabled,
snapshots remain enabled for undo, automatic compaction prunes old tool output,
and common generated directories are excluded from file watching. Exa search is
enabled with `OPENCODE_ENABLE_EXA=1` for interactive, standalone-server, and
OpenChamber sessions.

Configuration is loaded at process startup. After changing `opencode.json`, an
agent, command, prompt, skill, plugin, or other config-time file, quit and
restart both OpenCode and OpenChamber so their OpenCode processes reload it.

## Agents and enforced boundaries

| Agent | Role | Enforced permissions |
|-------|------|----------------------|
| `architect` | Discovery, decisions, planning, and orchestration | Bash requires user approval; may edit only repository-root `task-briefs/*.md` and explicitly requested Markdown handoffs; may delegate only to `developer` and `repo-scouter` |
| `developer` | Implements one approved Task Brief | Normal implementation edits except `ARCHITECTURE.md` and `task-briefs/*.md`; may delegate only to both code reviewers |
| `repo-scouter` | Maintains shared repository context when needed | May edit only repository-root `ARCHITECTURE.md`; cannot delegate, use Bash, or use network tools |
| `code-reviewer-1` | Primary independent correctness and security review | Cannot edit or delegate; Bash requires user approval |
| `code-reviewer-2` | Independent second deep review | Cannot edit or delegate; Bash requires user approval |

The policy-identical reviewers share one prompt so policy stays synchronized.
Each independently checks both Task/spec fit (the complete brief, interpretation,
scope, and failure behavior) and Standards/system fit (repository rules,
architecture and integration boundaries, security, dependencies, and material
design smells). Findings distinguish hard correctness/spec failures,
documented-standard violations, and judgment-call heuristics. Reviewer 1 uses
Sol and reviewer 2 uses Terra for model diversity. `subagent_depth` is 2, which
supports architect to developer to reviewer delegation. Task permissions govern
agent-initiated delegation; users can still manually invoke visible subagents
with `@name`.

## Approval gates and task workflow

The two user approval gates are mandatory:

1. During discovery, architect inspects available context, resolves material
   ambiguity, restates requirements, constraints, success criteria, and
   non-goals, then waits for user approval.
2. Architect presents the task plan and waits for a second user approval before
   writing a Task Brief or invoking developer.

After both gates:

1. Architect writes one Task Brief and gives developer its exact path.
2. Developer records the starting revision and pre-existing staged, unstaged,
   and untracked state, then implements only that brief.
3. Developer validates the current state and requests both code reviews in
   parallel.
4. Reviewers independently inspect the complete task diff and repository state,
   then return findings, approval, and residual risks to developer.
5. Developer addresses findings. Every implementation change invalidates both
   approvals and requires a fresh parallel review from both reviewers.
6. After both approve the same current state, developer reports the summary,
   files changed, validation evidence, reviewer outcomes, tradeoffs, and
   residual risks to architect. Architect decides whether the task is complete
   or needs a corrective revision.

Both reviewers are required for every implementation task; review is not
optional or risk-based.

## Task Brief lifecycle

- Store briefs at repository-root `task-briefs/NN-task-name.md`, numbered
  sequentially from `00` with a short descriptive name.
- The root `.gitignore` excludes `/task-briefs/`; briefs are temporary local
  workflow artifacts, not versioned project documentation.
- Architect alone creates, revises, and removes briefs. Developer and reviewers
  receive the exact path and treat it as read-only.
- Corrective instructions for the same task update its existing brief with a
  clearly identified revision instead of creating an unrelated brief.
- Architect removes a brief when it is no longer needed.

## Repository context

Architect establishes context during discovery. Existing `ARCHITECTURE.md`,
`AGENTS.md`, README files, or equivalent repository guidance can provide the
baseline. Architect invokes repo-scouter only when that baseline is materially
missing, stale, incomplete for the task, or contradicted by repository evidence.

`ARCHITECTURE.md` is the shared context cache and repo-scouter is its sole
editor. Developer and reviewers do not invoke repo-scouter; they report concrete
discrepancies upward through developer and architect.

## Review handoff

Every request sent in parallel to each reviewer includes:

- the exact Task Brief path;
- the comparison base;
- task-owned files;
- pre-existing unrelated changes;
- current staged, unstaged, and untracked state; and
- validation commands and results, including checks not run.

Reviewers use these inputs as coordinates, not as a substitute for inspection.
They inspect the current repository state and complete task diff against the
base, explicitly accounting for staged, unstaged, and untracked files; plain
`git diff` alone does not cover all three.

## Commands

### `/handoff`

Write one concise, redacted Markdown handoff for continuation in a fresh
session. Optional arguments identify the intended focus.

```text
/handoff
/handoff <focus for the fresh session>
```

Handoffs are stored outside repositories at
`~/.local/state/opencode/handoffs/YYYY-MM-DD-<short-name>.md`. The optional
OpenCode role creates the directory as the normal user with mode `0700`.
Existing names are never overwritten; a numeric suffix is added on collision.
OpenCode grants the architect directory-boundary access there, while its actual
edit permission remains limited to handoff `.md` files; unrelated external
directories retain their existing approval or denial rules.
The command reports the absolute path when done. Start a fresh session and
reference that path. Handoffs are local, unversioned transition artifacts;
review and delete them when no longer needed, especially if their context has
become stale.

### `/harvest`

Run a read-only post-ticket review that finds durable reusable knowledge and
proposes the smallest maintainable destination. It checks existing guidance,
may recommend zero changes, and never modifies files or external systems.

```text
/harvest
/harvest <ticket reference, commit range, or other scope context>
```

### `/wb-start`

Start or continue a Whitebox ticket through the `whitebox-development` skill.
The ticket link and shared core/plugin branch name are required; additional
context is optional. The command does not authorize pushes, merge requests, or
ticket updates.

```text
/wb-start <ticket-link> <branch-name> [additional context]
```

## Command and skill authoring rubric

- Put intentional user-invoked orchestration in a command.
- Put reusable behavior the model should recognize autonomously in a skill.
- Keep skill descriptions to narrow trigger and context pointers.
- Give operational steps checkable completion criteria.
- Give each behavior one authoritative home; progressively disclose
  branch-specific references instead of duplicating them.
- Prune no-op instructions. Prefer positive target behavior, retaining explicit
  prohibitions for genuine safety boundaries.
- Require every advertised skill to justify its permanent catalog/context load.

## Skills

### `diagnosing-bugs`

Use only for hard, intermittent, recurrent, or performance bugs that need a
disciplined diagnosis, not obvious one-line failures. It establishes a tight
feedback command, minimizes the exact symptom, ranks falsifiable hypotheses,
tests measured predictions one at a time, applies the smallest supported fix,
and reruns original and minimized reproductions before removing diagnostic
artifacts. If no meaningful feedback loop is possible, it stops and requests
the specific missing input rather than guessing.

### `whitebox-development`

Use for Whitebox ticket work across core and affected plugins. It coordinates
branches and worktrees, editable local Poetry dependencies during development,
Git dependencies for pushed plugin branches, per-repository validation, merge
requests, and ticket cross-linking. External changes such as pushes, merge
requests, and ticket updates happen only when explicitly requested.

The canonical merge-request workflow remains
`skills/whitebox-development/references/merge-request-workflow.md`. In
particular, a plugin MR description contains only this relationship block:

```md
PARENT: https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx

___

KERNEL: #<branch-name>
```

### `whitebox-review`

Use for architecture-aware review of Whitebox core, kernel, plugin, and
cross-repository merge requests. It resolves the complete MR bundle, checks
cross-plugin contracts and temporary dependencies, and reports architecture
risks before file-level findings.

Invoke skills explicitly when the surrounding context is not enough to trigger
them reliably:

```text
Use $whitebox-development to continue <ticket-link> on <branch-name>.
Use $whitebox-review to review <merge-request-url>.
```

OpenChamber uses the same skills through its managed OpenCode process.

## Server helpers

The `opencode` role installs manual helpers; it does not create a systemd or
launchd service:

```bash
opencode-serve-start
opencode-serve-stop
opencode-db-vacuum
```

`opencode-serve-start` runs on `0.0.0.0:4096` by default and logs to
`~/.local/state/opencode/serve.log`. Override a run with
`OPENCODE_SERVE_HOSTNAME` and `OPENCODE_SERVE_PORT`. OpenCode and OpenChamber
launchers warn when the database reaches 1 GiB; stop both applications and run
`opencode-db-vacuum` to integrity-check, checkpoint, and compact it. Override
the threshold with `OPENCODE_DB_VACUUM_WARN_BYTES`.

The optional OpenChamber role installs:

```bash
openchamber-serve-start
openchamber-serve-stop
```

OpenChamber listens on `0.0.0.0:4097`, runs its managed OpenCode child on port
`4095`, and logs to `~/.local/state/openchamber/serve.log` by default. The helper
rotates that log and OpenCode's log at 25 MiB, retaining three generations;
override with `OPENCHAMBER_LOG_MAX_BYTES` and `OPENCHAMBER_LOG_KEEP`. Set
`OPENCHAMBER_UI_PASSWORD` unless the network is fully trusted. Override the bind
with `OPENCHAMBER_SERVE_HOST` and `OPENCHAMBER_SERVE_PORT`, or its managed child
with `OPENCODE_PORT`. To use an external OpenCode server, set `OPENCODE_HOST` and
`OPENCODE_SKIP_START=true`.

OpenChamber requires Node.js 22 or newer and OpenCode. Install both with
`./bootstrap.sh --tags opencode,openchamber`. Start a new login shell (or source
`~/.zprofile`) before `openchamber update` so npm uses the user-writable
`~/.local` prefix.
