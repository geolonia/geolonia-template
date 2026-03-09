# AGENTS.md

> Agent-agnostic project instructions for all AI coding tools.
> Claude Code users: see CLAUDE.md for hooks and workflow.

## Project

<!-- TODO: Replace with your project info -->

**Name**: my-library
**Description**: A TypeScript library that does X.
**Owner**: group:geolonia/your-team
**License**: MIT

## Commands

```bash
pnpm install          # Install dependencies
pnpm run build        # Compile TypeScript → dist/
pnpm run typecheck    # Type check without emit
pnpm run lint         # Biome lint check
pnpm run lint:fix     # Biome lint + auto-fix
pnpm run format       # Biome format
pnpm run test         # Vitest run (single pass)
pnpm run test:watch   # Vitest watch mode
```

## Architecture

<!-- TODO: Describe your project's structure and design intent -->
<!-- Focus on things that aren't obvious from reading the code -->

```
src/        # Source code
tests/      # Tests (mirrors src/ structure)
dist/       # Compiled output (git-ignored)
docs/decisions/  # Architecture Decision Records
```

## Conventions

### Branches

```
feat/<description>    # New features
fix/<description>     # Bug fixes
chore/<description>   # Maintenance, deps
docs/<description>    # Documentation only
```

### Commits — Conventional Commits

```
feat: add new export function
fix: correct edge case in parser
```

### Pull Requests

- Small PRs preferred (< 400 lines diff)
- Each PR links a GitHub Issue (`Closes #N`)
- All CI checks pass before merge

## Testing

- **Test-first**: Write tests before implementation
- **Tests are specs**: Tests define expected behavior based on requirements — not the current implementation. If a test fails, investigate the implementation first
- **Mirror structure**: `src/foo/bar.ts` → `tests/foo/bar.test.ts`

## Gotchas

<!-- TODO: Document non-obvious pitfalls specific to this project -->
<!-- Things that can't be caught by linters or hooks -->
<!-- Examples:
- "MapLibre sets transform on marker root elements — never apply CSS transform directly on them"
- "FIWARE tenant names must not contain hyphens (causes 400)"
- "All config values must go through src/config/defaults.ts — no hardcoding"
-->

## Security

<!-- TODO: Add project-specific security constraints -->
<!-- Examples:
- "This repo will be open-sourced. Never embed internal infrastructure details (AWS account IDs, internal hostnames, etc.)"
- "All deployment config must be supplied via environment variables, never hardcoded"
-->

- Never commit `.env` or secrets
- Style and lint rules are enforced by Biome (`biome.json`). Do not weaken rules to suppress errors — fix the code instead
