# geolonia-template-library

Geolonia TypeScript ライブラリ開発の標準テンプレート。
新規リポジトリを作成する際にこのテンプレートを clone し、すぐに開発を始められる状態を提供します。

## Features

- **TypeScript strict** — `any` 禁止、null チェック厳格化
- **Biome** — ESLint+Prettier の代替。10-25x 高速 ([ADR-0001](docs/decisions/0001-use-biome.md))
- **Lefthook** — Git hooks。コミット前に自動 lint/typecheck ([ADR-0002](docs/decisions/0002-use-lefthook.md))
- **Vitest** — 高速テストランナー
- **Claude Code Hooks** — AI エージェントの品質ゲート (guard.sh)
- **code-review-expert** — プッシュ前のコードレビュースキル
- **Backstage + ISMS** — `catalog-info.yaml` でコンプライアンス対応

---

## Getting Started

### 1. Clone & Rename

```bash
# GitHub の "Use this template" ボタンを使うか、直接 clone する
git clone https://github.com/geolonia/geolonia-template-library.git your-library-name
cd your-library-name

# 新しいリポジトリとして初期化
rm -rf .git
git init
git checkout -b main
```

### 2. Customize

以下のファイルを実際のプロジェクト情報に更新してください:

| ファイル | 変更箇所 |
|--------|--------|
| `package.json` | `name`, `description`, `version` |
| `catalog-info.yaml` | `{{PROJECT_NAME}}`, `{{TEAM}}`, `{{SYSTEM}}` 等のプレースホルダー |
| `CODEOWNERS` | `@geolonia/your-team` のチームスラッグ |
| `CLAUDE.md` | プロジェクト固有のメモ（50行以内を維持） |
| `README.md` | このファイル自体 |

### 3. Initial Setup

```bash
# 依存関係のインストール
pnpm install

# Git hooks のインストール (Lefthook)
npx lefthook install

# 動作確認
pnpm run typecheck  # TypeScript 型チェック
pnpm run lint       # Biome lint
pnpm run test       # Vitest テスト
pnpm run build      # ビルド確認
```

### 4. Create First Commit

```bash
git add -A
git commit -m "chore: initialize from geolonia-template-library"
git remote add origin https://github.com/geolonia/your-library-name.git
git push -u origin main
```

### 5. Setup GitHub

- **Dependabot**: リポジトリ設定 → Security → Dependabot alerts を有効化
- **Secret Scanning**: リポジトリ設定 → Security → Secret scanning を有効化
- **Branch Protection**: `main` ブランチに PR required + CI required を設定
- **CODEOWNERS**: `.github/CODEOWNERS` のチームを実際のチームに更新

---

## Directory Structure

```
.
├── .claude/
│   ├── settings.json          # Claude Code hooks 設定
│   └── skills/
│       └── code-review-expert/
│           └── SKILL.md       # /code-review-expert スキル
├── .github/
│   ├── workflows/
│   │   └── ci.yml             # CI/CD パイプライン
│   ├── CODEOWNERS             # レビュー必須メンバー設定
│   └── dependabot.yml         # 依存関係自動更新
├── docs/
│   └── decisions/             # Architecture Decision Records
│       ├── 0000-template.md   # ADR 書き方テンプレート
│       ├── 0001-use-biome.md  # なぜ Biome を採用したか
│       └── 0002-use-lefthook.md  # なぜ Lefthook を採用したか
├── scripts/
│   └── hooks/
│       ├── guard.sh           # PreToolUse hook (安全ガード)
│       └── post-tool-format.sh  # PostToolUse hook (自動フォーマット)
├── src/
│   └── index.ts               # ライブラリエントリーポイント
├── tests/
│   └── index.test.ts          # テスト (src/ と同じ構造)
├── AGENTS.md                  # エージェント共通指示
├── CHANGELOG.md               # 変更履歴
├── CLAUDE.md                  # Claude Code 固有設定
├── LICENSE                    # MIT License
├── README.md                  # このファイル
├── biome.json                 # Biome 設定 (lint + format)
├── catalog-info.yaml          # Backstage + ISMS メタデータ
├── lefthook.yml               # Git hooks 設定
├── package.json               # npm パッケージ設定
└── tsconfig.json              # TypeScript コンパイラ設定
```

---

## Tools

### Biome (Lint + Format)

ESLint + Prettier の代替。Rust 製で 10-25x 高速。

```bash
pnpm run lint        # lint チェック
pnpm run lint:fix    # lint + 自動修正
pnpm run format      # フォーマット
```

設定: `biome.json`

主なルール:
- `noExplicitAny: error` — `any` 型は禁止
- `noNonNullAssertion: error` — `!` 演算子は禁止
- `noUnusedImports: error` — 未使用 import は禁止

設定変更が必要な場合はチームレビュー + ADR 作成が必要です (`CODEOWNERS` 参照)。

### Lefthook (Git Hooks)

コミット前・プッシュ前の自動チェック。

```yaml
# lefthook.yml の動作
pre-commit:
  - biome format (自動修正)
  - biome check (lint)
  - tsc --noEmit (型チェック)

pre-push:
  - tsc --noEmit
  - biome check
  - vitest run (テスト)
```

初回セットアップ: `npx lefthook install`

### Vitest (Testing)

