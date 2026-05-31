---
title: 하네스 Module 01 — 베이스라인 측정 + 실패 패턴 감사 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module1, baseline, failure-audit, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module1/01_failure_audit_prompt.md
  - harness-engineering/harness-kit/module1/02_baseline_prompt.md
  - harness-engineering/harness_engineering.md
created: 2026-05-31
updated: 2026-05-31
---

# 하네스 Module 01 — 베이스라인 측정 + 실패 패턴 감사

> **이 가이드 보기 전에**: [[guide-harness-00-prerequisites]] 를 먼저 끝내세요. Claude Code가 설치돼 있고, 본인 Node 프로젝트 폴더에서 `claude` 명령이 실행되며, git log가 5개 이상 있어야 합니다.

**이 모듈에서 얻을 것**:
1. `.claude/baseline.md` — 하네스 적용 **전** 본인 프로젝트 성능 기록 (Module 05에서 After와 비교)
2. **실패 패턴 표 3개 이상** — Module 02에서 CLAUDE.md STOP 트리거로 전환할 재료

**시간**: 약 1시간 (Failure Audit 20분 + 베이스라인 태스크 3개 30분 + 정리 10분)

**전제 스택**: Node.js + Express(또는 Fastify/NestJS) + 본인의 ORM(Prisma/Mongoose/Knex 등). 다른 스택이어도 명령어만 바꾸면 됨.

이론 배경: [[concept-harness-engineering]]

---

## Step 1 — 실습 환경 확인 (5분)

본인 Node 프로젝트 루트에서:

```bash
# 1. git 저장소인지, 커밋이 충분한지 확인
git log --oneline -10
# → 5개 이상 나와야 함. 안 나오면 prerequisites Q3 참고.

# 2. Claude Code 실행 가능한지
claude --version

# 3. baseline 저장할 폴더 미리 생성
mkdir -p .claude
```

확인 통과하면 다음 Step.

---

## Step 2 — Failure Audit (실패 패턴 감사) — 20분

> 원본: `raw/harness-engineering/harness-kit/module1/01_failure_audit_prompt.md`

**목적**: AI와 작업하면서 반복된 실수를 git log에서 찾고, **프롬프트 문제** vs **시스템 문제**로 분류.

### Step 2-1: Claude Code 실행 후 다음 프롬프트를 그대로 붙여넣기

```
지금 이 Node 프로젝트에서 내가 너(AI 에이전트)와 작업하면서
반복적으로 겪었던 문제들을 분석해줘.

## 분석 명령 (실행해줘)
1. git log --oneline -30
2. grep -rn "TODO\|FIXME\|HACK" src/ --include="*.js" --include="*.ts" 2>/dev/null | head -20
3. find . -name "*.js" -o -name "*.ts" | xargs grep -L "test\|describe\|it(" 2>/dev/null | grep -v node_modules | head -20
4. git log --all --oneline | grep -iE "revert|fix|hotfix|rollback" | head -10

## 출력
다음 표로 정리해줘:

| 문제 | 반복 횟수 | 분류 | 해결 방법 |
|------|-----------|------|-----------|
| 문제 설명 | N회 | 프롬프트/시스템 | 제안 |

## 분류 기준
- 프롬프트 문제: 지시를 더 명확히 하면 해결됨
- 시스템 문제: 아무리 잘 말해도 구조적으로 막지 않으면 반복됨
              → CLAUDE.md 규칙 또는 hooks 필요

분석 후 시스템 문제 3개 이상을 우선순위로 표시해줘.
```

### Step 2-2: 받은 표를 본인 메모에 저장

Claude가 출력한 표를 복사해서 `.claude/baseline.md`에 임시로 저장 (Step 5에서 합칠 것):

```bash
# 임시로
cat > .claude/failure-audit.md << 'EOF'
# Failure Audit — 2026-MM-DD

(Claude가 출력한 표 붙여넣기)
EOF
```

### Node 프로젝트에서 흔한 시스템 문제 예시

본인 결과가 이와 비슷하면 정상:

| 문제 | 반복 횟수 | 분류 | 해결 방법 |
|------|-----------|------|-----------|
| `.env` 파일을 실수로 commit | 1회 | **시스템** | `.gitignore` + guard.sh로 `.env` 수정 차단 |
| DB 모델을 API 응답에 그대로 노출 | 4회 | **시스템** | CLAUDE.md 금지 규칙 + DTO/스키마 변환 |
| 테스트 없이 새 라우트 추가 | 6회 | **시스템** | 자기검증 루프 (Jest 실행 강제) |
| `console.log(process.env.SECRET)` 잔존 | 3회 | **시스템** | guard.sh로 차단 + lint 규칙 |
| 사용 안 하는 npm 패키지가 누적 | 2회 | 프롬프트 | "필요한 것만 설치" 규칙 |
| `try/catch`로 에러 묻기 (silent fail) | 5회 | 시스템 | ESLint 규칙 + CLAUDE.md |

### Step 2 체크리스트

