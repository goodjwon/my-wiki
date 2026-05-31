---
title: 하네스 Module 03 — Hooks 시스템 강제 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module3, hooks, guard-sh, lint-fix, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module3/guard.sh
  - harness-engineering/harness-kit/module3/lint-fix.sh
  - harness-engineering/harness-kit/module3/hooks-config.json
  - harness-engineering/harness-kit/module3/01_hooks_setup_prompt.md
  - harness-engineering/harness-kit/module3/02_self_verify_prompt.md
created: 2026-05-31
updated: 2026-05-31
---

# 하네스 Module 03 — Hooks 시스템 강제

> **이 가이드 보기 전에**: [[guide-harness-module2]] 까지 완료. CLAUDE.md 섹션 7 STOP 트리거가 있어야 합니다 (hooks가 강제할 대상).

**이 모듈에서 얻을 것**:
1. `.claude/hooks/guard.sh` — 위험 명령 차단 (PreToolUse)
2. `.claude/hooks/lint-fix.sh` — 자동 포맷·린트 (PostToolUse)
3. `.claude/settings.json` — hooks 등록
4. **차단 검증 표** — 실제로 막혔는지 확인
5. **자기검증 루프** — Claude가 "완료" 선언 전에 `npm test` 자동 실행

**시간**: 약 1.5시간 (설치 20분 + 차단 검증 20분 + 자기검증 루프 30분 + 커스텀 20분)

이론 배경: [[concept-claude-hooks]]

---

## Step 1 — `.claude/hooks/` 폴더 만들기 — 5분

```bash
mkdir -p .claude/hooks
```

---

## Step 2 — guard.sh 설치 (Node 친화) — 20분

`.claude/hooks/guard.sh` 파일을 다음 내용으로 생성:

```bash
cat > .claude/hooks/guard.sh << 'EOF'
#!/bin/bash
# guard.sh — Claude Code PreToolUse Hook (Bash 실행 직전 검사)
# exit 1로 종료하면 Claude Code가 해당 명령을 차단

COMMAND="$1"
[ -z "$COMMAND" ] && read -r COMMAND

block() {
  echo "🚫 BLOCKED by guard.sh: $1" >&2
  echo "REASON: $2" >&2
  echo "ACTION: $3" >&2
  exit 1
}

warn() {
  echo "⚠️  WARN by guard.sh: $1 — $2" >&2
}

# 1. 시크릿·환경 파일 노출/커밋
if echo "$COMMAND" | grep -qE "git add.*\.env|git commit.*\.env|cat.*\.env\.production"; then
  block "환경 파일 조작" \
    ".env / .env.production은 시크릿 포함 가능" \
    ".gitignore 확인, .env.example만 추적"
fi

if echo "$COMMAND" | grep -qE "git add.*credentials|git add.*service-account|git add.*\.pem"; then
  block "자격증명 파일 커밋" \
    "credentials.json / service-account.json / *.pem 노출 위험" \
    "Secret Manager 또는 환경변수 사용"
fi

# 2. 시크릿 로그
if echo "$COMMAND" | grep -qE "echo.*\\\$.*(SECRET|TOKEN|PASSWORD|API_KEY|PRIVATE_KEY)"; then
  block "시크릿 echo" \
    "환경변수가 stdout/로그에 노출됨" \
    "로컬 디버깅은 임시변수에 마스킹 후 출력"
fi

# 3. DB 직접 조작
if echo "$COMMAND" | grep -qE "DROP TABLE|DROP DATABASE|TRUNCATE.*TABLE"; then
  block "위험한 DDL" \
    "프로덕션 데이터 삭제 위험" \
    "마이그레이션 파일 (prisma migrate / knex migrate) 경유"
fi

# 4. 마이그레이션 파일 조작
if echo "$COMMAND" | grep -qE "rm.*migrations?/|sed.*migrations?/"; then
  block "마이그레이션 파일 조작" \
    "적용된 마이그레이션 수정은 히스토리 깨짐" \
    "새 마이그레이션 추가 (prisma migrate dev --name fix_X 등)"
fi

# 5. main/master 직접 push
if echo "$COMMAND" | grep -qE "git push.*origin (main|master)( |$)"; then
  block "main/master 직접 push" \
    "보호 브랜치는 PR 경유" \
    "feature 브랜치 + PR 생성"
fi

# 6. force push
if echo "$COMMAND" | grep -qE "git push.*(-f|--force)"; then
  block "강제 push" \
    "히스토리 파괴 위험" \
    "팀 리드 승인 후 force-with-lease 사용"
fi

# 7. node_modules 강제 삭제 (재설치 비용)
if echo "$COMMAND" | grep -qE "rm -rf node_modules"; then
  warn "node_modules 삭제" "재설치 시간 소요. 정말 필요한가?"
fi

# 8. npm install --global (시스템 오염)
if echo "$COMMAND" | grep -qE "npm install -g|npm i -g"; then
  warn "전역 패키지 설치" "프로젝트 의존성은 로컬 설치 권장"
fi

exit 0
EOF

chmod +x .claude/hooks/guard.sh
```

