# OpenCode setup

This is a stowed OpenCode configuration for planning, implementation, and two
independent reviews. The optional Ansible role links this directory to
`~/.config/opencode/`.

## Install and authenticate

From the dotfiles repository:

```bash
./bootstrap.sh --tags opencode
```

Start `opencode`, enter `/connect`, select **OpenAI (ChatGPT Plus/Pro)**, and
complete browser OAuth. Credentials are stored outside the repository at
`~/.local/share/opencode/auth.json`.

## Everyday workflow

```text
You + @architect
  -> approve requirements
  -> approve the plan
  -> Task Brief
  -> @developer
  -> @code-reviewer-1 + @code-reviewer-2 (in parallel)
  -> fixes and fresh dual review as needed
  -> @architect reports the result
```

1. Start with `@architect`. Agree on the requirements, then approve the proposed
   plan. These are two separate approval points.
2. Architect writes a Task Brief and sends one approved task to `@developer`.
3. Developer implements and validates it, then requests both policy-identical
   reviewers in parallel. Both approvals are required.
4. Any implementation change starts a fresh review by both reviewers. Once both
   approve the same state, developer reports back to architect.

## Agents

| Agent | Normal use |
|---|---|
| `architect` | Discovers requirements, plans work, writes Task Briefs, and coordinates delivery |
| `developer` | Implements one approved Task Brief and runs the dual-review loop |
| `repo-scouter` | Refreshes `ARCHITECTURE.md` when repository guidance is materially incomplete |
| `code-reviewer-1` | First independent correctness and standards review |
| `code-reviewer-2` | Second independent review using the same review policy |

The detailed contracts live in the [agent prompts](agents/) and the
[shared reviewer prompt](prompts/code-reviewer.md).

## Commands

| Command | Purpose | Example |
|---|---|---|
| [`/handoff`](commands/handoff.md) | Write a concise continuation note for a fresh session | `/handoff focus on the failed Fedora install` |
| [`/harvest`](commands/harvest.md) | Review completed work for reusable knowledge without changing files | `/harvest main..feature-branch` |
| [`/wb-start`](commands/wb-start.md) | Start or continue a Whitebox ticket with its development skill | `/wb-start <ticket-link> <branch-name> [context]` |

## Skills

| Skill | Use it when |
|---|---|
| [`diagnosing-bugs`](skills/diagnosing-bugs/SKILL.md) | A hard, intermittent, recurrent, or performance bug needs disciplined diagnosis |
| [`whitebox-development`](skills/whitebox-development/SKILL.md) | Developing a Whitebox ticket across core and affected plugin repositories |
| [`whitebox-review`](skills/whitebox-review/SKILL.md) | Reviewing Whitebox core, kernel, plugin, or cross-repository changes |

Skills can trigger from context. When you want one explicitly, say, for example,
`Use $whitebox-review to review <merge-request-url>`.

## Task Briefs and handoffs

- Task Briefs are temporary local files at `task-briefs/NN-task-name.md`. They
  are ignored by Git. Architect creates, revises, and removes them; developer
  and reviewers use the exact path as read-only input. See the
  [architect prompt](agents/architect.md) for the lifecycle.
- `/handoff [focus]` writes a redacted note under
  `~/.local/state/opencode/handoffs/`. Start a fresh session, reference the path
  it reports, and delete the note when it is no longer useful. The
  [command source](commands/handoff.md) owns the file format and naming rules.

## Models

| Use | Model |
|---|---|
| Default, architect, developer, repo-scouter, and reviewer 1 | `openai/gpt-5.6-sol` |
| Reviewer 2 | `openai/gpt-5.6-terra` |
| Lightweight internal work | `openai/gpt-5.6-luna` |

Assignments and runtime settings are defined in [`opencode.json`](opencode.json).

## Server helpers

The helpers run manually; they do not install a system service.

| Helper | What it does |
|---|---|
| `opencode-serve-start` | Starts OpenCode on `0.0.0.0:4096`; logs to `~/.local/state/opencode/serve.log` |
| `opencode-serve-stop` | Stops the helper-managed OpenCode server |
| `opencode-db-vacuum` | Checks and compacts the OpenCode database after OpenCode and OpenChamber are stopped |
| `openchamber-serve-start` | Starts OpenChamber on `0.0.0.0:4097` with its managed OpenCode process on port `4095` |
| `openchamber-serve-stop` | Stops the helper-managed OpenChamber process |

Override the OpenCode bind with `OPENCODE_SERVE_HOSTNAME` and
`OPENCODE_SERVE_PORT`. Because the helper binds to every interface by default,
set `OPENCODE_SERVER_PASSWORD` unless the network is fully trusted. See
[OpenCode server authentication](https://opencode.ai/docs/server/#authentication).
OpenChamber logs to
`~/.local/state/openchamber/serve.log`; override its bind with
`OPENCHAMBER_SERVE_HOST` and `OPENCHAMBER_SERVE_PORT`, and its managed OpenCode
port with `OPENCODE_PORT`. Set `OPENCHAMBER_UI_PASSWORD` unless the network is
fully trusted.

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

Keep one authoritative source for each workflow and make its completion criteria
checkable.

## Restart after configuration changes

OpenCode loads configuration at startup. After changing `opencode.json`, an
agent, command, prompt, skill, plugin, or other configuration file, quit and
restart both OpenCode and OpenChamber.
