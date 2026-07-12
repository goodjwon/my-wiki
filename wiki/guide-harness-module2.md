---
title: 하네스 Module 02 — CLAUDE.md 작성 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module2, claude-md, karpathy, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module2/CLAUDE.md
  - harness-engineering/harness-kit/module2/01_draft_claude_md_prompt.md
  - harness-engineering/harness-kit/module2/02_before_after_prompt.md
created: 2026-05-31
updated: 2026-07-12
---

# 하네스 Module 02 — CLAUDE.md 작성

> **이 가이드 보기 전에**: [[guide-harness-module1]] 까지 완료하세요. `.claude/baseline.md` 맨 아래에 "Module 02로 넘길 시스템 문제 우선순위 표"가 채워져 있어야 합니다.

**왜 CLAUDE.md가 Module 1 다음인가**: Module 01에서 골라낸 우선순위 표는 "아무리 잘 말해도 구조적으로 막지 않으면 반복되는" 시스템 문제 목록입니다. CLAUDE.md는 에이전트가 매 세션 가장 먼저 읽는 규칙 문서이고, 그 표의 각 행이 이번 모듈에서 STOP 트리거(에이전트가 작업을 멈추고 사용자 확인을 요청해야 하는 조건) 한 줄로 바뀝니다. 측정 없이 규칙부터 쓰면 상상 속 문제를 막는 규칙이 되기 쉽고, 반대로 측정만 하고 규칙으로 옮기지 않으면 같은 실수가 다음 세션에도 반복됩니다 — 그래서 측정(M1) 바로 다음이 규칙 문서화(M2)입니다.

**이 모듈에서 얻을 것**:

1. 프로젝트 루트에 **`CLAUDE.md`** (Node 친화, 500줄 이하)
2. **Before/After 비교 표** — Module 01 태스크 재실행 결과
3. CLAUDE.md 섹션 11에 **누적 실패 패턴 첫 항목**

**진행 흐름**: 12섹션 골격 생성(Step 1) → 우선순위 표를 STOP 트리거로 이전(Step 2) → 프로젝트 구조 섹션 채우기(Step 3) → 분량 점검·커밋(Step 4) → 같은 유형의 새 태스크(태스크 D)로 Before/After 검증(Step 5) → 안 지켜진 규칙을 첫 실패 패턴으로 기록(Step 6).

**시간**: 약 1.5시간 (초안 작성 30분 + Before/After 30분 + 보완 30분)

> ✅ **Step 5 실행 검증됨 (2026-07-12, Node v24)**: Module 01 완료 상태(phone 구현·커밋)를 재현한 playground 복사본에서 태스크 D를 헤드리스(`claude -p` + stream-json 도구 호출 감사)로 실행해 확인했습니다 — CLAUDE.md를 먼저 읽고 섹션 8 체크리스트·섹션 7 STOP 대조 후 계획 제시, Zod Address 스키마(roadAddress 필수·detailAddress 선택·zipCode `^\d{5}$`)로 누락·형식 오류 400, api·web 동시 수정(섹션 6 모노레포 원칙 작동), 테스트 5→11개 전부 통과, `harness(M2-D)` 커밋까지 완주.

이론 배경: [[concept-claude-md]]

---

## Step 1 — CLAUDE.md 기본 골격 만들기 — 10분

