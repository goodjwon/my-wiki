---
title: 하네스 Module 02 — CLAUDE.md 작성 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module2, claude-md, karpathy, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module2/CLAUDE.md
  - harness-engineering/harness-kit/module2/01_draft_claude_md_prompt.md
  - harness-engineering/harness-kit/module2/02_before_after_prompt.md
created: 2026-05-31
updated: 2026-05-31
---

# 하네스 Module 02 — CLAUDE.md 작성

> **이 가이드 보기 전에**: [[guide-harness-module1]] 까지 완료. `.claude/baseline.md`와 시스템 문제 우선순위 표가 있어야 합니다.

**이 모듈에서 얻을 것**:
1. 프로젝트 루트에 **`CLAUDE.md`** (Node 친화, 500줄 이하)
2. **Before/After 비교 표** — Module 01 태스크 재실행 결과
3. CLAUDE.md 섹션 11에 **누적 실패 패턴 첫 항목**

**시간**: 약 1.5시간 (초안 작성 30분 + Before/After 30분 + 보완 30분)

이론 배경: [[concept-claude-md]]

---

## Step 1 — CLAUDE.md 기본 골격 만들기 — 10분

본인 프로젝트 루트에서:

```bash
# 기본 구조 자동 생성
cat > CLAUDE.md << 'EOF'
# CLAUDE.md — Agent Harness Constitution

> 이 파일은 프롬프트가 아니다. 에이전트 실행 환경의 헌법이다.
> 매 세션 시작 시 가장 먼저 읽힌다.

## 1. Tech Stack
- Runtime: Node.js __ LTS
- Framework: Express __ (또는 Fastify/NestJS)
- DB: ____ (PostgreSQL / MongoDB / ...)
- ORM/Driver: ____ (Prisma / Mongoose / Knex / ...)
- Test: Jest (또는 Vitest)
- Lint: ESLint + Prettier
- Package Manager: npm (또는 pnpm/yarn)

## 2. Think Before Coding
- 가정을 명시한다. 불확실하면 먼저 질문한다.
- 여러 해석 가능하면 옵션을 제시한다.
- 더 단순한 방법이 있으면 먼저 말한다.

## 3. Simplicity First
- 요청된 것만 구현. "나중에 쓸지도"의 추상화 금지.
- 100줄이 30줄로 가능하면 다시 쓴다.
- 외부 패키지 추가 전, 표준 라이브러리로 가능한지 먼저 확인.

## 4. Surgical Changes
- 기존 네이밍/구조를 임의 리팩토링 금지.
- 내 변경이 만든 unused import만 정리.
- 기존 dead code는 언급만 하고 삭제 X.

## 5. Goal-Driven Execution
- "[단계] → verify: [확인법]" 형식.
- 멀티스텝은 계획 먼저:
  1. 라우트 정의      → verify: 컴파일/lint OK
  2. 핸들러 구현      → verify: 단위 테스트 통과
  3. 통합 테스트      → verify: supertest 200 OK

## 6. 프로젝트 구조
(여기는 Step 3에서 채움)

## 7. ⛔ 절대 금지 트리거 (STOP)
(여기는 Step 2에서 채움 — baseline.md의 시스템 문제 우선순위 이전)

## 8. 작업 전 체크리스트
- [ ] 새 라우트인가? → 테스트 먼저 작성
- [ ] 환경변수 추가? → .env.example도 업데이트
- [ ] 외부 패키지 추가? → 정말 필요한가 다시 확인
- [ ] 응답 스키마 변경? → API 문서/타입 동기화

## 9. 빌드 & 테스트 명령어
- 실행: npm run dev
- 빌드: npm run build
- 테스트: npm test
- 린트: npm run lint
- 포맷: npm run format

## 10. 네이밍 컨벤션
| 종류 | 패턴 | 예시 |
|------|------|------|
| 파일명 | kebab-case | `user-service.js` |
| 함수 | camelCase | `getUserById` |
| 상수 | UPPER_SNAKE | `MAX_RETRY` |
| 라우트 핸들러 | `<verb><Resource>` | `createUser` |
| 테스트 파일 | `*.test.js` 또는 `*.spec.js` | `user.test.js` |

## 11. 누적된 실패 패턴
> 같은 실수 두 번이면 즉시 여기 추가. "다음엔 잘 해줘"는 없다.

| 날짜 | 실패 패턴 | 방지 규칙 |
|------|----------|-----------|

## 12. 세션 시작 시 에이전트 행동
1. `git log --oneline -10` 확인
2. README.md 또는 `claude-progress.txt`가 있으면 읽기
3. 위 STOP 트리거 목록 재확인
4. 작업 전 계획 먼저 제시
EOF

git add CLAUDE.md
git commit -m "docs: add CLAUDE.md skeleton"
```

---

## Step 2 — STOP 트리거 채우기 (Module 01 결과 이전) — 20분

