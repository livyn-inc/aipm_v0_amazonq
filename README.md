# 俺の考えた最強のAIPMシステム with Amazon Q Developer
## PMBOK × Lean UX × Agile ― 総合PMフレームワーク支援Rulesセット 利用ガイド (Amazon Q Developer版)

このドキュメントは、PMBOK標準、Lean UX、およびアジャイル手法を融合したプロジェクト管理システムのAmazon Q Developer版使用方法を説明するものです。

**対象読者**: プロジェクト責任者 / PO / スクラムマスター / UX デザイナー / PMO ― 「ドキュメントも実装もユーザー価値も、すべて1本のレールで回したい」Amazon Q Developer利用者

**Cursor版との違い**: `.cursor/rules/` → `.amazonq/rules/` + Prompt Library + Amazon Q Developer特有の使用方法

## 1. システム概要

このシステムは、プロジェクト管理における文書作成から確定・アーカイブまでの流れを自動化し、**Amazon Q Developer**の支援を受けながらプロジェクトを効率的に進めるためのものです。

### 主な特徴

- **PMBOK × Lean UX × Agileハイブリッド**: 上流工程はPMBOK準拠の文書管理、中流にLean UXの発見と検証、実装フェーズはアジャイル手法を採用
- **フォルダ構造の分離**: `Flow`（ドラフト）→ `Stock`（確定版）→ `Archived`（完了プロジェクト）
- **自動文書生成**: 質問応答による文書ドラフト作成
- **自動同期**: 「確定反映」コマンドによるFlowからStockへの文書移動
- **Amazon Q Developer活用**: Project Rules + Prompt Libraryによる効率的なプロジェクト管理

### Amazon Q Developer版の特長

- **既存のBasic Rulesを活用**: Cursor版と同じルールセットを使用
- **Prompt Library**: 再利用可能なプロンプトテンプレート
- **Project Rules**: プロジェクト全体で自動適用されるルール
- **永続的な会話履歴**: セッションを超えた継続的な作業が可能

## 2. システム全体像

```
┌──────────────────────────────┐   trigger（チャットコマンド）
│ amazonq_integration.mdc       │◀───────────────────────┐
│ 00_master_rules.mdc          │                        │
└─────────┬────────────────────┘                        │
          call                                          │
┌─────────▼────────────────────┐   発散/収束も Draft 化    │
│ 01‑06_pmbok_*.mdc            │──────────────────┐      │
│ 08_flow_assist.mdc           │    create_draft  │      │
└─────────┬────────────────────┘                │      │
          ▼ Draft (.md)                        │      │
      Flow/YYYYMM/YYYY‑MM‑DD/─────────────────────────────┘
          │  human review + "確定反映して"                 
          ▼                                              
      Stock/programs/PROGRAM/projects/PROJECT/.. ← flow_to_stock_rules.mdc
```

### Amazon Q Developer特有のワークフロー

```
VS Code + Amazon Q Developer
   ├── @prompt_name @workspace → Prompt Library活用
   ├── Project Rules自動適用 → .amazonq/rules/
   ├── Context Control → @workspace, @file
   └── 永続的会話履歴 → 継続的な作業
```

## 3. 基本的なフォルダ構造

```
プロジェクトルート/
├── .amazonq/                # Amazon Q Developer設定
│   └── rules/              # Project Rulesファイル群
│       ├── basic/          # 基本ルールフォルダ（既存Rules活用）
│       │   ├── pmbok_paths.mdc (→ .amazonq用に調整済み)
│       │   ├── 00_master_rules.mdc
│       │   ├── 01_pmbok_initiating.mdc
│       │   ├── amazonq_integration.mdc (新規追加)
│       │   └── ...
│       └── (additional_rules)/  # プロジェクト別特化ルール
├── ~/.aws/amazonq/prompts/  # Prompt Library (ユーザーホーム)
│   ├── project_charter_generator.md
│   ├── wbs_generator.md
│   ├── daily_task_generator.md
│   └── stakeholder_analysis.md
├── Flow/                   # 日付ごとのドラフト文書
│   ├── YYYYMM/            # 年月フォルダ
│   │   ├── YYYY-MM-DD/    # 作業日ごとのフォルダ
│   │   │   ├── draft_project_charter.md
│   │   │   └── ...
│   │   └── ...
│   └── templates/         # テンプレート
├── Stock/                 # 確定済み文書
│   ├── programs/          # プログラム（プロジェクトのまとまり）単位でのフォルダ
│   │   └── PROGRAM_NAME/  # プログラムフォルダ
│   │       └── projects/
│   │           └── PROJECT_ID/  # プロジェクトごとのフォルダ
│   │               └── documents/
│   │                   ├── 1_initiating/
│   │                   ├── 2_discovery/
│   │                   ├── 2_research/
│   │                   ├── 3_planning/
│   │                   ├── 4_executing/
│   │                   ├── 5_monitoring/
│   │                   └── 6_closing/
│   └── shared/            # 共有テンプレート
├── Archived/              # 完了プロジェクトのアーカイブ
└── scripts/               # 自動化スクリプト群
```

