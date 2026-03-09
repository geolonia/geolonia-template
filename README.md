# geolonia-template

Geolonia TypeScript プロジェクトのベーステンプレート。
ライブラリ、API、フロントエンドアプリなど、用途を問わず共通の開発基盤を提供します。

## Getting Started

### 1. Clone & Rename

```bash
git clone https://github.com/geolonia/geolonia-template.git your-project-name
cd your-project-name
rm -rf .git
git init
git checkout -b main
```

### 2. Customize

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

### 3. Setup

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

`guard.sh` (PreToolUse) が破壊的操作・main 直接 push・設定ファイル改竄をブロック。
`post-tool-format.sh` (PostToolUse) がファイル書き込み後に自動フォーマット。
詳細は各スクリプトを参照。

一時的に無効化する場合:
```bash
mv .claude/settings.json .claude/settings.json.bak
# 作業...
mv .claude/settings.json.bak .claude/settings.json
```

## License

MIT © [Geolonia Inc.](https://geolonia.com)
