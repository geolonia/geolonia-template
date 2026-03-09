# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial template structure for Geolonia TypeScript library development
- TypeScript 5 strict mode configuration (`tsconfig.json`)
- Biome for linting and formatting (`biome.json`) — see ADR-0001
- Lefthook for Git hooks (`lefthook.yml`) — see ADR-0002
- Vitest for testing
- Claude Code Hooks:
  - `scripts/hooks/guard.sh` (PreToolUse: Hook 2-5)
  - `scripts/hooks/post-tool-format.sh` (PostToolUse: auto-format)
- `.claude/settings.json` for Claude Code hook configuration
- `.claude/skills/code-review-expert/SKILL.md` (generic version)
- `AGENTS.md` for agent-agnostic instructions
- `CLAUDE.md` for Claude Code-specific settings (50 lines)
- `catalog-info.yaml` for Backstage + ISMS compliance
- `.github/workflows/ci.yml` for CI/CD
- `.github/CODEOWNERS` for code review requirements
- `.github/dependabot.yml` for automated dependency updates
- `docs/decisions/` with ADR template and initial ADRs
- `src/index.ts` and `tests/index.test.ts` as starter files
