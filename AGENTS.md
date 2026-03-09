# AGENTS.md

> Agent-agnostic instructions for Claude Code, Codex, Cursor, Copilot, and other coding agents.
> See CLAUDE.md for Claude Code-specific settings.

## Tech Stack

| Tool | Purpose | Why |
|------|---------|-----|
| Node.js 22+ | Runtime | LTS with native ESM, top-level await |
| TypeScript 5+ (strict) | Language | Type safety, better tooling, prevents `any` abuse |
| pnpm | Package manager | Faster installs, disk-efficient, strict dependency resolution |
| Biome | Lint + Format | 10-25x faster than ESLint+Prettier. Single tool, no config conflicts |
| Vitest | Testing | Native ESM, fast, Vite-powered |
| Lefthook | Git hooks | Go binary, fast, parallel execution |

## Build & Test Commands

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

- `src/` — Source code (TypeScript)
- `tests/` — Tests mirror the structure of `src/`
- `dist/` — Compiled output (generated, git-ignored)
- `docs/decisions/` — Architecture Decision Records (ADRs)

## Coding Conventions

### Branch Naming
```
feat/<description>    # New features
fix/<description>     # Bug fixes
chore/<description>   # Maintenance, deps
docs/<description>    # Documentation only
```

### Commit Messages (Conventional Commits)
```
feat: add new export function
fix: correct edge case in parser
chore: update dependencies
docs: improve README
```

### PR Rules
- Small PRs (< 400 lines diff) preferred
- Each PR must have a linked GitHub Issue (`Closes #N`)
- All CI checks must pass before merge
- CodeRabbit review required

## Code Style

All style rules are enforced by **Biome** (`biome.json`). Do not modify `biome.json` to suppress errors.

Key rules:
- `any` is **forbidden** (`noExplicitAny: error`)
- Non-null assertions (`!`) are **forbidden** (`noNonNullAssertion: error`)
- All imports must be used (`noUnusedImports: error`)
- Use `const` over `let` when possible (`useConst: error`)

## Testing

- **Test-first**: Write tests before implementation
- **Mirror structure**: `src/foo/bar.ts` → `tests/foo/bar.test.ts`
- **Coverage**: All public exports must have tests
- **No skipping**: Skipped tests = incomplete tests

## Security

- Never commit `.env` or secrets
- Run `pnpm audit` before releasing
- No `eval`, `innerHTML`, `dangerouslySetInnerHTML`
- Review OWASP Top 10 for applicable risks

## Prohibited Actions

Do NOT modify these files (see guard.sh Hook 5):
- `biome.json` — Lint/format config
- `tsconfig.json` — TypeScript config
- `lefthook.yml` — Git hooks config
- `.github/workflows/` — CI/CD pipelines
- `catalog-info.yaml` — ISMS metadata
- `CODEOWNERS` — Review requirements
