---
name: diagnosing-bugs
description: Use ONLY for hard, intermittent, recurrent, or performance bugs that need disciplined diagnosis; do not use for obvious one-line failures.
---

# Diagnosing hard bugs

Use this evidence-first process within the current Task Brief, risk-based
testing policy, validation requirements, and mandatory dual-review workflow.
It grants no additional execution, data-access, or external-action authority.
Collect only context relevant to the failure, not an exhaustive environment
matrix. Obvious one-line failures remain outside this skill's trigger.

## Establish and discriminate

1. Record the exact observed symptom and expected behavior, including the actual
   status/error where relevant. Identify the source/artifact revision, command or
   request, and relevant environment: browser/device, authentication state, cache,
   network, and server differences. Describe authentication state without copying
   credentials or customer data. Another browser's success does not disprove the
   reported browser's failure; keep both observations and their conditions.
   Relate the symptom to the brief's acceptance anchor: the normal user journey
   and target environment, not just a convenient component or synthetic fixture.
   Check high-risk device/browser capabilities early before building a harness
   around assumptions that the environment cannot support.
2. Establish one tight, agent-runnable feedback command that reproduces the user's
   exact symptom and can turn green after a fix. Minimize the reproduction without
   changing that symptom, retaining the original reproduction for validation.
   Failure to reproduce is evidence about the tested conditions, not proof that
   no bug exists. Continue investigating a meaningful loop within authority;
   without one, do not implement unsupported production guesses.
3. Before editing production code, write multiple ranked, falsifiable hypotheses
   and a prediction that distinguishes each from the alternatives. Test one
   prediction at a time with targeted instrumentation; update the ranking from
   results, including contradictory evidence. For performance failures, prefer
   measurements over intuition.
4. Prefer existing portable logs, traces, and test tooling within authorized
   access. Inspect retained recordings/artifacts before asking the user to
   repeat collection. Reuse evidence and name what's missing rather than adding
   a vendor upload, proprietary CI integration, or dependency for observability.
5. Add regression protection at a stable or public seam when risk justifies it,
   exercising the observed failure conditions. Implement the smallest
   evidence-supported fix, then rerun the minimized and original reproductions
   and relevant tests.

For intermittent failures, keep failing and passing runs with conditions/counts
and available seeds, timing or traces. Preserve the relevant failure conditions
when minimizing a reproduction: disabling tracing or changing cleanup can remove
the symptom without testing the fix. Record those differences. Repeated green
runs prove neither causality nor elimination; seek evidence of the mechanism and
regression protection under the failing conditions. Report confidence limits,
remaining uncertainty and what was not reproduced, not invented statistical
certainty or a universal retry quota. Prefer one distinguishing experiment to
another full-suite retry.

## Stop uninformative iteration

Stop and escalate when repeated attempts produce no discriminating evidence,
assumptions remain invalid, required access or environment is unavailable, or
costly iteration prevents useful progress. This includes repeated builds with
no new information. Do not silently switch environments until something works,
lower the success criteria, or loop indefinitely.

Report attempts and their evidence, current ranked hypotheses, the exact
blocker, its owner, and the next useful action through the existing escalation
path (to architect under the shared workflow). Request the specific environment,
captured artifact, access, instrumentation, or authorization needed, not just
"more context". Missing required validation blocks approval; investigation may
resume when the blocker is resolved, not by substituting a speculative fix.

Architect owns [expert escalation](../../agents/architect.md#expert-help);
developer does not call big-brain directly. Consultation alone never releases
an experiment: assigned scratch and an approved environment still need explicit
experiment authority.

## Preserve evidence before cleanup

Keep the useful sanitized evidence needed for follow-up: minimal reproduction,
environment and revision identity, relevant commands/results, selected traces
or state snapshots, supported root cause, rejected hypotheses worth retaining,
and actual validation limits. If the cause is unresolved, say so rather than
turning a hypothesis into a finding.

Use existing approved project, ticket, or artifact homes with their access and
retention practices. Evidence retention does not mean automatically committing
logs or keeping private transcripts permanently. Keep credentials and customer
data out of retained artifacts; do not post or upload externally without
authorization. If no safe approved home is available, report that blocker
before discarding needed evidence.

Read and apply the developer's
[product/tooling/experiment criteria](../../agents/developer.md#scope-and-freedom-to-change-code)
to decide what should remain. After retaining useful evidence, remove owned
temporary instrumentation and disposable leftovers, then check cleanup. Preserve
unrelated work and intentionally retained state. Follow the
[remote-compute lifecycle](../remote-compute/SKILL.md#tear-down-only-when-requested)
when active: ordinary completion does not tear down the worker. Diagnosis cleanup
is not authority for broad cleanup, data destruction, or external/shared-service
changes. Do not silently delete evidence.

## Build and operational evidence

When relevant, distinguish reproducing a build from validating the resulting
driver, image, or feature. A supplied binary does not establish a reproducible
build, and a successful build does not establish correct runtime behavior. If
sharing an artifact is authorized, identify its source revision and dirty state
or input snapshot, build configuration/environment, provenance, integrity
checksum, and tested behavior/limits as appropriate. Container tooling may be
a separately scoped remedy, not a mandatory new system.

Promote demonstrated recurring lessons into existing preflight or troubleshooting
documentation when in scope; otherwise propose a named follow-up. Preserve any
agreed follow-up in its approved home before removing its TODO. Separate
exploratory suggestions from validated guidance. For storage/media issues,
filesystem consistency is not media-health validation; destructive write tests
require explicit authorization and safe target identification and data handling.

## Completion

Claim a fix only after the feedback command goes red-to-green, the evidence
distinguishes the hypothesis, minimized and original reproductions pass, relevant
regressions are checked, useful sanitized evidence is retained and owned temporary
diagnostics are cleaned up. Keep the intermittent-failure limits above explicit.

Report unmet fix criteria as incomplete/blocked, with evidence and next action.
An investigation-only deliverable can conclude with an unresolved cause.
Component or synthetic success still does not prove the normal target journey.

Do not impose blanket TDD or launch extra review agents. This skill does not
authorize commits, pushes, publication, or external mutations.
