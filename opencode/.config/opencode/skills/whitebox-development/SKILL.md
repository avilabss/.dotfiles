---
name: whitebox-development
description: Develop Whitebox.aero efforts across core, plugins and SDK/library consumers using coordinated worktrees, dependencies, validation and merge requests. Use when starting or continuing tickets, preparing publication, raising or merging MRs, or explicitly asked to test or deploy that work on an SBC. Each operational phase requires its own authority.
---

# Whitebox ticket development

Only when the user explicitly requests SBC testing or deployment, read and follow
[references/sbc-testing.md](references/sbc-testing.md) before taking operational
steps. It covers allocation, one initial Docker reset, and pushed-ref deployment
for manual testing. It does not activate remote-compute or override role authority.

## Establish scope

1. Resolve the ticket, acceptance criteria, and requested branch.
2. Inspect the current repository, worktree, branch, status, remotes, existing
   worktrees, and relevant plugin dependencies before changing anything.
3. Map the complete core/plugin/library effort and the actual providers and
   consumers of changed contracts, including relevant unchanged repositories.
   Record each repository's original comparison base and starting revision,
   staged/unstaged/untracked state, and role in the effort. Inspect unchanged
   consumers without preparing or modifying every plugin by default.
4. Preserve unrelated changes and stop on unsafe worktree or branch conflicts.

If this skill is used outside the architect workflow, present the agreed scope
and get approval before changing code.

Read and follow the shared [architect](../../agents/architect.md) and
[developer](../../agents/developer.md) contracts for design, task, and cumulative
review. Outside that flow, still obtain evidence-backed decisions before broad
implementation and review the complete combined change against the original
bases before declaring readiness. A task or single-repository approval is not
cumulative approval. Record exact reviewed revisions and dirty-state diffs,
including untracked contents; renew affected approvals after implementation edits.

Use the same requested feature branch name in core and every plugin touched,
unless the ticket explicitly requires a different branch.

## Compatibility decisions

For consequential packaging or shared-contract changes, establish the supported
host/plugin/library combinations and the user-visible behavior before choosing
an implementation. Inspect the repositories' guidance and actual contracts, not
only the changed code. Keep the decision, evidence, alternatives, and known
limits in the relevant tracked project docs or contracts, and link them from the
core MR. Use `technical-documentation` for substantial explanations.

- Distinguish source/API breaks from build-artifact, runtime, and dependency
  resolution incompatibilities. An unchanged API does not prove that an older
  compiled plugin will load or share dependencies correctly on a newer host.
- For frontend packaging, trace the actual host and plugin federation/build
  configuration, shared dependency versions/resolution, generated artifacts,
  and loader behavior. Start with core `frontend/vite.config.js`,
  `backend/whitebox/plugin/jsx_manager/`, and `frontend/src/utils/federation.js`,
  then follow their configuration inputs and consumers at the selected revisions.
  A library name, analogy, or popularity claim is not compatibility evidence.
- Select credible risk-appropriate scenarios: older published plugins on a newer
  host, shared dependency/version resolution, upgrades or mixed-version operation,
  and non-developer installation, failure, and recovery. State expected outcomes,
  supported scope, and why excluded cases are unsupported or irrelevant. A small
  plugin fix with no such risk does not need an unrelated version matrix.
- Explain the end-user impact and migration/recovery tradeoff of deliberately
  unsupported combinations. Do not assume every plugin supports every core
  version or require indefinite backwards compatibility. Neither prebuilt assets
  nor install-time building is correct by default; justify the choice from the
  actual paths and supported scope.

Unsupported critical claims block the dependent decision and implementation.
Escalate to the scope owner (architect when present) for a decision or a separately
authorized experiment; do not substitute optimistic assumptions for evidence.

## Repository layout

- Parent core worktree: `~/Code/Work/Whitebox/whitebox`
- Parent plugin repositories:
  `~/Code/Work/Whitebox/whitebox/plugins`
- Feature plugin worktrees: the active core feature worktree's `plugins`
  directory

Create plugin worktrees from their corresponding parent repositories. Never use
another feature worktree as the canonical parent.

## Synchronize and prepare worktrees

Before creating or switching feature branches or worktrees:

1. Fetch the latest remote state for the parent core repository.
2. Update the parent core repository's local `main` without discarding changes
   or rewriting history.
3. For each relevant plugin, run `make sync-main` from the parent plugin
   repository.
4. Create feature worktrees from the updated `main`, unless the ticket
   explicitly names another base.
5. Verify every selected worktree is on the requested branch and has the
   expected upstream/base.

Do not overwrite dirty worktrees, delete worktrees, force branches, or repair
divergent history without explicit authorization.