## 4. セットアップ手順

### Step 1: Amazon Q Developer拡張機能のインストール

1. VS Codeを開く
2. Ctrl+P (Cmd+P) を押して拡張機能検索を開く
3. 以下を入力：
```
ext install AmazonWebServices.amazon-q-vscode
```

### Step 2: AWS Builder IDでサインイン

1. VS CodeでAmazon Q Developerを開く
2. AWS Builder IDでサインイン（無料アカウント）
3. 認証を完了

### Step 3: ワークスペースのセットアップ

```bash
# リポジトリのクローン（または新規作成）
git clone <your-repository> my-aipm-workspace
cd my-aipm-workspace

# セットアップスクリプトを実行
./setup_amazonq_workspace.sh

# または設定ファイルを指定
./setup_amazonq_workspace.sh setup_amazonq_config.sh
```

### Step 4: Project Rulesの有効化

1. VS CodeでAmazon Q Chatを開く
2. 「Rules」ボタンをクリック
3. 以下のルールにチェックを入れる：
   - ✅ aipm_basic
   - ✅ pmbok_phases
   - ✅ amazonq_integration
   - ✅ その他必要なルール

### Step 5: 動作確認

Amazon Q Chatで以下をテスト：
```
@project_charter_generator @workspace テストプロジェクトについて
```

プロジェクト憲章が生成されれば成功です！

## 5. Amazon Q Developer特有の使い方

### 基本的なプロンプト実行

#### Cursor版 vs Amazon Q Developer版

| 操作 | Cursor | Amazon Q Developer |
|------|--------|-------------------|
| プロジェクト憲章作成 | `@agent プロジェクト憲章を作成して` | `@project_charter_generator @workspace` |
| WBS作成 | `@agent WBSを作成して` | `@wbs_generator @workspace` |
| 日次タスク生成 | `@agent 今日のタスクを作成して` | `@daily_task_generator` |
| ステークホルダー分析 | `@agent ステークホルダー分析をして` | `@stakeholder_analysis @workspace` |

### Context Controlの活用

```bash
# ワークスペース全体を参照
@project_charter_generator @workspace

# 特定のファイルを参照
@wbs_generator @project_charter.md

# 特定のフォルダを参照  
@daily_task_generator @Stock/programs/current_project/
```

### Project Rulesの活用

Amazon Q DeveloperのProject Rulesは自動で適用されますが、手動で有効化する必要があります：

1. **Rulesボタン**をクリック
2. **適用したいルール**にチェック
3. **会話で自動適用**を確認

### Prompt Libraryの管理

新しいプロンプトを追加：
```bash
# 新しいプロンプトファイルを作成
~/.aws/amazonq/prompts/my_custom_prompt.md

# Amazon Q Chatで使用
@my_custom_prompt @workspace
```

## 6. フェーズ別の使い方

### 0️⃣ 事前準備

```bash
# プロジェクト作成ガイド（Amazon Q Developer版）
@project_charter_generator @workspace 新規プロジェクト「○○開発」について
# → プログラム名を尋ねられます
# → 質問に回答してプロジェクト憲章を作成
```

### 1️⃣ 立ち上げ（Initiating）

```bash
# プロジェクト憲章作成
@project_charter_generator @workspace このプロジェクトについて

# ステークホルダー分析
@stakeholder_analysis @workspace 

# 内容確認後、確定反映（手動でStockフォルダに移動）
```

### 2️⃣ 発見・調査（Discovery & Research）

```bash
# 仮説マップ作成
「仮説マップを作成したい」 

# ペルソナ作成
「ペルソナを作成したい」

# 競合調査
「競合調査をしたい」
```

### 3️⃣ 計画（Planning）

```bash
# WBS作成
@wbs_generator @workspace プロジェクト憲章から

# リスク計画
「リスク計画を立てたい」

# バックログ初期化
「バックログを初期化したい」
```

### 4️⃣ 実行（Executing）

```bash
# 日次タスク作成
@daily_task_generator 今日のバックログから

# スプリントゴール設定
「スプリントゴールを設定したい」

# 議事録作成
「議事録を作成したい」
```

### 5️⃣ 監視・コントロール（Monitoring & Controlling）

```bash
# ステータスレポート
「ステータスレポートを作成したい」

# 変更要求
「変更要求書を作成したい」

# リスク更新
「リスク登録簿を更新したい」
```

### 6️⃣ 終結（Closing）

```bash
# 最終報告書
「最終報告書を作成したい」

# Lessons Learned
「Lessons Learnedを作成したい」

# プロジェクト完了
「プロジェクト完了報告書を作成したい」
```

## 7. トラブルシューティング

### よくある問題と解決方法

#### Project Rulesが効かない
**症状**: プロンプトを実行してもルールが適用されない
**解決方法**: 
1. Amazon Q ChatでRulesボタンをクリック
2. 必要なルールにチェックを入れる
3. ルールが有効になっていることを確認