규칙을 옮기기 전에 규칙을 담을 그릇부터 만듭니다. 아래 골격은 기술 스택(섹션 1)부터 세션 시작 시 행동(섹션 12)까지, CLAUDE.md에 담을 내용을 12개 섹션으로 나눈 템플릿입니다. 이 중 섹션 6(프로젝트 구조)과 섹션 7(STOP 트리거)만 빈칸으로 남겨 두는데, 이 두 칸이 바로 Module 01 산출물이 들어갈 자리입니다. 실습은 Module 01과 같은 `~/harness-playground`에서 계속하고, 본인 프로젝트로의 이식은 5모듈 종료 후에 합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground` (Module 01을 진행한 프로젝트 그대로)
    - **만들 파일**: `CLAUDE.md` (프로젝트 루트) — 12섹션 기본 골격
    - **실행**: 아래 명령을 그대로 실행해 골격을 생성하고 커밋합니다.

```bash
cd ~/harness-playground

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
  1. 라우트 정의 → verify: 컴파일/lint OK
  2. 핸들러 구현 → verify: 단위 테스트 통과
  3. 통합 테스트 → verify: supertest 200 OK

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
git commit -m "docs(M2): CLAUDE.md 기본 골격 추가"
```

---

## Step 2 — STOP 트리거 채우기 (Module 01 결과 이전) — 20분

Step 1 골격에서 비워 둔 섹션 7을 채울 차례입니다. Module 01 Step 5에서 `.claude/baseline.md` 맨 아래에 정리한 시스템 문제 우선순위 표가 그대로 재료가 됩니다 — 표의 각 행을 "에이전트가 멈추고 확인을 요청해야 하는 조건" 한 줄로 바꿔 옮깁니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **수정할 파일**: `CLAUDE.md` 섹션 7 — `.claude/baseline.md` 우선순위 표를 STOP 항목으로 변환
    - **실행**: 아래 변환 예시대로 기본 목록을 붙여넣고, 본인 항목을 추가합니다.

### 왜 그대로 복사하지 않고 "변환"하는가

Module 01 우선순위 표에도 이미 `STOP: 환경 파일 커밋` 같은 메모가 적혀 있어서, 그 열을 그대로 복사하면 될 것처럼 보입니다. 하지만 두 문서는 읽는 주체가 다릅니다. 우선순위 표는 사람이 회고할 때 읽는 기록이라 "무슨 사고였는지" 떠올릴 짧은 이름이면 충분하지만, CLAUDE.md 섹션 7은 에이전트가 작업 도중 자기 행동과 대조하는 판정 조건이라 그 이름만으로는 판정이 안 됩니다. "환경 파일 커밋"이라고만 적으면 `.env.local`이나 `credentials.json` 커밋은 걸리지 않고, "내부 모델 직접 노출"이라고만 적으면 에이전트가 멈춘 뒤 대신 무엇을 해야 하는지가 없습니다.

그래서 표의 각 행을 옮길 때 두 가지를 붙입니다:

1. **판정 가능한 패턴** — 파일 글롭(`.env.*`, `*.pem`)이나 호출 형태(`console.log(process.env.*)`)처럼, 에이전트가 지금 하려는 행동과 기계적으로 대조할 수 있는 표현으로 범위를 넓혀 적습니다.
2. **멈춘 뒤의 대안** — 금지만 있으면 에이전트가 어중간하게 우회하므로, 대신 할 일(DTO 변환 필수, 새 마이그레이션 추가만)을 같은 줄에 명시합니다.

### 변환 예시

Module 01 표의 시스템 문제(왼쪽)에 위 두 가지가 붙어 섹션 7의 STOP 항목(오른쪽)으로 바뀌는 모습입니다:

| Module 01 시스템 문제 | CLAUDE.md 섹션 7 STOP 항목 |
|----------------------|---------------------------|
| `.env` 커밋 | STOP: `.env`, `.env.*`, `*credentials.json`, `*.pem` 커밋 |
| DB 모델 응답 노출 | STOP: ORM 모델(Prisma User, Mongoose Document)을 API 응답에 직접 반환 — DTO/Zod 스키마 변환 필수 |
| 테스트 없이 라우트 추가 | STOP: 라우트 핸들러를 `*.test.js` 없이 추가 |
| 시크릿 로깅 | STOP: `console.log(process.env.*)` 또는 logger에 password/token/secret 키 노출 |
| silent try/catch | STOP: catch 블록을 비우거나 `console.log`만 |

### Node + 일반 추천 STOP 트리거 (기본)

이 변환을 항목마다 손으로 할 필요는 없습니다. 자주 나오는 시스템 문제를 미리 변환해 둔 Node 공통 기본 목록이 아래에 있으므로, CLAUDE.md 섹션 7을 다음으로 교체합니다:

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

기본 목록에 이미 있는 항목은 그대로 두고, 본인 `.claude/baseline.md` 우선순위 표에만 있는 시스템 문제를 **추가 항목**으로 직접 적습니다 (해당 없는 기본 항목은 지워도 됩니다). 전체 8~10개면 적당합니다 — Module 01 Step 5에서 상위 3~5개만 고른 것과 같은 이유로, 트리거가 너무 많으면 에이전트가 목록 전체를 무시하기 시작합니다.

---

## Step 3 — 프로젝트 구조 섹션 채우기 — 10분

섹션 7을 채웠으니 골격에 남은 빈칸은 섹션 6(프로젝트 구조)뿐입니다. 이 섹션은 에이전트가 "어디에 무엇을 만들지"를 스스로 판단하게 해 주는 지도라서, 손으로 그리기보다 Claude에게 현재 구조를 읽혀 작성시키는 편이 빠르고 정확합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **수정할 파일**: `CLAUDE.md` 섹션 6 — 디렉터리 트리 + 책임 설명
    - **실행**: `claude` 세션에 아래 프롬프트를 붙여넣고, 받은 결과를 섹션 6에 붙여넣습니다.

````
프로젝트 구조를 파악해서 CLAUDE.md 섹션 6에 넣을 디렉터리 트리와
각 폴더의 책임 설명을 작성해줘.

실행:
1. find . -type d -not -path "./node_modules*" -not -path "./.git*" \
   -not -path "./dist*" | head -30
2. 각 주요 폴더 안의 파일 종류 1~2개씩 보여주기

출력 형식:
```
api/                # Express 백엔드 — User CRUD API
├── src/
│   ├── app.js      # 라우트 + Zod 스키마
│   ├── app.test.js # supertest API 테스트
│   └── server.js   # 서버 기동
└── package.json
web/                # React 프론트 — User 목록 화면
├── src/
│   └── App.jsx     # User 목록 + 추가 폼
└── package.json
```

원칙:
- web/(프론트)과 api/(백엔드)가 분리된 모노레포임을 명시
- 필드·API 변경이 양쪽에 걸치면 api/와 web/을 함께 수정
- API 응답은 Zod 스키마의 변환을 거침 (in-memory 모델 직접 반환 X)
- 계층(controllers/services/repositories)이 생기면: 라우트는 controller만,
  controller는 service만, service는 repository로 DB 접근
````

받은 결과를 CLAUDE.md 섹션 6에 붙여넣습니다. 출력 형식의 트리는 예시일 뿐이니 실제 `find` 결과를 따르되, **web/과 api/가 분리된 모노레포라는 사실과 "양쪽에 걸치는 변경은 함께 수정" 원칙은 반드시 들어가야 합니다** — 이 한 줄이 없으면 에이전트가 api만 고치고 web을 빼먹는 Module 01의 실패 패턴이 반복됩니다.

---

## Step 4 — 분량 점검 + 커밋 — 5분

두 빈칸이 모두 채워졌으니 커밋 전에 분량을 확인합니다. CLAUDE.md는 매 세션 컨텍스트에 통째로 들어가기 때문에, 길어질수록 개별 규칙이 묻혀 오히려 안 지켜집니다 — 그래서 500줄 이하를 기준으로 잡습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: 커밋 1개 — 섹션 6·7이 채워진 `CLAUDE.md`
    - **실행**: 아래 명령으로 줄 수를 확인하고 커밋합니다.

```bash
# 500줄 이하인지 확인
wc -l CLAUDE.md
# → 500 이하면 OK. 넘으면 일반 코딩 가이드를 줄이고
#    프로젝트 고유의 STOP/체크리스트에 집중.

