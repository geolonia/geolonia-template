#!/usr/bin/env bash
# guard.sh — Claude Code PreToolUse hook for Bash tool
# Generic version: Hook 2 (destructive ops), Hook 3 (main branch protection),
# Hook 4 (push-before-lint/typecheck), Hook 5 (config file protection)
#
# Reads JSON from stdin: {"tool_name": "Bash", "tool_input": {"command": "..."}}
# exit 0 = allow, exit 2 = block (stderr shown as error message)

set -euo pipefail

# Read JSON from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ============================================================
# Helper: resolve effective working directory from cd in command
# ============================================================
resolve_git_dir() {
  local cmd="$1"
  local cd_target
  cd_target=$(echo "$cmd" | grep -oP 'cd\s+\K("[^"]+"|[^\s&;|]+)' | tail -1 | tr -d '"')
  if [[ -n "$cd_target" && -d "$cd_target" ]]; then
    echo "$cd_target"
  else
    echo "."
  fi
}

GIT_TARGET_DIR=$(resolve_git_dir "$COMMAND")

# ============================================================
# Helper: detect git subcommand invocation
# ============================================================
has_git_subcmd() {
  local cmd="$1"
  local subcmd="$2"
  echo "$cmd" | grep -qE "git\s+$subcmd\b" && return 0
  echo "$cmd" | grep -qE "/git\s+$subcmd\b" && return 0
  echo "$cmd" | grep -qE "(command|env)\s+git\s+$subcmd\b" && return 0
  echo "$cmd" | grep -qE '\(\)\s*\{[^}]*git\b' && echo "$cmd" | grep -qE "\b$subcmd\b" && return 0
  echo "$cmd" | grep -qE '\w+=git(\s|;|&|$)' && echo "$cmd" | grep -qE "\b$subcmd\b" && return 0
  echo "$cmd" | grep -qiE "\w+=$subcmd(\s|;|&|\"|$)" && echo "$cmd" | grep -qE 'git\s+\$' && return 0
  return 1
}

# ============================================================
# Hook 2: 破壊的操作ガード (D001-D008)
# WHY: エージェントによる不可逆な操作を防ぐ安全ネット
# ============================================================

# D001: rm -rf on critical paths
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/\*?$|/mnt/\*|/home/\*|~(/|$| ))' || \
   echo "$COMMAND" | grep -qE 'rm\s+-rf\s+~$'; then
  echo "❌ Destructive operation blocked: rm -rf on critical path (D001)" >&2
  exit 2
fi

# D003: git push --force / -f (without --force-with-lease)
if has_git_subcmd "$COMMAND" "push" && echo "$COMMAND" | grep -qE '\-\-force\b' && ! echo "$COMMAND" | grep -q 'force-with-lease'; then
  echo "❌ Destructive operation blocked: git push --force (D003). Use --force-with-lease instead." >&2
  exit 2
fi
if has_git_subcmd "$COMMAND" "push" && echo "$COMMAND" | grep -qE '(^|\s)-f\b'; then
  echo "❌ Destructive operation blocked: git push -f (D003). Use --force-with-lease instead." >&2
  exit 2
fi

# D004: git reset --hard / git checkout -- . / git restore . / git clean -f
if has_git_subcmd "$COMMAND" "reset" && echo "$COMMAND" | grep -q '\-\-hard'; then
  echo "❌ Destructive operation blocked: git reset --hard (D004). Use git stash instead." >&2
  exit 2
fi
if has_git_subcmd "$COMMAND" "checkout" && echo "$COMMAND" | grep -qE '\-\-\s+\.'; then
  echo "❌ Destructive operation blocked: git checkout -- . (D004)" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+restore\s+\.'; then
  echo "❌ Destructive operation blocked: git restore . (D004)" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-f'; then
  echo "❌ Destructive operation blocked: git clean -f (D004). Run git clean -n first." >&2
  exit 2
fi

