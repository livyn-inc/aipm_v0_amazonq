#!/bin/bash
#============================================================
# setup_amazonq_workspace.sh
# ─ Amazon Q Developer用 AIプロジェクト管理ワークスペースの構築スクリプト
# 
# 使い方: ./setup_amazonq_workspace.sh [root_directory] [config_file]
#         ./setup_amazonq_workspace.sh [config_file]
# 例:     ./setup_amazonq_workspace.sh /Users/username/new_workspace ./setup_amazonq_config.sh
#         ./setup_amazonq_workspace.sh setup_amazonq_config.sh  # カレントディレクトリに作成
#
# Cursor版との主な違い：
# - .cursor/rules/ → .amazonq/rules/ 
# - Prompt Library設定を追加
# - Amazon Q Developer用のガイド生成
#============================================================

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_amazonq() {
  echo -e "${PURPLE}[AMAZON Q]${NC} $1"
}

# デフォルト設定
setup_default_config() {
  # ルールリポジトリ（Amazon Q Developer用パスに変更）
  RULE_REPOS=(
    "https://github.com/miyatti777/rules_basic_public.git|.amazonq/rules/basic"
  )
  
  # スクリプトリポジトリ
  SCRIPT_REPOS=(
    "https://github.com/miyatti777/scripts_public.git|scripts"
  )
  
  # プログラムリポジトリ
  PROGRAM_REPOS=(
    "https://github.com/miyatti777/sample_pj_curry.git|Stock/programs/夕食作り"
  )
  
  # サンプルプログラムフォルダ（フォールバック用）
  SAMPLE_PROGRAMS=(
    "夕食作り"
  )
  
  # 基本ディレクトリ（Amazon Q Developer用に調整）
  BASE_DIRS=(
    "Flow"
    "Stock"
    "Archived"
    "Archived/projects"
    "scripts"
    ".amazonq/rules"          # Cursor → Amazon Q Developer
    ".amazonq/rules/basic"    # Cursor → Amazon Q Developer
    "Stock/programs"
  )
  
  # AUTO_APPROVE：trueに設定すると確認メッセージをスキップ
  AUTO_APPROVE=false
  
  # AUTO_CLONE：trueに設定するとリポジトリを自動クローン
  AUTO_CLONE=false
  
  # Amazon Q Developer特有の設定
  AMAZONQ_PROMPT_LIBRARY_DIR="$HOME/.aws/amazonq/prompts"
  AMAZONQ_SETUP_PROMPTS=true
}

# コンフィグファイルの読み込み
load_config() {
  local config_file="$1"
  
  if [ -f "$config_file" ]; then
    log_info "コンフィグファイルを読み込んでいます: $config_file"
    # shellcheck source=/dev/null
    source "$config_file"
    log_success "コンフィグファイルを読み込みました"
  else
    log_warning "指定されたコンフィグファイルが見つかりません: $config_file"
    log_info "デフォルト設定を使用します"
  fi
}

# リポジトリのクローン処理
clone_repository() {
  local url=$1
  local target_path=$2
  
  log_info "リポジトリをクローンしています: $url → $target_path"
  
  if [ -d "$target_path" ]; then
    log_warning "既に存在します: $target_path"
    if [ "$AUTO_APPROVE" != "true" ]; then
      read -p "上書きしますか？ (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "スキップしました: $target_path"
        return
      fi
    fi
    rm -rf "$target_path"
  fi
  
  mkdir -p "$(dirname "$target_path")"
  
  if git clone "$url" "$target_path"; then
    log_success "クローン完了: $target_path"
  else
    log_error "クローンに失敗しました: $url"
    return 1
  fi
}

