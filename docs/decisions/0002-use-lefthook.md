# ADR-0002: Use Lefthook for Git Hooks

**Status**: Accepted
**Date**: 2026-03-09
**Author**: @geolonia/platform

---

## Context

Git hooks (pre-commit, pre-push) provide Layer 2 feedback in the 4-layer quality model:
faster than CI (minutes) but slightly slower than PostToolUse hooks (milliseconds).

The most common approach is Husky + lint-staged, but this has performance and configuration
overhead. We need a solution that is fast, easy to configure, and works well with
non-Node.js tools (like Biome and tsc).

## Decision

We will use **Lefthook** for Git hooks in all new TypeScript repositories.

Husky and lint-staged will **not** be used in new repositories created from this template.

## Options Considered

### Option A: Husky + lint-staged (current de facto standard)

**Pros:**
- Very widely adopted
- `npm install` auto-setup via `postinstall` hook
- lint-staged runs only on staged files (efficient)

**Cons:**
- Two tools (Husky + lint-staged), two configs
- Node.js dependent: Husky requires npm scripts for hook setup
- lint-staged config can be complex (glob patterns for each tool)
- Slow-ish: Node.js startup overhead on each hook run

### Option B: Lefthook (Go-based hook manager)

**Pros:**
- **Single binary** (Go): No runtime dependency on Node.js
- **Parallel execution**: Multiple commands run simultaneously
- **Native staged-files support**: `{staged_files}` placeholder in config
- **Simple YAML config**: `lefthook.yml` is readable and maintainable
- **Fast**: Go binary starts faster than Node.js scripts
- **All in one**: No need for a separate `lint-staged` tool

**Cons:**
- Less widely known than Husky
- Requires `npx lefthook install` after cloning (vs Husky's auto-postinstall)
- Some developers may not be familiar with it

### Option C: Simple shell scripts (`.git/hooks/`)

**Pros:**
- No dependencies

**Cons:**
- Not committed to the repository (`.git/hooks/` is not versioned)
- Each developer must set up manually
- No parallel execution support

## Rationale

Lefthook was chosen because:

1. **Speed**: Go binary starts faster than Node.js. Important for pre-commit hooks
   that run on every commit.

2. **Simplicity**: One tool, one `lefthook.yml`. No need for a separate `lint-staged` config.

3. **Parallel execution**: `parallel: true` in `lefthook.yml` runs typecheck and lint
   simultaneously, reducing total hook time.

4. **Compatibility with non-Node tools**: Biome and tsc can be invoked directly without
   the Node.js wrapper overhead that lint-staged adds.

5. **Stage-aware**: `{staged_files}` variable passes only staged files to Biome,
   avoiding unnecessary checks on unstaged files.

## Consequences

### Positive
- Faster pre-commit hooks (parallel execution)
- Simpler configuration (one file instead of Husky + lint-staged)
- Works well with Biome (see ADR-0001)

### Negative / Trade-offs
- Developers must run `npx lefthook install` after cloning
- Less community awareness than Husky

### Migration for existing repos
- Remove: `husky`, `lint-staged` from devDependencies
- Remove: `.husky/` directory and `lint-staged` config in `package.json`
- Add: `lefthook` devDependency
- Create: `lefthook.yml`
- Run: `npx lefthook install`

## Implementation Notes

- `lefthook.yml` is a protected file (cannot be modified by agents via guard.sh Hook 5)
- After cloning this template, run: `pnpm install && npx lefthook install`
- The pre-push hook runs tests, so ensure Vitest is set up before pushing

## References

- [Lefthook documentation](https://github.com/evilmartians/lefthook)
- [Harness Engineering Best Practices 2026](https://nyosegawa.github.io/posts/harness-engineering-best-practices-2026/)
- [ADR-0001: Use Biome](./0001-use-biome.md)
