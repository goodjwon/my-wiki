---
title: 하네스 Module 03 — Hooks 시스템 강제 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module3, hooks, guard-sh, lint-fix, node, step-by-step]
sources:
  - ai-engineering/harness-engineering/harness-kit/module3/guard.sh
  - ai-engineering/harness-engineering/harness-kit/module3/lint-fix.sh
  - ai-engineering/harness-engineering/harness-kit/module3/hooks-config.json
  - ai-engineering/harness-engineering/harness-kit/module3/01_hooks_setup_prompt.md
  - ai-engineering/harness-engineering/harness-kit/module3/02_self_verify_prompt.md
created: 2026-05-31
updated: 2026-07-04
---

# 하네스 Module 03 — Hooks 시스템 강제

> **이 가이드 보기 전에**: [[guide-harness-module2]] 까지 완료합니다. Module 02에서 CLAUDE.md 섹션 7에 채운 STOP 트리거 — 위험 작업 직전에 에이전트를 멈추게 하는 금지 조건 목록 — 가 있어야 합니다 (hooks가 강제할 대상).

**왜 CLAUDE.md 다음이 hooks인가**: Module 02에서 만든 STOP 트리거는 결국 "말로 하는 권고"입니다. 에이전트는 대화가 길어지면 규칙을 잊고, 급하면 어깁니다 — 실제로 CLAUDE.md에 적어 둔 금지 사항을 그대로 수행하는 장면을 Module 01 베이스라인 측정에서 이미 봤을 것입니다. hooks는 다릅니다. Claude Code가 도구를 실행하는 경로 자체에 끼어들어, 에이전트가 규칙을 어긴 순간에도 **물리적으로 차단**합니다. 규칙(권고) 위에 강제 층을 한 겹 더 얹는 것 — 그래서 CLAUDE.md 다음 모듈이 hooks입니다.

**이 모듈에서 얻을 것**:

1. `.claude/hooks/guard.sh` — 위험 명령 차단 (PreToolUse)
2. `.claude/hooks/lint-fix.sh` — 자동 포맷·린트 (PostToolUse)
3. `.claude/settings.json` — hooks 등록
4. **차단 검증 표** — 실제로 막혔는지 확인
5. **자기검증 루프** — Claude가 "완료" 선언 전에 `npm test` 자동 실행

위 목록의 PreToolUse·PostToolUse는 Claude Code hook의 **실행 시점 이름**입니다 — 각각 도구 실행 **직전**과 **직후**에 스크립트를 끼워 넣는 자리로, Step 2와 Step 3에서 하나씩 만듭니다.

**진행 흐름**: 파싱 도구 준비(Step 1) → 차단 스크립트 작성(Step 2~3) → hooks 등록(Step 4) → 터미널에서 단독 검증(Step 5) → Claude Code 안에서 실전 검증(Step 6) → 자기검증 루프 추가(Step 7) → 커밋(Step 8).

**시간**: 약 1시간 40분 (설치 40분 + 차단 검증 25분 + 자기검증 루프 30분 + 커밋 5분)

이론 배경: [[concept-claude-hooks]]

---

## Step 1 — `.claude/hooks/` 디렉터리 + jq 준비 — 5분

hooks의 실체는 평범한 셸 스크립트입니다. Claude Code는 hook 스크립트를 부를 때 지금 실행하려는 내용(도구 이름, 명령·파일 경로)을 **stdin으로 JSON 한 건**에 담아 넘겨줍니다 — 이후 "stdin JSON"은 이 입력을 가리킵니다. guard.sh / lint-fix.sh는 이 **JSON 입력을 `jq`로 파싱**하므로, 스크립트를 쓰기 전에 jq와 디렉터리부터 준비합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: jq 설치 + `.claude/hooks/` 디렉터리
    - **실행**: 아래 명령을 차례로 실행합니다.

```bash
# jq 설치 (Claude Code hook 입력 JSON 파싱용)
brew install jq          # macOS
# sudo apt install jq    # Ubuntu/Debian

jq --version             # 설치 확인

cd ~/harness-playground
mkdir -p .claude/hooks
```

---

## Step 2 — guard.sh 설치 (Node 친화) — 20분

