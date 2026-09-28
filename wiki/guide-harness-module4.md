---
title: 하네스 Module 04 — 멀티 에이전트 + 컨텍스트 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module4, multi-agent, agents-md, planner-coder-critic, node, step-by-step]
sources:
  - ai-engineering/harness-engineering/harness-kit/module4/AGENTS.md
  - ai-engineering/harness-engineering/harness-kit/module4/task-list.md
  - ai-engineering/harness-engineering/harness-kit/module4/claude-progress.txt
  - ai-engineering/harness-engineering/harness-kit/module4/01_threettier_workflow_prompt.md
created: 2026-05-31
updated: 2026-09-28
---

# 하네스 Module 04 — 멀티 에이전트 + 컨텍스트

> **이 가이드 보기 전에**: [[guide-harness-module3]] 까지 완료. CLAUDE.md + hooks가 작동 중이어야 합니다.

**왜 Module 3 다음이 역할 분담인가**: Module 2의 CLAUDE.md가 규칙을, Module 3의 hooks가 차단을 맡으면서 한 세션 안의 실수는 상당 부분 잡히게 됐습니다. 그런데 기능 하나를 통째로 맡기는 큰 작업에서는 다른 문제가 나타납니다 — 한 세션이 계획·구현·검증을 전부 겸하면 탐색·실패·재시도의 잡음이 컨텍스트에 쌓여 중요 지시가 밀리고, 검증할 때쯤에는 자기가 짠 코드를 스스로 옹호하게 됩니다. 그래서 이번 모듈은 규칙 추가가 아니라 **역할 분리**입니다. 역할은 셋으로 나눕니다 — 계획만 맡는 **Planner**, 구현만 맡는 **Coder**, 검증만 맡는 **Critic**. 여러 에이전트를 쓰는 목적은 분업이 아니라 **컨텍스트 윈도우 오염 방지** — 역할 분리는 그 잡음을 격리하는 방화벽입니다.

**이 모듈에서 얻을 것**:

1. `AGENTS.md` — 3개 역할(Planner/Coder/Critic) 정의
2. `task-list.md` — Planner가 분해한 태스크 목록
3. `claude-progress.txt` — 세션 인계 파일 (Stop hook으로 자동 갱신)
4. **첫 Planner-Coder-Critic 사이클** 경험

**진행 흐름**: 역할 헌법 작성(Step 1) → 공유 대장·인계 파일 준비와 Stop hook 검증(Step 2~3) → Planner로 태스크 분해(Step 4) → Coder로 한 태스크 구현(Step 5) → Critic으로 독립 검증(Step 6) → 사이클 반복 정착(Step 7).

**시간**: 약 2시간 (파일 설치 30분 + Planner 30분 + Coder 30분 + Critic 30분)

> ✅ **실행 검증됨 (2026-09-28, Claude Code 2.1.283, Node v26)**: Module 03 완료 상태(CLAUDE.md 12섹션 + 자기검증 루프, guard.sh·lint-fix.sh 등록)를 재현한 playground 복사본에서 이 가이드의 모든 명령을 그대로 실행하고, Planner·Coder·Critic 세션은 헤드리스(`claude -p` + stream-json 도구 호출 감사)로 돌려 확인했습니다 — Stop hook이 응답마다 `claude-progress.txt`를 다시 쓰면서 "📝 에이전트 메모" 칸을 보존(터미널 2회 연속 실행 + 실제 Coder 세션 1회), Planner가 `task-list.md`만 덮어써 TASK-001~006 6개(TASK-001 = auth 스키마) 생성(2회 실행 동일 구조), Coder가 TASK-001만 구현해 `npm test -- auth.schema` 6 passed·전체 9 passed(기존 3 + 6)로 "---검증 완료 보고---" 종료(2회 실행 동일), Critic이 파일 수정 없이 "판정: APPROVE", `harness(M4)` → `plan(M4)` → `feat(M4)` → `review(M4)` 커밋 체인까지 완주. 전체 테스트 수는 Module 01~03에서 추가된 테스트만큼 본인 환경에서 더 큽니다.

이론 배경: [[concept-multi-agent-pattern]]

---

## Step 1 — `AGENTS.md` 만들기 — 15분

역할을 분리하려면 먼저 각 역할이 무엇을 하고 무엇을 하면 안 되는지를 문서로 고정해야 합니다. `AGENTS.md`는 CLAUDE.md의 모델 불가지론적(model-agnostic) 버전으로, Planner/Coder/Critic 역할 정의를 한 곳에 모읍니다.

> ⚠️ **CLAUDE.md가 있는 프로젝트에서는 Claude Code가 AGENTS.md를 자동으로 읽지 않습니다.** Claude Code 2.1.283으로 확인한 동작은 다음과 같습니다 — CLAUDE.md가 없는 디렉터리에서는 AGENTS.md를 대신 읽지만, playground처럼 CLAUDE.md가 있으면 AGENTS.md는 컨텍스트에 들어가지 않습니다. 그래서 이 실습은 각 역할 프롬프트 첫머리에서 "AGENTS.md를 먼저 읽어줘"라고 **명시**해 Read 도구로 직접 읽게 만듭니다. 매번 명시가 번거로우면 CLAUDE.md 맨 위에 `@AGENTS.md` 한 줄을 넣어 import합니다 — 이 방식은 새 세션에서 AGENTS.md 내용이 자동으로 로드되는 것까지 확인했습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `AGENTS.md` — 3개 역할 정의 + 세션 인계 프로토콜 + 컨텍스트 규칙
    - **실행**: 아래 명령으로 파일을 만들고 커밋합니다.

