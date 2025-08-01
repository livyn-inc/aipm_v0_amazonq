# 🚀 Amazon Q Developer用 AIPMシステム クイックスタート

## ✅ セットアップ完了！

### 📦 作成されたもの
- **Project Rules**: `.amazonq/rules/basic/` (既存のBasic Rulesを活用)
- **Prompt Library**: `~/.aws/amazonq/prompts/`
- **AIPMディレクトリ**: `Flow/`, `Stock/`, `Archived/`
- **スクリプト群**: `scripts/`

### 🛠️ 次の手順

#### 1. Amazon Q Developer インストール
```bash
# VS CodeでCtrl+P (Cmd+P) を押して:
ext install AmazonWebServices.amazon-q-vscode
```

#### 2. サインイン
- VS CodeでAmazon Q Chatを開く
- AWS Builder IDでサインイン（無料）

#### 3. Project Rules有効化
1. Amazon Q ChatでRulesボタンをクリック
2. 作成されたルールにチェックを入れる
3. ルールが適用されていることを確認

#### 4. 使用例
```bash
# プロジェクト憲章作成
@project_charter_generator @workspace この新規プロジェクトについて

# WBS作成
@wbs_generator @workspace 先ほどのプロジェクト憲章から

# 日次タスク生成
@daily_task_generator 今日のバックログから
```

### 🔄 Cursorとの主な違い
| 機能 | Cursor | Amazon Q Developer |
|------|--------|-------------------|
| ルール適用 | 自動 | Rulesボタンで手動有効化 |
| プロンプト | `@agent` | `@prompt_name` |
| ファイル参照 | 自動 | `@workspace` |
| 会話継続 | セッション内 | 永続化・検索可能 |

### 🎯 基本的なワークフロー

#### プロジェクト開始
1. `@project_charter_generator` でプロジェクト憲章作成
2. `@stakeholder_analysis` でステークホルダー分析
3. `@wbs_generator` でWBS作成

#### 日常作業
1. `@daily_task_generator` で今日のタスク作成
2. 各種ドキュメント作成・更新
3. 「確定反映して」でStockフォルダに移動

### 🆘 トラブルシューティング
- **Project Rulesが効かない** → Rulesボタンで手動有効化
- **ワークスペースが認識されない** → `@workspace` を明示的に指定  
- **プロンプトが見つからない** → `~/.aws/amazonq/prompts/` を確認

## 🎉 今すぐ試す
1. VS CodeでAmazon Q Chatを開く
2. `@project_charter_generator @workspace` と入力
3. プロジェクト憲章が生成されることを確認

**成功です！Amazon Q DeveloperでAIPMシステムを活用開始！🚀**