준비가 끝났으니 첫 번째 강제 장치를 만듭니다. guard.sh는 **PreToolUse** 시점 — Claude가 Bash 명령을 실행하기 직전 — 에 호출되어, Module 02 STOP 트리거 중 정규식으로 잡을 수 있는 것들을 실행 전에 차단합니다. 차단 신호는 종료 코드로 전달합니다 — Claude Code hook 규약에서 **exit 2가 차단**, exit 0이 통과입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.claude/hooks/guard.sh` — 위험 명령을 실행 직전에 차단하는 PreToolUse hook
    - **실행**: 아래 명령으로 파일을 생성하고 실행 권한을 부여합니다.

아래 스크립트에는 **차단 규칙 6종**(`block` — 명령을 막음)과 **경고 규칙 2종**(`warn` — 막지 않고 메시지만 남김)이 담겨 있습니다. `.claude/hooks/guard.sh` 파일을 다음 내용으로 생성:

```bash
cat > .claude/hooks/guard.sh << 'EOF'
#!/bin/bash
# guard.sh — Claude Code PreToolUse Hook (Bash 실행 직전 검사)
# Claude Code는 hook 입력을 stdin으로 JSON 전달한다:
#   {"tool_name":"Bash","tool_input":{"command":"..."}}
# 명령을 차단하려면 exit 2 로 종료한다 (stderr가 Claude에게 전달돼 자동 처리됨).
# exit 0 = 통과, exit 1 = 비차단 오류(실행 계속). 차단은 반드시 exit 2.
# 의존: jq (brew install jq)

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
# jq가 없거나 평문으로 직접 테스트할 때는 입력 전체를 명령으로 간주
[ -z "$COMMAND" ] && COMMAND="$INPUT"