- [ ] 시스템 문제 **3개 이상** 발견했는가?
- [ ] 각 문제가 CLAUDE.md 규칙 또는 guard.sh 항목으로 전환 가능한가?
- [ ] `.claude/failure-audit.md`에 저장했는가?

> **막힐 때**: git log가 짧아서 패턴이 안 보이면? → 가공이 적은 새 프로젝트라면 패턴이 안 나오는 게 정상. 그러면 Step 3 (베이스라인 측정)에서 패턴을 **생성**한다.

---

## Step 3 — 베이스라인 측정 — 30분

> 원본: `raw/harness-engineering/harness-kit/module1/02_baseline_prompt.md` (Node 친화로 치환)

**목적**: 하네스 적용 **전** 에이전트 성능을 수치로 기록. Module 05에서 After와 비교해서 효과 확인.

**중요**: 이 Step은 `CLAUDE.md`도 hooks도 **없는 상태**에서 진행. Claude의 "맨몸 성능"을 본다.

### 측정용 미니 프로젝트 (본인 프로젝트가 비어있다면)

본인 프로젝트가 충분히 있으면 그걸로 한다. 비어있다면 임시로:

```bash
# 임시 실습용 폴더 (본인 프로젝트 있으면 skip)
mkdir -p ~/harness-baseline-tmp && cd ~/harness-baseline-tmp
npm init -y
npm install express
npm install --save-dev jest

cat > src/server.js << 'EOF'
const express = require('express');
const app = express();
app.use(express.json());

// 임시 in-memory store
const users = [];

app.get('/users', (req, res) => res.json(users));
app.post('/users', (req, res) => {
  users.push(req.body);
  res.status(201).json(req.body);
});

module.exports = app;
EOF

mkdir -p src
mv src/server.js src/server.js 2>/dev/null || true
git init && git add . && git commit -m "initial baseline scaffold"
```

### 태스크 A — 모델에 필드 추가 (10분)

Claude Code에 **그대로 붙여넣기**:

```
[베이스라인 측정 중 — CLAUDE.md, hooks 없음. 평소처럼 작업해줘]

User 모델에 'phone' 필드를 추가해줘.
- 형식 검증 (010-XXXX-XXXX 또는 +82-...)
- 필수 항목 (없으면 400)
- POST /users 와 GET /users 응답에 반영
- 가능하면 테스트도

```

**완료 후 측정 (체크박스 손으로)**:

```
[태스크 A]
□ DB/내부 모델을 API 응답에 그대로 노출했는가? (Y/N) ________
□ 마이그레이션 또는 스키마 변경 처리했는가? (Y/N) ________
□ 테스트 작성했는가? (Y/N) ________
□ 요청 안 한 코드(다른 라우트, 미사용 import) 추가 줄 수: ________ 줄
□ 완료까지 주고받은 메시지 횟수: ________ 회
□ Claude가 가정을 먼저 말했는가? (Y/N) ________
```

### 태스크 B — 새 조회 API (10분)

```
[베이스라인 측정 중]

GET /users 에 다음을 추가해줘:
- status 쿼리 파라미터로 필터링 (active/inactive)
- 페이징: limit (기본 20), offset (기본 0)
- 응답에 total 카운트 포함
```

```
[태스크 B]
□ 기존 GET /users 시그니처를 깨뜨렸는가? (Y/N) ________
□ 요청 안 한 정렬/검색 기능 추가했는가? (Y/N) ________
□ 기존 코드를 "개선" 한답시고 수정했는가? (Y/N) ________
□ 페이징 경계값(limit=0, offset 음수) 처리했는가? (Y/N) ________
□ 완료까지 메시지 횟수: ________ 회
```

### 태스크 C — 버그 수정 (10분)

```
[베이스라인 측정 중]

버그 리포트: POST /users 에서 phone 필드를 빈 문자열("")로 보내면
서버가 500 에러를 내고 죽음.
빈 문자열은 400 (validation error)을 반환해야 함.

고쳐줘.
```

```
[태스크 C]
□ 버그 재현 테스트를 먼저 작성했는가? (Y/N) ________
□ 관련 없는 다른 검증 로직도 같이 수정했는가? (Y/N) ________
□ Claude가 원인을 먼저 가정으로 말했는가, 아니면 조용히 코드부터 고쳤는가? ________
□ 완료까지 메시지 횟수: ________ 회
```

### Step 3 체크리스트

- [ ] 태스크 A·B·C **모두 실행**했는가?
- [ ] 측정 시트를 손으로 채웠는가?
- [ ] 본인 프로젝트(또는 미니 프로젝트)에 git commit 했는가? (변화를 추적해야 Module 5에서 비교 가능)

---

## Step 4 — baseline.md 저장 — 5분

위 측정 결과를 `.claude/baseline.md` 한 파일로 합쳐서 저장한다.