`.claude/baseline.md`의 시스템 문제 우선순위 표를 STOP 트리거로 옮긴다.

### 변환 공식

```
[Module 01 시스템 문제]   →  [CLAUDE.md 섹션 7 STOP 항목]
.env 커밋               →  STOP: .env, .env.*, *credentials.json, *.pem 커밋
DB 모델 응답 노출        →  STOP: ORM 모델(Prisma User, Mongoose Document)을
                              API 응답에 직접 반환 (DTO/Zod 스키마 변환 필수)
테스트 없이 라우트 추가  →  STOP: 라우트 핸들러를 *.test.js 없이 추가
시크릿 로깅             →  STOP: console.log(process.env.*) 또는
                              logger에 password/token/secret 키 노출
silent try/catch        →  STOP: catch 블록을 비우거나 console.log만
```

### Node + 일반 추천 STOP 트리거 (기본)

CLAUDE.md 섹션 7을 다음으로 교체:

```markdown
## 7. ⛔ 절대 금지 트리거 (STOP)

다음 행동을 하려 할 때 즉시 멈추고 사용자에게 확인을 요청한다:

STOP: .env, .env.*, *credentials.json, *.pem, service-account.json 커밋
STOP: ORM 모델을 API 응답에 직접 반환 (Zod/Joi/DTO 변환 필수)
STOP: 라우트 핸들러를 테스트 없이 추가 (*.test.js 또는 *.spec.js 동반)
STOP: console.log(process.env.SECRET|TOKEN|PASSWORD|API_KEY)
STOP: 빈 catch 블록 또는 catch에서 에러 삼키기 (logger.error + rethrow/명시 처리)
STOP: DB 마이그레이션 파일 수정/삭제 (새 마이그레이션 추가만)
STOP: main 브랜치 직접 push (PR 경유)
STOP: package-lock.json 임의 삭제 (의존성 잠금 파괴)
STOP: 외부 패키지를 사용자 확인 없이 추가 (npm install ___ 전에 옵션 제시)
```

본인 `.claude/baseline.md`의 시스템 문제로 **추가 항목**을 직접 적는다. 8개 항목으로 시작하면 적당.

---

## Step 3 — 프로젝트 구조 섹션 채우기 — 10분

본인 프로젝트 구조에 맞춰 섹션 6을 채운다. Claude에게 시키면 빠름:

```
프로젝트 구조를 파악해서 CLAUDE.md 섹션 6에 넣을 디렉터리 트리와
각 폴더의 책임 설명을 작성해줘.

실행:
1. find . -type d -not -path "./node_modules*" -not -path "./.git*" \
   -not -path "./dist*" | head -30
2. 각 주요 폴더 안의 파일 종류 1~2개씩 보여주기

출력 형식:
\`\`\`
src/
├── routes/         # Express 라우트 정의
├── controllers/    # HTTP 핸들러
├── services/       # 비즈니스 로직
├── repositories/   # DB 접근
├── schemas/        # Zod 입력 검증 + DTO
├── middlewares/    # 인증, 에러 처리
└── utils/          # 공통 유틸
\`\`\`

원칙:
- 라우트는 controller만 호출 (service 직접 X)
- controller는 service만 호출 (DB 직접 X)
- service는 repository로 DB 접근
- API 응답은 schemas의 변환 거침 (모델 직접 X)
```

받은 결과를 CLAUDE.md 섹션 6에 붙여넣기.

---

## Step 4 — 분량 점검 + 커밋 — 5분

```bash
# 500줄 이하인지 확인
wc -l CLAUDE.md
# → 500 이하면 OK. 넘으면 일반 코딩 가이드를 줄이고
#    프로젝트 고유의 STOP/체크리스트에 집중.

git add CLAUDE.md
git commit -m "docs: customize CLAUDE.md with STOP triggers from baseline"
```

---

## Step 5 — Before/After 비교 — 30분

Module 01에서 했던 태스크 A·B·C를 **CLAUDE.md가 있는 상태에서 다시** 실행한다.

### Step 5-1: Claude Code 새 세션 시작

기존 세션을 종료하고 다시 `claude` 실행. CLAUDE.md를 새로 읽도록.

### Step 5-2: CLAUDE.md가 실제 로드됐는지 확인

```
CLAUDE.md 섹션 7의 STOP 트리거 첫 3개를 그대로 인용해줘.
```

3개를 정확히 인용해주면 통과. 못 하면 CLAUDE.md 위치(프로젝트 루트인지) 다시 확인.

### Step 5-3: 태스크 A 재실행 (Module 1과 같은 표현)

```
User 모델에 'phone' 필드를 추가해줘.
- 형식 검증 (010-XXXX-XXXX 또는 +82-...)
- 필수 항목 (없으면 400)
- POST /users 와 GET /users 응답에 반영
- 가능하면 테스트도

시작 전 CLAUDE.md의 섹션 8 작업 전 체크리스트와
섹션 7 STOP 트리거를 먼저 확인하고, 단계별 계획을 제시해줘.
```

