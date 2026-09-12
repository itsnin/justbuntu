# Agents Guide

This is the entrypoint for agents working on JustBuntu. Read it before
touching code, then read the relevant skill files under `.agent/skills/`.
The implementation and skills are the source of truth for details; this file
keeps only the project contract, behavior rules, and routing.

## Behavioral Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```less
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Project Contract

JustBuntu is a one-command setup script for Ubuntu 26.04 LTS and newer
desktop releases. It keeps Ubuntu close to stock, makes optional choices
explicit, and supports GNOME while degrading gracefully for other environments.

All application source is rooted at `src/`. The Rust terminal application and
the existing Bash command, core, library, provision, revert, configuration,
migration, and shell trees live there together. `bin/justbuntu` remains the
stable launcher, and the installed terminal application is also named
`justbuntu`.

The durable architecture, install/revert boundaries, and GNOME extension phase
ordering live in
[`project-architecture`](.agent/skills/project-architecture/SKILL.md).

## Skill Routing

Read these first for every non-trivial change:

- [`project-architecture`](.agent/skills/project-architecture/SKILL.md) for
  design contracts, module boundaries, GNOME ordering, and revert boundaries.
- [`guidance-maintenance`](.agent/skills/guidance-maintenance/SKILL.md) for
  what belongs in agent guidance and what must stay out of it.
- [`verification-discipline`](.agent/skills/verification-discipline/SKILL.md)
  for evidence, scope, testing, and reporting claims.
- [`release-versioning`](.agent/skills/release-versioning/SKILL.md) for
  calendar release identifiers, patch sequencing, and tag/release workflow.

Then read the focused skill for the code being changed: shell style, strict
mode, defensive programming, security, quoting, functions, control flow,
arrays, portability, logging, filesystem operations, processes, command
execution, testing, code review, or writing tone. The `.agent/skills/`
directory is the source of truth for the available skills.

## Working Rules

- Keep the entry point as wiring; component logic belongs in its module.
- Keep terminal interaction behind the shared Rust application protocol; do
  not add a second shell UI or direct UI dependency calls in provisioners.
- Keep installation, configuration, and revert responsibilities separate.
- Use Bash for shell modules and Rust for the terminal application; quote shell
  paths, use strict mode, and make changes idempotent where practical.
- Explain why in comments, not what the code already says. Avoid LLM-smell
  wording and unrelated cleanup.
- Inspect all callers and search for the same bug pattern elsewhere before
  fixing a bug.
- Read every changed line before reporting completion.
- Update guidance only when a durable contract or standard changes. Do not add
  inventories, version snapshots, provider URLs, one-off fixes, or history.
- Do not modify README content beyond the smallest requested user-facing
  detail.

## Minimum Verification

Run `bash -n` on every modified shell file and use the smallest focused test
that proves the requested behavior. Run broader checks when the change affects
installer flow, security boundaries, or shared infrastructure. Report missing
tools or unrun tests plainly.
