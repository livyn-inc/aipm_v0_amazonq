#!/bin/bash
#============================================================
# setup_amazonq_config.sh
# ─ Amazon Q Developer用 AIPMワークスペース構築スクリプト設定
#
# 使い方: cp setup_amazonq_config.sh.example setup_amazonq_config.sh
#         編集後、./setup_amazonq_workspace.sh [path] setup_amazonq_config.sh を実行
#============================================================

# 自動確認をスキップする（trueに設定すると確認なしで進行）
AUTO_APPROVE=false

# リポジトリを自動クローンする（trueに設定すると確認なしでクローン）
AUTO_CLONE=false

# ルールリポジトリ
# 形式: "GitリポジトリURL|ターゲットパス"
RULE_REPOS=(
  "https://github.com/miyatti777/rules_basic_public.git|.amazonq/rules/basic"
  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/custom_rules.git|.amazonq/rules/custom"
)

# スクリプトリポジトリ
SCRIPT_REPOS=(
  "https://github.com/miyatti777/scripts_public.git|scripts"
  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/custom_scripts.git|scripts/custom"
)

# プログラムリポジトリ
PROGRAM_REPOS=(
  "https://github.com/miyatti777/sample_pj_curry.git|Stock/programs/夕食作り"
  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/custom_program.git|Stock/programs/CUSTOM"
)

# 基本ディレクトリ構造（Amazon Q Developer用に調整）
BASE_DIRS=(
  "Flow"
  "Stock"
  "Archived"
  "Archived/projects"
  "scripts"
  ".amazonq/rules"              # Cursor → Amazon Q Developer
  ".amazonq/rules/basic"        # Cursor → Amazon Q Developer
  "Stock/programs"
  # 必要に応じて追加
)

# Amazon Q Developer特有の設定
AMAZONQ_PROMPT_LIBRARY_DIR="$HOME/.aws/amazonq/prompts"
AMAZONQ_SETUP_PROMPTS=true