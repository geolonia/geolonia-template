# CLAUDE.md

> Claude Code-specific settings. See AGENTS.md for project info and conventions.

## Hooks

`scripts/hooks/guard.sh` (PreToolUse) and `scripts/hooks/post-tool-format.sh` (PostToolUse) run automatically. They handle destructive operation blocking, branch protection, pre-push checks, config file protection, and auto-formatting. See the scripts for details.

## Workflow

1. Write tests before implementation
2. Run `/code-review-expert --auto` before every push

<!-- TODO: Add project-specific workflow notes -->
<!-- Examples:
- "Run npm start before E2E tests — the server must be running"
- "After changing API endpoints, update docs/API.md and the OpenAPI spec"
- "New features require an ADR in docs/decisions/"
-->

## Project Notes

<!-- TODO: Add context that helps the agent make better decisions -->
<!-- Things that aren't obvious from the code or config files -->
<!-- Examples:
- "This is a FIWARE-compatible broker. All entity operations must follow NGSIv2 spec"
- "The proxy in vite.config.ts forwards /v2/* to localhost:3001 — add new API paths there too"
- "Config values are centralized in src/config/defaults.ts — never hardcode"
-->
