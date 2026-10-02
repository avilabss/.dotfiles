---
name: technical-documentation
description: Use when planning, writing, or reviewing substantial technical documentation or onboarding, or when non-obvious code contracts need explanation. Not for routine typo fixes or generic prose polishing.
---

# Technical documentation

Help a specific reader understand or accomplish something accurately. Apply this
workflow to the authorized work, not as a reason to expand its scope. A small API
reference can be complete without becoming a tutorial; trivial code does not
need encyclopedic docstrings or a new documentation suite.

## Establish the reader task

Before substantial writing, identify:

- Audience and prerequisite knowledge, tools, access, and environment.
- Reader goal and the observable result or question the document must answer.
- Document type and its existing authoritative home, including relevant links.

Inspect repository guidance, source, tests, and primary documentation to resolve
facts before asking the user. Ask only for missing material decisions. Preserve
the repository's tone and structure; update the existing home rather than
creating parallel explanations that will drift.

## Choose what to teach

Use the distinctions in Django's
[documentation organization guidance](https://docs.djangoproject.com/en/5.2/internals/contributing/writing-documentation/#how-the-documentation-is-organized):

| Type | Reader need | Completion check |
|---|---|---|
| Tutorial | Learn by building something | Steps reach an observable useful result early; explain the problem first and concepts when they help the next step or reflection |
| How-to | Complete a particular task with existing knowledge | Prerequisites, steps, expected result, and relevant failure recovery make the task achievable |
| Topic explanation | Understand a concept or constraint | The reader can explain the mental model, why it works this way, and relevant tradeoffs |
| Reference | Look up an exact contract | Inputs, outputs, defaults, guarantees, supported versions, and failure behavior are precise where relevant |

Link between these types instead of mixing every type into every page or
duplicating reference material. Do not import Django's tooling or formatting
rules into another repository. An accurate, focused API reference needs no
tutorial, but a newcomer guide missing setup or a usable result is incomplete.

Teach why and how, not only names of internal components. Introduce a generic
extension concept before an implementation-specific example when readers need
that model to understand the example. Retain foundational explanation even if
it could apply to another project; connect it to this reader's task. Use headings,
paragraphs, lists, and whitespace to group meaning, not to meet line quotas.

## Keep claims and examples honest

- Verify claims against the relevant source and primary documentation. Preserve
  assumptions and supported versions when they affect the result. Never invent
  usage history, research, measured outcomes, rejected alternatives, or rationale.
- Give commands enough context to use safely: working directory, prerequisites,
  placeholders, permissions, side effects, and expected outcomes as relevant.
  Preserve authentication, tenant, secret, path, and other safety boundaries.
  Where failure matters, explain how to recognize it and recover without
  destructive retries or bypassing safeguards.
- Validate examples to their risk: inspect source/contracts, check syntax, and
  exercise representative behavior in an authorized safe environment when
  appropriate. Do not install dependencies, mutate live systems, or run examples
  outside the task's authority just to improve an evidence claim.
- Report the actual commands/checks and results, what was not run, and unmet
  environment requirements. Label invented illustrations and unexecuted examples.
  A documentation build checks structure; it proves neither that examples work
  nor that a reader can learn from them. Missing required evidence blocks approval
  under the shared review contract, rather than becoming an optimistic caveat.

## Explain code where the knowledge belongs

Comments and docstrings should preserve useful local invariants and explain why
an unusual design is necessary. Document relevant ordering, lifecycle, ownership,
failure constraints, and tempting unsafe alternatives, not what the syntax says.
Public contracts describe relevant input/output, guarantees, and failures.
Remove stale explanations when behavior changes; do not add commentary to
self-explanatory code for coverage.

Put cross-cutting decisions in existing tracked architecture documentation or a
focused decision record when warranted, and link from local code. Follow the
project's file ownership rules; this skill grants no authority to edit protected
architecture files. Do not repeat the whole decision at every call site.

Read [the focused examples](references/examples.md) when writing or assessing
comments, semantic code grouping, or explanations that currently read like an
internal inventory. They illustrate the quality bar, not mandatory templates.

## Check with a fresh reader

For substantial new or reworked documentation, the developer must request a
fresh-context check through an existing reviewer, normally as part of the dual
review. A self-pass is preparation, not an independent cold read. Keep phase,
same-state dual approval, and escalation rules in the shared agent contracts.

1. Give the reviewer the intended audience, reader goal and prerequisites, entry
   document, and a short direct read-only authority boundary. No edits, mutating
   commands, experiments, external actions, or approval are authorized in this
   reader stage. Do not supply the Task Brief, diff rationale, an author's
   walkthrough, or a forced contract-first reading sequence.
   If entry text and explanatory notes share a file, supply an explicit safe read
   range or a separate entry artifact. Metadata must not teach the answer.
2. Use a new reviewer context, not a resumed session that already learned the
   explanation. The reviewer first follows the durable reader path and emits
   initial observations, including missing steps, mental models, or contracts,
   before opening the Task Brief, explanatory diff rationale, or author notes.
   Then use the [developer's explicit bootstrap procedure](../../agents/developer.md#review-instruction-delivery)
   before the brief/diff-based full specification, correctness, and scope review.
   The cold read is not a replacement for those duties or for verified loading.
3. Have the reviewer demonstrate a representative reader task when feasible
   within review authority. For a reference, this can be resolving a contract
   question from the page. For instructions requiring unavailable dependencies,
   credentials, edits, or external effects, trace the steps without executing
   them and explicitly report that limit, rather than bypassing authorization.
4. Report inputs used, prior exposure, task attempted, observed gaps, and what
   could not be demonstrated. Developer verifies the order and complete loading
   using the linked delivery procedure, not a final assertion. Disclose unavoidable
   system/catalog/ambient exposure; do not call injected answers independently
   discovered. Scope the check to what can genuinely be assessed, or request a
   fresh context if the target explanation was supplied. Unavailable capability,
   contaminated evidence, or unverified order must be disclosed and remedied;
   otherwise report blocked work with an owner and next action, not a fictitious
   cold-read pass. Do not inspect private reasoning or retain raw sensitive sessions.

Make missing prerequisites, unusable examples, material missing explanation, and
inability to reach the stated reader goal actionable findings: identify where,
the reader impact, and the correction or evidence needed. Separate correctness
and comprehension failures from cosmetic preferences. Author/developer owns
fixes; reviewers are not replacement writers. If AI cannot meet the bar, report
the specific human input or manual writing needed through the existing escalation
path instead of lowering the bar or transferring the obligation to a reviewer.
An AI cold read cannot certify human understanding or ownership.

## Optional prose editing

`unslop` can help polish prose after the technical structure and facts are sound.
Technical accuracy, necessary terminology, qualified uncertainty, foundational
explanation, and repository tone take precedence. Read its
[editing guidance](../unslop/SKILL.md) when using it; prose-origin detection is not
acceptance evidence.
