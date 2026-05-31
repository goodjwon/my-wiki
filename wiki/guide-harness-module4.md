---
title: 하네스 Module 04 — 멀티 에이전트 + 컨텍스트 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module4, multi-agent, agents-md, planner-coder-critic, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module4/AGENTS.md
  - harness-engineering/harness-kit/module4/task-list.md
  - harness-engineering/harness-kit/module4/claude-progress.txt
  - harness-engineering/harness-kit/module4/01_threettier_workflow_prompt.md
created: 2026-05-31
updated: 2026-05-31
---

# 하네스 Module 04 — 멀티 에이전트 + 컨텍스트

> **이 가이드 보기 전에**: [[guide-harness-module3]] 까지 완료. CLAUDE.md + hooks가 작동 중이어야 합니다.

**이 모듈에서 얻을 것**:
1. `AGENTS.md` — 3개 역할(Planner/Coder/Critic) 정의
2. `task-list.md` — Planner가 분해한 태스크 목록
3. `claude-progress.txt` — 세션 인계 파일 (Stop hook으로 자동 갱신)
4. **첫 Planner-Coder-Critic 사이클** 경험

**시간**: 약 2시간 (파일 설치 30분 + Planner 30분 + Coder 30분 + Critic 30분)

**핵심 개념**: 여러 에이전트는 **분업**이 아니라 **컨텍스트 윈도우 오염 방지**가 목적. 한 에이전트가 탐색·실패·재시도를 반복하면 "잡음"이 쌓여 중요 지시가 밀린다. 역할 분리는 그 잡음을 격리하는 방화벽.

이론 배경: [[concept-multi-agent-pattern]]

---

## Step 1 — `AGENTS.md` 만들기 — 15분

`AGENTS.md`는 CLAUDE.md의 모델 불가지론적 버전. 여러 에이전트가 공통으로 읽음.

```bash
cat > AGENTS.md << 'EOF'
# AGENTS.md — Multi-Agent Protocol

> 이 파일은 Claude/Codex/Gemini 등 어떤 에이전트든 공통으로 읽습니다.
> CLAUDE.md (Claude 전용)와 함께 사용. 충돌 시 CLAUDE.md 우선.

## 역할 정의

### 🎯 Planner Agent
역할: 사용자 요구사항 → task-list.md의 원자 단위 태스크 분해

책임:
- 각 태스크는 2시간 이내 완료 크기
- 명확한 verify 기준 (npm test --tests "X" 등)
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

---

## Step 2 — `task-list.md` 템플릿 — 5분

```bash
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
- verify: `npm test -- TASK-001 관련`
- 구현 범위:
  - src/routes/...
  - src/services/...
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

### Step 3-1: 초기 progress 파일

```bash
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
  1. cat claude-progress.txt
  2. git log --oneline -5
  3. cat task-list.md
  4. npm test
  5. (중단 지점 파일 열기)
📝 에이전트 메모: 
  - CLAUDE.md 섹션 11에 추가할 패턴: 
  - guard.sh에 추가할 규칙:
EOF
```

### Step 3-2: Stop hook으로 자동 갱신

```bash
cat > .claude/hooks/update-progress.sh << 'EOF'
#!/bin/bash
# Stop hook — 세션 종료 시 claude-progress.txt 자동 갱신

DATE=$(date '+%Y-%m-%d %H:%M')
LAST_COMMIT=$(git log --oneline -1 2>/dev/null)
CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10)
TEST=$(npm test --silent 2>&1 | tail -3)

cat > claude-progress.txt << END
# Claude Progress — 자동 업데이트: $DATE

## 마지막 커밋
$LAST_COMMIT

## 최근 변경 파일
$CHANGED

## 테스트 상태
$TEST

## 수동 메모 (다음 세션을 위해 직접 추가)
- 

## 다음 세션 시작
1. cat claude-progress.txt
2. cat task-list.md
3. npm test
END

echo "✅ claude-progress.txt 갱신됨"
EOF

chmod +x .claude/hooks/update-progress.sh
```

### Step 3-3: settings.json에 Stop hook 등록

`.claude/settings.json`에 다음을 추가 (기존 hooks 블록에):

```json
"Stop": [
  {
    "hooks": [
      { "type": "command", "command": "bash .claude/hooks/update-progress.sh" }
    ]
  }
]
```

---

## Step 4 — Planner Agent 시연 — 30분

본인 프로젝트에서 실제로 만들 작은 기능을 골라 Planner로 시킨다.

### Step 4-1: 새 세션에서 Planner 호출

```
너는 지금부터 Planner Agent로만 동작해.
AGENTS.md의 Planner 역할 정의를 먼저 읽고 따라줘.

## 요구사항
사용자 인증 (이메일 + 비밀번호) 기능을 만들고 싶어.
- POST /auth/register — 회원가입
- POST /auth/login — 로그인 (JWT 발급)
- GET /auth/me — 현재 사용자 정보 (인증 미들웨어)

## 제약
- 비밀번호는 bcrypt 해시
- JWT는 환경변수로 secret 관리 (.env)
- 이메일 형식 검증 (Zod)
- 이미 등록된 이메일은 409

## 출력
task-list.md 형식으로 원자 단위 태스크로 분해해줘.
DDD 레이어 순서 대신 Node 흐름 (route → controller → service → repository → schema) 으로 분리.

직접 코드는 작성하지 마. 계획만.
```

