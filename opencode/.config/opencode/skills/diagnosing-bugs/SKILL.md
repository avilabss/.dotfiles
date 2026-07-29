---
name: diagnosing-bugs
description: Use ONLY for hard, intermittent, recurrent, or performance bugs that need disciplined diagnosis; do not use for obvious one-line failures.
---

# Diagnosing hard bugs

Use this evidence-first process within the current Task Brief, risk-based
testing policy, validation requirements, and mandatory dual-review workflow.

1. Establish one tight, agent-runnable feedback command. Demonstrate that it
   reproduces the user's exact symptom and can turn green after a fix.
2. Reproduce and minimize the failure without changing the exact symptom.
3. Before editing production code, write multiple ranked, falsifiable
   hypotheses.
4. Test one prediction at a time with targeted instrumentation. For performance
   failures, prefer measurements over intuition.
5. When regression risk justifies it, add a regression test at the appropriate
   stable or public seam. Then implement the smallest evidence-supported fix.
6. Rerun the minimized and original reproductions, relevant tests, and cleanup
   checks. Remove all temporary instrumentation and artifacts.

Completion requires a demonstrated red-to-green feedback command, evidence
that distinguishes the selected hypothesis, successful minimized and original
reproductions after the fix, relevant regression checks, and a clean workspace
without diagnostic leftovers.

If no meaningful feedback loop can be constructed, stop. Report what was
attempted and request the specific environment, captured artifact, access,
instrumentation, or authorization needed. Do not proceed with unsupported
implementation guesses.

Do not impose blanket TDD, launch extra review agents, commit, push, publish, or
mutate external systems.

Adapted from diagnostic patterns reviewed in
[`mattpocock/skills`](https://github.com/mattpocock/skills) at revision
`2ab958093e83e0ec752e6c1c5932da465bf23e0c` (2026-07-28).