git add CLAUDE.md
git commit -m "docs(M2): baseline 시스템 문제를 STOP 트리거로 이전"
```

---

## Step 5 — Before/After 비교 — 30분

Step 4까지 만든 CLAUDE.md가 실제로 에이전트 행동을 바꿨는지 검증할 차례입니다. 방법은 Module 01 Step 3에서 맨몸 성능 측정에 썼던 태스크 A(phone 필드 추가)와 **요구 구조가 같은 새 태스크를 CLAUDE.md가 있는 상태에서** 실행해, Module 01의 Before 측정치와 나란히 비교하는 것입니다. 이 새 태스크를 **태스크 D**라고 부릅니다 (A·B·C는 Module 01의 베이스라인 태스크) — User에 address 필드를 추가하는 일로, 필드 추가·형식 검증·필수 처리·web 반영·테스트라는 요구 구조와 측정 7항목이 태스크 A와 같아서 유형 단위 비교가 성립합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: `.claude/baseline.md`에 "Module 02 After" 비교 표 추가
    - **실행**: 새 `claude` 세션에서 태스크 D(address 필드 추가)를 실행하고 측정합니다.

### Step 5-1: 왜 재실행이 아니라 새 태스크인가 + 새 세션 시작

Module 01 태스크 A를 이미 실행했기 때문에 playground에는 phone 필드가 들어가 있습니다. 이 상태에서 같은 태스크를 다시 던지면 "이미 구현돼 있다"로 끝나 버려 비교가 성립하지 않습니다. 태스크 커밋을 `git revert`로 되돌려 출발선을 맞추는 방법도 있지만, 태스크 커밋에 CLAUDE.md나 `.claude/` 변경이 섞여 있으면(에이전트가 작업 중 CLAUDE.md를 만들거나 고친 것이 `git add -A`에 함께 담긴 경우) 되돌리는 순간 방금 완성한 CLAUDE.md까지 초기화되는 함정이 있습니다. 그래서 이 실습은 되돌리지 않습니다 — phone은 그대로 두고, 같은 유형의 새 필드(address)로 비교합니다.

기존 Claude 세션을 종료하고 다시 `claude`를 실행합니다. 새 세션이어야 방금 만든 CLAUDE.md를 처음부터 읽고 시작합니다.

### Step 5-2: CLAUDE.md가 실제 로드됐는지 확인

새 세션이 떴으면, 본 태스크를 던지기 전에 CLAUDE.md가 실제로 로드됐는지부터 확인합니다:

```
CLAUDE.md 섹션 7의 STOP 트리거 첫 3개를 그대로 인용해줘.
```

3개를 정확히 인용해주면 통과입니다. 못 하면 CLAUDE.md 위치(프로젝트 루트인지)를 다시 확인합니다.

### Step 5-3: 태스크 D 실행 (태스크 A와 같은 요구 구조)

로드를 확인했으면 태스크 D를 던집니다. Module 01 태스크 A에서 바뀐 곳은 세 군데입니다 — 대상 필드가 phone에서 address로 바뀌었고, Module 01에서 "규칙 없이 평소처럼 작업하라"는 안내로 프롬프트 머리에 붙였던 `[베이스라인 측정 중 …]` 표시를 뺐고, 끝에 CLAUDE.md 확인 지시를 붙였습니다. 요구 구조(필드 추가·형식 검증·필수 처리·web 반영·테스트)는 동일해야 비교가 유효합니다. address는 행정안전부 도로명주소 체계를 따르는 요구사항으로 구체화합니다:

```
이 모노레포에 User에 'address' 필드를 추가해줘.
- api/: POST /users 와 GET /users 응답에 address 포함
- 행정안전부 도로명주소 체계에 맞게 구성:
  roadAddress(도로명주소, 예: "서울특별시 종로구 세종대로 209"),
  detailAddress(상세주소, 선택), zipCode(우편번호, 숫자 5자리)