### Step 4-2: 받은 task-list 평가

좋은 분해의 표지:
- ✅ 5~8개 태스크 (너무 적으면 한 태스크가 큼, 너무 많으면 잘게 쪼개짐)
- ✅ 각 태스크에 verify (예: `npm test -- auth.register`)
- ✅ 의존 순서 (schema → repository → service → controller → route → middleware)
- ✅ 한 태스크 = 한 파일 또는 한 모듈

나쁜 분해의 표지:
- ❌ "회원가입 구현" 같이 한 줄짜리 거대 태스크
- ❌ verify 없음
- ❌ "그리고 ~도 같이" 같은 끼워넣기

받은 task-list를 `task-list.md`에 저장:

```bash
# Planner 출력을 그대로 task-list.md에 붙여넣기
git add task-list.md
git commit -m "plan(M4): 인증 기능 태스크 분해"
```

---

## Step 5 — Coder Agent 시연 (TASK-001만) — 30분

### Step 5-1: 새 세션에서 Coder 호출

```
너는 지금부터 Coder Agent로만 동작해.
AGENTS.md의 Coder 역할 정의를 먼저 읽어줘.

## 지금 할 태스크
task-list.md의 TASK-001 만 구현해.
(예: "User Zod 스키마 + repository 인터페이스")

## 실행 순서
1. cat claude-progress.txt
2. CLAUDE.md 섹션 7 STOP 트리거 다시 확인
3. 단계별 계획 제시:
   - Step 1: ____ → verify: ____
   - Step 2: ____ → verify: ____
4. 구현
5. 자기검증 루프 (CLAUDE.md 섹션 5 끝부분)
6. 검증 완료 보고

다른 TASK는 건드리지 마. 끝나면 task-list.md의 TASK-001 상태를 ✅로 바꾸고 끝.
```

### Step 5-2: Coder 작업 관찰 포인트

- 단계별 계획을 **먼저** 제시했는가? (아니면 "계획 먼저 제시해줘" 한 번 더)
- 자기검증 루프를 **실제로** 돌렸는가? (npm test 출력이 보여야)
- TASK-001 범위를 **벗어나서** TASK-002까지 손댔는가? (벗어났으면 멈춰)
- task-list.md를 업데이트했는가?

완료 후:

```bash
git add task-list.md src/
git commit -m "feat(M4): TASK-001 User 스키마 + 리포지토리"
```

---

## Step 6 — Critic Agent 시연 — 30분

### Step 6-1: 새 세션에서 Critic 호출

세션을 새로 시작하는 이유: Coder의 컨텍스트(시도·실패·중간 출력)에서 격리하기 위해.

```
너는 지금부터 Critic Agent로만 동작해.
AGENTS.md의 Critic 역할 정의와 체크리스트를 먼저 읽어줘.

## 검토 대상
방금 완료된 TASK-001 (User schema + repository).

## 검토 명령
1. git log --oneline -3
2. git diff HEAD~1 HEAD
3. cat src/schemas/user.js src/repositories/user.repo.js
4. cat src/schemas/user.test.js  (테스트 있다면)

## 판정 형식
APPROVE | CONDITIONAL REJECT | REJECT 중 하나로 판정.

CONDITIONAL REJECT면:
  - 문제: [구체적 위반]
  - 수정 요청: [구체적 방법]
  - 재검토 후 APPROVE 가능

REJECT면:
  - 이유: 
  - 권장 접근:

직접 코드 수정은 하지 마. 판정만.
```

### Step 6-2: Critic 결과 처리

- **APPROVE**: task-list.md의 "완료된 태스크" 표에 기록, 다음 TASK 진행
- **CONDITIONAL REJECT**: 새 Coder 세션 시작 → Critic 지적 사항만 수정 → Critic 재검토
- **REJECT**: Planner로 돌아가 태스크 재분해

```bash
# 판정 결과 기록
echo "TASK-001 Critic: APPROVE" >> .claude/critic-log.md
git add task-list.md .claude/critic-log.md
git commit -m "review(M4): TASK-001 APPROVE"
```

---

## Step 7 — 사이클 반복 정착 — (시간 외)

TASK-002 → Coder → Critic → TASK-003 → ... 반복. 처음에는 세션 전환이 번거롭지만, 한 사이클이 익숙해지면 컨텍스트가 깨끗해서 오히려 빠름.

**한 세션에서 다 하지 마라**. Planner도 Coder도 Critic도 같은 컨텍스트면 잡음으로 서로 영향.

---

## 막힐 때 (Module 4 전용 FAQ)

### Q. 매번 세션 전환이 귀찮아요
초기에는 그렇다. **TASK가 작아질수록** 한 세션 안에서 전환해도 큰 문제 없음 — 다만 Critic은 가능한 새 세션.

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
| `task-list.md` | 첫 기능의 5~8개 원자 태스크 |
| `claude-progress.txt` | 세션 인계 메모 (Stop hook 자동 갱신) |
| `.claude/hooks/update-progress.sh` | Stop hook 스크립트 |
| `.claude/critic-log.md` | Critic 판정 기록 (옵션) |
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