```bash
cat > .claude/baseline.md << 'EOF'
# 하네스 적용 전 베이스라인 — 2026-MM-DD

## 측정 환경
- 프로젝트: ____________
- Node 버전: ____________
- Claude Code 버전: ____________
- CLAUDE.md 적용 여부: ❌ 없음
- hooks 적용 여부: ❌ 없음

---

## Failure Audit 결과 (Step 2)

(Claude가 출력한 표 붙여넣기)

---

## 태스크 A — User 모델에 phone 필드 추가
- DB/내부 모델 노출: __
- 마이그레이션 처리: __
- 테스트 작성: __
- 불필요한 코드 추가 줄 수: __
- 메시지 횟수: __
- 가정 명시 여부: __

## 태스크 B — GET /users 필터링·페이징
- 기존 시그니처 보존: __
- 불필요 기능 추가: __
- 기존 코드 임의 수정: __
- 경계값 처리: __
- 메시지 횟수: __

## 태스크 C — 빈 문자열 phone 버그 수정
- 재현 테스트 먼저: __
- 무관 코드 수정: __
- 가정 명시: __
- 메시지 횟수: __

---

## 종합
- 총 문제 발생 수: __ 건
- 평균 메시지 횟수: __ 회
- 가장 자주 발생한 문제: ____________

> 이 파일은 Module 05에서 **그대로** 재실행하여 After와 비교합니다.
> 동일 태스크를 같은 표현으로 다시 요청해야 비교가 유효합니다.
EOF

# git에 commit (팀 공유나 본인 추적용)
git add .claude/baseline.md .claude/failure-audit.md
git commit -m "harness: add module1 baseline + failure audit"
```

---

## Step 5 — 회고 + Module 02 입력 정리 — 5분

발견한 시스템 문제 중 **상위 3~5개**를 다음 표로 골라낸다. Module 02에서 CLAUDE.md STOP 트리거로 옮길 후보:

| 우선순위 | 시스템 문제 | Module 02에서 옮길 곳 | 향후 module 03 hook 가능? |
|---------|------------|---------------------|--------------------------|
| 1 | `.env` 커밋 | STOP: 환경 파일 커밋 | ✅ guard.sh |
| 2 | DB 모델 응답 노출 | STOP: 내부 모델 직접 노출 | ⚠️ 정적 검사 필요 |
| 3 | 테스트 없이 라우트 추가 | STOP: 테스트 없는 라우트 | ⚠️ PostToolUse 후 검사 |
| 4 | 시크릿 로깅 | STOP: `console.log(process.env.SECRET)` | ✅ guard.sh + eslint |
| 5 | silent try/catch | STOP: 빈 catch 블록 | ✅ eslint 규칙 |

이 표를 `.claude/baseline.md` 맨 아래에 추가.

---

## 막힐 때 (Module 1 전용 FAQ)

### Q. Failure Audit에서 시스템 문제가 1~2개밖에 안 나와요
신규 프로젝트면 정상. **Step 3 (베이스라인 측정)**에서 일부러 잘못 동작하게 만든 다음, 거기서 나온 패턴을 시스템 문제로 분류하면 된다.

### Q. 베이스라인 측정 중 Claude가 너무 잘 해서 "문제"가 안 나와요
모델이 좋아서 그렇다. 그러면 **태스크를 더 모호하게** 다시 던진다:
- "phone 필드 추가해줘" → "사용자 정보 보강해줘" (모호한 표현)
- 또는 태스크 범위를 더 크게 ("페이징 + 정렬 + 검색 + 통계 같이")
- 이렇게 해야 에이전트가 자유롭게 행동하면서 어떤 기본 습관을 갖는지 보임

### Q. `.claude/` 폴더를 git에 커밋해도 되나요
**baseline.md, failure-audit.md는 커밋 권장** (시간이 지나면서 비교용). `.claude/settings.json`도 커밋 (팀 공유). 단 `claude-progress.txt` (Module 4에서 등장)는 개인용이면 `.gitignore` 추가.

### Q. 이미 큰 프로젝트라 git log가 너무 많아요
프롬프트에서 `git log --oneline -30`을 `--since="1 month ago"` 같이 제한:
```
git log --oneline --since="1 month ago" | head -30
```

---

## 산출물 정리

| 파일 | 내용 | 다음 모듈에서 |
|------|------|--------------|
| `.claude/baseline.md` | Before 측정 + Failure Audit + 시스템 문제 우선순위 표 | Module 5에서 After 비교 |
| `.claude/failure-audit.md` | 발견된 모든 실패 패턴 | Module 2 STOP 트리거 입력 |
| git commit (`harness: add module1 baseline`) | 추적 시작점 | Module 5에서 diff 가능 |

---

## 다음 단계

▶ [[guide-harness-module2]] — CLAUDE.md 작성. Step 5에서 골라낸 시스템 문제들을 **STOP 트리거**로 옮긴다.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 환경 셋업 + 용어 사전
- [[src-harness-engineering]] — 전체 커리큘럼
- [[concept-harness-engineering]] — 마구 비유, 시대 진화, 4원칙
- [[guide-harness-module2]] — 다음 모듈
- [[guide-harness-module5]] — Before/After 비교 시점
