# geolonia-template

Geolonia TypeScript プロジェクトのベーステンプレート。
ライブラリ、API、フロントエンドアプリなど、用途を問わず共通の開発基盤を提供します。

## Getting Started

### 方法 1: 新規リポジトリ（GitHub UI）

1. このリポジトリの **"Use this template"** → **"Create a new repository"** をクリック
2. リポジトリ名と説明を入力して作成
3. クローンしてカスタマイズ（下記「カスタマイズ」参照）

### 方法 2: 新規リポジトリ（CLI）

```bash
gh repo create my-project --template geolonia/geolonia-template --public
gh repo clone my-project
cd my-project
```

### 方法 3: 既存リポジトリに適用

```bash
npx @geolonia/template apply
```

または、AI エージェントが `template-manifest.yaml` を読んで必要なファイルを適用できます。

### カスタマイズ

| ファイル | 変更箇所 |
|--------|--------|
| `package.json` | `name`, `description` |
| `catalog-info.yaml` | `{{PLACEHOLDER}}` を実際の値に |
| `.github/CODEOWNERS` | チームスラッグ |
| `CLAUDE.md` | プロジェクト固有のメモ |
| `AGENTS.md` | プロジェクト概要・Gotchas |
| `README.md` | このファイル自体 |

用途に応じて追加:
- **ライブラリ**: `publishConfig`, `main`, `types`, `exports` を package.json に追加。`tsconfig.json` に `declaration: true`。CI に npm publish ジョブ追加
- **フロントエンド**: Vite, React, TailwindCSS 等を追加
- **API**: Lambda handler, Express/Hono 等を追加

### セットアップ

```bash
pnpm install
npx lefthook install
pnpm run typecheck && pnpm run lint && pnpm run test && pnpm run build
```

## What's Included

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

```
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
├── src/                        # ソースコード
├── tests/                      # テスト (src/ と同じ構造)
├── AGENTS.md                   # エージェント共通指示
├── CLAUDE.md                   # Claude Code 固有設定
├── biome.json                  # Biome 設定
├── catalog-info.yaml           # Backstage + ISMS メタデータ
├── lefthook.yml                # Git hooks 設定
└── tsconfig.json               # TypeScript 設定
```

## Claude Code Hooks

**初期状態で有効:**
- `guard.sh` (PreToolUse) — 破壊的操作ブロック、main 直接 push ブロック、push 前 typecheck/lint
- `post-tool-format.sh` (PostToolUse) — ファイル書き込み後に自動フォーマット

**問題が起きたら有効化:**

| 問題 | 対策 | 方法 |
|------|------|------|
| エージェントが biome.json 等のルールを緩めた | 設定ファイル保護 | `guard.sh` に Hook 5 を追加（[コード例](https://github.com/geolonia/multi-agent-shogun/blob/main/scripts/hooks/guard.sh)） |
| push 前レビューを強制したい | code-review-expert 必須化 | `guard.sh` に Hook 6 を追加 |
| エージェントがテストなしで完了宣言 | Stop Hook | `.claude/settings.json` に Stop hook を追加 |

## License

MIT © [Geolonia Inc.](https://geolonia.com)