> 본인 baseline의 시스템 문제 중 정규식으로 잡을 수 있는 것을 **추가**한다. 잡기 어려운 것 (예: "DB 모델 노출")은 lint-fix.sh의 ESLint 규칙으로 위임.

---

## Step 3 — lint-fix.sh 설치 (Node 친화) — 10분

```bash
cat > .claude/hooks/lint-fix.sh << 'EOF'
#!/bin/bash
# lint-fix.sh — Claude Code PostToolUse Hook (파일 수정 직후)
# Write/Edit/MultiEdit 후 자동 포맷·린트

MODIFIED_FILE="${CLAUDE_TOOL_OUTPUT_FILE:-}"
[ -z "$MODIFIED_FILE" ] && exit 0
[ ! -f "$MODIFIED_FILE" ] && exit 0

# JS/TS 파일만 처리
if echo "$MODIFIED_FILE" | grep -qE "\.(js|jsx|ts|tsx|mjs|cjs)$"; then
  echo "🔧 lint-fix.sh: $MODIFIED_FILE"

  # Prettier (있으면)
  if [ -f "package.json" ] && grep -q "\"prettier\"" package.json; then
    npx prettier --write "$MODIFIED_FILE" 2>/dev/null && echo "  ✅ Prettier"
  fi

  # ESLint --fix (있으면)
  if [ -f "package.json" ] && grep -q "\"eslint\"" package.json; then
    npx eslint --fix "$MODIFIED_FILE" 2>&1 | tail -5
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
      echo "  ❌ ESLint 잔여 오류 — 수동 수정 필요" >&2
      exit 1
    fi
    echo "  ✅ ESLint"
  fi

  # 금지 패턴 감지 (경고만)
  if grep -nE "console\.log\(process\.env\." "$MODIFIED_FILE" 2>/dev/null; then
    echo "  ⚠️  process.env 로깅 감지 — 시크릿 노출 위험" >&2
  fi
  if grep -nE "catch\s*\([^)]*\)\s*\{\s*\}" "$MODIFIED_FILE" 2>/dev/null; then
    echo "  ⚠️  빈 catch 블록 감지 — silent fail 위험" >&2
  fi
fi

exit 0
EOF

chmod +x .claude/hooks/lint-fix.sh
```

> 본인 프로젝트에 ESLint·Prettier가 없으면 먼저 설치:
> ```bash
> npm install --save-dev eslint prettier
> npx eslint --init
> ```

---

## Step 4 — `.claude/settings.json`에 hooks 등록 — 5분

```bash
# settings.json이 없으면 빈 객체로 시작
[ ! -f .claude/settings.json ] && echo '{}' > .claude/settings.json

# hooks 블록 추가 (이미 있으면 머지 — 아래는 신규 생성 케이스)
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/lint-fix.sh" }
        ]
      }
    ]
  }
}
EOF
```

