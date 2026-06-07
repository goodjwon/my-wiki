#!/usr/bin/env bash
# wiki/ 를 docs/ 로 복사한 뒤 MkDocs 빌드
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "▶ docs/ 초기화"
rm -rf docs
mkdir -p docs

echo "▶ wiki/ → docs/ 복사 (log.md 제외)"
rsync -a \
  --exclude 'log.md' \
  wiki/ docs/

if [ -d "raw/assets" ]; then
  echo "▶ raw/assets/ → docs/assets/ 복사"
  mkdir -p docs/assets
  cp -R raw/assets/ docs/assets/
fi

if [ -d "scripts/css" ]; then
  echo "▶ 사이트 전용 CSS → docs/stylesheets/ 복사"
  mkdir -p docs/stylesheets
  cp scripts/css/*.css docs/stylesheets/
fi

echo "▶ [[wikilink]] → 표준 마크다운 변환"
if [ -x ".venv/bin/python3" ]; then
  .venv/bin/python3 scripts/wikilinks.py docs
else
  python3 scripts/wikilinks.py docs
fi

echo "▶ mkdocs build"
if [ -x ".venv/bin/mkdocs" ]; then
  .venv/bin/mkdocs build --clean
else
  mkdocs build --clean
fi

echo "✅ 빌드 완료 → site/"