#### Prompt Libraryが見つからない
**症状**: `@prompt_name` が認識されない
**解決方法**:
1. `~/.aws/amazonq/prompts/` フォルダを確認
2. プロンプトファイルが存在することを確認
3. ファイル名と`@prompt_name`が一致することを確認

#### ワークスペースが認識されない
**症状**: `@workspace` でプロジェクトファイルが参照されない
**解決方法**:
1. VS Codeでプロジェクトフォルダが正しく開かれていることを確認
2. Amazon Q Developerがワークスペースをインデックスするまで少し待つ
3. 必要に応じて明示的に`@file_name`でファイル指定

#### 会話履歴が見つからない
**症状**: 以前の会話が見つからない
**解決方法**:
1. Amazon Q ChatのSearch機能（検索アイコン）を使用
2. キーワードで過去の会話を検索
3. 必要に応じて会話をエクスポート

## 8. Cursor版からの移行ガイド

### 主な変更点

| 項目 | Cursor版 | Amazon Q Developer版 |
|------|----------|---------------------|
| ルールディレクトリ | `.cursor/rules/` | `.amazonq/rules/` |
| プロンプト実行 | `@agent [prompt]` | `@[prompt_name] @workspace` |
| ファイル参照 | 自動認識 | `@workspace`, `@file` |
| ルール適用 | 自動 | 手動有効化（Rulesボタン） |
| 会話継続 | セッション内 | 永続化・検索可能 |

### 移行手順

1. **既存プロジェクトのバックアップ**
```bash
cp -r existing_project existing_project_backup
```

2. **Amazon Q Developer版セットアップ**
```bash
./setup_amazonq_workspace.sh existing_project
```

3. **Project Rules手動有効化**
4. **Prompt Libraryの活用方法に慣れる**
5. **新しいワークフローでテスト実行**

### 注意点

- **手動でのルール有効化**が必要
- **プロンプト実行方法**が変更
- **会話履歴の永続化**により継続作業が可能
- **Context Control**により精密な制御が可能

## 9. 応用・カスタマイズ

### カスタムプロンプトの作成

```bash
# 新しいプロンプトを作成
cat > ~/.aws/amazonq/prompts/my_review_template.md << 'EOF'
コードレビューを実施してください。以下の観点で評価：

1. **機能性**: 要求通りに動作するか
2. **保守性**: 理解しやすく修正しやすいか  
3. **性能**: パフォーマンスに問題はないか
4. **セキュリティ**: セキュリティ上の問題はないか

Markdown形式で出力してください。
EOF

# 使用
@my_review_template @current_branch
```

### プロジェクト固有ルールの追加

```bash
# プロジェクト固有のルールを作成
cat > .amazonq/rules/project_specific.md << 'EOF'
# プロジェクト固有ルール

## 当プロジェクトの特別ルール
- 全てのAPIはRESTful設計に従う
- データベースアクセスはRepository パターンを使用
- テストカバレッジは80%以上を維持

## 成果物の要件
- 技術仕様書は必ずPlantUMLで図表を含める
- API仕様書はOpenAPI 3.0形式で作成
EOF
```

### チーム固有のワークフロー

```bash
# チーム固有のデイリータスクテンプレート
cat > ~/.aws/amazonq/prompts/team_daily_standup.md << 'EOF'
チーム用デイリースタンドアップ資料を作成してください。

## 今日の予定

### 開発チーム
- [ ] 担当者: タスク内容

### QAチーム  
- [ ] 担当者: テスト内容

### PMチーム
- [ ] 担当者: 管理業務内容

## 昨日の成果・課題
## 今日のリスク・懸念事項

Markdown形式で出力してください。
EOF
```

## 10. まとめ

Amazon Q Developer版のAIPMシステムは、既存のCursor版と同等の機能を持ちながら、以下の追加メリットを提供します：

### ✅ **メリット**
- **永続的な会話履歴**により継続的な作業が可能
- **Prompt Library**により再利用性が向上
- **Context Control**により精密な制御が可能
- **既存のBasic Rules**をそのまま活用
- **無料で利用可能**（AWS Builder ID）

### ⚠️ **注意点**
- **手動でのルール有効化**が必要
- **プロンプト実行方法**が変更
- **学習コスト**が若干発生

### 🚀 **推奨用途**
- **Amazon Q Developer利用者**
- **VS Code中心の開発者**
- **永続的な会話履歴**を重視する場合
- **チーム全体でのPrompt Library共有**を行いたい場合

このシステムを活用して、効率的で体系的なプロジェクト管理を実現してください！

---

## 参考資料

- [Amazon Q Developer 公式ドキュメント](https://docs.aws.amazon.com/amazonq/)
- [VS Code Amazon Q Developer 拡張機能](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.amazon-q-vscode)
- [AWS Builder ID 登録](https://aws.amazon.com/builder-id/)
- [PMBOK ガイド](https://www.pmi.org/pmbok-guide-standards)

**🎉 Amazon Q DeveloperでAIPMシステムを活用し、プロジェクト管理を次のレベルへ！**