```bash
cd ~/harness-playground

cat > AGENTS.md << 'EOF'
# AGENTS.md — Multi-Agent Protocol

> 이 파일은 Claude/Codex/Gemini 등 어떤 에이전트와도 함께 쓰도록 작성합니다.
> (Claude Code는 이 파일을 자동 로드하지 않으므로 프롬프트에서 명시적으로 읽게 하거나
>  CLAUDE.md에 @AGENTS.md로 import.) CLAUDE.md와 충돌 시 CLAUDE.md 우선.

## 역할 정의

### 🎯 Planner Agent
역할: 사용자 요구사항 → task-list.md의 원자 단위 태스크 분해

책임:
- 각 태스크는 2시간 이내 완료 크기
- 명확한 verify 기준 (npm test -- <테스트 파일 이름> 등)
- 의존관계와 순서 명시
- 구현 범위(파일/모듈) 명시

금지:
- 직접 코드 작성 X (계획만)
- 구현 세부사항 가정 X

### 💻 Coder Agent
역할: 한 번에 한 태스크 구현

책임:
- 구현 전 CLAUDE.md 섹션 8 체크리스트 확인
- 단계별 계획 제시 → 구현 → 자기검증 루프
- 완료 후 task-list.md 상태 업데이트
- 컨텍스트 80% 이상 사용 → 세션 인계 후 종료

금지:
- 태스크 범위 벗어난 "개선" X
- verify 없이 "완료" 선언 X

### 🔍 Critic Agent
역할: 독립적 검증

검토 체크리스트 (Node + REST API):
- [ ] 라우트는 controller만 호출하는가?
- [ ] controller는 service만 호출하는가? (DB 직접 X)
- [ ] 응답 스키마가 Zod/DTO 변환을 거치는가? (모델 직접 X)
- [ ] 에러 처리: try/catch 또는 next(err) 일관성?
- [ ] 테스트가 의미 있는 케이스를 커버하는가?
- [ ] CLAUDE.md 섹션 7 STOP 트리거를 위반하지 않는가?
- [ ] 환경변수가 코드에 하드코딩되지 않았는가?

판정:
- APPROVE: 모두 통과
- CONDITIONAL REJECT: [문제]·[수정 방법] 명시, 재검토 후 통과 가능
- REJECT: 근본적 재설계 필요

## 세션 인계 프로토콜

새 세션 시작 시:
1. cat AGENTS.md
2. cat claude-progress.txt
3. git log --oneline -5
4. cat task-list.md
5. npm test (현재 테스트 상태 확인)

세션 종료 시:
1. claude-progress.txt 업데이트 (Stop hook으로 자동화 가능)
2. task-list.md 상태 업데이트
3. 미완료 태스크는 "중단 지점" 명시

## 컨텍스트 관리

- 컨텍스트 80% 이상 → 현재 태스크 완료 후 새 세션
- 컨텍스트 90% 이상 → 즉시 progress 저장 후 종료
- 서브에이전트는 결과만 본체로 반환 (중간 과정 노이즈 차단)
EOF

git add AGENTS.md
git commit -m "harness(M4): AGENTS.md 추가 (Planner/Coder/Critic)"
```

역할 정의 안의 섹션 번호들은 Module 02에서 작성한 CLAUDE.md를 가리킵니다 — 섹션 7은 STOP 트리거, 섹션 8은 작업 전 체크리스트, 섹션 5는 자기검증 루프가 들어 있는 Goal-Driven Execution입니다. Critic의 판정 용어도 여기서 처음 등장합니다: **APPROVE**(통과), **CONDITIONAL REJECT**(조건부 반려 — 지적 사항을 고치면 재검토로 통과 가능), **REJECT**(근본적 재설계 필요). 이 세 단계 판정은 Step 6에서 실제로 받아 처리하게 됩니다.

---

## Step 2 — `task-list.md` 템플릿 — 5분

역할이 정해졌으니 이제 역할들이 주고받을 공유 대장을 준비합니다. `task-list.md`는 Planner가 채우고 Coder가 상태를 갱신하며 Critic이 판정을 기록하는 파일입니다. 지금은 빈 템플릿만 만들어 두고, Step 4에서 Planner가 실제 태스크로 채웁니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `task-list.md` — 태스크 상태·verify·의존 관계를 기록하는 공유 대장 템플릿
    - **실행**: 아래 명령으로 템플릿을 만듭니다. 커밋은 Step 3 끝에서 Step 2~3 산출물을 함께 합니다.

템플릿의 `구현 범위` 경로가 `api/src/`로 시작하는 이유는 playground가 api/·web/ 모노레포이기 때문입니다 — 루트에는 `src/`가 없고, 백엔드 코드는 모두 `api/src/` 아래에 있습니다. 루트의 `npm test`는 api 워크스페이스의 Jest를 실행하고, `npm test -- auth.schema`처럼 `--` 뒤에 붙인 이름은 Jest에 그대로 전달되어 파일 이름이 일치하는 테스트만 골라 실행합니다.