# Amazon Q Developer用のPrompt Libraryセットアップ
setup_amazonq_prompts() {
  if [ "$AMAZONQ_SETUP_PROMPTS" != "true" ]; then
    return
  fi
  
  log_amazonq "Amazon Q Developer Prompt Libraryをセットアップ中..."
  
  # Prompt Libraryディレクトリ作成
  mkdir -p "$AMAZONQ_PROMPT_LIBRARY_DIR"
  
  # 基本的なプロンプトを作成
  cat > "$AMAZONQ_PROMPT_LIBRARY_DIR/project_charter_generator.md" << 'EOF'
プロジェクト憲章を作成してください。以下の要素を必ず含めてください：

1. **ビジネスケース**: なぜこのプロジェクトが必要なのか
2. **プロジェクト目的**: 何を達成するのか
3. **プロジェクトスコープ**: 含むもの・含まないもの
4. **主要ステークホルダー**: 関係者の役割と責任
5. **マイルストーン**: 主要な節目とタイミング
6. **リスクと仮定**: 想定されるリスクと前提条件
7. **成功基準**: どうなったら成功なのか

PMBOK準拠の構造でMarkdown形式で出力してください。
EOF

  cat > "$AMAZONQ_PROMPT_LIBRARY_DIR/wbs_generator.md" << 'EOF'
Work Breakdown Structure (WBS)を作成してください。

要件：
- 3レベル以上の詳細度
- 各タスクに担当者・期間・依存関係を明記
- 成果物を明確に定義
- リスクレベル（高・中・低）を付与
- CSV出力とMarkdown出力の両方を生成

フォーマットはPMBOK準拠の標準的なWBS構造にしてください。
EOF

  cat > "$AMAZONQ_PROMPT_LIBRARY_DIR/daily_task_generator.md" << 'EOF'
今日の日次タスクリストを作成してください。

## 日次タスク - [日付]

### バックログタスク
- [ ] (ストーリーID): (タスク名) - 期待時間: XX分

### ルーチンタスク  
- [ ] 日次振り返り（15分）
- [ ] メール・Slack確認（30分）

### 緊急タスク
- [ ] (必要に応じて)

Markdown形式で出力してください。
EOF

  cat > "$AMAZONQ_PROMPT_LIBRARY_DIR/stakeholder_analysis.md" << 'EOF'
ステークホルダー分析を実施してください。

要素：
1. ステークホルダー一覧（役割・責任・関心度・影響度）
2. 影響度・関心度マトリクス
3. コミュニケーション計画
4. 期待値管理戦略

PMBOK準拠でMarkdown形式で出力してください。
EOF

  log_success "Prompt Library作成完了: $AMAZONQ_PROMPT_LIBRARY_DIR"
}

# Amazon Q Developer用のルール適応処理
adapt_rules_for_amazonq() {
  local rules_dir="$1"
  
  log_amazonq "Amazon Q Developer用にルールを適応中..."
  
  # pmbok_paths.mdcをAmazon Q Developer用に調整
  if [ -f "$rules_dir/pmbok_paths.mdc" ]; then
    log_info "パス設定をAmazon Q Developer用に調整中..."
    
    # バックアップ作成
    cp "$rules_dir/pmbok_paths.mdc" "$rules_dir/pmbok_paths.mdc.backup"
    
    # .cursor → .amazonq に置換
    sed -i.bak 's|\.cursor/rules|.amazonq/rules|g' "$rules_dir/pmbok_paths.mdc"
    
    log_success "パス設定を調整しました"
  fi
  
  # Amazon Q Developer用の追加ルールファイル作成
  cat > "$rules_dir/amazonq_integration.mdc" << 'EOF'
# Amazon Q Developer Integration Rules

## Amazon Q Developer用の基本設定

### プロンプト実行方法
- Agent modeの代わりに: `@prompt_name @workspace`
- ファイル参照: `@workspace` または `@file_name`
- Project Rules: `.amazonq/rules/` で自動適用

### 主要な違い
| 機能 | Cursor | Amazon Q Developer |
|------|--------|-------------------|
| ルール適用 | 自動 | Rulesボタンで手動有効化 |
| プロンプト実行 | `@agent [prompt]` | `@[prompt_name] @workspace` |
| ファイル参照 | 自動認識 | `@workspace`, `@file` |
| 会話継続 | セッション内 | 永続化・検索可能 |

### 推奨ワークフロー
1. VS CodeでAmazon Q Developer拡張機能をインストール
2. AWS Builder IDでサインイン
3. Project Rulesを有効化（Rulesボタン）
4. Prompt Libraryを活用してプロンプト実行

### トラブルシューティング
- Project Rulesが認識されない → Rulesボタンで手動有効化
- ワークスペースが認識されない → `@workspace` を明示的に指定
- プロンプトが見つからない → `~/.aws/amazonq/prompts/` を確認
EOF

  log_success "Amazon Q Developer用ルール適応完了"
}

# 基本ディレクトリの作成
create_base_directories() {
  log_info "基本ディレクトリを作成中..."
  
  for dir in "${BASE_DIRS[@]}"; do
    if mkdir -p "$dir"; then
      log_success "作成: $dir"
    else
      log_error "作成失敗: $dir"
      return 1
    fi
  done
  
  # Flow の日付フォルダ作成
  local today
  today=$(date +%Y%m)
  local today_full
  today_full=$(date +%Y-%m-%d)
  
  mkdir -p "Flow/$today/$today_full"
  log_success "Flow日付フォルダ作成: Flow/$today/$today_full"
}

