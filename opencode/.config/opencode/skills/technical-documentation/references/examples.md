# Focused explanation examples

These are small contrasts, not formatting rules. Except for the source-based
OpenCode setup explanation, the scenarios and Python snippets are invented,
unexecuted illustrations, not verified Whitebox code or production recipes.
Their stated constraints are hypothetical; verify equivalent claims against
real source before using them in project documentation. Read the section that
matches your reader's task rather than copying every example's shape.

## Explain a proposal with an open decision

Audience: a product/engineering teammate deciding whether an invitation flow is
ready to implement. Hypothetical facts: invitations expire after a day; the server
checks expiry before granting access; the delivery channel is not yet selected.

An inventory hides both the mechanism and the decision:

> The design uses invitations, tokens, expiry validation and delivery integration.

A proposal can explain the normal flow without pretending it is fully decided:

> An administrator invites a teammate to a workspace. The server creates an
> invitation that expires after 24 hours. When the teammate opens it,
> the server checks the invitation before granting access to that workspace.
> An expired invitation grants no access.
>
> We have not selected how to deliver invitations. Email would let the teammate
> open one directly, but needs a configured mail service. An administrator copying
> the link avoids that service dependency but leaves delivery to them. Choose the
> delivery route before implementing that part of the flow.

Copy the connection between actor, mechanism, result and open choice. Keep the
useful technical contrast: delivery affects setup. Do not copy the 24-hour policy
or imply that this example proves token security. A real design must establish
authentication, authorization and token handling from its own contracts.

## Write an MR for another reviewer

Audience: a contributor with the project's existing review build running in a
supported desktop browser. Hypothetical change: a table retains sorting in the
current tab across page reloads, but a fresh independent tab starts with defaults.
The supplied validation facts are source inspection and a focused component test;
the desktop browser journey has not run. Private worker setup is irrelevant to
manual acceptance. The quoted description below illustrates those facts, not
tests performed for this repository.

> ### What
>
> The results table remembers the selected sort column and direction when you
> reload the page in the same browser tab. A fresh independent tab still uses the
> default order.
>
> ### Testing
>
> Use your existing review-build setup in a supported desktop browser and a table
> with different values in the Name column.
>
> 1. Select Name and set descending order. The rows should appear in that order.
> 2. Reload the page in the same tab. Name and descending order should remain selected.
> 3. Open the table in a fresh independent tab, rather than duplicating the old tab.
>    It should start with the default sort.
>
> Source inspection and the focused component test cover the stored sort value,
> not this complete browser journey. Browser acceptance remains for the project
> reviewer to run; report any difference between these expected results and the build.

Copy observable actions/results and the honest boundary between component evidence
and manual acceptance. Replace private execution details with relevant platform
and coverage facts, not with claims of broader success. Use the real project's
template, including its other required sections; this excerpt is not a substitute
Whitebox template. Link project-owned setup docs when prerequisites need more
explanation. Do not add worker login/sync instructions, test-count inventories or
links the reviewer cannot access. Keep a useful limitation here instead of
repeating it in every section.

## A comment that preserves a constraint

Before:

```python
# Convert to a tuple.
self.handlers = tuple(handlers)
```

After, assuming a dispatcher whose handler order must stay fixed after creation:

```python
# Freeze registration order: mutating the caller's list must not change which
# handlers this dispatcher runs. The handler objects themselves remain shared.
self.handlers = tuple(handlers)
```

The first comment repeats syntax. The second explains ownership and the invariant
that would be broken by retaining the caller's list. It also avoids claiming a
deep copy. If that constraint does not exist, omit the explanation rather than
inventing a reason for the tuple.

## Group code by meaning

Before:

```python
def mean_duration(samples):
    values = tuple(samples)
    if not values:
        raise ValueError("at least one sample is required")
    total = sum(values)
    count = len(values)
    return total / count
```

After:

```python
def mean_duration(samples):
    values = tuple(samples)
    if not values:
        raise ValueError("at least one sample is required")

    total = sum(values)
    count = len(values)
    return total / count
```

One blank line separates input preparation and rejection from calculation.
Behavior is unchanged. No helper extraction or arbitrary maximum block length
is needed to make these two responsibilities visible. Larger real functions
may need different boundaries; whitespace cannot repair a confused design.

## Make an instruction usable

This is an invented contrast applying the maintained workflow's distinction
between evidence retention and cleanup, not a report of an experiment.

Before:

> Ensure proper handling of all artifacts before proceeding appropriately.

After:

> Developer retains the failed trace and its command/environment before deleting
> the temporary probe. Otherwise the next investigator cannot compare the failure
> with a passing run under the same conditions. Keep credentials out of the trace
> retained for handoff.

The second instruction names the actor, order, evidence and reason. It does not
invent a retention service or imply that every raw log should be committed.

## Turn an inventory into a reader explanation

This contrast uses the supported local skill pattern in the
[OpenCode V2 skills guide](https://opencode.ai/v2/docs/skills). It is a source-based
illustration, not a report of a runtime discovery test.

Before:

> Skills have SKILL.md, frontmatter, references, and scripts. There is a skill
> tool and a discovery mechanism.

After, for a contributor who already has OpenCode V2 and wants a project skill:

> A skill gives an agent reusable instructions for a specific task without
> loading those instructions into every conversation. OpenCode advertises a
> permitted skill's description; the agent loads its body when needed.
>
> In your project, create `.opencode/skills/release-notes/SKILL.md` with a
> description stating when to use it and a body containing the workflow. The
> directory determines the skill ID, `release-notes`; the frontmatter name is
> only its display label. Keep supporting material in `references/` beside it.
> Paths in the skill are relative to that skill directory, and supporting file
> contents are not loaded automatically, so tell the agent which file to read.
>
> Ask the agent to load `release-notes`. Successful loading supplies the skill's
> instructions, not proof that the workflow was executed. If it cannot load,
> check the exact filename and ID, description, skill permissions, and whether
> a later source overrides that ID using the guide's troubleshooting section.

The after version introduces the reusable-instruction concept before its
OpenCode implementation, gives a concrete authoring path and expected outcome,
and points to recovery checks. It does not copy the entire discovery reference.
A reference page about frontmatter fields would instead stay focused on those
fields and link to an authoring guide rather than repeat this explanation.