```bash
cd ~/harness-playground
cat > task-list.md << 'EOF'
# task-list.md
> Planner Agent가 관리. 상태: 🔲 대기 / 🔄 진행중 / ✅ 완료 / ❌ 블로킹

## 현재 스프린트: [기능명]
- 목표: ____
- 기한: ____

## 태스크 목록

### TASK-001: [태스크명]
- 상태: 🔲
- 복잡도: LOW / MEDIUM / HIGH
- 의존: 없음
- verify: `npm test -- <테스트 파일 이름>`
- 구현 범위:
  - api/src/...
  - api/src/...
- 완료 기준:
  - [ ] 단위 테스트 통과
  - [ ] Critic APPROVE
- 메모:

## 완료된 태스크

| ID | 태스크명 | 완료일 | Critic 판정 |
|----|---------|--------|------------|

## 블로킹 이슈

| 이슈 | 태스크 | 원인 | 해결 |
|------|--------|------|------|
EOF
```

---

## Step 3 — `claude-progress.txt` 템플릿 + Stop hook 자동화 — 10분

task-list.md가 "무엇을 할지"의 대장이라면 `claude-progress.txt`는 "어디까지 했는지"의 인계장입니다. 역할마다 새 세션을 여는 이 워크플로에서는 세션 간 기억이 끊기므로, 다음 세션이 가장 먼저 읽을 인계 파일이 필요합니다. Module 3에서 만든 hook 인프라를 재사용해, Claude가 응답을 마칠 때마다(Stop hook) 자동 갱신되게 만듭니다. Stop hook은 세션 종료가 아니라 매 응답 종료마다 실행되며, 세션 종료 이벤트는 별도의 SessionEnd입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `claude-progress.txt` — 세션 인계 메모, `.claude/hooks/update-progress.sh` — Stop hook 자동 갱신 스크립트
    - **실행**: 템플릿과 스크립트를 만들고, `.claude/settings.json`에 Stop hook을 등록한 뒤 커밋합니다.

### Step 3-1: 초기 progress 파일

먼저 손으로 채우는 초기 템플릿을 만듭니다. 맨 아래 "에이전트 메모" 칸이 이 파일의 숨은 역할입니다 — 세션 중 발견한 개선점을 CLAUDE.md 섹션 11(Module 02의 누적 실패 패턴 표)과 guard.sh(Module 03의 명령 차단 hook)로 되돌려 보내는 통로입니다.

```bash
cd ~/harness-playground
cat > claude-progress.txt << 'EOF'
# Claude Progress — 새 세션이 가장 먼저 읽는 파일

📅 마지막 업데이트: 2026-MM-DD HH:MM
🎯 현재 목표: [한 줄]
✅ 마지막으로 완료: (TASK ID + 결과)
🔄 현재 진행 중인 태스크: 
  - TASK-XXX
  - 중단 지점: 
  - 다음 작업: 
⚠️ 주의사항: (이번 세션 발견)
🐛 발견된 버그: (별도 트래킹)
📊 테스트 상태: 
  - npm test: __ pass / __ fail
🗺️ 다음 세션 시작 가이드:
  1. cat AGENTS.md
  2. cat claude-progress.txt
  3. git log --oneline -5
  4. cat task-list.md
  5. npm test
  6. (중단 지점 파일 열기)
📝 에이전트 메모: 
  - CLAUDE.md 섹션 11에 추가할 패턴: 
  - guard.sh에 추가할 규칙:
EOF
```

이 템플릿의 위쪽 칸(🎯 현재 목표 ~ 🗺️ 다음 세션 시작 가이드)은 Step 3-2의 Stop hook이 첫 응답부터 자동 섹션으로 다시 씁니다. 첫 응답 이후에도 그대로 남는 것은 맨 아래 "📝 에이전트 메모" 칸뿐입니다 — 그래서 사람이 직접 남길 내용은 항상 이 칸에 적습니다.

### Step 3-2: Stop hook으로 자동 갱신

`.claude/hooks/update-progress.sh` 파일을 만듭니다. 이 스크립트는 Claude가 응답을 마칠 때마다 마지막 커밋·최근 변경 파일·테스트 결과를 모아 claude-progress.txt를 다시 씁니다. 자동으로 모을 수 있는 사실은 스크립트가 채우고, 판단이 필요한 메모만 사람(또는 에이전트)이 "📝 에이전트 메모" 칸에 남기는 구조입니다. 테스트 상태는 Jest 요약 중 `Tests:` 줄만 뽑습니다 — 출력 끝 몇 줄을 `tail`로 자르면 Snapshots·Time 줄만 남아 통과 수가 빠지기 때문입니다. 매 응답마다 파일을 다시 쓰므로, 스크립트는 기존 파일의 "📝 에이전트 메모" 줄부터 끝까지를 먼저 떼어 두었다가 새 파일 맨 끝에 그대로 붙여 수동 메모가 지워지지 않게 합니다.