# リポジトリ群のクローン
clone_repositories() {
  log_info "リポジトリをクローン中..."
  
  # ルールリポジトリ
  for repo_info in "${RULE_REPOS[@]}"; do
    if [ "$AUTO_CLONE" = "true" ] || [ "$AUTO_APPROVE" = "true" ]; then
      IFS='|' read -r url path <<< "$repo_info"
      clone_repository "$url" "$path"
      
      # Amazon Q Developer用に適応
      adapt_rules_for_amazonq "$path"
    else
      log_info "手動確認: $repo_info"
      read -p "このリポジトリをクローンしますか？ (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        IFS='|' read -r url path <<< "$repo_info"
        clone_repository "$url" "$path"
        adapt_rules_for_amazonq "$path"
      fi
    fi
  done
  
  # スクリプトリポジトリ
  for repo_info in "${SCRIPT_REPOS[@]}"; do
    if [ "$AUTO_CLONE" = "true" ] || [ "$AUTO_APPROVE" = "true" ]; then
      IFS='|' read -r url path <<< "$repo_info"
      clone_repository "$url" "$path"
    else
      log_info "手動確認: $repo_info"
      read -p "このリポジトリをクローンしますか？ (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        IFS='|' read -r url path <<< "$repo_info"
        clone_repository "$url" "$path"
      fi
    fi
  done
  
  # プログラムリポジトリ
  for repo_info in "${PROGRAM_REPOS[@]}"; do
    if [ "$AUTO_CLONE" = "true" ] || [ "$AUTO_APPROVE" = "true" ]; then
      IFS='|' read -r url path <<< "$repo_info"
      clone_repository "$url" "$path"
    else
      log_info "手動確認: $repo_info"
      read -p "このリポジトリをクローンしますか？ (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        IFS='|' read -r url path <<< "$repo_info"
        clone_repository "$url" "$path"
      fi
    fi
  done
}

# Amazon Q Developer用クイックスタートガイド作成
create_amazonq_guide() {
  log_amazonq "Amazon Q Developer用ガイドを作成中..."
  
  cat > "AMAZON_Q_QUICKSTART.md" << 'EOF'
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
EOF

  log_success "Amazon Q Developer用ガイド作成完了: AMAZON_Q_QUICKSTART.md"
}

# 使用方法表示
show_usage() {
  echo "使い方: $0 [root_directory] [config_file]"
  echo "       $0 [config_file]"
  echo ""
  echo "例:"
  echo "  $0 /Users/username/new_workspace ./setup_amazonq_config.sh"
  echo "  $0 setup_amazonq_config.sh  # カレントディレクトリに作成"
  echo ""
  echo "オプション:"
  echo "  -h, --help    この使用方法を表示"
}

# メイン処理
main() {
  # 引数の解析
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
  esac
  
  local root_dir=""
  local config_file=""
  
  if [ $# -eq 0 ]; then
    root_dir="."
    config_file="setup_amazonq_config.sh"
  elif [ $# -eq 1 ]; then
    if [[ "$1" == *.sh ]]; then
      root_dir="."
      config_file="$1"
    else
      root_dir="$1"
      config_file="setup_amazonq_config.sh"
    fi
  elif [ $# -eq 2 ]; then
    root_dir="$1"
    config_file="$2"
  else
    log_error "引数が多すぎます"
    show_usage
    exit 1
  fi
  
  # ルートディレクトリに移動
  if [ "$root_dir" != "." ]; then
    mkdir -p "$root_dir"
    cd "$root_dir"
  fi
  
  log_amazonq "=========================================="
  log_amazonq "Amazon Q Developer用 AIPMワークスペース構築"
  log_amazonq "=========================================="
  log_info "作業ディレクトリ: $(pwd)"
  log_info "設定ファイル: $config_file"
  
  # デフォルト設定を読み込み
  setup_default_config
  
  # コンフィグファイルを読み込み（オーバーライド）
  load_config "$config_file"
  
  # 確認
  if [ "$AUTO_APPROVE" != "true" ]; then
    echo ""
    log_info "以下の設定でワークスペースを作成します："
    log_info "  作業ディレクトリ: $(pwd)"
    log_info "  Amazon Q Rules: .amazonq/rules/"
    log_info "  Prompt Library: $AMAZONQ_PROMPT_LIBRARY_DIR"
    echo ""
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "キャンセルされました"
      exit 0
    fi
  fi
  
  # セットアップ実行
  create_base_directories
  setup_amazonq_prompts
  clone_repositories
  create_amazonq_guide
  
  log_success "=========================================="
  log_success "Amazon Q Developer用ワークスペース構築完了！"
  log_success "=========================================="
  echo ""
  log_amazonq "次の手順:"
  log_amazonq "1. VS CodeでAmazon Q Developer拡張機能をインストール"
  log_amazonq "2. AWS Builder IDでサインイン"  
  log_amazonq "3. AMAZON_Q_QUICKSTART.md を参照して開始"
  echo ""
  log_info "詳細な手順は AMAZON_Q_QUICKSTART.md をご確認ください"
}

# スクリプト実行
main "$@"