# D005: chmod -R / chown -R on system paths
if echo "$COMMAND" | grep -qE '(chmod|chown)\s+-R\b' && \
   echo "$COMMAND" | grep -qE '\s/(etc|usr|bin|sbin|lib|lib64|var|opt|root|sys|proc|boot|dev|srv|mnt|snap)(/| |$)'; then
  echo "❌ Destructive operation blocked: chmod/chown -R on system path (D005)" >&2
  exit 2
fi

# D006: kill/killall/pkill
if echo "$COMMAND" | grep -qE '\b(killall|pkill)\b'; then
  echo "❌ Destructive operation blocked: killall/pkill (D006)" >&2
  exit 2
fi

# D007: mkfs/dd if=/fdisk
if echo "$COMMAND" | grep -qE '\b(mkfs|fdisk)\b'; then
  echo "❌ Destructive operation blocked: mkfs/fdisk (D007)" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'dd\s+if='; then
  echo "❌ Destructive operation blocked: dd if= (D007)" >&2
  exit 2
fi

# D008: pipe-to-shell patterns
if echo "$COMMAND" | grep -qE '(curl|wget)\s+.*\|\s*(bash|sh)'; then
  echo "❌ Destructive operation blocked: curl/wget|bash/sh pattern (D008)" >&2
  exit 2
fi

# ============================================================
# Hook 3: main ブランチ保護
# WHY: main への直接コミット/プッシュは意図しない変更を本番反映するリスクがある
# ============================================================
if has_git_subcmd "$COMMAND" "commit" || has_git_subcmd "$COMMAND" "push"; then
  CURRENT_BRANCH=$(git -C "$GIT_TARGET_DIR" branch --show-current 2>/dev/null || echo "")
  if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo "❌ Direct commit/push to main/master is not allowed. Please create a branch." >&2
    exit 2
  fi
fi

# ============================================================
# Hook 4: push 前 lint/typecheck チェック
# WHY: CI 失敗を防ぐ。ローカルで早期検出する方が修正コストが低い
# ============================================================
if has_git_subcmd "$COMMAND" "push"; then
  PKG_JSON=$(find "$GIT_TARGET_DIR" -maxdepth 2 -name "package.json" ! -path "*/node_modules/*" 2>/dev/null | head -1)
  if [[ -n "$PKG_JSON" ]]; then
    PKG_DIR=$(dirname "$PKG_JSON")
    HAS_TYPECHECK=$(jq -r '.scripts.typecheck // ""' "$PKG_JSON")
    HAS_LINT=$(jq -r '.scripts.lint // ""' "$PKG_JSON")

    if [[ -n "$HAS_TYPECHECK" || -n "$HAS_LINT" ]]; then
      cd "$PKG_DIR"
      FAILED=0
      if [[ -n "$HAS_TYPECHECK" ]]; then
        if ! npm run typecheck --silent 2>/dev/null; then
          FAILED=1
        fi
      fi
      if [[ -n "$HAS_LINT" ]]; then
        if ! npm run lint --silent 2>/dev/null; then
          FAILED=1
        fi
      fi
      if [[ $FAILED -eq 1 ]]; then
        echo "❌ typecheck/lint errors detected. Please fix before pushing." >&2
        exit 2
      fi
    fi
  fi
fi

# ============================================================
# Hook 5: 設定ファイル保護
# WHY: エージェントがlintエラーを修正する代わりに設定を緩めることを防ぐ
# ============================================================
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
if [[ -n "$FILE_PATH" ]]; then
  PROTECTED_PATTERNS=(
    "biome.json"
    "tsconfig.json"
    "tsconfig.*.json"
    "lefthook.yml"
    ".github/workflows/"
    "catalog-info.yaml"
    "CODEOWNERS"
  )
  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$FILE_PATH" == *"$pattern"* ]]; then
      echo "❌ Configuration file '$FILE_PATH' is protected and cannot be modified by agents." >&2
      echo "   WHY: Config files define code quality standards. Agent modifications could weaken them." >&2
      echo "   FIX: Modify this file manually after team review (ADR required for significant changes)." >&2
      exit 2
    fi
  done
fi

exit 0