```bash
cat > .claude/hooks/update-progress.sh << 'EOF'
#!/bin/bash
# Stop hook — Claude가 응답을 마칠 때마다 claude-progress.txt 자동 갱신
# 세션이 cd api 등으로 이동했어도 항상 프로젝트 루트에서 실행 (터미널 직접 실행 시엔 현재 디렉터리)
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

DATE=$(date '+%Y-%m-%d %H:%M')
LAST_COMMIT=$(git log --oneline -1 2>/dev/null)
CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10)
TEST=$(npm test --silent 2>&1 | grep -E '^Tests:')
# 수동 메모 보존: "📝 에이전트 메모" 줄부터 파일 끝까지 (없으면 빈 칸)
MEMO=$(sed -n '/^📝 에이전트 메모/,$p' claude-progress.txt 2>/dev/null)

cat > claude-progress.txt << END
# Claude Progress — 자동 업데이트: $DATE

## 마지막 커밋
$LAST_COMMIT

## 최근 변경 파일
$CHANGED

## 테스트 상태
$TEST

## 다음 세션 시작
1. cat AGENTS.md
2. cat claude-progress.txt
3. cat task-list.md
4. npm test

${MEMO:-📝 에이전트 메모: }
END

echo "✅ claude-progress.txt 갱신됨"
EOF

chmod +x .claude/hooks/update-progress.sh
```

### Step 3-3: settings.json에 Stop hook 등록

Module 03 Step 4에서 만든 `.claude/settings.json`에는 이미 `PreToolUse`(guard.sh)와 `PostToolUse`(lint-fix.sh)가 들어 있습니다. JSON을 손으로 고치다 쉼표 하나를 빠뜨리면 hooks 전체가 로드되지 않으므로, Module 03 Step 1에서 설치한 jq로 `hooks` 블록에 `Stop` 항목만 추가합니다. 결과를 임시 파일에 쓴 뒤 원본을 교체하는 방식이라, jq가 실패하면 원본은 그대로 남습니다. 스크립트 경로는 Module 03 Step 4와 같은 이유로 `"$CLAUDE_PROJECT_DIR"`를 붙여 적습니다 — Claude가 `cd api`를 한 번 실행하면 상대 경로 hook은 파일을 찾지 못해 조용히 멈추기 때문입니다. 스크립트 맨 앞의 `cd` 줄도 같은 목적입니다(git·npm·claude-progress.txt를 항상 루트 기준으로 처리):

```bash
cd ~/harness-playground
jq '.hooks.Stop = [{"hooks":[{"type":"command","command":"bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/update-progress.sh"}]}]' \
  .claude/settings.json > .claude/settings.tmp && mv .claude/settings.tmp .claude/settings.json

jq -c '.hooks | keys' .claude/settings.json
```

마지막 줄의 출력이 다음과 같으면 등록된 것입니다:

```text
["PostToolUse","PreToolUse","Stop"]
```

### Step 3-4: hook 단독 실행으로 메모 보존 확인

Claude Code 안에서 돌리기 전에, 터미널에서 스크립트를 두 번 연속 실행해 두 가지를 확인합니다 — 자동 섹션이 채워지는지, 그리고 두 번째 갱신에서도 수동 메모가 살아남는지입니다. 먼저 메모 칸에 표식 한 줄을 적고 스크립트를 두 번 실행합니다:

```bash
cd ~/harness-playground
echo "  - 메모 보존 테스트" >> claude-progress.txt
bash .claude/hooks/update-progress.sh
bash .claude/hooks/update-progress.sh
cat claude-progress.txt
```

실행할 때마다 `✅ claude-progress.txt 갱신됨`이 출력되고, 파일은 다음 모양이어야 합니다 (날짜·커밋 해시·테스트 수는 본인 환경 값):

```text
# Claude Progress — 자동 업데이트: 2026-09-28 10:05

## 마지막 커밋
a1b2c3d harness(M4): AGENTS.md 추가 (Planner/Coder/Critic)

## 최근 변경 파일
AGENTS.md

## 테스트 상태
Tests:       3 passed, 3 total

## 다음 세션 시작
1. cat AGENTS.md
2. cat claude-progress.txt
3. cat task-list.md
4. npm test

📝 에이전트 메모: 
  - CLAUDE.md 섹션 11에 추가할 패턴: 
  - guard.sh에 추가할 규칙:
  - 메모 보존 테스트
```

`## 테스트 상태`에는 본인 playground의 전체 테스트 수가 나옵니다 — Module 01~03에서 추가된 테스트만큼 3보다 큽니다. 두 번 실행한 뒤에도 맨 아래 "메모 보존 테스트" 줄이 남아 있으면 통과입니다. 표식 줄은 확인용이므로 지운 뒤, Step 2~3 산출물을 커밋합니다:

```bash
cd ~/harness-playground
grep -v '메모 보존 테스트' claude-progress.txt > progress.tmp && mv progress.tmp claude-progress.txt
git add task-list.md claude-progress.txt .claude/hooks/update-progress.sh .claude/settings.json
git commit -m "harness(M4): task-list·progress 템플릿 + Stop hook 등록"
```

Stop hook은 이제 Claude가 응답을 마칠 때마다 `npm test`를 한 번 돌리고(1~2초) `claude-progress.txt`를 다시 씁니다. 그래서 이후 Claude 세션을 한 번이라도 쓰고 나면 `git status`에 `claude-progress.txt`가 항상 수정됨으로 보입니다 — 정상입니다. 이 가이드는 각 단계의 커밋에 `claude-progress.txt`를 함께 담아 작업 트리를 깨끗하게 유지합니다.

---

## Step 4 — Planner Agent 시연 — 30분

