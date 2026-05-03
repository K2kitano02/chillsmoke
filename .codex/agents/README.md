# Agent Workflow

このディレクトリは、ChillSmoke の開発で `agent-workflows` SKILL を使うときの役割別ガイドを管理します。

`.codex/rules/TODO.md` は、`.codex/rules/Plan.md` と `.codex/rules/ER.md` を正として作成された Issue 一覧です。Test Writer は対象 Issue の受け入れ条件からテスト観点を整理し、Generator は対象 Issue を小さく実装し、Evaluator は仕様・テスト・画面操作で合否を確認します。

## エージェント構成

- `planner.md`: 依頼や仕様変更を、受け入れ条件と作業単位へ整理します。
- `test-writer.md`: 対象 Issue の仕様から、実装前または実装中に必要なテストを定義します。
- `generator.md`: 対象 Issue、バグ、レビュー指摘を、既存構成に沿って実装します。
- `evaluator.md`: Docker 経由のテスト、lint、必要な MCP/Playwright 操作で変更を検証します。

## 基本フロー

1. Planner が依頼内容、仕様資料、対象 Issue を確認し、必要なら受け入れ条件を整理する。
2. Test Writer が壊れやすい振る舞いをテスト可能な期待値へ落とす。
3. Generator が対象範囲だけを実装する。
4. Generator が変更内容、検証内容、残リスクを整理する。
5. Evaluator がテスト、lint、画面確認、差分確認で合否を判定する。
6. 不合格の場合、Generator がフィードバックに基づいて修正する。
7. 合格後、必要に応じて `codex-general-dev` SKILL の手順で commit、push、PR 作成へ進む。

## 重要な境界

Planner は「何を満たすべきか」を定義し、実装詳細を過剰に固定しません。

Test Writer は「正しさをどう確認するか」を定義します。必要な場合はテストファイルを追加・更新しますが、実装コードは Generator の責務です。

Generator は実装を担当します。`README.md`、`.codex/rules/Plan.md`、`.codex/rules/ER.md`、`.codex/rules/TODO.md`、`AGENTS.md` の範囲と Issue 順を優先します。

Evaluator は仕様、操作、表示、回帰リスクに基づいて判定します。好みの実装方針だけでは不合格にしません。
