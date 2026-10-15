# OpenCode setup

This repository includes a stowed OpenCode configuration for planning,
implementation, two regular independent reviews, and a required final whole-effort
review. The optional Ansible role links it to `~/.config/opencode/`.
Install the role, authenticate, and ask `@architect`
to define one task.

## Find what you need

| Goal | Go to |
|---|---|
| Install and complete first-use authentication | [Install and authenticate](#install-and-authenticate) |
| Run the normal agent process | [Everyday workflow](#everyday-workflow) |
| Choose an agent, command, or skill | [Agents](#agents), [Commands](#commands), or [Skills](#skills) |
| Analyze binaries or APKs through REA | [Reverse engineering](#reverse-engineering-with-rea) |
| Run a password-protected web helper | [Server helpers](#server-helpers) |
| Update configuration safely | [Restart after configuration changes](#restart-after-configuration-changes) |

## Install and authenticate

From the dotfiles repository:

```bash
./bootstrap.sh --tags opencode
```

Start `opencode`, enter `/connect`, select **OpenAI (ChatGPT Plus/Pro)**, and
complete browser OAuth. OpenCode stores credentials outside the repository at
`~/.local/share/opencode/auth.json`.

Claude-backed reviewers also need the Claude Code CLI signed in to a Claude plan: check
`claude auth status`, or run `claude auth login --claudeai` if signed out. The
pinned [Claude Code plugin](https://github.com/openchamber/opencode-claude) uses
that CLI login, not an API key. Keep `claude-code` in `enabled_providers` alongside
`openai`, then [reload](#restart-after-configuration-changes) and confirm the
models appear under **Claude Code**.

For a first task, open the target repository in OpenCode and ask `@architect`
to inspect it and help define the requirements. Do not start implementation
until requirements and the resulting plan have each been approved.

## Everyday workflow

1. Start with `@architect`. Agree on the requirements, then approve the proposed
   plan. These are two separate approval points.
2. Architect writes a Task Brief for developer. Consequential decisions get
   parallel dual design review first, with no edits or experiments; architect
   resolves material decisions with you and explicitly releases implementation.
3. Developer implements and validates the task, then requests both reviewers in
   parallel. Any implementation edit requires fresh approvals from both on the
   same state; missing required evidence or reviewer capability blocks approval.
4. Multi-task work also needs cumulative dual review of the combined change.
5. Once the complete effort passes validation and regular reviews, architect
   releases final review through developer. Reviewer 3 reviews the whole delivery,
   including single-task work, before it is declared done or ready for human review.
   No additional user permission question is needed. Corrections require authorized
   fixes, renewed whole-effort pair review, then final review again on the new state.
   Architect reports the result; only you can confirm understanding and ownership.

AI approval does not replace project review or authorize publication. The
[developer review loop](../opencode/.config/opencode/agents/developer.md#review-loop)
owns dispatch inputs, independent same-state review, and escalation. The
[technical-documentation skill](../opencode/.config/opencode/skills/technical-documentation/SKILL.md#check-with-a-fresh-reader)
owns the fresh-reader procedure. Agents must read linked instructions when
required; a link alone does not load them.

If work is blocked, keep it blocked. Report the missing decision, evidence, or
capability with an owner and next action to architect; do not automatically
substitute another reviewer or treat pending final review as acceptance. The
[final review gate](../opencode/.config/opencode/agents/developer.md#final-review-gate)
is required, not advisory. Native retries can hold the parent inside a blocking
dispatch, so an immediate report may not be possible until the call returns.
User-owned interruption/recovery may be needed; agents have no standing authority
to cancel, reload, change accounts or purchase usage. After control returns,
report the block and resume only with the required capability/authority restored.
Never lower the criteria or treat a failed dispatch as a vote. Architect resolves
scope conflicts and material changes with you. Resume only when the blocker and
any required authorization are resolved.

Run long builds, tests, migrations, and similar work in the foreground. Set a
larger timeout when needed. Start persistent processes, services, or containers
only as a planned part of the task. Record their owner and stop command, then
clean them up unless the user explicitly asks to retain them. Active
[remote-compute](../opencode/.config/opencode/skills/remote-compute/SKILL.md#tear-down-only-when-requested)
is the deliberate exception: retain useful worker state until explicit teardown.
Its whole-worker authority never extends to external or shared systems.

## Agents

| Agent | Normal use |
|---|---|
| `architect` | Discovers requirements, plans work, writes Task Briefs, and coordinates delivery |
| `developer` | Implements one approved Task Brief or dispatches an authorized review-only phase |
| `repo-scouter` | Refreshes `ARCHITECTURE.md` when repository guidance lacks important details |
| `code-reviewer-1` | Full independent review, emphasizing system behavior, contracts, and security |
| `code-reviewer-2` | Full independent review, emphasizing maintainability, explanation, and onboarding |
| `code-reviewer-3` | Required sequential final review of the complete effort before human handoff |

The detailed contracts live in the
[agent prompts](../opencode/.config/opencode/agents/) and the
[shared reviewer prompt](../opencode/.config/opencode/prompts/code-reviewer.md).

Developer file edits and architect/reviewer shell commands run without tool
approval prompts. Task Brief and `ARCHITECTURE.md` ownership is enforced by the
agent instructions, rather than developer file-deny patterns that also block
nested implementation notes. Reviewers retain their edit-tool denial, and
delegation remains limited to the agents named in each contract. Shell access
is not a read-only sandbox; agents must still follow their role instructions.

The architect -> developer -> reviewer path uses `experimental.subagent_depth: 2`
in `opencode.json`. V2 ignores the old top-level field; see the
[V2 migration guide](https://opencode.ai/v2/docs/migrate-v1#accepted-but-unsupported-fields).
A depth-limit error means review did not run. Follow the
[reload guidance](#restart-after-configuration-changes) before retrying.

OpenChamber's per-session auto-accept handles approval requests, but cannot
override OpenCode's explicit `deny` rules. Child sessions inherit the nearest
explicit parent setting unless they have their own setting. External-directory
access can still require approval. See
[OpenCode V2 permissions](https://opencode.ai/v2/docs/permissions/) for rule matching
and agent overrides.

## Commands

| Command | Purpose | Example |
|---|---|---|
| [`/handoff`](../opencode/.config/opencode/commands/handoff.md) | Write a concise continuation note for a fresh session | `/handoff focus on the failed Fedora install` |
| [`/harvest`](../opencode/.config/opencode/commands/harvest.md) | Review completed work for reusable knowledge without changing files | `/harvest main..feature-branch` |
| [`/simplify`](../opencode/.config/opencode/commands/simplify.md) | Ask architect for a read-only simplification audit; approve recommendations before changes | `/simplify` or `/simplify main..feature-branch` |
| [`/remote-compute-cleanup`](../opencode/.config/opencode/commands/remote-compute-cleanup.md) | Explicitly tear down all host-local state on the active remote-compute worker | `/remote-compute-cleanup` |
| [`/wb-review`](../opencode/.config/opencode/commands/wb-review.md) | Review one Whitebox effort from one or more work-item/MR URLs without external changes | `/wb-review <work-item-url> [<work-item-or-mr-url> ...]` |
| [`/wb-start`](../opencode/.config/opencode/commands/wb-start.md) | Start or continue a Whitebox ticket with its development skill | `/wb-start <ticket-link> <branch-name> [context]` |

After activation verifies SSH access and allocation, remote-compute treats the
entire worker as an exclusive, disposable host-local sandbox. The agent may
administer and clean up the whole host without further approval. That authority
includes packages, services, processes, containers, and reboots. Ordinary task
completion retains useful worker state. `/remote-compute-cleanup` tears down the
whole worker's host-local state. This authority never includes external or
shared systems, and it does not automatically roll them back.

## Skills

| Skill | Use it when |
|---|---|
| [`diagnosing-bugs`](../opencode/.config/opencode/skills/diagnosing-bugs/SKILL.md) | A hard, intermittent, recurrent, or performance bug needs disciplined diagnosis |
| [`remote-compute`](../opencode/.config/opencode/skills/remote-compute/SKILL.md) | An exclusive disposable SSH worker should run every project execution command while the current local Git worktree remains authoritative |
| [`technical-documentation`](../opencode/.config/opencode/skills/technical-documentation/SKILL.md) | Planning, writing, or reviewing substantial technical docs/onboarding or explaining non-obvious code contracts |
| [`unslop`](../opencode/.config/opencode/skills/unslop/SKILL.md) | Polishing prose for clarity while preserving meaning and the author's voice |
| [`whitebox-development`](../opencode/.config/opencode/skills/whitebox-development/SKILL.md) | Developing a Whitebox effort across core, plugins and SDK/library consumers; authorized [publication/merging](../opencode/.config/opencode/skills/whitebox-development/references/merge-request-workflow.md), or explicit [SBC testing/deployment](../opencode/.config/opencode/skills/whitebox-development/references/sbc-testing.md) |
| [`whitebox-review`](../opencode/.config/opencode/skills/whitebox-review/SKILL.md) | Reviewing Whitebox core, kernel, plugin, or cross-repository changes |

Skills can trigger from context. When you want one explicitly, say, for example,
`Use $whitebox-review to review <merge-request-url>`.

### Instruction delivery

The global [AGENTS.md](../opencode/.config/opencode/AGENTS.md) owns tool-selection,
process-lifecycle and [task-continuation](../opencode/.config/opencode/AGENTS.md#task-continuation)
guidance. The OpenCode stow package places it at
`~/.config/opencode/AGENTS.md`, which [native V2 loads automatically](https://opencode.ai/v2/docs/instructions/#scope)
alongside the target repository's guidance. Keep shared rules here rather than
in the `instructions` config field, whose [entries are not loaded](https://opencode.ai/v2/docs/config/#instructions).
V2 detects global/upward `AGENTS.md` edits before the next model request;
[ambient instruction updates](https://opencode.ai/v2/docs/instructions/#updates)
do not require a server reload. Nested instructions already loaded through file
discovery need a new session to receive edits immediately.

That native behavior is not proof that every provider bridge forwards the same
instructions. With the installed Claude Code plugin 1.3.2, a fresh Claude-backed
reviewer context did not receive the complete OpenCode reviewer contract/global
rules before tools. Inspection of that version's prompt and query paths supports the limit:
it uses Claude Code's own system prompt and omits OpenCode system messages from
transferred history. Rules may arrive later through steering or explicit reads;
Claude-side discovery can also supply repository guidance depending on the
working directory. This is not a universal claim about plugin versions or paths,
and no complete provider request was captured.

Developer therefore uses the
[verified user-prompt bootstrap](../opencode/.config/opencode/agents/developer.md#review-instruction-delivery)
for every reviewer in every review phase. Normal reviews load the contract,
global rules, and repository guidance first. A fresh-reader exercise emits
natural reader-path observations first, then completes verified bootstrap before
the brief/diff-based review or verdict. Direct/manual reviewer use outside this
dispatch must explicitly load those same current files; do not assume the bridge
supplies them. A denied external-directory read or unavailable complete read-event
evidence blocks acceptance rather than triggering model substitution. Developer
also verifies actual public session and assistant model/variant records for each
dispatch; defaults do not migrate already-existing child sessions.

The procedure establishes instruction availability for the reviewed context,
not obedience, durable retention, bridge repair, or review quality. Native
ambient loading, explicit Claude-backed reviewer reads, and cold-reader
observations are separate evidence. It does not change models, permissions,
or external-action authority.

## Reverse engineering with REA

The stowed OpenCode V2 config registers `rea` under `mcp.servers`. OpenChamber
uses that connection through its managed OpenCode server; it does not need a
separate MCP registration. The launcher loads host paths itself, so it also works
when the server starts without an interactive Zsh environment.

### Install on another machine

Install/stow OpenCode first, then opt into the analysis tools:

```bash
cd ~/dotfiles
./bootstrap.sh --tags opencode
rea-setup
```

On an already installed host, `stow -R opencode` refreshes only the symlinks.
`rea-setup` installs the pinned `rea-agents@6.4.0` into `~/.local`, downloads
`jadx-headless-mcp` 0.7.1 with a fixed SHA-256 check, and links the matching bundled
skill into `~/.config/opencode/skills/reverse-engineer-anything`. It preserves an
existing host environment file and refuses to overwrite an unrelated skill or
an engine JAR with the wrong checksum. Node.js 22.19+, 24.11+, or 26+ is required,
as are npm and curl. Installation needs network access; normal local analysis
uses the installed package.

Edit `~/.config/rea/env` (created from the tracked `env.example`):

```bash
export GHIDRA_INSTALL_DIR="$HOME/Extras/ghidra_12.1.4"
export JAVA_HOME="/absolute/path/to/full-jdk"
export IDA_INSTALL_DIR="$HOME/ida-free-9.4"  # Optional GUI launcher
```

These paths belong to the machine running OpenCode. The env file and generated
skill link are ignored by Git. The setup command does not install Ghidra, Java,
IDA, or the JADX Flatpak. Supply Ghidra 12.1.x with its native decompiler and a
64-bit full JDK 21+ for native analysis. Android analysis uses the separate
headless JAR, defaulting to
`~/.local/share/rea/engines/jadx-headless-mcp-0.7.1-all.jar`; override it with
`REA_JADX_MCP_JAR` in the env file if necessary.

The configured Fedora host uses `~/Extras/ghidra_12.1.4`,
`/usr/lib/jvm/java-25-temurin-jdk`, and `~/ida-free-9.4`. Native function
analysis and static inspection of the public Appium ApiDemos APK were verified
with these installations on 2026-10-12. An isolated OpenCode 2.0.26 server also
reported `rea` connected; the active OpenChamber sessions were not reloaded
during setup. IDA Free 9.4 remains a GUI tool:
[REA's IDA dependency excludes IDA Free](https://github.com/mrexodia/ida-pro-mcp#prerequisites).
Use Ghidra for automated native decompilation with this setup.

### Use from OpenChamber or OpenCode

After installation, follow [reload guidance](#restart-after-configuration-changes)
for the server you actually use. The OpenChamber helper's default managed server
is `http://127.0.0.1:4095`; the separate OpenCode background service is a different
process. Reload only after coordinating with any active sessions. In the same
workspace, check the MCP connection in OpenChamber or OpenCode's `/mcps` UI.
It should show `rea` connected. Existing project configuration can override the
global connection, including selecting an SSH-based remote engine.

Example prompts (replace the paths with absolute paths on the analysis host):

> Use the reverse-engineer-anything skill and REA to analyze
> `/absolute/path/to/program`. Find how it parses its configuration, show the
> relevant functions and pseudocode, and distinguish observations from inferences.

> Use REA to inspect `/absolute/path/to/app.apk`. Summarize its manifest and
> permissions, then locate and explain its login code without running the APK.

The installed skill provides target routing and evidence-handling instructions.
For a bridge that does not expose MCP tools or discover the skill, explicitly
ask the agent to read the installed `SKILL.md` and use `rea-local` CLI commands.
Do not assume native OpenCode behavior proves Claude bridge tool delivery.

### Terminal commands and checks

| Command | Use |
|---|---|
| `rea-local` | REA CLI with the same host configuration as the MCP server |
| `jadx -d output app.apk` | Flatpak JADX CLI; also available as a Zsh alias |
| `ghidra-headless` | Ghidra's `analyzeHeadless` with configured paths |
| `ghidra` | Open Ghidra's GUI |
| `ida-free` | Open the installed IDA Free GUI |

```bash
rea-local doctor --provider ghidra --format json
rea-local mcp doctor --json
rea-local function /absolute/path/to/program main --provider ghidra --format json
rea-local inspect-android-package /absolute/path/to/app.apk --format json
```

The scoped doctor checks Ghidra readiness; MCP doctor starts a temporary REA
server, verifies its catalog, and makes a target-free request. Actual analysis
is a stronger engine check. `rea` alone does not load `~/.config/rea/env`;
use `rea-local` when invoking the configured CLI from an agent shell.

[OpenCode V2](https://opencode.ai/v2/docs/mcp-servers/) uses `mcp.servers` and
`disabled`, whereas REA 6.4.0's setup/registration doctor expects the older
OpenCode shape. Do not run `rea setup` over this stowed config to resolve that
registration warning. Use REA's provider/MCP checks and OpenCode's actual
connection status instead. This integration deliberately registers no other
agent clients. It retains OpenCode's existing permission rules.

If the CLI works but OpenChamber lacks tools, check the workspace's effective
config and the managed server's loaded state. A project `rea` entry replaces the
entire global entry; it must contain its own command/environment. An active
remote-compute task must use its authorized worker and worker-local paths, not
silently fall back to this laptop's engine. The global launcher does not change
project remote configurations.

If Java or Flatpak fails only inside an agent's sandbox, use the client's normal
approval mechanism for the required local process access. A shell alias does not
bypass that boundary. The Flatpak CLI has its own filesystem permissions; use
files under your home directory or grant a specific extra path when needed.

To update, review REA's release requirements, then change the pinned version
(and, when required, engine URL/checksum) in `rea-setup`, rerun it, verify the
engines, and reload the correct OpenCode server. Avoid `rea update` or generic
setup commands that drift from this repository's pinned integration.

Upstream references: [REA setup](https://rea.tools/get-started/) and
[Android provider](https://github.com/morluto/rea/blob/main/docs/android-analysis.md).

## Task Briefs and handoffs

- Task Briefs are temporary local files at `task-briefs/NN-task-name.md`. They
  are ignored by Git. Architect creates, revises, and removes them; developer
  and reviewers use the exact path as read-only input. See the
  [architect prompt](../opencode/.config/opencode/agents/architect.md) for the
  lifecycle.
- `/handoff [focus]` writes a redacted note under
  `~/.local/state/opencode/handoffs/`. Start a fresh session, reference the path
  it reports, and delete the note when it is no longer useful. The
  [command source](../opencode/.config/opencode/commands/handoff.md) owns the
  file format and naming rules.

## Models

Current model assignments and variants are defined in
[`opencode.json`](../opencode/.config/opencode/opencode.json) and the
[agent frontmatter](../opencode/.config/opencode/agents/), not duplicated here.
Update those configuration values when upgrading models; role duties and gates
remain unchanged. The [Agents table](#agents) describes those duties.

Reviewers 1 and 2 form the regular pair; reviewer 3 performs the required final
whole-effort pass. The pair approves before spending final-pass quota, rather
than calling three reviewers at every checkpoint. Usage limits depend on the
configured provider, model and signed-in plan; these assignments do not promise
spare capacity or establish quality, latency or quota efficiency.

The required final gate is the user's choice, not an advisory vote. Automatic
quota fallback is removed: native blocking retries can keep the parent inside
the dispatch, preventing it from starting a replacement. This workflow does not
repair runtime retries or promise spare capacity. An unavailable authorized final
reviewer blocks handoff, even after implementation and pair approval.

Explicit user model/variant selections remain possible, including omitted variants.
A selection specifically for the final role/pass overrides that model for the
stated scope without a second permission round; it does not remove the final
stage. Pair-only selections never change reviewer 3, and exhaustion is not an
override request. The [developer review loop](../opencode/.config/opencode/agents/developer.md#review-loop)
owns these rules and verification, not an automatic failover plugin.

Developer resolves each named role's effective configuration, unless an explicit
scoped user selection overrides it, and verifies actual public session and
assistant model/variant records against that selection. A default named-role
dispatch does not invent a model override. Configuration updates do not migrate
stored child-session selections; coordinate required activation using the
[configuration reload guidance](#restart-after-configuration-changes).
Use the configured provider's catalog for exact model IDs and available variants;
Claude-backed selections use the installed CLI's inventory, not Anthropic API IDs.

## Server helpers

The helpers run manually and do not install a system service. Their default
`0.0.0.0` binds accept network connections. Set a strong password, keep the
secret out of the repository and shell history, and restrict access with the
host firewall or a trusted network.

| Helper | What it does |
|---|---|
| `opencode-serve-start` | Starts OpenCode on `0.0.0.0:4096`; logs to `~/.local/state/opencode/serve.log` |
| `opencode-serve-stop` | Stops the helper-managed OpenCode server |
| `opencode-db-vacuum` | Checks and compacts the OpenCode database after OpenCode and OpenChamber are stopped |
| `openchamber-serve-start` | Starts OpenChamber on `0.0.0.0:4097` with its managed OpenCode process on port `4095` |
| `openchamber-serve-stop` | Stops the helper-managed OpenChamber process |

Both start helpers bind to `0.0.0.0` by default and refuse to launch without a
non-empty password. Set `OPENCODE_SERVER_PASSWORD` for `opencode-serve-start`
and `OPENCHAMBER_UI_PASSWORD` for `openchamber-serve-start`. The helpers do not
support passwordless launches. Provide secrets through the environment and keep
them uncommitted. See
[OpenCode V2 web access](https://opencode.ai/v2/docs/cli/web/#access).

Override the OpenCode bind with `OPENCODE_SERVE_HOSTNAME` and
`OPENCODE_SERVE_PORT`. OpenChamber logs to
`~/.local/state/openchamber/serve.log`; override its bind with
`OPENCHAMBER_SERVE_HOST` and `OPENCHAMBER_SERVE_PORT`, and its managed OpenCode
port with `OPENCODE_PORT`.

Session interruption and OpenChamber shutdown perform best-effort cleanup of
owned foreground or managed processes. Detached daemons, containers, system
services, and similar external state can survive. OpenChamber stops only the
OpenCode server it manages. An external OpenCode server remains running.

OpenCode and OpenChamber launchers warn when the OpenCode database reaches 1
GiB. Stop both applications before running `opencode-db-vacuum`.

OpenChamber needs Node.js 22 or newer and OpenCode. Install it with:

```bash
./bootstrap.sh --tags opencode,openchamber
```

Start a new login shell, or source `~/.zprofile`, before using
`openchamber update` so npm uses the user-writable `~/.local` prefix.

## Commands or skills?

- Use a command for a workflow you intentionally start.
- Use a skill for reusable behavior OpenCode should recognize from context.

Keep one authoritative source for each workflow. Its completion criteria must
be checkable.

## Restart after configuration changes

OpenCode V2's server owns loaded configuration; closing its terminal client
does not necessarily stop the shared server. After changing `opencode.json`,
agents, commands, prompts, skills, or plugins, coordinate with connected users
and [reload](https://opencode.ai/v2/docs/cli/commands/#reload) the server your
session actually uses:

```bash
opencode reload --server <server-url>
```

Replace `<server-url>` with that server's URL and use its configured
authentication context. Do not target an unrelated background service. The
[V2 reload API](https://opencode.ai/v2/openapi.json) rebuilds every loaded
location and cancels pending permissions and forms; running sessions receive
fresh services at their next step boundary. Reload is not a reason to interrupt
other users without coordination.

Check that the same client can reach the intended server with
`opencode api --server <server-url> get /api/info` before reloading. If it reports
unauthorized access, stop and ask the server owner to restore the client's
authenticated connection. Do not remove password protection, copy credentials
into the repository, or reload another server as a workaround.

If a restart is needed instead, restart the server that owns the session: use
`opencode service restart` for the shared background service, or the matching
stop/start helpers for a helper-managed server. Restart OpenChamber when changing
its own configuration. See [service troubleshooting](https://opencode.ai/v2/docs/troubleshooting/#check-the-background-service).

After a depth-limit failure, reload or restart the correct server before retrying
the affected reviewer dispatches. Keep the task blocked until required reviewers
actually run and approve the same current state, including the final gate before
handoff. These are recovery instructions, not authorization for an agent to
reload or restart a live service during review.
