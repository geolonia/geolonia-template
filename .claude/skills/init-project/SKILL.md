---
name: init-project
description: "プロジェクト情報を対話的に入力し、テンプレートのプレースホルダーを置換する。初回でも途中でも、未入力の項目だけを聞く。"
license: MIT
tags:
  - setup
  - template
  - initialization
---

# init-project

プロジェクトのプレースホルダーを対話的に入力・更新するスキル。

## いつ使うか

- テンプレートからリポジトリを作成した直後（初回セットアップ）
- CODEOWNERS のチーム名や Backstage の資産 ID が後から決まったとき（部分更新）
- 既存リポジトリに geolonia-template を適用した後のカスタマイズ

## ワークフロー

### Step 1: 現状スキャン

以下のファイルをスキャンし、`{{...}}` プレースホルダーの残存状況を確認する:

- `catalog-info.yaml` — `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{DISPLAY_NAME}}`, `{{TEAM}}`, `{{SYSTEM}}`, `{{TYPE}}`
- `.github/CODEOWNERS` — `{{TEAM}}` プレースホルダーが残っているか
- `package.json` — `name` が `@geolonia/my-project` のまま、または `description` が `Replace with your project description` のまま
- `AGENTS.md` — プロジェクト概要の `<!-- TODO:` コメントが残っている
- `CLAUDE.md` — `<!-- TODO:` コメントが残っている

各項目について:
- `{{...}}` が残っている → **未入力** ❓
- 具体的な値に置換済み → **入力済み** ✅
- package.json の name/description がデフォルト値 → **未入力** ❓

### Step 2: 結果表示

```text
プロジェクト設定の状況:

✅ PROJECT_NAME: my-geocoder
✅ DESCRIPTION: A TypeScript library for geocoding
❓ DISPLAY_NAME: (未入力)
❓ TEAM: (未入力)
❓ SYSTEM: (未入力)
✅ TYPE: library
❓ CODEOWNERS: {{TEAM}} が未置換
❓ AGENTS.md: TODO コメントが残っています
❓ CLAUDE.md: TODO コメントが残っています
```

### Step 3: 対話的入力

未入力の項目についてのみ、ユーザーに質問する。

質問の形式:

```text
以下の項目が未入力です。入力してください（スキップする場合は空 Enter）:

1. DISPLAY_NAME — 人が読む表示名（日本語可）
   例: Geolonia Geocoder

2. TEAM — Backstage チームスラッグ
   例: platform
   ※ CODEOWNERS にも反映されます

3. SYSTEM — Backstage システム名
   例: geolonia-developer-platform

4. AGENTS.md — プロジェクトの概要を入力してください
   例: 住所から緯度経度を返すジオコーディング API

5. CLAUDE.md — プロジェクト固有のメモ（任意）
   例: ローカルテスト前に npm start が必要
```

**重要**: 全項目を一度に聞く（AskUserQuestion を1回だけ使う）。項目ごとに別々に聞かない。

### Step 4: 置換実行

入力された値で以下のファイルを更新する:

| 入力項目 | 更新対象ファイル | 更新内容 |
|---------|----------------|---------|
| PROJECT_NAME | `catalog-info.yaml`, `package.json` | プレースホルダー置換 + package.json の `name` を `@geolonia/{値}` に |
| DESCRIPTION | `catalog-info.yaml`, `package.json` | プレースホルダー置換 + package.json の `description` |
| DISPLAY_NAME | `catalog-info.yaml` | プレースホルダー置換 |
| TEAM | `catalog-info.yaml`, `.github/CODEOWNERS` | `{{TEAM}}` を置換（CODEOWNERS の全 `@geolonia/{{TEAM}}` を `@geolonia/{値}` に） |
| SYSTEM | `catalog-info.yaml` | プレースホルダー置換 |
| TYPE | `catalog-info.yaml` | プレースホルダー置換（値は library/service/website/documentation のいずれか） |
| AGENTS.md 概要 | `AGENTS.md` | `<!-- TODO: Replace with your project info -->` コメントと以下のプレースホルダーテキストを実際の内容に置換 |
| CLAUDE.md メモ | `CLAUDE.md` | `<!-- TODO:` コメントを実際の内容に置換 |

### Step 5: 結果表示

```text
✅ 以下のファイルを更新しました:
  - catalog-info.yaml (DISPLAY_NAME, TEAM, SYSTEM)
  - .github/CODEOWNERS (@geolonia/{{TEAM}} → @geolonia/frontend)
  - AGENTS.md (プロジェクト概要)

⏭️ スキップされた項目: CLAUDE.md

次回 /init-project を実行すると、スキップした項目だけを聞きます。
```

## 引数による非対話実行

`/init-project KEY=VALUE ...` で対話なしに特定項目だけ更新できる:

```bash
/init-project TEAM=frontend SYSTEM=geolonia-maps
```

引数がある場合は AskUserQuestion を使わず、即座に置換を実行する。

## 注意事項

- `template-manifest.yaml` 自体のプレースホルダー定義（`placeholders:` セクション）は更新しない。あれはテンプレート適用時の参照情報
- package.json の `name`, `version`, `dependencies` のうち、`name` と `description` のみ更新対象。`version` と `dependencies` は変更しない
- CODEOWNERS の置換は `{{TEAM}}` プレースホルダーが残っている場合のみ実行。既に具体的なチーム名に置換済みの場合はスキップ
