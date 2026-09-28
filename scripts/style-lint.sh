#!/usr/bin/env bash
# 위키 §7 문체 표준(guide-wiki-authoring-standards.md)의 기계 검출 가능한 위반을 검사한다.
# 토큰 0 무료 게이트 — 위반이 있으면 exit 1 + 목록 출력, 없으면 exit 0.
#
# 사용법: bash scripts/style-lint.sh <wiki/파일.md> [<wiki/파일2.md> ...]
set -uo pipefail

if [ "$#" -eq 0 ]; then
  echo "사용법: bash scripts/style-lint.sh <wiki/파일.md> [...]" >&2
  exit 2
fi

TOTAL_VIOLATIONS=0
CURLY_QUOTES=$'“”'  # 좌우 곡선따옴표 — 리터럴 글리프는 도구 경유 시 직선따옴표로 뭉개져 유니코드 이스케이프로 지정

# 코드펜스(``` 또는 4-backtick 포함) · frontmatter(--- ~ ---) 블록을 제거하고
# "라인번호:내용" 형태로 출력한다. 본문 프로즈만 검사 대상으로 남긴다.
strip_noise() {
  awk '
    NR == 1 && /^---$/ { infm = 1; next }
    infm && /^---$/ { infm = 0; next }
    infm { next }
    /^[[:space:]]*`{3,}/ { infence = !infence; next }
    infence { next }
    { print NR ":" $0 }
  ' "$1"
}

lint_file() {
  local file="$1"
  local base
  base="$(basename "$file")"
  local violations=0

  if [ ! -f "$file" ]; then
    echo "❌ 파일 없음: $file"
    TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
    return
  fi

  local stripped
  stripped="$(strip_noise "$file")"

  echo "── $file ──"

  # 규칙 자체를 정의하는 작성 표준 문서는 금칙어·금지 문구를 예시로 인용하므로 검사 제외
  if [[ "$base" == guide-wiki-authoring-standards.md ]]; then
    echo "  (규칙 정의 문서 — 검사 제외)"
    return
  fi

  # 1) 금칙 용어 (§7-5)
  local term_hits
  term_hits="$(printf '%s\n' "$stripped" | grep -E '커맨드|폴더|디렉토리' || true)"
  if [ -n "$term_hits" ]; then
    echo "  [금칙 용어] 커맨드→명령 / 폴더·디렉토리→디렉터리"
    printf '%s\n' "$term_hits" | sed 's/^/    /'
    local n
    n=$(printf '%s\n' "$term_hits" | grep -c '.')
    violations=$((violations + n))
  fi

  # 2) 라벨형 성공 문구 (§7-3)
  local label_hits
  label_hits="$(printf '%s\n' "$stripped" | grep -E '성공 판정:|성공:|성공 출력:' || true)"
  if [ -n "$label_hits" ]; then
    echo "  [라벨형 성공 문구 금지] '예상 결과' 펜스 또는 완결 문장으로 교체"
    printf '%s\n' "$label_hits" | sed 's/^/    /'
    local n
    n=$(printf '%s\n' "$label_hits" | grep -c '.')
    violations=$((violations + n))
  fi

  # 3) 곡선따옴표 (§7-6)
  local quote_hits
  quote_hits="$(printf '%s\n' "$stripped" | grep -E "[${CURLY_QUOTES}]" || true)"
  if [ -n "$quote_hits" ]; then
    echo "  [곡선따옴표] 곧은따옴표(\") 로 교체"
    printf '%s\n' "$quote_hits" | sed 's/^/    /'
    local n
    n=$(printf '%s\n' "$quote_hits" | grep -c '.')
    violations=$((violations + n))
  fi

  # 4) 독자 콘텐츠 산문 한정 — 평어 종결 (§7-1)
  #    챕터·가이드·개념·엔티티·소스·비교 페이지가 대상. backlog/plan 같은 저자 전용 운영 메모(§7-1 예외)와
  #    규칙 자체를 인용하는 작성 표준 문서는 제외.
  #    🎯/✏️ 슬롯은 평어 예외. 콜아웃(blockquote `>`)은 챕터에서만 예외("따라 하는 법" 등 §7-1 매트릭스).
  #    검출: 줄 끝 "다." / 문장 중간 "다. " / 목록·표 줄 끝 "다" / 표 셀 "다 |" — 인라인 코드·큰따옴표 인용은 제외.
  if [[ "$base" == java-study-ch*.md || "$base" == guide-*.md || "$base" == concept-*.md || "$base" == entity-*.md \
     || "$base" == src-*.md || "$base" == comparison-*.md ]] && [[ "$base" != guide-wiki-authoring-standards.md ]]; then
    local prose
    prose="$(printf '%s\n' "$stripped" | grep -v '🎯\|✏️' || true)"
    if [[ "$base" == java-study-ch*.md ]]; then
      prose="$(printf '%s\n' "$prose" | grep -v '^[0-9]*:>' || true)"
    fi
    # 인라인 코드와 "..." 인용을 지운 뒤 검사 (인용문은 원문 문체 보존)
    prose="$(printf '%s\n' "$prose" | sed -E 's/`[^`]*`//g; s/"[^"]*"//g')"
    local heoje_hits
    heoje_hits="$(printf '%s\n' "$prose" | grep -E '다\.[\"'"'"')*]*$|[^니]다\. |^[0-9]+:[[:space:]]*([-*]|[0-9]+\.) .*[^니]다$|[^니마보]다 *\|' \
      | grep -vE '니다\.[\"'"'"')*]*$' || true)"
    if [ -n "$heoje_hits" ]; then
      echo "  [산문 평어체] 합니다체로 교체 (스캐폴드·콜아웃 슬롯은 이미 제외됨)"
      printf '%s\n' "$heoje_hits" | sed 's/^/    /'
      local n
      n=$(printf '%s\n' "$heoje_hits" | grep -c '.')
      violations=$((violations + n))
    fi
  fi

  if [ "$violations" -eq 0 ]; then
    echo "  ✅ 위반 없음"
  fi
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + violations))
}

for f in "$@"; do
  lint_file "$f"
done

echo "────────────────"
if [ "$TOTAL_VIOLATIONS" -eq 0 ]; then
  echo "✅ style-lint 통과 (위반 0건)"
  exit 0
else
  echo "❌ style-lint 실패 — 위반 ${TOTAL_VIOLATIONS}건"
  exit 1
fi