block() {
  echo "🚫 BLOCKED by guard.sh: $1" >&2
  echo "REASON: $2" >&2
  echo "ACTION: $3" >&2
  exit 2
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

> Module 01에서 `.claude/baseline.md`에 기록한 본인 baseline의 시스템 문제 중 정규식으로 잡을 수 있는 것을 **추가**합니다. 잡기 어려운 것 (예: "DB 모델 노출")은 lint-fix.sh의 ESLint 규칙으로 위임합니다.

---

## Step 3 — lint-fix.sh 설치 (Node 친화) — 10분

guard.sh가 "실행 전 차단"이라면 lint-fix.sh는 "수정 후 교정"입니다. **PostToolUse** 시점 — Claude가 파일을 수정한 직후 — 에 자동으로 포맷·린트를 실행하고, 남은 오류는 Claude에게 되돌려 스스로 고치게 합니다. 정규식으로 잡기 어려운 코드 품질 문제를 이 층이 맡습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.claude/hooks/lint-fix.sh` — 파일 수정 직후 자동 포맷·린트하는 PostToolUse hook
    - **실행**: 아래 명령으로 파일을 생성하고 실행 권한을 부여합니다.

```bash
cat > .claude/hooks/lint-fix.sh << 'EOF'
#!/bin/bash
# lint-fix.sh — Claude Code PostToolUse Hook (파일 수정 직후)
# Write/Edit/MultiEdit 후 자동 포맷·린트
# Claude Code는 hook 입력을 stdin으로 JSON 전달: {"tool_input":{"file_path":"..."}}
# 린트 실패를 Claude에게 되돌려 자동 수정시키려면 exit 2. 의존: jq (brew install jq)

INPUT=$(cat)
MODIFIED_FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
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
      echo "  ❌ ESLint 잔여 오류 — Claude가 수정해야 함" >&2
      exit 2
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
> ```
>
> 그다음 ESLint 설정 마법사를 **따로** 실행합니다 (모듈 종류·프레임워크 등 질문에 직접 답해야 하는 대화형):
>
> ```bash
> npx eslint --init
> ```

---

## Step 4 — `.claude/settings.json`에 hooks 등록 — 5분

스크립트 두 개는 만들어 두는 것만으로는 아무 일도 하지 않습니다. Claude Code가 **언제**(PreToolUse/PostToolUse) **어떤 도구에 대해**(matcher) 무엇을 부를지 `settings.json`에 등록해야 비로소 hooks로 작동합니다. 여기서 `matcher`는 hook을 적용할 도구를 고르는 이름 패턴입니다 — 아래 블록처럼 `"Bash"` 하나만 쓰거나, `"Write|Edit|MultiEdit"`처럼 `|`로 여러 도구를 묶습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.claude/settings.json` — 두 hook의 실행 시점·대상 등록
    - **실행**: 아래 명령으로 새로 생성합니다. 기존 설정이 있는 프로젝트라면 코드블록 아래 머지 안내를 따릅니다.

실습 playground는 `.claude/settings.json`이 아직 없으므로 아래처럼 **새로 만들면 됩니다**. (이미 다른 설정이 있는 본인 프로젝트라면 아래 명령으로 통째 덮어쓰지 말고, `hooks` 블록만 머지합니다 — jq 또는 수동. 머지 방법은 코드블록 아래 참조.)

```bash
# 신규 생성 케이스: settings.json을 새로 만든다
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

**기존 프로젝트 머지**: 이미 `.claude/settings.json`에 다른 설정이 있으면 위 명령으로 덮어쓰지 말고 `hooks` 블록만 추가합니다. jq로 머지하거나, 에디터로 `hooks` 키만 직접 붙여 넣습니다.

---

## Step 5 — 차단 검증 — 15분

등록까지 마쳤지만, 하네스에서 "작동한다고 믿는 것"과 "작동을 확인한 것"은 다릅니다. Claude Code에 들어가기 전에 먼저 일반 터미널에서 guard.sh 단독으로 검증합니다 — 여기서 통과해야 Step 6에서 문제가 생겼을 때 원인을 스크립트가 아닌 등록·권한 쪽으로 좁힐 수 있습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground` — Claude Code 밖, 일반 터미널
    - **만들 것**: 차단 검증 표 (아래 표의 "실제" 칸 채우기)
    - **실행**: 아래 stdin JSON 테스트 9개를 실행하고 exit 코드를 표에 기록합니다.

본인이 직접 명령을 실행해서 차단되는지 확인합니다. **Claude Code 안에서가 아니라 일반 터미널에서**. Claude Code가 실제로 보내는 것과 동일하게 **stdin JSON**으로 넣어 테스트합니다 (argv가 아니라 stdin이 진짜 hook 경로):

```bash
# 차단되어야 하는 명령 (exit 2)
echo '{"tool_input":{"command":"git add .env"}}'                | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"git push origin main"}}'        | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"git push -f origin feature"}}'  | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"DROP TABLE users"}}'            | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"echo $DB_PASSWORD"}}'           | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"rm migrations/20230101_init.sql"}}' | bash .claude/hooks/guard.sh ; echo "→ exit $?"

# 허용되어야 하는 명령 (exit 0)
echo '{"tool_input":{"command":"npm test"}}'                    | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"git checkout -b feature/x"}}'   | bash .claude/hooks/guard.sh ; echo "→ exit $?"
echo '{"tool_input":{"command":"npm install zod"}}'             | bash .claude/hooks/guard.sh ; echo "→ exit $?"
```

검증 표 — 방금 실행한 9개 테스트의 기대 exit 코드입니다. 터미널에 출력된 값을 "실제" 칸에 적습니다:

| 명령 | 기대 | 실제 |
|------|------|------|
| `git add .env` | exit 2 (BLOCKED) | __ |
| `git push origin main` | exit 2 | __ |
| `git push -f origin feature` | exit 2 | __ |
| `DROP TABLE users` | exit 2 | __ |
| `echo $DB_PASSWORD` | exit 2 | __ |
| `rm migrations/20230101_init.sql` | exit 2 | __ |
| `npm test` | exit 0 (OK) | __ |
| `git checkout -b feature/x` | exit 0 | __ |
| `npm install zod` | exit 0 | __ |

전부 일치하면 통과합니다. (`exit 2`가 Claude Code에서 명령 차단을 의미합니다. `exit 1`은 차단이 아니라 "비차단 오류"라 명령이 그대로 실행됩니다 — 그래서 차단 hook은 반드시 2로 끝내야 합니다.)

---

## Step 6 — Claude Code 안에서 실제 차단 테스트 — 10분

Step 5의 터미널 검증은 스크립트 자체의 정확성만 보장합니다. 이번에는 Claude Code가 실제로 guard.sh를 호출하는지 — 등록(settings.json)·경로·실행 권한까지 포함한 전체 경로를 확인합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground` — Claude Code **새 세션** (settings.json 반영을 위해 완전 종료 후 재실행)
    - **실행**: 새 세션에서 아래 프롬프트를 붙여넣고 BLOCKED 메시지가 나오는지 확인합니다.

settings.json 변경을 반영하려면 실행 중인 Claude Code를 **완전 종료한 뒤 다시 실행**(새 세션 시작)합니다. 그다음, 일부러 차단 대상 명령을 시키는 아래 프롬프트를 붙여넣습니다:

```
git push origin main 명령을 실행해봐.
```

Claude가 실행을 시도하면 guard.sh가 차단해서 BLOCKED 메시지가 보여야 합니다. 만약 Claude가 그냥 통과하거나 hook이 안 걸리면:

```bash
# 디버그
cat .claude/settings.json | jq .
ls -la .claude/hooks/
```

settings.json의 `"matcher": "Bash"`와 권한(`x`)을 확인합니다.

---

## Step 7 — 자기검증 루프 — 30분

지금까지 만든 것은 전부 "나쁜 행동 차단"이었습니다. 하네스의 나머지 절반은 "좋은 행동 강제" — Claude가 코드 작성 후 "완료"를 선언하기 전에 **스스로 npm test를 실행하고, 실패하면 스스로 수정**하게 만드는 자기검증 루프입니다. hooks가 아니라 CLAUDE.md 규칙으로 구현하는 이유는, "테스트를 돌려라"는 특정 명령 차단이 아니라 작업 절차 전체에 걸친 지시라 정규식 hook으로 표현할 수 없기 때문입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: CLAUDE.md 섹션 5 끝에 자기검증 루프 규칙 추가
    - **실행**: 규칙 블록을 붙여 넣어 저장한 뒤, 새 세션에서 Step 7-2 프롬프트로 적용을 확인합니다.

### Step 7-1: CLAUDE.md 섹션 5에 자기검증 규칙 추가

Module 02 골격에서 만든 CLAUDE.md 섹션 5(Goal-Driven Execution)는 "단계 → verify: 확인법" 형식으로 작업 절차를 정한 자리였습니다. 그 절차의 마지막 관문으로, 섹션 5 끝에 아래 규칙 블록을 그대로 붙여 넣습니다:

```text
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

CLAUDE.md를 저장했으면 이 규칙은 다음 세션부터 로드됩니다. 실행 중인 Claude Code를 종료하고 새 세션을 시작한 뒤, 아래 작업을 시켜 규칙이 실제로 적용되는지 확인합니다.

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

만약 4번이 안 나오면 → "검증 완료 보고 형식으로 마무리해줘" 한 번 더 지시합니다. 두 번째 세션부터는 보통 알아서 합니다.

---

## Step 8 — 커밋 — 5분

이번 모듈의 산출물을 커밋으로 남깁니다. Module 05에서 하네스 전/후를 비교할 때 "hooks가 언제부터 있었는지"를 git 이력으로 추적하는 기준점이 됩니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **실행**: 아래 명령으로 산출물 3종(hooks, settings.json, CLAUDE.md)을 커밋합니다.

```bash
git add .claude/hooks/ .claude/settings.json CLAUDE.md
git commit -m "harness(M3): guard.sh + lint-fix.sh + 자기검증 루프 설치"
```

> `.claude/settings.json`을 팀과 공유하려면 git으로 추적하고, 개인 설정이면 `.gitignore`에 추가합니다.

---

## 막힐 때 (Module 3 전용 FAQ)

### Q. guard.sh가 직접 실행은 되는데 Claude Code 안에서 안 걸려요

1. `.claude/settings.json`의 `"matcher": "Bash"` 정확한지 (대소문자)
2. `chmod +x .claude/hooks/guard.sh` 실행 권한 확인
3. Claude Code를 **완전 종료 후 재실행** (설정 재로드)
4. `claude --debug` 로 hook 호출 로그 확인

### Q. lint-fix.sh가 ESLint 오류로 자꾸 멈춰요
처음에는 의도된 동작입니다 — `exit 2`라 Claude에게 오류가 전달돼 스스로 고치게 합니다. ESLint 규칙이 너무 엄격하면 `.eslintrc`에서 일부 규칙을 warning으로 낮추거나, lint-fix.sh의 `exit 2`를 `exit 0`(경고만, 차단 안 함)으로 바꿉니다.

### Q. lint-fix.sh가 파일 경로를 못 잡아요 (린트가 안 됩니다)
파일 경로는 **stdin JSON의 `.tool_input.file_path`**에서 온다 (예전 `CLAUDE_TOOL_OUTPUT_FILE` 환경변수가 아님). jq가 설치돼 있는지(`jq --version`), `claude --debug`로 PostToolUse가 받는 JSON에 `tool_input.file_path`가 있는지 확인. 직접 테스트:
```bash
echo '{"tool_input":{"file_path":"src/app.js"}}' | bash .claude/hooks/lint-fix.sh
```

### Q. 자기검증 루프가 무한 반복돼요
3단계까지 실패하면 멈추도록 CLAUDE.md에 명시합니다. "각 단계 3회 시도 후 사용자에게 보고" 같은 한계 규칙을 추가합니다.

### Q. hooks 때문에 단순 작업이 너무 느려요
PostToolUse의 lint-fix가 매 Edit마다 실행되면 답답할 수 있습니다. `matcher`를 `"Write"`로만 좁히거나 (Edit는 제외), lint-fix를 비동기로 실행합니다 (`&` 백그라운드).

---

## 산출물 정리

이번 모듈이 남긴 것들입니다. Module 04·05에서 이 상태를 전제로 이어갑니다.

| 파일 | 내용 |
|------|------|
| `.claude/hooks/guard.sh` | 시크릿/마이그레이션/main push 등 6종 차단 + 2종 경고 |
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
