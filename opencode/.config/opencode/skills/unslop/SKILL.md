---
name: unslop
description: Use when drafting, rewriting, or polishing prose for clarity while preserving meaning and the author's voice.
---

# Unslop

Edit prose so the intended reader can understand and use it. Preserve the
author's voice rather than inventing a personality or trying to disguise how
the text was produced. Prose-origin detection is not a quality check.

## Technical writing takes precedence

For technical documentation, load `technical-documentation` for the reader task,
structure, accuracy, and validation. This skill is an optional editing pass, not
a replacement for those checks. Technical accuracy and the repository's tone
take precedence over every suggestion below.

## Process

1. Identify the audience, purpose, and established voice. Inspect surrounding
   text before changing its tone or structure.
2. Find concrete problems: unclear actors, unsupported claims, repetition,
   filler, or sentences that make the reader backtrack.
3. Edit only where the change helps the reader. Preserve facts, attribution,
   terminology, uncertainty, and necessary explanation.
4. Compare against the original. Check that the reader can still find the action,
   reason, limitation, or source and that no claim has changed accidentally.

## Preserve meaning and voice

- Do not add opinions, anecdotes, measured results, or usage history that the
  author did not supply. Keep existing opinions attributed to their author.
- Preserve qualified uncertainty. "May fail on older hosts" is not equivalent
  to "fails on older hosts"; remove hedging only when it adds no meaning.
- Keep technical terms when they name a real concept. Prefer one consistent
  term over rotating synonyms merely for variety.
- Retain foundational explanation even when it could apply to another project.
  Ask whether this reader needs it, not whether the sentence sounds generic.
- Keep useful examples and local context. Do not introduce deliberate messiness
  or first-person claims to make the text feel more personal.

## Make the point concrete

- Replace praise or abstract significance with the actual behavior or consequence.
  "A groundbreaking reliability improvement" tells less than "The worker retries
  a failed transfer once, then reports the error." The latter is an invented
  illustration, not a claim about this repository.
- Name the actor when it matters: "The server validates the token" is clearer
  than "The token is validated." Passive voice is useful when the actor is
  unknown or irrelevant.
- Replace vague attribution such as "experts believe" with the available source.
  If the source is missing, flag the claim instead of inventing one.
- Use the plain word when it has the same meaning: "use" instead of "utilize",
  "to" instead of "in order to". Do not maintain a blacklist of ordinary words.

## Remove avoidable reading work

- Split dense sentences at a meaningful boundary. Keep conditions beside the
  instruction they qualify; splitting them must not hide a safety constraint.
- Remove repeated introductions, conclusions, and labels that add no information.
  Keep intentional local reminders where readers load sections independently.
- Group related steps and distinguish prerequisites, actions, and expected
  results. Use the document's existing heading and list conventions.
- Let the subject determine the number of examples or list items. Do not force
  ideas into groups of three or rewrite every paragraph to the same length.
- Use punctuation to clarify relationships. Dashes, parentheses, colons, and
  semicolons are allowed; revise overuse only when it makes a sentence hard to
  follow. Preserve punctuation in quotations and technical syntax.
- Use emphasis for navigation or a genuine warning, not to decorate every term.

## Final check

Read the result as someone who has not seen the conversation. Can that reader
identify the point, follow the needed action, and find its limits or evidence?
Compare facts, names, links, quotations, and uncertainty against the original.
Report unresolved factual or structural gaps rather than polishing them away.
