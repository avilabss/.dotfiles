# Focused explanation examples

These are small contrasts, not formatting rules. The Python snippets are
invented, unexecuted illustrations, not verified Whitebox code or production
recipes. Their stated constraints are hypothetical; verify equivalent claims
against real source before using them in project documentation.

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
