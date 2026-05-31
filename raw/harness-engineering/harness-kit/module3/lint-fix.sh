#!/bin/bash
# lint-fix.sh — Claude Code Post-Tool Hook
# 파일 수정 후 자동으로 포맷과 린트를 적용합니다
# 위치: .claude/hooks/lint-fix.sh
# 권한: chmod +x .claude/hooks/lint-fix.sh

# 수정된 파일 경로 (Claude Code가 env로 전달)
MODIFIED_FILE="${CLAUDE_TOOL_OUTPUT_FILE:-}"

# ─── Java 파일 처리 ───────────────────────────────────────
if echo "$MODIFIED_FILE" | grep -q "\.java$"; then

  echo "🔧 lint-fix.sh: Java 파일 감지 → $MODIFIED_FILE"

  # 1. Google Java Format (설치된 경우)
  if command -v google-java-format &> /dev/null; then
    google-java-format --replace "$MODIFIED_FILE"
    echo "  ✅ Google Java Format 적용"
  fi

  # 2. Checkstyle (Gradle 프로젝트)
  if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    # 변경된 파일이 src/main에 있을 때만 checkstyle
    if echo "$MODIFIED_FILE" | grep -q "src/main"; then
      ./gradlew checkstyleMain -q 2>&1 | tail -5
      if [ $? -ne 0 ]; then
        echo "  ❌ Checkstyle 실패 — 규칙 위반이 있습니다"
        echo "  📄 자세한 내용: build/reports/checkstyle/main.html"
        exit 1
      fi
      echo "  ✅ Checkstyle 통과"
    fi

    # 변경된 파일이 test에 있을 때
    if echo "$MODIFIED_FILE" | grep -q "src/test"; then
      ./gradlew checkstyleTest -q 2>&1 | tail -5
    fi
  fi

  # 3. 금지 패턴 감지
  echo "  🔍 금지 패턴 검사 중..."

  # @Autowired 필드 주입 감지
  if grep -n "@Autowired" "$MODIFIED_FILE" 2>/dev/null | grep -v "//"; then
    echo "  ⚠️  @Autowired 필드 주입 감지 → 생성자 주입으로 변경하세요"
  fi

  # Entity를 Controller에서 직접 반환하는 패턴
  if echo "$MODIFIED_FILE" | grep -q "Controller"; then
    if grep -n "return.*Entity\|ResponseEntity.*Entity" "$MODIFIED_FILE" 2>/dev/null; then
      echo "  ⚠️  Controller에서 Entity 직접 반환 의심 → DTO 변환 확인하세요"
    fi
  fi

  # infrastructure에서 domain import 역방향 감지
  if echo "$MODIFIED_FILE" | grep -q "infrastructure"; then
    if grep -n "import.*application\." "$MODIFIED_FILE" 2>/dev/null; then
      echo "  ⚠️  infrastructure → application 역방향 의존 감지"
    fi
  fi
fi

# ─── TypeScript / React 파일 처리 ────────────────────────
if echo "$MODIFIED_FILE" | grep -qE "\.(ts|tsx)$"; then

  echo "🔧 lint-fix.sh: TypeScript 파일 감지 → $MODIFIED_FILE"

  if [ -f "package.json" ]; then
    # ESLint auto-fix
    npx eslint --fix "$MODIFIED_FILE" 2>/dev/null
    echo "  ✅ ESLint auto-fix 적용"

    # Prettier
    npx prettier --write "$MODIFIED_FILE" 2>/dev/null
    echo "  ✅ Prettier 적용"
  fi
fi

# ─── SQL Migration 파일 처리 ─────────────────────────────
if echo "$MODIFIED_FILE" | grep -qE "\.sql$"; then
  echo "🔧 lint-fix.sh: SQL 파일 감지 → $MODIFIED_FILE"

  # Migration 파일 네이밍 규칙 확인
  FILENAME=$(basename "$MODIFIED_FILE")
  if ! echo "$FILENAME" | grep -qE "^V[0-9]+__[a-z_]+\.sql$"; then
    echo "  ⚠️  Migration 파일 네이밍 규칙 위반"
    echo "  올바른 형식: V{숫자}__{소문자_언더스코어}.sql"
    echo "  예시: V20240101__add_manager_email_to_contract.sql"
  fi
fi

echo "✅ lint-fix.sh 완료"
exit 0
