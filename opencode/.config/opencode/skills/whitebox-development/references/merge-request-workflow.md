# Whitebox publication and merge workflow

Read this reference for authorized branch/MR publication, ticket updates, or
merging a Whitebox effort. Publication, SBC testing, final readiness, and merging
are separate phases; publishing a draft is not permission to merge.

## Preparation and authority

Prepare the complete repository/ref inventory and review evidence using
[the development skill](../SKILL.md) before publication. For existing MRs, resolve
the [ReviewBundle](../../whitebox-review/SKILL.md#resolve-the-reviewbundle-first)
rather than assuming proposed links are real. Record original comparison bases
and exact reviewed revisions/state across the effort, including relevant
unchanged providers/consumers. Individual repository or task approvals do not
replace cumulative review.

A local draft or readiness report authorizes no external action. Pushes, MR
creation/updates, feedback posting, ticket edits, approvals, merging, publication,
and CI retry/cancellation each remain subject to the user's authorized scope.
An explicitly authorized early/draft
submission is allowed with incomplete readiness clearly labeled and missing
checks identified; do not represent it as final approval. `/wb-review` remains
strictly read-only even when it produces a report suitable for later publication.

## Publish branches and draft MRs

Publication order is not merge order. A coordinated plugin MR needs a real core
`PARENT` URL, and plugin MR CI needs its `KERNEL` branch already pushed. Creating
plugin MRs first leaves those relationships unavailable.

1. Discover the actual repositories, provider/consumer edges and existing MRs,
   including affected SDKs/libraries. Reuse matching MRs; do not prepare every
   repository by default. Confirm publication authority and task-owned commits.
2. Commit and push changed providers before consumer references. For core/plugin
   co-development, push plugin branches, replace core editable overrides with
   those real Git refs using [push preparation](../SKILL.md#prepare-a-push),
   refresh lock-resolved commits, then commit and push core. Apply provider-first
   ordering to SDK/plugin dependencies too; local paths must not escape into CI.
3. If the effort needs a core MR and none exists, create a **draft core MR** now
   to obtain its URL. Use the core template, noting relationships still being
   filled and missing checks. Referenced dependency branches must already exist.
   This intermediate MR is not ready for review, deployment, or merging.
4. Create/update coordinated plugin MRs with the real `PARENT` and `KERNEL` block
   below, then complete core `Related MRs` and ticket links, including libraries.
   SDK MRs use their own repository template, not the plugin-only block. If no
   template exists, describe scope, testing and actual relationships concisely.
5. Reconcile pushed refs, MR/ticket links and locks before declaring publication
   complete or starting [SBC reset/deployment](sbc-testing.md#complete-publication-before-device-operations).
   Label draft/testing state and missing evidence honestly.

Never publish a consumer ref to an unpushed provider. For later changes, push the
provider first, refresh the consumer's lock-resolved commit, push the consumer,
and update existing MRs. A branch label alone does not prove the new commit is
under test. Resume editable paths only for local development, then repeat push
preparation before publication.

### Standalone plugin or library efforts

Confirm through discovery that no coordinated core change/parent MR is needed.
Use core `main` where appropriate; do not create an empty core MR or fake `PARENT`.
Use the repository's applicable template, or, if none exists, a concise truthful
description of scope, testing and actual relationships. Explain the absent parent
in review context. Standalone plugin CI defaults to core `main` when `KERNEL` is
absent; include real `KERNEL` evidence when another branch is needed. A genuinely
inapplicable parent is not a missing required link.

## Plugin MR description

For a coordinated plugin MR, use only this relationship block as the description:

```md
PARENT: https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx

___

KERNEL: #<branch-name>
```

Replace both placeholders. `PARENT:` points to the core MR. `KERNEL: #<branch>`
selects the core feature branch required by plugin CI; retain the `#`, spelling
and capitalization exactly. Without `#`, the CI parser can interpret the branch
as a clone URL. Standalone MRs follow the exception above, not a fake parent block.

## Core MR description

Read the current core `.gitlab/merge_request_templates/default.md` and consolidate
the ticket's core, plugin, and library changes there. Use its existing sections,
not a second readiness form:

- **What**: concrete affected behavior and contracts, with per-repository scope.
- **Why / How**: the problem, chosen approach, compatibility expectations and
  tradeoffs, and links to tracked decisions/contracts. For substantial changes,
  give a reading order across repositories and identify the risky paths. The MR
  summarizes durable rationale rather than being its only home.
- **Testing**: put reproducible setup and commands in Developer Testing
  Instructions, with prerequisites, working directories, dependency mode,
  revisions/lock state and artifact identities. Include expected outcomes and
  actual evidence, distinguishing execution from inspection. Use Sandbox Testing
  Instructions for applicable product-review steps and Common Testing
  Instructions to avoid repetition. Do not manually edit the auto-managed
  Sandbox Hosting section.
- **Anything Else?**: missing checks with owners/next actions, known risks,
  unsupported combinations and recovery limits, and the current readiness state.
  Required missing evidence is a blocker, not a passed check.

Update the existing `Related MRs` section immediately after `What`; add it there
only if absent:

```md
## Related MRs

- https://gitlab.com/whitebox-aero/whitebox-plugin-name/-/merge_requests/xxx
```

List every related plugin/library MR once and omit the section when there are
none. For coordinated efforts, keep consolidated explanation and per-repository
reading/testing guidance here, not in relationship-only plugin descriptions.

Preserve the project's Before Merge Checklist: testing, documentation where
applicable, two code reviews with no outstanding comment, product review for
user-facing changes, and internal dependency version bumps where applicable.
Do not check review boxes merely because internal AI reviews passed. Report
author understanding only after explicit human confirmation; AI review neither
certifies that understanding nor replaces project code/product review.

## Ticket

Add an `MRs` section at the top of the original ticket and list the core MR, when
applicable, followed by every related plugin/library MR:

```md
## MRs

- https://gitlab.com/whitebox-aero/whitebox/-/merge_requests/xxx
- https://gitlab.com/whitebox-aero/whitebox-plugin-name/-/merge_requests/xxx
```

Preserve the rest of the ticket exactly unless another change is explicitly
requested. Check for an existing `MRs` section and update it instead of adding
a duplicate.

Before finishing, check the links, branch names, dependency refs, and duplicate
sections.

## Merge and verify publication

Begin only when the user authorizes merging this effort. Draft publication or a
manual-testing green flag is not merge approval. Check current project rules,
required code/product reviews, CI, resolved discussions and exact source/target
revisions for each MR. Internal AI votes do not replace project reviews or bypass
branch protection. Dependency edits change the reviewed state: validate, push,
and refresh required reviews/CI before merging it.

1. **SDK/library providers first.** Merge only eligible requested MRs in dependency
   order. Observe their resulting default-branch pipelines, automatic version bump
   and expected registry publication. Verify the publication's source, version and
   artifact contain the intended changes. A merged MR, tag, unrelated green
   pipeline or wrong package version is insufficient. CI may publish from a
   version-bump commit rather than the MR merge SHA.
2. **Consuming plugins next.** Replace this effort's temporary Git/path SDK overrides
   with the verified published releases, update locks in the repository's supported
   environment and test the installed resolved versions/artifacts. Preserve
   unrelated entries. The inspected plugin jobs bump and publish but do not run
   core's temporary-dependency cleanup: leaving an SDK override can publish that
   temporary source in package metadata. Refresh reviews/CI, merge eligible plugins
   in dependency order and verify every needed publication before proceeding.
3. **Core last.** Update the actual normal dependency groups and lockfile to the
   verified latest intended compatible plugin releases. Remove this effort's
   corresponding temporary overrides, not unrelated work; a stale override can
   mask the published package. Validate installed versions/artifacts in normal
   install mode, not only with `plugins-temporary`. Do not broadly upgrade unrelated
   packages. Refresh reviews/CI, then merge eligible core.
4. **Observe completion.** Monitor core main's required CI and configured release/
   publication outputs. Inspect the actual pipeline: core is not assumed to publish
   PyPI. Verify resulting refs/artifacts and report complete or blocked state;
   clicking Merge does not finish the effort.

### Retained dependency reachability

Inspect source-branch deletion and merge policy before merging providers. Immediately
before any normal or exceptional core merge, verify each retained temporary
dependency's repository, named Git ref **and lock-resolved commit** can be fetched
under the consuming build's access. Include relevant transitive Git sources in the
consuming lock, such as an SDK referenced by a plugin. A local path unavailable to
CI is not a usable replacement. Apply provider-before-consumer preparation at
each level.

Squash/deletion can affect reachability but do not universally destroy it. A
reachable commit alone does not repair a missing branch selector. Keep necessary
branches/commits accessible until their dependencies are replaced. If a source is
missing or inaccessible, stop and prepare a reviewed dependency/lock correction
before merging core. Do not silently switch sources, recreate deleted branches,
retag or force-push to pass the gate.

## Failed jobs or publication

For SDKs, plugins and core, inspect the exact project, ref, SHA, pipeline, job and
failure before retrying. A recoverable transient failure may be retried once. If
it repeats without new evidence, stop and report what failed, what already merged/
published, what remains blocked and the next useful remedy. Do not retry
deterministic failures until lucky or loop indefinitely. Honor rate-limit/backoff;
do not busy-poll. No arbitrary version edits, overwritten artifacts, retagging or
force pushes.

Before a side-effectful retry, inspect whether bumps, commits, tags or publication
already happened. Prefer the narrow failed job when safe; never blindly replay a
successful bump/publish step. Pipeline retry can rerun failed/canceled jobs, not
restore consistency. The inspected publish job pulls branch HEAD, so main movement
can also change what a retried job builds. If retry is unsafe, stop for a recovery
decision.

Job retries retain the pipeline's captured includes. When a shared CI definition
changed in core, create a new permitted pipeline if new configuration is needed,
after checking workflow rules and duplicate release side effects. Distinguish this
from retrying failed jobs in an existing pipeline.

## Exceptional core-first recovery

Normal order remains SDK → plugins → core. This exception applies only to an
evidenced plugin-main failure caused by required feature changes missing from core
main, not any failed test. Plugin-main tests clone core main at job runtime; they
can fail before plugin versioning/publication when that core change is absent.

### Approval and preconditions

Ask for **explicit user approval for this effort's exception**, even if ordinary
merging was authorized. Explain intermediate main, affected consumers, retained
temporary refs, the whole pipeline to cancel, timing risk, completion owner and
the new dependency follow-up MR. Main will temporarily retain feature Git overrides
instead of the normal post-maintenance state. Canceled/not-run tests, docs
publication, versioning and other applicable jobs/releases are not validated or
completed by that pipeline; inspect what already ran rather than claim nothing did.

Whole-pipeline cancellation is the approved operation, not a narrower job cancel.
It halts the exceptional interim pipeline until the coherent published-dependency
follow-up runs normally. In the inspected core CI, maintenance removes temporary
dependencies, relocks, bumps versions and pushes commits/tags. Letting it run mid-
sequence would discard overrides still needed by coordinated plugin consumers.
This scoped exception does not authorize removing someone else's temporary work.
Cancellation is neither atomic with merge nor a way to undo completed side effects.

Before merging, inspect the actual current CI/DAG and cleanup job; verify merge/
cancel rights, normal project review/merge gates, exact source/target refs,
[dependency reachability](#retained-dependency-reachability), and the ability to
identify and observe the resulting pipeline promptly. If safe observation/
cancellation cannot be arranged, stop before merging. Do not bypass protections
or promise atomic cancellation.

### Merge, cancel and verify

1. After approval, merge the reviewed core state retaining required accessible
   temporary refs. Immediately identify and cancel the **whole exact main
   pipeline(s) for the actual merge SHA**. Never select an unrelated newer main
   pipeline solely because it is “latest”.
2. Inspect terminal pipeline/job status **and** current main dependency/lock
   contents, commits and tags. HTTP success does not prove cleanup was prevented;
   running/canceled jobs may already have side effects. Keep referenced branches
   and commits reachable. No blanket `[ci skip]`, runner disabling or CI changes
   are authorized by this workflow.
3. If cleanup/versioning ran, cancellation failed/arrived late, identity is
   ambiguous or unrelated main changes interfere, **stop**. Retain sanitized
   evidence and notify the user of actual state and a proposed minimal reviewed
   corrective MR/recovery. Do not retry plugins under false assumptions, rewrite
   main/tags, silently restore dependencies or report the exception complete.
   Approval of this sequence is not advance approval of destructive recovery.

### Publish dependencies and finish the follow-up

Once main retains the intended changes and temporary overrides with the target
pipeline stopped, resume blocked plugin-main tests/publication in dependency order.
Whether to retry a job or create a new pipeline depends on changed source/config
inputs; use the [failure checks](#failed-jobs-or-publication) first. Verify every
needed publication.

Create a **new core MR** replacing this effort's temporary refs with verified
published plugin versions and updated locks. Validate normal dependency mode,
obtain current required reviews/CI and merge as authorized. Let core CI run
normally and monitor required jobs/releases. Do not resume the intentionally
canceled interim cleanup pipeline. If the follow-up stalls, report intermediate
main and the exact next action; the exception remains incomplete.

## Source basis

Reinspect each effort's actual pipeline and package configuration before acting;
these inspected sources establish the rationale, not future live state:

- Core `5148ee47f2252acde1a1fb44aba0292a6e8d17bc`: `.gitlab-ci.yml` main rules,
  stages, maintenance and Pages; `.gitlab/config/shared-ci.yml` kernel selection
  (28–44), plugin tests (361–376), publish (479–494), cleanup/versioning (646–697);
  `packaging/scripts/maintenance/remove_temporary_dependencies.sh`;
  `backend/pyproject.toml` temporary/normal groups; `docs/development_guide.md`
  versioning/temporary dependencies; `.gitlab/merge_request_templates/default.md`.
- SDK example `insta360` at `9427a9613c84164bb9d766b66297a0f78d168baf` and plugin
  example `whitebox-plugin-device-insta360` at
  `9846474c1bbee6835b98033d9aaad0d22ab794e6`: their `.gitlab-ci.yml` includes core
  main and uses shared bump/publish jobs; the plugin's `pyproject.toml` has a normal
  SDK dependency. Examples are not universal SDK contracts.
- GitLab [cancel](https://docs.gitlab.com/api/pipelines/#cancel-all-jobs-for-a-pipeline)
  returns HTTP 200 regardless of state; identify/verify by project, ref and SHA.
  [Pipeline retry](https://docs.gitlab.com/api/pipelines/#retry-jobs-in-a-pipeline)
  reruns failed/canceled jobs; [include snapshots](https://docs.gitlab.com/ci/yaml/#include)
  persist for job retries, while new pipelines fetch includes anew.
