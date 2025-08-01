#!/bin/bash
#============================================================
# convert_mdc_to_md.sh
# ─ MDCファイルをMDファイルに変換するスクリプト
#============================================================

set -e

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 変換対象ディレクトリ
RULES_DIR=".amazonq/rules/basic"

log_info "Converting .mdc files to .md files in $RULES_DIR"

# MDCファイルを検索してMDに変換
find "$RULES_DIR" -name "*.mdc" -type f | while read -r mdc_file; do
  # .mdc を .md に置換したファイル名を生成
  md_file="${mdc_file%.mdc}.md"
  
  # ファイルをコピー
  cp "$mdc_file" "$md_file"
  
  log_success "Converted: $mdc_file -> $md_file"
done

log_info "Conversion completed!"