AGENTS.md·task-list.md·claude-progress.txt 세 파일이 준비됐으니 첫 역할인 Planner를 실제로 돌려 봅니다. Planner의 일은 코드가 아니라 분해입니다 — 요구사항을 받아 task-list.md 형식의 원자 단위 태스크로 쪼개는 것까지만 맡깁니다. 실습 기능은 playground의 api/에 새로 붙일 사용자 인증(회원가입·로그인·내 정보)입니다. 인증을 고른 이유는 크기와 모양 때문입니다 — 스키마·리포지토리·서비스·미들웨어·컨트롤러·라우트가 모두 필요해 6개 원자 태스크로 자연스럽게 쪼개지고, 태스크 간 의존 순서도 뚜렷해서 Planner의 분해 품질을 평가하기에 알맞습니다. Module 01·02의 필드 추가 태스크(A·D)와 달리 새 도메인을 붙이는 작업이라, 기존 User CRUD나 phone·address 필드에는 영향을 주지 않습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `task-list.md` — Step 2에서 만든 템플릿을 Planner가 분해 결과로 덮어씁니다.
    - **실행**: `claude`를 새 세션으로 열고 아래 Planner 프롬프트를 붙여넣은 뒤, 저장된 태스크 목록을 평가하고 커밋합니다.

### Step 4-1: 새 세션에서 Planner 호출

파일 배치를 요구사항에 미리 못 박아 두는 이유는 재현성입니다. 배치를 Planner에게 맡기면 실행할 때마다 태스크 수(5~9개)와 TASK-001의 내용이 달라져 — 실측에서는 "외부 패키지 확정" 같은 결정 전용 태스크가 TASK-001로 나오기도 했습니다 — Step 5·6의 프롬프트가 가리키는 대상이 어긋납니다. 배치를 고정하면 Planner가 할 일은 각 태스크의 verify·의존·완료 기준을 설계하는 것으로 좁혀지고, 누가 실행해도 TASK-001은 `auth.schema.js`가 됩니다. 패키지(bcryptjs·jsonwebtoken)도 요구사항에서 미리 승인해 두어, CLAUDE.md 섹션 7의 "외부 패키지를 사용자 확인 없이 추가" STOP 트리거 때문에 계획이 멈추지 않게 합니다.

새 세션에서 Claude가 뜨면 다음 프롬프트를 그대로 붙여넣습니다. 역할 선언 → 요구사항 → 제약 → 파일 배치 → 출력 형식 순서로 짜여 있어서, Claude는 AGENTS.md의 Planner 정의를 읽은 뒤 코드를 한 줄도 쓰지 않고 `task-list.md`만 덮어쓰게 됩니다. 파일 쓰기 권한을 묻는 창이 뜨면 대상이 `task-list.md`인지 확인하고 허용합니다.

```
너는 지금부터 Planner Agent로만 동작해.
AGENTS.md의 Planner 역할 정의와 task-list.md 템플릿을 먼저 읽고 따라줘.

## 요구사항
api/에 사용자 인증(이메일 + 비밀번호) 기능을 만들고 싶어.
- POST /auth/register — 회원가입 (201, 응답에 비밀번호·해시 없음)
- POST /auth/login — 로그인 (JWT 발급)
- GET /auth/me — 현재 사용자 정보 (Authorization: Bearer 토큰 검증 미들웨어)

## 제약
- 비밀번호 해시는 bcryptjs, JWT는 jsonwebtoken (두 패키지 모두 사용자 승인됨 — 처음 쓰는 태스크에서 설치)
- JWT secret은 process.env.JWT_SECRET, api/.env.example에는 키 이름만 추가
- 회원가입 입력은 email, password 두 필드만. 이메일 형식·비밀번호 8자 이상 검증은 Zod
- 응답의 사용자 정보는 publicUserSchema(id, email만 남김)로 변환 — 비밀번호·해시 노출 금지
- 이미 등록된 이메일은 409, 로그인 실패·토큰 없음·토큰 무효는 401
- 로그인 응답은 { token }, 토큰 만료 1h
- 저장소는 in-memory. 기존 /users 코드는 건드리지 않음
  (app.js에는 app.use('/auth', require('./routes/auth.routes')) 한 줄만 추가)

## 파일 배치 (고정 — 태스크 하나 = 아래 한 줄, 테스트는 같은 폴더의 *.test.js)
1. api/src/schemas/auth.schema.js — registerSchema, loginSchema, publicUserSchema
2. api/src/repositories/auth-user.repo.js — in-memory 저장소 (findByEmail, findById, create)
3. api/src/services/auth.service.js — register / login / getMe (bcryptjs·jsonwebtoken)
4. api/src/middlewares/require-auth.js — Bearer 토큰 검증 → req.userId
5. api/src/controllers/auth.controller.js — req/res 처리, service만 호출
6. api/src/routes/auth.routes.js — 라우트 정의 + app.js 마운트 + supertest 통합 테스트

## 출력
위 6줄을 순서 그대로 TASK-001 ~ TASK-006으로 삼아 task-list.md 템플릿 형식에 맞춰 분해하고,
task-list.md 파일을 그 내용으로 덮어써.
- 현재 스프린트: 사용자 인증 (register / login / me)
- 각 태스크: 상태 🔲, 복잡도, 의존, verify, 구현 범위, 완료 기준
- verify는 저장소 루트에서 실행하는 `npm test -- <테스트 파일 이름>` 형식
task-list.md 외의 파일은 만들거나 고치지 마. 코드는 작성하지 마. 계획만.
```

