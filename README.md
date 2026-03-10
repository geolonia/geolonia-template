# geolonia-template

AI コーディングエージェント（Claude Code, Codex, Cursor 等）を安全に使うための品質ガードを組み込んだ、Geolonia TypeScript プロジェクトのベーステンプレートです。

**主な特徴:**
- エージェントの破壊的操作（`rm -rf`、`git push --force` 等）を自動ブロック
- ファイル保存のたびに自動フォーマット（PostToolUse hook）
- pre-commit / pre-push / CI の多層品質ゲート
- ライブラリ、API、フロントエンドなど用途を問わず使える共通基盤

## Getting Started

### セットアップ

```bash
pnpm install          # TypeScript, Biome, Vitest, Lefthook 等をインストール
npx lefthook install  # Git hooks を有効化
```

初期状態で `src/index.ts`（サンプル関数）と `tests/index.test.ts`（テスト）が含まれており、以下のコマンドはすべて成功します:

```bash
pnpm run typecheck && pnpm run lint && pnpm run test && pnpm run build
```

### 方法 1: 新規リポジトリ（GitHub UI）

1. このリポジトリの **"Use this template"** → **"Create a new repository"** をクリック
2. リポジトリ名と説明を入力して作成
3. クローンしてセットアップ → カスタマイズ

### 方法 2: 新規リポジトリ（CLI）

```bash
gh repo create my-project --template geolonia/geolonia-template --public
gh repo clone my-project
cd my-project
```

### 方法 3: 既存リポジトリに適用

AI エージェントに以下のように指示してください:

> このリポジトリに geolonia-template を適用してください。
> https://github.com/geolonia/geolonia-template/blob/main/template-manifest.yaml を読んで、
> `apply_to_existing` の手順に従ってファイルを追加してください。

エージェントが `template-manifest.yaml` の `required` / `recommended` / `optional` を判断し、衝突チェック付きで適用します。

