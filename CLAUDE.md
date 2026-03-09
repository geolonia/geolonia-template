# CLAUDE.md

> See AGENTS.md for agent-agnostic instructions (build commands, conventions, architecture).
> This file contains Claude Code-specific settings only.

## Claude Code Hooks

Two hooks protect code quality automatically:

| Hook | File | Trigger | Purpose |
|------|------|---------|---------|
| PreToolUse | `scripts/hooks/guard.sh` | Before Bash/Write/Edit | Block destructive ops + main branch protection + config file protection |
| PostToolUse | `scripts/hooks/post-tool-format.sh` | After Write/Edit | Auto-format with Biome |

**WHY hooks**: Provides ms-level feedback (Layer 1 of the 4-layer quality model). Catches issues before they reach pre-commit (seconds) or CI (minutes).

### guard.sh Protections

- **Hook 2**: Blocks destructive operations (rm -rf, force push, reset --hard, etc.)
- **Hook 3**: Blocks direct commit/push to `main`/`master` — always use a branch
- **Hook 4**: Runs typecheck + lint before push
- **Hook 5**: Blocks agent modification of config files (biome.json, tsconfig.json, etc.)

### Disabling Hooks (for legitimate use)

To temporarily disable for human-initiated work:
```bash
# Remove or rename .claude/settings.json temporarily
mv .claude/settings.json .claude/settings.json.bak
# ... do your work ...
mv .claude/settings.json.bak .claude/settings.json
```

## Code Review

Use the built-in skill before pushing:
```
/code-review-expert --auto
```

See `.claude/skills/code-review-expert/SKILL.md` for details.

## Workflow

1. Non-trivial changes: Use Plan Mode first (`/plan`)
2. Write tests before implementation
3. For changes touching >3 files: create a plan and get approval
4. Run `/code-review-expert --auto` before every push

## Project-Specific Notes

<!-- Add project-specific notes here after cloning the template -->
<!-- Keep total CLAUDE.md under 50 lines -->
<!-- Example:
## API Keys
- SOME_API_KEY: Used for X. See .env.sample for setup.
-->