### Step 4-2: 받은 task-list 평가

Planner 세션이 끝나면 터미널에서 결과를 확인합니다:

```bash
cd ~/harness-playground
grep -E '^### TASK-' task-list.md
git status --short
```

기대 출력은 다음과 같습니다. 태스크 제목의 표현은 실행마다 조금씩 다르지만, 6개라는 개수와 TASK-001 = auth 스키마라는 순서는 같아야 합니다. `git status`에는 `task-list.md`와 Stop hook이 갱신한 `claude-progress.txt` 두 파일만 보여야 합니다 — 다른 파일이 보이면 Planner가 "계획만" 제약을 어긴 것입니다.

```text
### TASK-001: auth Zod 스키마 (registerSchema, loginSchema, publicUserSchema)
### TASK-002: in-memory 인증 사용자 저장소
### TASK-003: auth 서비스 (register / login / getMe)
### TASK-004: Bearer 토큰 검증 미들웨어
### TASK-005: auth 컨트롤러
### TASK-006: auth 라우트 + app.js 마운트 + 통합 테스트
 M claude-progress.txt
 M task-list.md
```

이어서 `task-list.md`를 열어 분해 품질을 평가합니다. 좋은 분해의 표지:

- ✅ 각 태스크에 실행 가능한 verify (예: TASK-001 → `npm test -- auth.schema`)
- ✅ 의존 순서 (schema → repository → service → middleware → controller → route)
- ✅ 한 태스크 = 한 파일(+ 그 테스트)
- ✅ 완료 기준에 "단위 테스트 통과"와 "Critic APPROVE"가 함께 있음

나쁜 분해의 표지:

- ❌ "회원가입 구현" 같이 한 줄짜리 거대 태스크
- ❌ verify 없음, 또는 "동작 확인" 같은 실행 불가능한 verify
- ❌ "그리고 ~도 같이" 같은 끼워넣기 (예: TASK-001에 서비스 로직까지 포함)

위 표지를 통과하면 커밋합니다. 커밋 접두어는 여기서부터 역할별로 나눕니다 — 하네스 설치는 `harness(M4)`로 남겼고, 사이클의 산출물은 계획 `plan(M4)`, 구현 `feat(M4)`, 판정 `review(M4)`로 구분합니다. git 히스토리만 봐도 사이클의 어느 단계인지 추적하기 위해서입니다:

```bash
git add task-list.md claude-progress.txt
git commit -m "plan(M4): 인증 기능 태스크 분해"
```

---

## Step 5 — Coder Agent 시연 (TASK-001만) — 30분

계획이 생겼으니 이제 구현입니다. Planner 세션은 그대로 닫고, Step 4에서 만든 `task-list.md`의 첫 태스크(TASK-001, `api/src/schemas/auth.schema.js`)만 새 Coder 세션에 넘깁니다 — 계획 과정의 잡음이 구현 컨텍스트에 섞이지 않게 하기 위해서입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: `api/src/schemas/auth.schema.js` + `api/src/schemas/auth.schema.test.js`, `task-list.md` 상태 갱신
    - **실행**: `claude`를 새 세션으로 열고 아래 Coder 프롬프트를 붙여넣은 뒤, 작업을 관찰하고 완료되면 커밋합니다.

### Step 5-1: 새 세션에서 Coder 호출

새 세션에서 Claude가 뜨면 다음 프롬프트를 그대로 붙여넣습니다. 태스크 지정, 테스트 케이스 6개, 실행 순서(인계 파일 확인 → 계획 제시 → 구현 → 자기검증)를 못 박아 두었기 때문에, Claude는 TASK-001 하나만 구현하고 task-list.md 상태를 갱신한 뒤 멈추게 됩니다. 테스트 케이스를 고정해 두는 이유도 재현성입니다 — 누가 실행해도 `npm test -- auth.schema`의 결과가 `6 passed`로 같아야 Step 6의 Critic 판정을 비교할 수 있습니다.

```
너는 지금부터 Coder Agent로만 동작해.
AGENTS.md의 Coder 역할 정의를 먼저 읽어줘.

## 지금 할 태스크
task-list.md의 TASK-001 (api/src/schemas/auth.schema.js) 만 구현해.
- registerSchema: email(이메일 형식), password(문자열 8자 이상)
- loginSchema: email(이메일 형식), password(빈 문자열 불가)
- publicUserSchema: { id, email } — 그 외 필드(passwordHash 등)는 parse 결과에서 제거
- 테스트: api/src/schemas/auth.schema.test.js — 아래 6개 케이스만 (it 6개)
  1. registerSchema 정상 입력 통과
  2. registerSchema 이메일 형식 오류 거부
  3. registerSchema 8자 미만 비밀번호 거부
  4. loginSchema 정상 입력 통과
  5. loginSchema password 누락 거부
  6. publicUserSchema가 passwordHash를 제거

## 실행 순서
1. cat claude-progress.txt, cat task-list.md
2. CLAUDE.md 섹션 7 STOP 트리거 다시 확인
3. 단계별 계획 제시 (Step N: ____ → verify: ____)
4. 구현
5. 자기검증 루프 (CLAUDE.md 섹션 5 끝부분) — npm test -- auth.schema, 이어서 npm test
6. 검증 완료 보고

다른 TASK는 건드리지 마. 끝나면 task-list.md의 TASK-001 상태를 🔄로(✅는 Critic APPROVE 후),
완료 기준의 "단위 테스트 통과"를 [x]로 바꾸고 끝. 커밋은 하지 마.
```