## Develop with local plugin dependencies

For core/plugin co-development, add each modified plugin to the core backend
`plugins-temporary` dependency group from inside the backend development
container as an editable local path:

```bash
poetry add -e --group plugins-temporary /plugins/whitebox-plugin-name
```

Do this for every modified plugin. Verify the path and resulting Poetry
configuration and lockfile. Keep editable dependencies during development and
validate cross-repository behavior.

## Prepare a push

This ordering applies only when publication is explicitly authorized. Preparing
a draft or readiness report does not authorize any push or MR/ticket mutation.
An explicitly requested early/draft push or review may proceed with its state,
missing evidence, and limits clearly labeled; it is not final readiness.

Before pushing core changes, reconcile the planned repository set, branches,
dependency refs, and unresolved relationships locally. No MR URLs are needed to
plan or review unpublished changes; never invent them. Once MRs exist, use the
[ReviewBundle discovery](../whitebox-review/SKILL.md#resolve-the-reviewbundle-first)
to reconcile the actual effort. Follow the canonical
[branch and draft-MR publication order](references/merge-request-workflow.md#publish-branches-and-draft-mrs),
including affected SDK/library providers and standalone cases. It obtains a real
core `PARENT` URL before creating coordinated child MRs; publication order is not
merge order.

Replace this effort's editable plugin dependencies in core with Git dependencies
targeting their real pushed branches:

```bash
poetry add --group plugins-temporary git+https://gitlab.com/whitebox-aero/whitebox-plugin-name.git#feature/whitebox-1337
```

Run this from core's backend directory inside its backend development container.
Substitute the actual repository/branch, verify pushed refs and refreshed
lock-resolved commits, and validate the resulting configuration before pushing
core. Preserve unrelated dependency entries.

For later provider changes or resumed local development, follow that same
canonical publication procedure; do not leave a consumer lock on an old commit.

## Validate

For explicitly requested SBC testing, keep the focused checks needed for safe,
credible testing, but do not wait for CI during the manual push/pull/deploy loop.
Track missing or failing checks without claiming readiness. The user's manual
green flag starts CI cleanup and the normal final validation/project-review gates;
it is not permission to merge or bypass them. Follow the SBC reference for this
phase distinction and for retaining the deployment the user is testing.

- Run repository-provided focused tests, linting, and formatting for every
  changed repository.
- Validate core with the touched plugins installed through the dependency mode
  appropriate to the current phase.
- For packaging or production-installation changes, inspect the built or
  published-equivalent artifacts and exercise the relevant installation/runtime
  paths in an authorized safe environment when needed to establish the claimed
  behavior. Also check relevant development behavior. Editable installs expose
  source files that may be absent from a package; their success cannot replace
  required artifact validation. Local builds can supply equivalent artifacts;
  real registry publication is not required or implicitly authorized.
- Trace what core and relevant consumers actually installed: package versions,
  resolved Git commits, artifact identity, dependency entries, and lock state.
  Branch labels or an intended override alone do not establish what was tested.
  Confirm worktrees and branches as well.
- Report the selected scenarios, environment, exact revisions/artifacts, commands,
  expected outcomes, actual results, and unavailable checks. Separate source
  inspection from execution. Required missing evidence blocks approval/readiness;
  name its owner and next action rather than treating it as a minor residual risk.

## Merge requests and ticket

Use [references/merge-request-workflow.md](references/merge-request-workflow.md)
as the canonical MR and ticket format.

For an explicitly authorized merge, follow its
[SDK → plugins → core sequence](references/merge-request-workflow.md#merge-and-verify-publication)
and [failed-job/publication checks](references/merge-request-workflow.md#failed-jobs-or-publication).
An evidenced core-first recovery needs
[separate informed approval](references/merge-request-workflow.md#exceptional-core-first-recovery)
and a new published-dependency follow-up MR; ordinary merge authority is not that
approval. Reading this skill grants no operational authority. In the architect
flow, architect plans/delegates through a Task Brief; developer performs only
authorized operations.

Author/developer owns code and explanatory fixes. Investigate external reviewer
disagreements against the evidence, record the resolution, and escalate unresolved
material decisions rather than silently omitting feedback or asking the reviewer
to rewrite the submission. Keep implemented/validated, AI-reviewed,
author-reviewed/understood, and ready-for-project-review distinct. Only the human
author can confirm understanding; internal AI approvals do not automatically
count as the project's required code or product review votes.

Creating or updating branches, pushes, merge requests, and tickets changes
external state. Do it only when the user's request authorizes that phase; never
infer authorization merely from inspecting or setting up the ticket.

Do not put ticket-specific refs or paths in persistent configuration, or
permanent dependencies in `plugins-temporary`.