```bash
pnpm run test        # 全テストを1回実行
pnpm run test:watch  # ウォッチモード
```

テストは `tests/` に配置し、`src/` と同じディレクトリ構造にしてください。
例: `src/foo/bar.ts` → `tests/foo/bar.test.ts`

---

## Claude Code Hooks

### guard.sh (PreToolUse)

Claude Code 等の AI エージェントが実行する操作を自動的にチェックします。

| Hook | 内容 |
|------|------|
| Hook 2 | 破壊的操作のブロック (rm -rf, force push 等) |
| Hook 3 | `main`/`master` への直接コミット・プッシュをブロック |
| Hook 4 | プッシュ前に typecheck + lint を自動実行 |
| Hook 5 | `biome.json`, `tsconfig.json` 等の設定ファイルの変更をブロック |

**設定ファイル保護 (Hook 5) の対象:**
- `biome.json` — lint/format ルール
- `tsconfig.json` — TypeScript 設定
- `lefthook.yml` — Git hooks
- `.github/workflows/` — CI/CD
- `catalog-info.yaml` — ISMS メタデータ
- `CODEOWNERS` — レビュー要件

#### フックを一時的に無効化する方法

人間が作業で一時的に無効化が必要な場合:

```bash
mv .claude/settings.json .claude/settings.json.bak
# 作業...
mv .claude/settings.json.bak .claude/settings.json
```

### post-tool-format.sh (PostToolUse)

`Write` または `Edit` ツール実行後に自動でフォーマットします。
Claude Code がファイルを書いた直後に Biome が走り、フォーマットのずれを即座に修正します。

### code-review-expert スキル

```
/code-review-expert          # インタラクティブモード
/code-review-expert --auto   # 自動修正モード (CI/push前推奨)
```

プッシュ前に必ず実行することを推奨します。

---

## CI/CD

### GitHub Actions (ci.yml)

| イベント | ジョブ |
|--------|-------|
| PR → main | typecheck + lint + test + build |
| tag push (v*.*.*) | 上記 + npm publish |

### npm 公開

1. `package.json` の `version` を更新
2. `CHANGELOG.md` を更新
3. `git tag v1.0.0 && git push origin v1.0.0`
4. GitHub Actions が自動的に npm publish

npm 公開には `NPM_TOKEN` シークレットの設定が必要です (GitHub リポジトリ設定 → Secrets)。

---

## catalog-info.yaml 記入ガイド

Backstage カタログ登録 + ISMS コンプライアンスのためのメタデータファイルです。

### 必須フィールド

| フィールド | 例 | 説明 |
|---------|---|-----|
| `metadata.name` | `my-library` | リポジトリ名と同じ（小文字・ハイフン） |
| `spec.owner` | `group:geolonia/platform` | 担当チーム |
| `spec.system` | `geolonia-developer-platform` | 所属する上位システム |

### ISMS アノテーション

| アノテーション | 値 | 意味 |
|-------------|---|-----|
| `geolonia.com/data-classification` | `none` / `internal` / `confidential` / `restricted` | 扱うデータの機密度 |
| `geolonia.com/backup-required` | `true` / `false` | 定期バックアップが必要か |
| `geolonia.com/regulatory-scope` | `none` / `pii` / `payment` | 規制対象データの種類 |

詳細は `catalog-info.yaml` 内のコメントと [ISMS Issue #93](https://github.com/geolonia/geolonia-backstage/issues/93) を参照。

---

## Architecture Decisions (ADRs)

設計上の重要な決定は `docs/decisions/` に記録します。

| ADR | 内容 |
|-----|-----|
| [ADR-0000](docs/decisions/0000-template.md) | ADR 書き方テンプレート |
| [ADR-0001](docs/decisions/0001-use-biome.md) | Biome 採用理由 |
| [ADR-0002](docs/decisions/0002-use-lefthook.md) | Lefthook 採用理由 |

新しい技術的決定は ADR として記録してください。テンプレートは `docs/decisions/0000-template.md`。

---

## FAQ

### Q: Biome に未対応の ESLint ルールが必要になった場合は？

CI 層 (`.github/workflows/ci.yml`) に Oxlint または Semgrep を追加してください。
PostToolUse/pre-commit 層は Biome のみで十分です（速度優先）。

### Q: `pnpm run lint` が設定ファイルにエラーを報告する

guard.sh の Hook 5 が保護するファイルは人間が手動で変更してください。
変更の理由は ADR として記録することを推奨します。

### Q: Lefthook のフックをスキップしたい

```bash
git commit --no-verify  # pre-commit をスキップ
git push --no-verify    # pre-push をスキップ
```

緊急時のみ使用してください。CI は必ず通す必要があります。

### Q: npm publish するには何が必要？

1. `NPM_TOKEN` を GitHub シークレットに設定
2. `package.json` の `name` を `@geolonia/your-actual-name` に変更
3. npm org メンバーシップの確認

### Q: このテンプレートのアップデートを受け取るには？

[geolonia-template-library](https://github.com/geolonia/geolonia-template-library) のリリースを Watch してください。
変更は CHANGELOG.md で確認できます。
手動でのマージが必要ですが、`@geolonia/config` パッケージ（将来実装予定）で設定の自動更新を予定しています。

---

## License

MIT © [Geolonia Inc.](https://geolonia.com)
