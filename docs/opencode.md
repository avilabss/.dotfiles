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
| Get help on a hard problem | [Expert help](#expert-help) |
| Decide what review feedback blocks | [Findings and follow-ups](#findings-and-follow-ups) |
| Interpret source, runtime and review evidence | [What the evidence proves](#what-the-evidence-proves) |
| Update configuration safely | [Configuration pickup and recovery](#restart-after-configuration-changes) |

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
`openai`, then check [configuration pickup](#restart-after-configuration-changes)
and confirm the models appear under **Claude Code**.

For a first task, open the target repository in OpenCode and ask `@architect`
to inspect it and help define the requirements. Do not start implementation
until requirements and the resulting plan have each been approved.

## Everyday workflow

1. Ask `@architect` to inspect the repository. Agree on requirements, then approve
   the plan. These are separate approval points; implementation starts only after
   plan approval and architect's explicit release.
2. Architect writes a Task Brief for developer. It names the normal user journey
   or observable deliverable, target environment and smallest early end-to-end
   proof—the **acceptance anchor**. Consequential design decisions get independent
   dual design review, without edits or experiments, before architect explicitly
   releases implementation.
3. Developer implements and validates, then calls both regular reviewers in
   parallel. A **frozen round** means both inspect the same unchanged source and
   scope decisions. Any edit requires renewed pair approval, not a review of only
   the latest lines. Missing required evidence or reviewer capability blocks approval.
4. For multi-task work, architect also releases cumulative pair review of the
   combined change against its original bases. Per-task approvals are not enough.
5. After validation and regular reviews pass, architect releases the required
   final whole-effort review through developer. Reviewer 3 runs even for a single
   task; no extra permission question is needed just to invoke that required gate.
   Authorized corrections need renewed whole-effort pair and final review.

Architect reports the result. Only you can confirm understanding and ownership;
AI approval does not replace project review or authorize publication. The
[developer review loop](../opencode/.config/opencode/agents/developer.md#review-loop)
owns dispatch, verification and correction details. For documentation, agents
also follow the [fresh-reader procedure](../opencode/.config/opencode/skills/technical-documentation/SKILL.md#check-with-a-fresh-reader).

When an agent cannot proceed, it reports the missing decision, evidence or
capability, with an owner and next action, to architect. A failed or pending
review is not a vote. Architect resolves scope conflicts with you; agents do not
quietly lower the criteria or substitute reviewers.

A reviewer call can remain stuck inside the runtime's retry handling, preventing
the coordinating agent from reporting immediately. You may need to stop/cancel
the affected call using your client's controls, then restore access/quota or
[explicitly choose a model for the named role](#models). Reload is not a quota
remedy. Agents have no standing authority to cancel calls, reload services,
change accounts or buy usage. Once control returns, the agent reports the gap
and resumes only with the missing capability and authority restored.

The [global process rules](../opencode/.config/opencode/AGENTS.md#process-lifecycle)
require foreground builds/checks and owned cleanup with stop commands. Active
[remote-compute](../opencode/.config/opencode/skills/remote-compute/SKILL.md#tear-down-only-when-requested)
retains its worker until explicit teardown; that exception never grants authority
over external or shared systems.

### Expert help

Developer asks architect for help when investigation stalls or complexity grows
without advancing the goal. You can also ask architect for expert investigation.
Architect may invoke `big-brain` early for a hard problem, consequential reviewer
disagreement or stagnant diagnosis; it need not wait for a fixed attempt count.

Expert help still needs an approved plan and a Task Brief. A focused investigation
can be the planned task before broad implementation. Ask architect to scope it;
"early help" does not bypass plan approval or brief creation.

Architect sends the goal, evidence, failed approaches, hypotheses and question
with either **read-only consultation** or **experiment released** authority. The
second permits only an already-approved experiment in assigned scratch and the
approved environment, not edits to product source, worktree state or briefs.
Developer integrates supported results. New scope or external effects need approval.

The expert returns facts, inferences and untested ideas separately. Its output
is evidence for the normal review gates, not an approval vote. Architect verifies
instruction delivery and the publicly recorded model/variant—the requested model
and reasoning option, not proof of provider-internal effort. Expert use can share
final-review quota; choose it for a useful question, not as a routine fourth review.
The [architect contract](../opencode/.config/opencode/agents/architect.md#expert-help)
owns dispatch and [big-brain](../opencode/.config/opencode/agents/big-brain.md) owns
its investigative boundaries.

### Findings and follow-ups

Severity describes impact; task relevance determines whether a finding blocks
this goal. An introduced or worsened regression, an acceptance-anchor failure or
missing required validation blocks. An old defect newly exposed on the acceptance
path may block too; an independent old UI defect normally becomes a follow-up
rather than a new code project. Serious
security/data-loss/release risk needs your informed decision before proceeding,
not a quiet waiver. Missing reviewer capability or verification cannot be waived.

Reviewers use stable IDs and propose `fix`, `scope`, `defer` or `reject` with
evidence. Developer fixes issues already covered by the brief. Architect resolves
disputed or out-of-scope decisions between frozen rounds and asks you to approve
material plan changes. A recorded disposition is not approval: reviewers may
challenge its facts or relevance with concrete evidence.

A deferral retains evidence/impact, why it is outside scope, owner/next action
and a home that survives the brief: the final report to you, a `/handoff` note you
explicitly request, or an existing project tracker when updates are authorized.
Preserve it before deleting the brief. A local follow-up is enough when no external
ticket is authorized; disclose that limit rather than inventing a URL or tracker.
Reopen an agreed deferral when new evidence changes relevance or impact, not
automatically every round. See the [authoritative finding rules](../opencode/.config/opencode/agents/architect.md#findings-and-scope-decisions)
for ID origins and blocking criteria.

### What the evidence proves

Read a status report by what it establishes, not how many reviews ran:

- **Implemented/validated** says what changed and what checks covered. A source
  or component test is not runtime verification of the ordinary target journey.
- **AI-reviewed** identifies the reviewed state and stage. Pair approval is not
  cumulative or final approval, and none certifies human understanding.
- **Author-reviewed/understood** requires your confirmation. Ready for project
  review still needs the required evidence and final AI gate; it is not publication
  authority or a replacement for project code/product review.

The approved brief decides which target-environment evidence is required. A green
synthetic fixture, for example, does not prove a mobile-device flow. An unavailable
target stays in the report as a gap while safe authorized implementation can
continue; missing required evidence blocks that delivery claim. Only you can
explicitly narrow the scope to a source-validated delivery or a **manual-test
candidate**, an intermediate version to try with known limits. That decision
changes the scope of the claim, not the evidence: it proves no runtime behavior
and waives no required AI review gate.

Use [diagnosing-bugs](../opencode/.config/opencode/skills/diagnosing-bugs/SKILL.md)
for hard failures: reuse retained captures before asking for more, and preserve
the failing conditions when testing a hypothesis. Keep production changes,
maintained regression/tooling and disposable experiments distinct so a one-off
investigation does not become permanent machinery without an ongoing need.

## Agents

| Agent | Normal use |
|---|---|
| `architect` | Discovers requirements, plans work, writes Task Briefs, and coordinates delivery |
| `developer` | Implements one approved Task Brief or dispatches an authorized review-only phase |
| `repo-scouter` | Refreshes `ARCHITECTURE.md` when repository guidance lacks important details |
| `big-brain` | Architect-invoked investigation with explicit consultation or scratch-experiment authority; not another reviewer |
| `code-reviewer-1` | Full independent review, emphasizing system behavior, contracts, and security |
| `code-reviewer-2` | Full independent review, emphasizing maintainability, explanation, and onboarding |
| `code-reviewer-3` | Required sequential final review of the complete effort before human handoff |

The detailed contracts live in the
[agent prompts](../opencode/.config/opencode/agents/) and the
[shared reviewer prompt](../opencode/.config/opencode/prompts/code-reviewer.md).

Developer file edits and architect/reviewer shell commands run without tool
approval prompts. Task Brief and `ARCHITECTURE.md` ownership is enforced by the
agent instructions, rather than developer file-deny patterns that also block
nested implementation notes. Reviewers retain their edit-tool denial. Native
`subagent` rules limit that route to named roles, but this is not a universal
delegation barrier: observed Claude-bridge developer/reviewer catalogs also
exposed alternative session tools. No bypass was executed. Contracts prohibit
extra sessions or delegation through those tools, APIs or shell. Shell access
is not a read-only sandbox; agents must still follow their role instructions.

The architect -> developer -> reviewer path uses `experimental.subagent_depth: 2`
in `opencode.json`. V2 ignores the old top-level field; see the
[V2 migration guide](https://opencode.ai/v2/docs/migrate-v1#accepted-but-unsupported-fields).
A depth-limit error means review did not run. Follow the
[reload guidance](#restart-after-configuration-changes) before retrying.

OpenChamber's per-session auto-accept handles approval requests, but cannot
override OpenCode's explicit `deny` rules. Child sessions inherit the nearest
explicit parent setting unless they have their own setting. External-directory
access can still require approval when configured to ask. Native V2 allows
external directories by default; it does not retain V1's default external-path
ask. An ask, including a secret-read ask, can be answered by auto-accept without
human intervention; it is not a promise of isolation or secret protection. See
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

The global [AGENTS.md](../opencode/.config/opencode/AGENTS.md) owns the default
[writing voice](../opencode/.config/opencode/AGENTS.md#writing-voice), tool-selection,
process-lifecycle and [task-continuation](../opencode/.config/opencode/AGENTS.md#task-continuation)
guidance. The OpenCode stow package places it at
`~/.config/opencode/AGENTS.md`, which [native V2 loads automatically](https://opencode.ai/v2/docs/instructions/#scope)
alongside the target repository's guidance. Keep shared defaults in that file
rather than duplicating them across agent prompts or config.
V2 detects global/upward `AGENTS.md` edits before the next model request;
[ambient instruction updates](https://opencode.ai/v2/docs/instructions/#updates)
do not require a server reload. Nested instructions already loaded through file
discovery need a new session to receive edits immediately.

That native behavior is not proof that every provider bridge forwards the same
instructions. In earlier checks with Claude Code plugin 1.3.2, a fresh Claude-backed
reviewer context did not receive the complete OpenCode reviewer contract/global
rules before tools. Inspection of that version's prompt and query paths supports the limit:
it uses Claude Code's own system prompt and omits OpenCode system messages from
transferred history. Rules may arrive later through steering or explicit reads;
Claude-side discovery can also supply repository guidance depending on the
working directory. This is not a universal claim about plugin versions or paths,
and no complete provider request was captured.

Developer's [delivery procedure](../opencode/.config/opencode/agents/developer.md#review-instruction-delivery)
is authoritative for reviewers and experts. Read and apply it before dispatch:
developer verifies reviews; architect verifies expert help. Both require explicit
user-prompt reads and public model/variant evidence, not a provider's assurance
or a config entry. Direct/manual reviewer use must explicitly load the current
contract, global rules and repository guidance too. Missing evidence blocks review
acceptance or verified expertise; it does not justify model substitution.

The [fresh-reader procedure](../opencode/.config/opencode/skills/technical-documentation/SKILL.md#check-with-a-fresh-reader)
is the deliberate ordering exception: reader-path observations come before the
brief and author explanations, then full verified bootstrap before a verdict.
Disclose ambient exposure rather than claiming injected answers as discoveries.

For version-specific read-only inspection, resolve the existing server and its
authenticated context first. From the target repository:

```bash
# Replace placeholders; use the existing authenticated context, never pasted credentials.
opencode api --server <server-url> get '/api/agent?location[directory]=<encoded-absolute-path>'
opencode api --server <server-url> get '/api/model?location[directory]=<encoded-absolute-path>'
opencode api --server <server-url> get '/api/session/<child-session-id>'
opencode api --server <server-url> get '/api/session/<child-session-id>/message?order=asc&limit=100'
```

These examples use the V2 `/api` surface; check the running server's
`/openapi.json` for version-specific shapes. Session metadata and assistant
messages expose requested model/variant; completed public tool results establish
read paths/ranges and order. Follow pagination, inspect only the relevant public
records, and omit private reasoning and credential-bearing content from evidence.
Do not run bare `opencode api` against an unknown service: its discovery can
start a background service. An explicit-server authentication failure needs the
owner's help, not another server, copied credentials or weaker protection.

These records establish instruction availability and public requested identity,
not obedience, retention, provider-internal effort or review quality. Native
ambient loading, explicit bridge reads and cold-reader observations are different
evidence; none changes permissions or external-action authority.

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

Use the configured provider's catalog for exact IDs and reasoning variants;
Claude-backed selections use its CLI inventory, not Anthropic API IDs. Existing
child sessions keep their stored selections when a default changes.

You can choose a model/variant for a named role and scope, including no variant.
A choice specifically for the final pass applies without another permission
question; a pair-only choice does not change reviewer 3. This never waives a gate
or changes persistent configuration or permissions. Developer owns the
[selection and identity checks](../opencode/.config/opencode/agents/developer.md#model-selection-and-verification).

Usage limits depend on provider, model and plan; assignments promise neither
spare capacity nor model superiority. The pair approves before final-pass quota
is spent. There is no automatic quota fallback: an unavailable required reviewer
blocks its gate, and exhaustion alone is not a request to substitute a model.

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

[The V2 models guide](https://opencode.ai/v2/docs/models/#caveats) says configuration
files normally reload automatically and a request already running keeps its
initial settings. That caveat does not establish passive pickup of agent, prompt
or skill Markdown. Global/upward instruction updates have the separate behavior
described under [instruction delivery](#instruction-delivery). Already-selected
session models do not migrate when a role default changes.

In read-only checks of an OpenChamber-managed OpenCode 2.2.0 server, agent-file
edits were not reflected in the same-location `/api/agent` registry without a
reload. No reload was tested in those checks. This is a server-registry pickup
observation, not evidence of a provider-bridge fault or a guarantee about other
versions. Use the [read-only API examples](#instruction-delivery) to check the
effective role before and after any separately authorized reload. Then verify
the actual dispatch: registry/catalog presence alone is not operational usability,
and provider-bridge instruction delivery remains a separate check.

Keep each agent file entirely V1 or entirely native V2:
[V2 selects one parser for the whole frontmatter](https://opencode.ai/v2/docs/migrate-v1/#agent-files).
Adding `permissions` to a V1 sibling would cause its `permission` and other V1
fields to be ignored. The new expert is native V2; existing agents stay wholly
V1 with supported normalization, rather than an unrelated config-wide migration.

The server owns loaded configuration; closing a terminal client does not
necessarily stop it. If passive pickup fails and a full reload is actually needed,
coordinate with connected users and obtain authority before
[reloading](https://opencode.ai/v2/docs/cli/commands/#reload) the server in use:

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

After a depth-limit failure, inspect effective configuration and routing first;
seek coordinated reload/restart authority only if needed before retrying the
affected reviewer dispatches. Keep the task blocked until required reviewers
actually run and approve the same current state, including the final gate before
handoff. These are recovery instructions, not authorization for an agent to
reload or restart a live service during review.

## Why these boundaries

The pinned MIT-licensed [tstack source](https://github.com/t3dotgg/tstack/tree/1085050f3baed1ac724caa4a8166145fb2ac88af)
informed this workflow: challenge review scope, validate the original journey,
reconsider sunk work and explain the problem before the implementation inventory.
The wording here is original. We did not import its single-reviewer/changed-lines
shortcuts, scores, automatic cancellation, PR automation or broad autonomy grants.

Our independent whole-state gates keep investigators from approving their own
work. Explicit scratch authority makes effects clear without pretending shell
permissions isolate them. One owner per rule keeps those boundaries readable:

| Contract | Authoritative home |
|---|---|
| Approval, briefs, expert dispatch and finding-scope decisions | [Architect](../opencode/.config/opencode/agents/architect.md) |
| Implementation, delivery/identity verification and review gates | [Developer](../opencode/.config/opencode/agents/developer.md) |
| Independent assessment and finding evidence | [Reviewer](../opencode/.config/opencode/prompts/code-reviewer.md) |
| Investigation authority | [Big-brain](../opencode/.config/opencode/agents/big-brain.md) |
| Voice, continuation and process lifetime | [Global rules](../opencode/.config/opencode/AGENTS.md) |
| Diagnosis, writing and operational procedures | Their [specific skills](#skills) and references |

Consumers keep short local boundaries because they can be loaded independently.
Required linked reads remain explicit; a link is not evidence that a contract
was delivered. This guide explains how to use the workflow, not a second policy
engine or a guarantee that prompts enforce it.
