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

> このリポジトリに [geolonia-template](https://github.com/geolonia/geolonia-template) を適用してください。
> リポジトリの `template-manifest.yaml` を読んで、
> `apply_to_existing` の手順に従ってファイルを追加してください。

エージェントが `template-manifest.yaml` の `required` / `recommended` / `optional` を判断し、衝突チェック付きで適用します。

> **Note**: CLI での適用（`npx @geolonia/template apply`）は未実装です。進捗は [#10](https://github.com/geolonia/geolonia-template/issues/10) を参照してください。

### 初期セットアップ（`/init-project`）

テンプレートを適用したら、Claude Code で `/init-project` を実行してプロジェクト情報を入力します:

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

## Skills

Claude Code のスラッシュコマンドとして呼び出せるスキルが同梱されています。

| スキル | 呼び出し方 | 概要 |
|-------|-----------|------|
| `/init-project` | `> /init-project` | テンプレート適用後の初期セットアップ。プロジェクト名・チーム名等のプレースホルダーを対話的に置換。何度でも実行可能 |
| `/code-review-expert` | `> /code-review-expert --auto` | SOLID 原則・セキュリティ・品質を構造的にレビュー。`--auto` で P0/P1 を自動修正し push ブロック解除マーカーを生成 |

スキルの実体は `.claude/skills/{skill-name}/SKILL.md` に格納されています。

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
│   └── skills/                 #   スキル（/コマンドで呼び出し可能）
│       ├── init-project/       #     /init-project — 初期セットアップ
│       └── code-review-expert/ #     /code-review-expert — コードレビュー
├── .github/                    # GitHub 設定
│   ├── workflows/ci.yml        #   CI
│   ├── CODEOWNERS              #   レビュー必須設定
│   └── dependabot.yml          #   依存関係自動更新
├── docs/decisions/             # ADR (Architecture Decision Records)
├── scripts/hooks/              # Claude Code hook スクリプト
│   ├── guard.sh                #   安全ガード (PreToolUse)
│   ├── post-tool-format.sh     #   自動フォーマット (PostToolUse)
│   └── guards.d/               #   追加ガード（.disabled を外して有効化）
│       ├── config-protection.sh.disabled
│       └── review-enforcer.sh.disabled
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

`scripts/hooks/guards.d/` にプラグインとして同梱されています。**ファイル名から `.disabled` を外すだけで有効化**できます。guard.sh 本体を編集する必要はありません。

```bash
# 設定ファイル保護を有効化
mv scripts/hooks/guards.d/config-protection.sh.disabled \
   scripts/hooks/guards.d/config-protection.sh

# シークレットファイル保護を有効化
mv scripts/hooks/guards.d/secret-protection.sh.disabled \
   scripts/hooks/guards.d/secret-protection.sh

# push 前レビュー強制を有効化
mv scripts/hooks/guards.d/review-enforcer.sh.disabled \
   scripts/hooks/guards.d/review-enforcer.sh
```

| ファイル | 問題 | 効果 |
|---------|------|------|
| `config-protection.sh` | エージェントが biome.json 等のルールを緩める | Write/Edit で設定ファイルの変更をブロック |
| `secret-protection.sh` | エージェントが .env を読み取り・上書きする | Read/Write/Edit/Bash で `.env*` ファイルへのアクセスをブロック |
| `review-enforcer.sh` | レビューなしで push してしまう | `/code-review-expert` 実行後のマーカー（`.code-review-done`）がないと push をブロック。マーカーはスキルが自動生成 |

#### Stop Hook: テストなし完了防止（手動設定）

エージェントがテストを書かずに「完了」と宣言する問題には、`.claude/settings.json` の `hooks` に `Stop` キーを追加します:

```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "bash -c 'npx vitest run --silent 2>/dev/null || { echo \"❌ テストが失敗しています。\" >&2; exit 2; }'"
      }
    ]
  }
]
```

> 既存の `PreToolUse` / `PostToolUse` と同じレベルに追加してください。詳細は [Claude Code Hooks ドキュメント](https://docs.anthropic.com/en/docs/claude-code/hooks) を参照。

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