- roadAddress와 zipCode는 필수, 없거나 형식이 틀리면 400
- web/: 추가 폼에 address 입력, 목록에 address 표시
- 가능하면 api 테스트도

시작 전 CLAUDE.md의 섹션 8 작업 전 체크리스트와
섹션 7 STOP 트리거를 먼저 확인하고, 단계별 계획을 제시해줘.
```

완료 후 측정 (Module 1 태스크 A와 **같은 7개 항목**):

```
[태스크 D — After]
□ 내부 모델(in-memory users) 노출: __
□ Zod 스키마로 검증: __
□ api 테스트 작성: __
□ 요청 안 한 코드 줄 수: __
□ 메시지 횟수: __
□ 가정 명시 여부: __
□ 화면 실제 작동 확인: __
```

측정을 마쳤으면 결과를 커밋해 둡니다. Module 05에서는 또 다른 같은 유형의 새 태스크(태스크 E)로 5모듈 누적 효과를 측정하므로, 이 커밋을 되돌릴 일은 없습니다:

```bash
git add -A
git commit -m "harness(M2-D): 태스크 D — address 필드 추가 (CLAUDE.md 적용)"
```

### Step 5-4: 비교 표 작성

Step 5-3에서 측정한 After 값과 Module 01의 Before 값을 한 표에 모읍니다. 아래 블록을 그대로 실행한 뒤, `__` 칸에 **본인이 측정한 Before/After 숫자를 직접 채웁니다**:

```bash
cat >> .claude/baseline.md << 'EOF'

---

## Module 02 After — CLAUDE.md 적용 후 (2026-MM-DD)

### 필드 추가 태스크 비교 — Before: 태스크 A(phone) / After: 태스크 D(address)
| 항목 | Before (M1) | After (M2) | 개선 |
|------|------------|-----------|------|
| 내부 모델(in-memory) 노출 | __ | __ | __ |
| Zod 스키마 검증 | __ | __ | __ |
| api 테스트 작성 | __ | __ | __ |
| 불필요한 코드 (줄) | __ | __ | __ |
| 메시지 횟수 | __ | __ | __ |
| 가정 명시 | __ | __ | __ |
| 화면 작동 확인 | __ | __ | __ |