이미 `.claude/settings.json`에 다른 설정이 있으면 hooks 블록만 머지 (jq 또는 수동).

---

## Step 5 — 차단 검증 — 15분

본인이 직접 명령을 실행해서 차단되는지 확인. **Claude Code 안에서가 아니라 일반 터미널에서**:

```bash
# 차단되어야 하는 명령 (exit 1)
bash .claude/hooks/guard.sh "git add .env"                ; echo "→ exit $?"
bash .claude/hooks/guard.sh "git push origin main"        ; echo "→ exit $?"
bash .claude/hooks/guard.sh "git push -f origin feature"  ; echo "→ exit $?"
bash .claude/hooks/guard.sh "DROP TABLE users"            ; echo "→ exit $?"
bash .claude/hooks/guard.sh "echo \$DB_PASSWORD"          ; echo "→ exit $?"
bash .claude/hooks/guard.sh "rm migrations/20230101_init.sql" ; echo "→ exit $?"

# 허용되어야 하는 명령 (exit 0)
bash .claude/hooks/guard.sh "npm test"                    ; echo "→ exit $?"
bash .claude/hooks/guard.sh "git checkout -b feature/x"   ; echo "→ exit $?"
bash .claude/hooks/guard.sh "npm install zod"             ; echo "→ exit $?"
```

검증 표:

| 명령 | 기대 | 실제 |
|------|------|------|
| `git add .env` | exit 1 (BLOCKED) | __ |
| `git push origin main` | exit 1 | __ |
| `git push -f origin feature` | exit 1 | __ |
| `DROP TABLE users` | exit 1 | __ |
| `echo $DB_PASSWORD` | exit 1 | __ |
| `rm migrations/20230101_init.sql` | exit 1 | __ |
| `npm test` | exit 0 (OK) | __ |
| `git checkout -b feature/x` | exit 0 | __ |
| `npm install zod` | exit 0 | __ |

전부 일치하면 통과.

---

## Step 6 — Claude Code 안에서 실제 차단 테스트 — 10분

Claude Code 새 세션 시작 후:

```
git push origin main 명령을 실행해봐.
```

Claude가 실행을 시도하면 guard.sh가 차단해서 BLOCKED 메시지가 보여야 한다. 만약 Claude가 그냥 통과하거나 hook이 안 걸리면:

```bash
# 디버그
cat .claude/settings.json | jq .
ls -la .claude/hooks/
```

settings.json의 `"matcher": "Bash"`와 권한(`x`) 확인.

---

## Step 7 — 자기검증 루프 — 30분

> 원본: `raw/harness-engineering/harness-kit/module3/02_self_verify_prompt.md`

**목적**: Claude가 코드 작성 후 "완료" 선언하기 전에 **자동으로 npm test를 돌리고, 실패 시 스스로 수정**.

### Step 7-1: CLAUDE.md 섹션 5에 자기검증 규칙 추가

CLAUDE.md 섹션 5 (Goal-Driven Execution) 끝에:

```markdown
### 자기검증 루프 (모든 구현 작업에 적용)

"완료" 선언 전 반드시:

1단계: 컴파일/문법 확인
  - TS: npx tsc --noEmit
  - JS: node --check src/<수정파일>.js
  → 통과 못 하면 수정 후 재시도

2단계: 단위 테스트
  - npm test -- --findRelatedTests <수정파일>  (Jest)
  - 또는 npx vitest run <수정파일>             (Vitest)
  → 실패 시 원인 파악 후 수정. 통과까지 반복.

3단계: 전체 테스트
  - npm test
  → 기존 테스트 깨지면 내 변경이 원인인지 확인.
    원인이면 수정, 기존 버그면 보고만.

4단계: 검증 완료 보고
---검증 완료 보고---
구현 내용: [한 줄]
컴파일: ✅
단위 테스트: ✅ N pass / 0 fail
전체 테스트: ✅ N pass / 0 fail
추가된 테스트: [파일 + 케이스]
변경된 파일: [목록]
---
```

