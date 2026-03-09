# ADR-0001: Use Biome for Linting and Formatting

**Status**: Accepted
**Date**: 2026-03-09
**Author**: @geolonia/platform

---

## Context

Every TypeScript project needs consistent code style (formatting) and quality checks (linting).
The traditional choice is ESLint (lint) + Prettier (format), but this combination has friction:
- Two separate tools with separate configs, sometimes conflicting rules
- Slow startup time (ESLint: 2-5 seconds per run)
- Complex configuration for TypeScript strict rules

We need a solution that is fast enough for Claude Code PostToolUse hooks (ms-level feedback)
and simple enough to maintain across many repositories.

## Decision

We will use **Biome** as the unified linter and formatter for all new TypeScript repositories.

ESLint and Prettier will **not** be used in new repositories created from this template.

## Options Considered

### Option A: ESLint + Prettier (current de facto standard)

**Pros:**
- Widely adopted, large ecosystem
- Many plugins available (react, import, etc.)
- Familiar to most developers

**Cons:**
- Two separate tools, two configs
- Slow: ESLint startup takes 2-5 seconds
- Config conflicts between ESLint and Prettier
- Complex TypeScript setup requires `@typescript-eslint/parser`, `@typescript-eslint/eslint-plugin`

### Option B: Biome (Rust-based all-in-one tool)

**Pros:**
- 10-25x faster than ESLint+Prettier (Rust implementation)
- Single tool, single config (`biome.json`)
- Built-in TypeScript support (no extra plugins)
- Fast enough for PostToolUse hooks (Layer 1 feedback)
- `biome migrate` command converts existing ESLint/Prettier configs

**Cons:**
- Smaller ecosystem than ESLint
- Some ESLint plugins have no Biome equivalent (e.g., complex custom rules)
- Newer tool (stable since 2024)

### Option C: Oxlint (Rust-based lint only)

**Pros:**
- 50-100x faster than ESLint
- Strong security ruleset

**Cons:**
- Lint only, no formatting → still needs Prettier
- Does not eliminate the two-tool problem

## Rationale

Biome was chosen because:

1. **Speed**: The 4-layer quality model requires ms-level feedback at Layer 1 (PostToolUse hooks).
   ESLint's 2-5 second startup makes it unusable for this purpose. Biome runs in milliseconds.

2. **Simplicity**: One tool, one config. Reduces maintenance overhead across many repos.

3. **TypeScript-first**: Built-in TypeScript support without plugin configuration.

4. **Future-proof**: Biome is backed by the Rome collective and has strong momentum.

Oxlint's security rules can complement Biome for specific security scanning in CI (Layer 3),
but Biome covers all daily development needs.

## Consequences

### Positive
- PostToolUse hooks give instant format feedback (Layer 1)
- Consistent formatting across all new repositories
- Simpler dependency tree (fewer devDependencies)

### Negative / Trade-offs
- Cannot use ESLint-specific plugins (e.g., `eslint-plugin-react-hooks` for internal rules)
- Developers must learn Biome's config format instead of ESLint's

### Risks
- If Biome lacks a rule we need, we may need to add Oxlint or a custom CI check

## Implementation Notes

- `biome.json` is a protected file (cannot be modified by agents via guard.sh Hook 5)
- `noExplicitAny: error` enforces TypeScript strict mode at the lint level
- Use `biome migrate` to convert existing ESLint/Prettier configs when adopting this template

## References

- [Biome documentation](https://biomejs.dev/)
- [Harness Engineering Best Practices 2026](https://nyosegawa.github.io/posts/harness-engineering-best-practices-2026/)
- [ADR-0002: Use Lefthook](./0002-use-lefthook.md)
