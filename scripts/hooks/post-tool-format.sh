#!/usr/bin/env bash
# post-tool-format.sh — Claude Code PostToolUse hook
# Automatically formats and lints files after Write/Edit operations.
# WHY: Provides ms-level feedback (Layer 1). Biome/Oxlint are Rust-based and
#      start in milliseconds, unlike ESLint which takes seconds.
#
# Usage: Called automatically by Claude Code via .claude/settings.json
# Input: FILE_PATH environment variable (set by Claude Code)

set -euo pipefail

FILE_PATH="${1:-${FILE_PATH:-}}"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only process TypeScript/JavaScript files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx|mjs|cjs)$ ]]; then
  exit 0
fi

# Only process files that exist
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

FAILED=0
ERRORS=""

# Step 1: Auto-format with Biome
if command -v npx &>/dev/null; then
  if ! npx biome format --write "$FILE_PATH" 2>/dev/null; then
    FAILED=1
    ERRORS+="[biome format] Failed to format $FILE_PATH\n"
  fi

  # Step 2: Lint check with Biome
  if ! npx biome check "$FILE_PATH" 2>&1; then
    FAILED=1
    ERRORS+="[biome check] Lint errors in $FILE_PATH\n"
  fi
fi

if [[ $FAILED -eq 1 ]]; then
  echo -e "$ERRORS" >&2
  exit 1
fi

exit 0
