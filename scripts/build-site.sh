#!/usr/bin/env bash
# wiki/ 를 docs/ 로 복사한 뒤 Zensical 빌드 (BUILDER=mkdocs 로 Material for MkDocs 빌드)
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

PY=python3; [ -x ".venv/bin/python3" ] && PY=.venv/bin/python3
BIN=""; [ -d ".venv/bin" ] && BIN=".venv/bin/"

# Zensical은 MkDocs 훅을 실행하지 않음 → seo.py·new_badge.py 역할을 전후 단계로 수행
echo "▶ description·noindex·🆕 배지 전처리"
$PY scripts/zensical_prep.py pre docs mkdocs.yml .zensical.yml

if [ "${BUILDER:-zensical}" = "mkdocs" ]; then
  # 비상 대안: Material for MkDocs (2027-05-05 지원 종료)
  echo "▶ mkdocs build"
  ${BIN}mkdocs build --clean   # 훅(seo·new_badge)이 직접 실행되므로 원본 설정 사용
else
  echo "▶ zensical build"
  ${BIN}zensical build -c -f .zensical.yml
fi

echo "▶ sitemap.xml (lastmod = frontmatter updated)"
$PY scripts/zensical_prep.py post docs site "$(sed -n 's/^site_url: *//p' mkdocs.yml)"

echo "✅ 빌드 완료 → site/"