### 작동한 CLAUDE.md 규칙
- (예: "STOP: ORM 모델 직접 반환" → Zod 스키마 변환 자동 수행)
- 

### 작동 안 했거나 우회된 규칙
- (예: "테스트 없이 라우트 추가" → 여전히 테스트 없이 추가)
- 
EOF
```

같은 방식으로 태스크 B(검색·페이징)·C(버그 수정)와 같은 유형의 새 태스크를 만들어 반복하면 더 좋지만, 시간이 빠듯하면 태스크 D 하나만 해도 효과를 확인할 수 있습니다.

---

## Step 6 — 첫 누적 실패 패턴 기록 — 10분

Step 5-4 비교 표의 "작동 안 했거나 우회된 규칙" 칸이 비어 있지 않다면, 그것이 CLAUDE.md 섹션 11(누적된 실패 패턴)의 첫 항목입니다. 확인된 그 자리에서 바로 기록해야 다음 세션에서 같은 실수를 잡을 수 있고, Module 03에서 hooks(에이전트의 도구 실행 전후에 자동으로 도는 검사 스크립트)로 강제할 후보 목록도 여기서 나옵니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **수정할 파일**: `CLAUDE.md` 섹션 11 — 작동 안 한 규칙을 표에 추가
    - **실행**: 아래 예시처럼 표를 채우고, `CLAUDE.md`와 `.claude/baseline.md`를 함께 커밋합니다.

기록 예시:

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
git commit -m "harness(M2): Before/After 비교 + 첫 누적 실패 패턴"
```

---

## 막힐 때 (Module 2 전용 FAQ)

### Q. CLAUDE.md를 500줄 이하로 줄이기 힘들어요
원본 템플릿의 DDD 섹션, 네이밍 컨벤션의 모든 케이스, 빌드 명령어 전체를 다 옮길 필요는 없습니다. **본인 프로젝트 고유의 STOP과 작업 전 체크리스트에 집중합니다**.

### Q. 섹션 6 (프로젝트 구조)에 뭘 적어야 할지 모르겠어요
처음엔 비워둬도 됩니다. 작업하면서 "라우트는 controller만 호출" 같은 원칙이 자연스럽게 보일 때 추가합니다. CLAUDE.md는 살아있는 문서입니다.

### Q. Before/After가 별 차이 안 나요
모델이 좋아서 기본 동작이 이미 잘 됐을 가능성이 있습니다. 그러면 **태스크를 더 모호하게** 던지거나, **STOP 트리거가 정말 작동했는지** 확인합니다 — 작동했다면 보이지 않는 차이입니다.

### Q. CLAUDE.md 섹션 7 STOP 트리거가 실제로 막아주나요
**아닙니다.** CLAUDE.md는 선언일 뿐입니다. **Module 03의 hooks**가 진짜 강제입니다. CLAUDE.md는 "에이전트가 자발적으로 따르려는 규칙" 정도입니다.

### Q. AGENTS.md도 같이 만들까요
Claude Code만 쓰면 CLAUDE.md만 있으면 됩니다. 나중에 Codex나 다른 에이전트를 섞을 때 Module 04에서 AGENTS.md를 추가합니다.

---

## 산출물 정리

이 모듈을 마치면 playground에 다음 세 가지가 남아 있어야 합니다:

| 파일 | 상태 | 다음 모듈에서 |
|------|------|--------------|
| `CLAUDE.md` (프로젝트 루트) | 12섹션 채워짐, 500줄 이하, STOP 8~10개 | Module 03 hooks가 자동화할 후보 |
| `.claude/baseline.md` | Before/After 비교 표 추가 | Module 05에서 5모듈 누적 비교 |
| 누적 실패 패턴 첫 항목 | 섹션 11 시작 | 매주 추가 → Module 05 진화 |

---

## 다음 단계

▶ [[guide-harness-module3]] — CLAUDE.md의 STOP 트리거 중 **자동화 가능한 것**을 hooks로 끌어내립니다.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 환경 셋업
- [[guide-harness-module1]] — 입력 (baseline.md + 시스템 문제)
- [[guide-harness-module3]] — 다음 모듈 (hooks로 물리적 강제)
- [[concept-claude-md]] — Karpathy 4원칙 + STOP 이론
- [[src-harness-engineering]] — 전체 커리큘럼