> **Note**: CLI での適用（`npx @geolonia/template apply`）は未実装です。進捗は [#10](https://github.com/geolonia/geolonia-template/issues/10) を参照してください。

### カスタマイズ（`/init-project`）

Claude Code で `/init-project` を実行すると、対話的にプロジェクト情報を入力できます:

```
> /init-project

プロジェクト設定の状況:
❓ PROJECT_NAME: (未入力)
❓ DESCRIPTION: (未入力)
...

以下の項目が未入力です。入力してください（スキップする場合は空 Enter）:
1. PROJECT_NAME — リポジトリ名（小文字・ハイフン区切り）
2. DESCRIPTION — プロジェクトの1行説明
...
```

**特徴:**
- **何度でも実行可能** — 未入力の項目だけを聞きます。CODEOWNERS のチーム名や Backstage の資産 ID が後から決まったら、その時点で `/init-project` を再実行
- **引数指定** — `/init-project TEAM=frontend SYSTEM=geolonia-maps` で対話なしに特定項目だけ更新
- **更新対象** — `catalog-info.yaml`, `package.json`, `.github/CODEOWNERS`, `AGENTS.md`, `CLAUDE.md` のプレースホルダーを一括置換

<details>
<summary>手動でカスタマイズする場合</summary>

| ファイル | 変更箇所 |
|--------|--------|
| `package.json` | `name`, `description` |
| `catalog-info.yaml` | プレースホルダーを実際の値に置換（`{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{DISPLAY_NAME}}`, `{{TEAM}}`, `{{SYSTEM}}`, `{{TYPE}}`）。詳細は `template-manifest.yaml` の `placeholders` セクション参照 |
| `.github/CODEOWNERS` | `{{TEAM}}` をチームスラッグに置換 |
| `AGENTS.md` | プロジェクト概要・Gotchas（全エージェントツール共通 — Claude Code / Codex / Cursor 等が読む） |
| `CLAUDE.md` | Claude Code 固有の設定・ワークフロー（Claude Code のみが読む） |
| `README.md` | このファイル自体 |

</details>

用途に応じて追加:
- **ライブラリ**: `publishConfig`, `main`, `types`, `exports` を package.json に追加。`tsconfig.json` に `declaration: true`。CI に npm publish ジョブ追加
- **フロントエンド**: Vite, React, TailwindCSS 等を追加
- **API**: Lambda handler, Express/Hono 等を追加

## What's Included

### 4層品質モデル

このテンプレートは、品質チェックを4つの層で段階的に実行します:

| 層 | タイミング | ツール | 速度 |
|---|-----------|-------|------|
| Layer 1 | ファイル保存直後 | PostToolUse hook (Biome format) | ミリ秒 |
| Layer 2 | commit / push 時 | Lefthook (format + lint + typecheck + test) | 秒 |
| Layer 3 | push 後 | GitHub Actions CI | 分 |
| Layer 4 | PR 作成後 | Human review / CodeRabbit | 時間 |

### ツール一覧

| ツール | 目的 | 設定ファイル | 採用理由 |
|-------|------|------------|---------|
| TypeScript 5+ strict | 型安全 | `tsconfig.json` | |
| Biome | Lint + Format | `biome.json` | [ADR-0001](docs/decisions/0001-use-biome.md) |
| Lefthook | Git hooks | `lefthook.yml` | [ADR-0002](docs/decisions/0002-use-lefthook.md) |
| Vitest | テスト | (package.json) | |
| Claude Code Hooks | AI エージェント品質ゲート | `.claude/settings.json` | |
| Backstage + ISMS | コンプライアンス | `catalog-info.yaml` | |
| GitHub Actions | CI | `.github/workflows/ci.yml` | |
| Dependabot | 依存関係自動更新 | `.github/dependabot.yml` | |

## Directory Structure

```text
.
├── .claude/                    # Claude Code 設定
│   ├── settings.json           #   hooks 設定
│   └── skills/                 #   スキル
├── .github/                    # GitHub 設定
│   ├── workflows/ci.yml        #   CI
│   ├── CODEOWNERS              #   レビュー必須設定
│   └── dependabot.yml          #   依存関係自動更新
├── docs/decisions/             # ADR (Architecture Decision Records)
├── scripts/hooks/              # Claude Code hook スクリプト
│   ├── guard.sh                #   安全ガード (PreToolUse)
│   └── post-tool-format.sh     #   自動フォーマット (PostToolUse)
├── src/                        # ソースコード (初期: index.ts)
├── tests/                      # テスト (初期: index.test.ts)
├── AGENTS.md                   # エージェント共通指示 (全ツール対応)
├── CLAUDE.md                   # Claude Code 固有設定
├── biome.json                  # Biome 設定
├── catalog-info.yaml           # Backstage + ISMS メタデータ
├── lefthook.yml                # Git hooks 設定
├── template-manifest.yaml      # テンプレート適用ガイド (AI/CLI 向け)
└── tsconfig.json               # TypeScript 設定
```

## Claude Code Hooks

### 初期状態で有効

- **`guard.sh`** (PreToolUse: Bash, Write, Edit) — 破壊的操作ブロック（`rm -rf /`, `git push --force` 等）、main 直接 commit/push ブロック、push 前 typecheck/lint 自動実行
- **`post-tool-format.sh`** (PostToolUse: Write, Edit) — ファイル書き込み後に Biome で自動フォーマット

> `guard.sh` は Write/Edit にも PreToolUse として設定されています。初期状態では Bash コマンドのみをチェックしますが、後述の Hook 5（設定ファイル保護）を追加すると Write/Edit 時にも保護が効きます。

### 段階的に有効化するガード

問題が起きてから追加すれば十分です。最初から全部入れる必要はありません。

#### Hook 5: 設定ファイル保護

**問題**: エージェントが `biome.json` のルールを緩めたり、`tsconfig.json` の `strict` を外したりする。

`guard.sh` の `exit 0` の直前に以下を追加:

```bash
# ============================================================
# Hook 5: 設定ファイル保護
# ============================================================
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
  PROTECTED_FILES="biome.json|lefthook.yml|tsconfig.json|\.claude/settings\.json"
  if echo "$FILE_PATH" | grep -qE "(${PROTECTED_FILES})$"; then
    echo "❌ 設定ファイル ($(basename "$FILE_PATH")) は保護されています。変更は手動で行ってください。" >&2
    exit 2
  fi
fi
```

#### Hook 6: push 前レビュー強制

**問題**: エージェントがレビューなしで push してしまう。

`guard.sh` の `exit 0` の直前に以下を追加:

```bash
# ============================================================
# Hook 6: code-review-expert 実行強制（マーカーファイル方式）
# ============================================================
if has_git_subcmd "$COMMAND" "push"; then
  HEAD_HASH=$(git -C "$GIT_TARGET_DIR" rev-parse HEAD 2>/dev/null || echo "")
  if [[ -n "$HEAD_HASH" ]]; then
    REVIEW_DONE_FILE="$GIT_TARGET_DIR/.code-review-done"
    if [[ ! -f "$REVIEW_DONE_FILE" ]]; then
      echo "❌ code-review-expert を実行してください。push 前にレビューが必要です。" >&2
      exit 2
    fi
    REVIEW_HASH=$(tr -d '[:space:]' < "$REVIEW_DONE_FILE" 2>/dev/null || echo "")
    if [[ "$REVIEW_HASH" != "$HEAD_HASH" ]]; then
      echo "❌ code-review-expert を実行してください。（コミット後に再レビューが必要です）" >&2
      exit 2
    fi
  fi
fi
```

レビュー完了後に `git rev-parse HEAD > .code-review-done` でマーカーを書き込むと、push が許可されます。

#### Stop Hook: テストなし完了防止

**問題**: エージェントがテストを書かずに「完了」と宣言する。

`.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'npx vitest run --silent 2>/dev/null || { echo \"❌ テストが失敗しています。修正してから完了してください。\" >&2; exit 2; }'"
          }
        ]
      }
    ]
  }
}
```

> 既存の `PreToolUse` / `PostToolUse` と同じ `hooks` オブジェクト内に `Stop` キーを追加してください。

<details>
<summary>設計の原案</summary>

このテンプレートは以下の情報源をもとに設計しています。

| 情報源 | 取り込んだ機能 |
|-------|-------------|
| [Harness Engineering Best Practices 2026](https://nyosegawa.github.io/posts/harness-engineering-best-practices-2026/)（逆瀬川） | 4層品質モデル、PreToolUse/PostToolUse 設計、設定ファイル保護 |
| [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) (Anthropic) | hook の仕組み、`guard.sh` / `post-tool-format.sh` の実装パターン |
| [AGENTS.md](https://openai.com/index/introducing-agents-md/) (OpenAI) | エージェント非依存の指示ファイル規約 |
| [CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory#claudemd) (Anthropic) | Claude Code 固有の設定ファイル |
| [ADR](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) (Michael Nygard) | 設計判断の記録（`docs/decisions/`） |
| [Backstage](https://backstage.io/) (Spotify) | サービスカタログ（`catalog-info.yaml`） |
| [Biome](https://biomejs.dev/) | 高速 Linter + Formatter（[ADR-0001](docs/decisions/0001-use-biome.md)） |
| [Lefthook](https://github.com/evilmartians/lefthook) (Evil Martians) | 高速 Git hooks（[ADR-0002](docs/decisions/0002-use-lefthook.md)） |

</details>

## License

MIT © [Geolonia Inc.](https://geolonia.com)