완료 후 측정 (Module 1과 같은 항목):

```
[태스크 A — After]
□ DB/내부 모델 노출: __
□ 마이그레이션 처리: __
□ 테스트 작성: __
□ 불필요한 코드 줄 수: __
□ 메시지 횟수: __
□ 가정 명시 여부: __
```

### Step 5-4: 비교 표 작성

```bash
cat >> .claude/baseline.md << 'EOF'

---

## Module 02 After — CLAUDE.md 적용 후 (2026-MM-DD)

### 태스크 A 비교
| 항목 | Before (M1) | After (M2) | 개선 |
|------|------------|-----------|------|
| DB 모델 노출 | __ | __ | __ |
| 마이그레이션 처리 | __ | __ | __ |
| 테스트 작성 | __ | __ | __ |
| 불필요한 코드 (줄) | __ | __ | __ |
| 메시지 횟수 | __ | __ | __ |

### 작동한 CLAUDE.md 규칙
- (예: "STOP: ORM 모델 직접 반환" → Zod 스키마 변환 자동 수행)
- 

### 작동 안 했거나 우회된 규칙
- (예: "테스트 없이 라우트 추가" → 여전히 테스트 없이 추가)
- 
EOF
```

태스크 B·C도 동일하게 반복하면 더 좋지만, 시간이 빠듯하면 A 하나만 해도 효과 확인 가능.

---

## Step 6 — 첫 누적 실패 패턴 기록 — 10분

Step 5에서 **작동 안 한 규칙**이 있으면 CLAUDE.md 섹션 11에 추가:

```markdown
## 11. 누적된 실패 패턴

| 날짜 | 실패 패턴 | 방지 규칙 |
|------|----------|-----------|
| 2026-05-31 | 라우트 추가 시 *.test.js 자동 생성 안 함 | (Module 3 hooks에서 PostToolUse로 강제 예정) |
| 2026-05-31 | Zod 스키마 안 거치고 res.json(user) 직접 반환 | 섹션 7 STOP에 추가 (이미 있음 → 강화 필요) |
```

커밋:

```bash
git add CLAUDE.md .claude/baseline.md
git commit -m "harness: add module2 before/after comparison + first failure patterns"
```

---

## 막힐 때 (Module 2 전용 FAQ)

### Q. CLAUDE.md를 500줄 이하로 줄이기 힘들어요
원본 템플릿의 DDD 섹션, 네이밍 컨벤션의 모든 케이스, 빌드 명령어 전체를 다 옮길 필요 없음. **본인 프로젝트 고유의 STOP과 작업 전 체크리스트에 집중**.

### Q. 섹션 6 (프로젝트 구조)에 뭘 적어야 할지 모르겠어요
처음엔 비워둬도 된다. 작업하면서 "라우트는 controller만 호출" 같은 원칙이 자연스럽게 보일 때 추가. CLAUDE.md는 살아있는 문서.

### Q. Before/After가 별 차이 안 나요
모델이 좋아서 기본 동작이 이미 잘 됐을 가능성. 그러면 **태스크를 더 모호하게** 던지거나, **STOP 트리거가 정말 작동했는지** 확인 — 작동했다면 보이지 않는 차이.

### Q. CLAUDE.md 섹션 7 STOP 트리거가 실제로 막아주나요
**아니다.** CLAUDE.md는 선언일 뿐. **Module 03의 hooks**가 진짜 강제. CLAUDE.md는 "에이전트가 자발적으로 따르려는 규칙" 정도.

### Q. AGENTS.md도 같이 만들까요
Claude Code만 쓰면 CLAUDE.md만. 나중에 Codex나 다른 에이전트를 섞을 때 Module 04에서 AGENTS.md 추가.

---

## 산출물 정리

| 파일 | 상태 | 다음 모듈에서 |
|------|------|--------------|
| `CLAUDE.md` (프로젝트 루트) | 12섹션 채워짐, 500줄 이하, STOP 8~10개 | Module 03 hooks가 자동화할 후보 |
| `.claude/baseline.md` | Before/After 비교 표 추가 | Module 05에서 5모듈 누적 비교 |
| 누적 실패 패턴 첫 항목 | 섹션 11 시작 | 매주 추가 → Module 05 진화 |

---

## 다음 단계

▶ [[guide-harness-module3]] — CLAUDE.md의 STOP 트리거 중 **자동화 가능한 것**을 hooks로 끌어내린다.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 환경 셋업
- [[guide-harness-module1]] — 입력 (baseline.md + 시스템 문제)
- [[guide-harness-module3]] — 다음 모듈 (hooks로 물리적 강제)
- [[concept-claude-md]] — Karpathy 4원칙 + STOP 이론
- [[src-harness-engineering]] — 전체 커리큘럼
