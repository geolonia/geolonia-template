---
name: code-review-expert
description: "Expert automated code review with SOLID, security, and quality checks. Supports --auto mode for CI/pre-push hooks. Use /code-review-expert or /code-review-expert --auto"
license: MIT
tags:
  - code-review
  - security
  - solid
  - automation
  - quality
---

# Code Review Expert

## Overview

Perform a structured review of the current git changes with focus on SOLID, architecture, removal candidates, and security risks. Default to review-only output unless the user asks to implement changes.

## Severity Levels

| Level | Name | Description | Action |
|-------|------|-------------|--------|
| **P0** | Critical | Security vulnerability, data loss risk, correctness bug | Must block merge |
| **P1** | High | Logic error, significant SOLID violation, performance regression | Should fix before merge |
| **P2** | Medium | Code smell, maintainability concern, minor SOLID violation | Fix in this PR or create follow-up |
| **P3** | Low | Style, naming, minor suggestion | Optional improvement |

## Workflow

### 1) Preflight context

- Use `git status -sb`, `git diff --stat`, and `git diff` to scope changes.
- If needed, use `rg` or `grep` to find related modules, usages, and contracts.
- Identify entry points, ownership boundaries, and critical paths (auth, payments, data writes, network).

### 1.5) Automated lint & typecheck (MANDATORY)

Run the project's lint and typecheck commands **before** starting the manual review.

**Execution order**:
1. **Typecheck**: `npm run typecheck` or `pnpm run typecheck`
2. **Lint**: `npm run lint` or `pnpm run lint`

**Rules**:
- If either command **fails**, report all errors as **P1 findings**.
- If both **pass**, note "Typecheck: PASS, Lint: PASS" in the review summary.

### 2) SOLID + architecture smells

Look for:
- **SRP**: Overloaded modules with unrelated responsibilities.
- **OCP**: Frequent edits to add behavior instead of extension points.
- **LSP**: Subclasses that break expectations or require type checks.
- **ISP**: Wide interfaces with unused methods.
- **DIP**: High-level logic tied to low-level implementations.

### 3) Removal candidates

Identify code that is unused, redundant, or feature-flagged off.

### 4) Security and reliability scan

Check for:
- XSS, injection (SQL/NoSQL/command), SSRF, path traversal
- AuthZ/AuthN gaps, missing tenancy checks
- Secret leakage or API keys in logs/env/files
- Rate limits, unbounded loops, CPU/memory hotspots
- Unsafe deserialization, weak crypto, insecure defaults

### 5) Code quality scan

Check for:
- **Error handling**: swallowed exceptions, missing async error handling
- **Performance**: N+1 queries, unbounded memory, missing cache
- **Boundary conditions**: null/undefined, empty collections, numeric boundaries

### 6) Output format

**Check `--auto` flag FIRST to decide output format.**

#### Auto mode output (--auto flag present):

```
Review: X files, Y lines | Typecheck: PASS/FAIL | Lint: PASS/FAIL
P0: 0 | P1: 0 | P2: N | P3: N
[If P0/P1 exist, list ONLY those — one line each: file:line — description]
```

Maximum 10 lines. No P2/P3 details, no markdown headers.

#### Interactive mode output (no --auto flag):

```markdown
## Code Review Summary

**Files reviewed**: X files, Y lines changed
**Overall assessment**: [APPROVE / REQUEST_CHANGES / COMMENT]

## Findings

### P0 - Critical
(none or list)

### P1 - High
- **[file:line]** Brief title
  - Description of issue
  - Suggested fix

### P2 - Medium
...

### P3 - Low
...
```

### 7) Next steps — AUTO vs INTERACTIVE

#### If `--auto` IS present (auto mode):

1. If P0 or P1 issues exist -> fix them immediately, no questions asked
2. If NO P0/P1 issues -> output the summary
3. Do NOT use AskUserQuestion under any circumstances
4. Do NOT wait for user input
5. After the review, immediately continue with remaining workflow steps

#### If `--auto` is NOT present (interactive mode):

After presenting findings, ask user how to proceed:

```
How would you like to proceed?
1. Fix all
2. Fix P0/P1 only
3. Fix specific items
4. No changes — review complete
```

Do NOT implement any changes until user explicitly confirms.