### Step 5-2: Coder 작업 관찰 포인트

- 단계별 계획을 **먼저** 제시했는가? (아니면 "계획 먼저 제시해줘" 한 번 더)
- 자기검증 루프를 **실제로** 돌렸는가? (`npm test` 출력이 보여야)
- TASK-001 범위를 **벗어나서** TASK-002까지 손댔는가? (벗어났으면 멈춰)
- task-list.md를 업데이트했는가?

관찰이 끝나면 터미널에서 결과를 직접 확인합니다:

```bash
cd ~/harness-playground
git status --short
npm test -- auth.schema 2>&1 | grep -E '^Tests:'
```

기대 출력은 다음과 같습니다. `git status`에 `api/src/schemas/` 외의 코드 파일이 보이면 범위를 벗어난 것입니다:

```text
 M claude-progress.txt
 M task-list.md
?? api/src/schemas/
Tests:       6 passed, 6 total
```

확인이 끝나면 TASK-001 산출물을 커밋합니다:

```bash
git add task-list.md claude-progress.txt api/src/schemas/
git commit -m "feat(M4): TASK-001 auth Zod 스키마"
```

---

## Step 6 — Critic Agent 시연 — 30분

구현이 끝났다고 Coder의 "완료" 선언을 그대로 믿으면 자기 코드를 자기가 채점하는 셈입니다. 그래서 Step 5에서 Coder가 구현한 TASK-001 결과(코드 + 커밋)를 Critic이 독립적으로 검증합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.claude/critic-log.md` — Critic 판정 기록
    - **실행**: `claude`를 새 세션으로 열고 아래 Critic 프롬프트를 붙여넣은 뒤, 판정에 따라 처리하고 커밋합니다.

### Step 6-1: 새 세션에서 Critic 호출

세션을 새로 시작하는 이유: Coder의 컨텍스트(시도·실패·중간 출력)에서 격리하기 위해서입니다. 새 세션에서 Claude가 뜨면 다음 프롬프트를 그대로 붙여넣습니다. 검토 대상 커밋과 판정 형식을 지정해 두었기 때문에, Claude는 코드를 고치지 않고 AGENTS.md 체크리스트를 기준으로 Step 1에서 정의한 세 단계 판정 중 하나만 내리게 됩니다. 판정 범위를 TASK-001로 제한하는 문장은 필수입니다 — 이 문장이 없으면 Critic이 아직 없는 라우트·서비스를 "누락"으로 지적해 CONDITIONAL REJECT를 내기 쉽습니다.

```
너는 지금부터 Critic Agent로만 동작해.
AGENTS.md의 Critic 역할 정의와 체크리스트를 먼저 읽어줘.

## 검토 대상
직전 커밋(HEAD)의 TASK-001 — api/src/schemas/auth.schema.js + auth.schema.test.js.
TASK-001 범위 안에서만 판정해. 아직 없는 다른 태스크(저장소·서비스·라우트) 몫이나
스타일·취향은 지적하지 마. 이 태스크에 해당 없는 체크리스트 항목은 "해당 없음"으로 표시.

## 검토 명령
1. git log --oneline -3
2. git show --stat HEAD
3. git diff HEAD~1 HEAD -- api/
4. npm test -- auth.schema

## 판정 형식
첫 줄은 "판정: APPROVE", "판정: CONDITIONAL REJECT", "판정: REJECT" 중 하나.

CONDITIONAL REJECT면:
  - 문제: [구체적 위반]
  - 수정 요청: [구체적 방법]
  - 재검토 후 APPROVE 가능

REJECT면:
  - 이유:
  - 권장 접근:

파일은 수정하지 마. 판정만.
```

### Step 6-2: Critic 결과 처리

판정에 따라 다음 행동이 갈립니다:

- **APPROVE**: task-list.md의 "완료된 태스크" 표에 기록, 다음 TASK 진행
- **CONDITIONAL REJECT**: 새 Coder 세션 시작 → Critic 지적 사항만 수정 → 새 Critic 세션으로 재검토
- **REJECT**: Planner로 돌아가 태스크 재분해

APPROVE가 나왔으면 `task-list.md`를 에디터로 열어 세 곳을 고칩니다 — TASK-001의 `상태: 🔄`를 `상태: ✅`로, 완료 기준의 `- [ ] Critic APPROVE`를 `- [x] Critic APPROVE`로 바꾸고, "완료된 태스크" 표의 헤더 아래에 다음 한 줄을 추가합니다 (날짜는 오늘 날짜):

```markdown
| TASK-001 | auth Zod 스키마 | 2026-09-28 | APPROVE |
```

어느 판정이든 결과는 기록으로 남깁니다 — `.claude/critic-log.md`는 태스크별 Critic 판정을 한 줄씩 누적하는 기록 파일입니다. 아래는 APPROVE가 나온 경우입니다:

```bash
cd ~/harness-playground
echo "$(date '+%Y-%m-%d') TASK-001 Critic: APPROVE" >> .claude/critic-log.md
git add task-list.md claude-progress.txt .claude/critic-log.md
git commit -m "review(M4): TASK-001 APPROVE"
git log --oneline -4
```

마지막 명령의 출력으로 한 사이클이 git 히스토리에 plan → feat → review 순서로 남았는지 확인합니다 (해시는 본인 환경 값):

```text
d4e5f6a review(M4): TASK-001 APPROVE
c3d4e5f feat(M4): TASK-001 auth Zod 스키마
b2c3d4e plan(M4): 인증 기능 태스크 분해
a1b2c3d harness(M4): task-list·progress 템플릿 + Stop hook 등록
```

---

## Step 7 — 사이클 반복 정착 — (시간 외)

첫 사이클(계획 → 구현 → 검증)을 완주했습니다. 남은 태스크에도 같은 사이클을 반복하며 몸에 익힙니다: TASK-002 → Coder → Critic → TASK-003 → ... 처음에는 세션 전환이 번거롭지만, 한 사이클이 익숙해지면 컨텍스트가 깨끗해서 오히려 빠릅니다.

**한 세션에서 다 하지 않습니다**. Planner도 Coder도 Critic도 같은 컨텍스트면 잡음으로 서로 영향을 줍니다.

---

## 막힐 때 (Module 4 전용 FAQ)

### Q. 매번 세션 전환이 귀찮아요
초기에는 그렇습니다. **TASK가 작아질수록** 한 세션 안에서 전환해도 큰 문제는 없습니다 — 다만 Critic은 가능한 새 세션을 씁니다. 완전 재시작 대신 세션 안에서 `/clear`로 컨텍스트만 비우면 더 가볍습니다.

### Q. Claude Code 네이티브 서브에이전트로 역할을 나눌 수 있나요
가능하고, 수동 세션 전환보다 깔끔합니다. `.claude/agents/` 디렉터리에 역할별 정의 파일(시스템 프롬프트·허용 도구)을 두고 `/agents`로 관리하면 Planner/Coder/Critic을 **독립 컨텍스트로 격리** 실행할 수 있습니다 (서브에이전트는 결과만 본체로 반환 → 잡음 차단이라는 이 모듈의 목적과 정확히 일치합니다). 이 실습은 개념 이해를 위해 수동 전환으로 진행하지만, 익숙해지면 네이티브 서브에이전트로 옮기는 걸 권합니다.

### Q. Critic이 자꾸 APPROVE만 해요

- 체크리스트가 너무 추상적일 수 있음 → 본인 프로젝트 특화 항목 추가
- 한 가지 시도: "지금 구현에서 **가장 약한 부분 3개**를 지적해줘" 같이 비판 강요

### Q. Critic이 너무 깐깐해서 무한 반려돼요

- CONDITIONAL REJECT 사유가 "스타일·취향"이면 무시 가능 (Critic에게 명시: "취향 X, 기능·보안·테스트만")
- 정말 근본적 결함이면 Planner로 돌아가 재분해

### Q. claude-progress.txt가 자동 갱신 안 돼요

- Stop hook 등록 확인: `cat .claude/settings.json | jq '.hooks.Stop'`
- 실행 권한: `ls -la .claude/hooks/update-progress.sh`
- 직접 호출 테스트: `bash .claude/hooks/update-progress.sh`

### Q. AGENTS.md와 CLAUDE.md의 중복이 부담스러워요

- CLAUDE.md = 코딩 규칙·STOP·체크리스트 (모든 작업 공통)
- AGENTS.md = 역할 정의·세션 인계 프로토콜 (멀티 에이전트 운영)
- 겹치는 부분은 한 곳에만 두고 다른 쪽은 링크.

### Q. Planner/Coder/Critic을 다른 모델로 분담 가능한가요
가능. Coder는 Claude, Critic은 Codex 같이 분담하면 모델 간 교차 검증 효과. 그럴 때 **AGENTS.md가 필수** (모델 공통 헌법).

---

## 산출물 정리

| 파일 | 내용 |
|------|------|
| `AGENTS.md` | 3개 역할 + 세션 인계 + 컨텍스트 규칙 |
| `task-list.md` | 인증 기능의 6개 원자 태스크 (TASK-001 ✅ + Critic APPROVE) |
| `claude-progress.txt` | 세션 인계 메모 (Stop hook 자동 갱신) |
| `.claude/hooks/update-progress.sh` | Stop hook 스크립트 |
| `api/src/schemas/auth.schema.js` + `auth.schema.test.js` | TASK-001 구현 (테스트 6개) |
| `.claude/critic-log.md` | Critic 판정 기록 |
| 첫 사이클 git 히스토리 | plan → feat → review 패턴 |

---

## 다음 단계

▶ [[guide-harness-module5]] — 하네스 자산화 + 주간 리뷰 + Rippable 점검.

## 관련 페이지

- [[guide-harness-module3]] — 입력 (Stop hook 인프라)
- [[guide-harness-module5]] — 다음 모듈
- [[concept-multi-agent-pattern]] — Planner/Coder/Critic 이론
- [[concept-claude-md]] — AGENTS.md ↔ CLAUDE.md 관계
- [[src-harness-engineering]] — 전체 커리큘럼
