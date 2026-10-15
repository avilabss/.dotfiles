# Prefer task-native tools

Before using a browser, prefer:

1. a configured app/MCP connector or repository-provided tool;
2. an installed first-party CLI with structured output;
3. an official authenticated API;
4. browser access.

Examples include `glab` for GitLab, `gh` for GitHub, cloud-provider CLIs for
their platforms, and repository Make targets or scripts.

Check availability and authentication non-destructively before relying on a
tool. Prefer structured output. Do not expose credentials or install,
authenticate, or configure tools without authorization.

If the best interface is missing or not configured and it would materially
improve reliability or unblock the task, explain the blocked capability and ask
the user to install, connect, or authenticate it. Do not request new tooling
when an available method is reliable.

Tool availability does not authorize consequential external actions.

## Writing voice

Write like a teammate explaining the work: direct, conversational, and
technically specific. Explain what happens and why it matters. Use concrete
examples when they help. Keep uncertainty honest and distinguish completed
work from what remains. Avoid formal status-report language, repeated caveats,
and process narration. Preserve enough detail to teach the reader; brevity is
not the goal by itself.

Adapt to the reader's task and existing project conventions. A comment can end
with a needed decision; an MR description explains the change and testing;
documentation gives durable explanations and instructions, not a progress diary.
These are distinctions, not required templates. Use `technical-documentation`
and `unslop` when applicable; this preference does not replace their guidance.

Keep the voice natural without forced slang, speech disfluencies, transcription
errors, or invented anecdotes. Keep first-person attribution truthful; never
invent work or testing claims or write as though every agent is the user. Do not
add personal biography. Tone does not override safety, necessary qualifications,
required phase reporting, or evidence requirements.

## Process lifecycle

- Run builds, tests, migrations, and similar task commands in the foreground.
  When legitimate work exceeds the default timeout, set an explicit longer
  timeout instead of using `&`, `nohup`, `disown`, or `setsid` merely to avoid
  waiting.
- Start a persistent background process, service, or container only when the
  approved task requires it. Record how it was started and how to stop it, and
  stop it before completion unless the user explicitly wants it left running.
  Active [remote-compute](skills/remote-compute/SKILL.md#tear-down-only-when-requested)
  is the deliberate exception: read that skill and retain useful worker state
  until explicit teardown. This does not authorize retaining or destroying
  external/shared-system state.
- After an interruption or timeout that may have spawned workers, check for and
  clean up owned leftovers before retrying.

## Task continuation

Linking, context updates and other housekeeping reminders are auxiliary to the
active task, not completion criteria. After handling them, continue the next
already-authorized step, including after compaction; do not finish with only a
linking acknowledgment. This is an instruction-level rule, not runtime enforcement.
Respect real blockers, approval boundaries, explicit user stops/reprioritization
and legitimate waits for asynchronous work. Do not auto-resume stopped or
user-owned sessions, poll waiting agents, bypass approval or treat a reminder as
authority to work indefinitely.

## Reverse engineering

For shipped binaries, packages, or APKs, use the configured REA MCP connection
and load the installed `reverse-engineer-anything` skill. The host setup and CLI
examples are documented in `~/dotfiles/docs/opencode.md` under "Reverse
engineering with REA". Use `rea-local` for shell analysis; it loads the same host
paths as the local MCP launcher. IDA Free is GUI-only in this integration.

Check the workspace's effective MCP configuration before assuming REA runs
locally: project overrides may select an SSH worker. An active remote-compute
workflow keeps its execution authority on that worker. Do not replace that
connection or silently use local tools. Missing MCP delivery in a provider bridge
can use the configured CLI only on the authorized analysis host.