### Step 7-2: 첫 실험

새 세션에서:

```
새 라우트 GET /health 를 추가해줘.
- 200 OK 응답
- { status: "ok", uptime: process.uptime() } 반환
- 자기검증 루프 (CLAUDE.md 섹션 5 끝부분) 적용
```

기대 동작:
1. Claude가 계획 제시
2. 라우트 + 테스트 작성
3. **스스로** `npm test` 실행
4. **검증 완료 보고** 형식으로 결과 출력

만약 4번이 안 나오면 → "검증 완료 보고 형식으로 마무리해줘" 한 번 더 지시. 두 번째 세션부터는 보통 알아서 한다.

---

## Step 8 — 커밋 — 5분

```bash
git add .claude/hooks/ .claude/settings.json CLAUDE.md
git commit -m "harness(M3): guard.sh + lint-fix.sh + 자기검증 루프 설치"
```

> `.claude/settings.json`을 팀과 공유하려면 git 추적, 개인 설정이면 `.gitignore` 추가.

---

## 막힐 때 (Module 3 전용 FAQ)

### Q. guard.sh가 직접 실행은 되는데 Claude Code 안에서 안 걸려요
1. `.claude/settings.json`의 `"matcher": "Bash"` 정확한지 (대소문자)
2. `chmod +x .claude/hooks/guard.sh` 실행 권한 확인
3. Claude Code를 **완전 종료 후 재실행** (설정 재로드)
4. `claude --debug` 로 hook 호출 로그 확인

### Q. lint-fix.sh가 ESLint 오류로 자꾸 멈춰요
처음에는 의도된 동작. ESLint 규칙이 너무 엄격하면 `.eslintrc`에서 일부 규칙을 warning으로 낮추거나, lint-fix.sh의 `exit 1`을 `exit 0`(경고만)으로 바꿈.

### Q. `CLAUDE_TOOL_OUTPUT_FILE` 환경변수가 안 들어와요
Claude Code 버전에 따라 변수 이름이 다를 수 있음. `claude --debug`로 PostToolUse 호출 시 환경변수 목록 확인 후 lint-fix.sh의 변수명 조정.

### Q. 자기검증 루프가 무한 반복돼요
3단계까지 실패하면 멈추도록 CLAUDE.md에 명시. "각 단계 3회 시도 후 사용자에게 보고" 같은 한계 규칙 추가.

### Q. hooks 때문에 단순 작업이 너무 느려요
PostToolUse의 lint-fix가 매 Edit마다 실행되면 답답할 수 있다. `matcher`를 `"Write"`로만 좁히거나 (Edit는 제외), lint-fix를 비동기로 (`&` 백그라운드).

---

## 산출물 정리

| 파일 | 내용 |
|------|------|
| `.claude/hooks/guard.sh` | 시크릿/마이그레이션/main push 등 8종 차단 |
| `.claude/hooks/lint-fix.sh` | Prettier + ESLint + 금지 패턴 경고 |
| `.claude/settings.json` | PreToolUse + PostToolUse 등록 |
| `CLAUDE.md` 섹션 5 (확장) | 자기검증 루프 4단계 |
| 차단 검증 표 (수기) | 본인 환경에서 통과 확인 |

---

## 다음 단계

▶ [[guide-harness-module4]] — 여러 에이전트 역할로 작업 분리 + 세션 인계 자동화.

## 관련 페이지

- [[guide-harness-module2]] — 입력 (CLAUDE.md STOP 트리거)
- [[guide-harness-module4]] — 다음 모듈 (Stop hook으로 progress 자동 인계)
- [[concept-claude-hooks]] — Hooks 라이프사이클 이론
- [[src-harness-engineering]] — 전체 커리큘럼
