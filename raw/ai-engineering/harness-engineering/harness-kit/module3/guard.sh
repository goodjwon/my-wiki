#!/bin/bash
# guard.sh — Claude Code PreToolUse Hook
# 위험한 명령을 실행 전에 차단합니다
# 위치: .claude/hooks/guard.sh
# 권한: chmod +x .claude/hooks/guard.sh
# 의존: jq (brew install jq / apt install jq)
#
# Claude Code는 hook 입력을 stdin으로 JSON 전달한다:
#   {"tool_name":"Bash","tool_input":{"command":"..."}}
# 명령을 차단하려면 exit 2 로 종료한다 (stderr 메시지가 Claude에게 전달돼 자동 처리됨).
# exit 0 = 통과, exit 1 = 비차단 오류(실행 계속). 차단은 반드시 exit 2.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
# jq가 없거나 평문으로 직접 테스트할 때는 입력 전체를 명령으로 간주
[ -z "$COMMAND" ] && COMMAND="$INPUT"

# ─── 차단 규칙 ─────────────────────────────────────────

block() {
  echo "🚫 BLOCKED by guard.sh: $1" >&2
  echo "REASON: $2" >&2
  echo "ACTION: $3" >&2
  exit 2
}

warn() {
  echo "⚠️  WARNING by guard.sh: $1" >&2
  echo "REASON: $2" >&2
}

# 1. Migration 파일 수정/삭제
if echo "$COMMAND" | grep -qE "(rm|del|delete|DROP|truncate).*migration"; then
  block "Migration 파일 조작" \
    "migration 파일은 한 번 적용 후 수정 불가" \
    "새 migration 파일을 생성하세요: V{버전}__description.sql"
fi

if echo "$COMMAND" | grep -qE "sed.*src/main/resources/db/migration"; then
  block "Migration 파일 직접 수정" \
    "sed로 migration 파일 수정은 히스토리를 파괴함" \
    "새 migration 파일 V{N+1}__fix_*.sql 생성하세요"
fi

# 2. 프로덕션 DB 직접 조작
if echo "$COMMAND" | grep -qE "DROP TABLE|DROP DATABASE|TRUNCATE"; then
  block "위험한 DDL" \
    "프로덕션 데이터 삭제 위험" \
    "Migration 파일로만 스키마 변경하세요"
fi

# 3. main 브랜치 직접 push
if echo "$COMMAND" | grep -qE "git push.*origin main|git push.*origin master"; then
  block "main 브랜치 직접 push" \
    "main은 PR을 통해서만 업데이트" \
    "feature 브랜치에서 PR을 생성하세요"
fi

# 4. 강제 push
if echo "$COMMAND" | grep -qE "git push.*(-f|--force)"; then
  block "강제 push" \
    "히스토리 파괴 위험" \
    "팀 리드 승인 없이 force push 금지"
fi

# 5. .env, secrets 파일 노출
if echo "$COMMAND" | grep -qE "cat.*\.env|echo.*SECRET|echo.*PASSWORD|echo.*API_KEY"; then
  block "민감 정보 노출" \
    "환경변수/시크릿이 로그에 노출될 위험" \
    "환경변수는 application.properties 또는 Vault 사용"
fi

# 6. 테스트 스킵하고 빌드
if echo "$COMMAND" | grep -qE "gradle.*-x test.*build|gradle.*skipTests"; then
  warn "테스트 스킵 빌드" \
    "CI에서는 테스트가 필수입니다"
  # warn만 하고 차단하지는 않음 (로컬 빠른 빌드는 허용)
fi

# 7. node_modules, .gradle 삭제 (재설치 비용 큼)
if echo "$COMMAND" | grep -qE "rm -rf node_modules|rm -rf \.gradle"; then
  warn "캐시 디렉토리 삭제" \
    "재설치에 시간이 걸립니다. 정말 필요한가요?"
fi

# ─── 모든 체크 통과 ──────────────────────────────────────
exit 0
