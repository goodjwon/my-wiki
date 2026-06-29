---
title: 하네스 Module 01 — 베이스라인 측정 + 실패 패턴 감사 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module1, baseline, failure-audit, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module1/01_failure_audit_prompt.md
  - harness-engineering/harness-kit/module1/02_baseline_prompt.md
  - harness-engineering/harness_engineering.md
created: 2026-05-31
updated: 2026-06-29
---

# 하네스 Module 01 — 베이스라인 측정 + 실패 패턴 감사

> **이 가이드 보기 전에**: [[guide-harness-00-prerequisites]] 의 [실습용 미니 프로젝트 만들기](guide-harness-00-prerequisites.md#실습용-미니-프로젝트-만들기-react--express-풀스택)를 끝내세요. `~/harness-playground` 폴더에 api/ + web/ 가 만들어져 있고, `git log`로 3~4개 커밋이 보여야 합니다.

**이 모듈에서 얻을 것**:
1. `.claude/baseline.md` — 하네스 적용 **전** 성능 기록 (Module 05에서 After와 비교)
2. **실패 패턴 표 3개 이상** — Module 02에서 CLAUDE.md STOP 트리거로 전환할 재료

**시간**: 약 1시간 (Failure Audit 20분 + 베이스라인 태스크 3개 30분 + 정리 10분)

**실습 대상**: `~/harness-playground` (prerequisites에서 만든 React + Express 풀스택). **본인 기존 프로젝트는 이 시점에 쓰지 않는다** — 5모듈 종료 후 이식.

이론 배경: [[concept-harness-engineering]]

---

## Step 1 — 실습 환경 확인 — 3분

prerequisites에서 만든 playground로 이동해 환경 확인:

```bash
cd ~/harness-playground

# 1. git 저장소인지, 커밋 있는지
git log --oneline
# → 3~4개 커밋이 보여야 정상 (chore: init, feat(api), feat(web), ...)

# 2. Claude Code 실행 가능한지
claude --version

# 3. baseline 저장할 폴더
mkdir -p .claude

# 4. 테스트 통과 확인 (출발선)
npm test
# → api 3개 통과해야 정상
```

확인 통과하면 다음 Step.

> **git log가 짧다고 걱정 No**: Step 2의 Failure Audit이 빈약해지지만, 그건 정상. 패턴은 Step 3 베이스라인 태스크에서 **만들어진다**. 신규 프로젝트의 정상 흐름.

---

## Step 2 — Failure Audit (실패 패턴 감사) — 20분

> 원본: `raw/harness-engineering/harness-kit/module1/01_failure_audit_prompt.md`

**목적**: AI와 작업하면서 반복된 실수를 git log에서 찾고, **프롬프트 문제** vs **시스템 문제**로 분류해 Module 02에서 막을 재료를 모은다.

> **먼저 알아둘 것 — 이 감사의 진짜 대상은 "본인이 AI와 오래 작업해 온 실제 프로젝트"입니다.** 거기엔 반복된 revert·재발한 버그·쌓인 TODO가 git 이력에 남아 분석거리가 풍부합니다. 반면 지금 실습하는 `~/harness-playground`는 방금 만든 신규라 커밋이 3~4개뿐이고 그런 이력이 없습니다. **그래서 아래 분석을 실습 프로젝트에 돌리면 표가 거의 비는 게 정상입니다.** 여기서는 "claude 실행 → 분석 프롬프트 → 표"라는 흐름과 도구 사용법만 익히세요. 진짜 반복 패턴은 Step 3에서 직접 만들어 냅니다. 이 프롬프트를 나중에 본인 실제 프로젝트에 그대로 옮겨 돌리면 그때 진가가 드러납니다.

### Step 2-1: playground에서 Claude Code 실행

```bash
cd ~/harness-playground
claude
```

### Step 2-2: Claude가 뜨면 다음 프롬프트를 그대로 붙여넣기

```
이 Node 프로젝트의 git 이력을 분석해서, 내가 AI 에이전트와 작업하며
반복된 실수 패턴이 있는지 찾아줘.
(반복 이력이 거의 없는 신규 프로젝트면 "특이 패턴 없음"이라고 솔직히 말해줘.)

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

반복 패턴이 있으면 시스템 문제를 우선순위로 표시해줘 (없으면 "없음"으로 끝내도 됨).
```

### Step 2-3: 받은 표를 본인 메모에 저장

Claude가 출력한 표를 복사해서 `.claude/failure-audit.md`에 임시로 저장 (Step 5에서 합칠 것). **실습이라 표가 비거나 "특이 패턴 없음"이어도 그대로 저장하면 됩니다** — Step 5에서 Before/After를 비교할 때 출발선 기록이 됩니다.

```bash
# 임시로
cat > .claude/failure-audit.md << 'EOF'
# Failure Audit — 2026-MM-DD

(Claude가 출력한 표 붙여넣기)
EOF
```

### 참고 — 실제 프로젝트라면 이런 표가 나온다

아래는 **AI와 오래 작업한 실제 프로젝트**에서 흔히 잡히는 패턴입니다. 실습 playground는 이력이 없어 대부분 빈 표가 정상이지만, 본인 프로젝트에 옮겨 돌리면 이런 식으로 나옵니다:

| 문제 | 반복 횟수 | 분류 | 해결 방법 |
|------|-----------|------|-----------|
| `.env` 파일을 실수로 commit | 1회 | **시스템** | `.gitignore` + guard.sh로 `.env` 수정 차단 |
| DB 모델을 API 응답에 그대로 노출 | 4회 | **시스템** | CLAUDE.md 금지 규칙 + DTO/스키마 변환 |
| 테스트 없이 새 라우트 추가 | 6회 | **시스템** | 자기검증 루프 (Jest 실행 강제) |
| `console.log(process.env.SECRET)` 잔존 | 3회 | **시스템** | guard.sh로 차단 + lint 규칙 |
| 사용 안 하는 npm 패키지가 누적 | 2회 | 프롬프트 | "필요한 것만 설치" 규칙 |
| `try/catch`로 에러 묻기 (silent fail) | 5회 | 시스템 | ESLint 규칙 + CLAUDE.md |

### Step 2 체크리스트

- [ ] `claude` 실행 → 분석 프롬프트 → 표 출력까지 흐름을 한 번 돌려봤는가?
- [ ] (실습) 표가 비거나 1~2개여도 **정상** — 그대로 다음 Step으로.
- [ ] `.claude/failure-audit.md`에 저장했는가?
- [ ] (선택·본인 실제 프로젝트에 적용 시) 시스템 문제 3개 이상을 CLAUDE.md 규칙·guard.sh 후보로 뽑았는가?

> **빈 표가 나와도 정상**: playground는 커밋이 3~4개뿐이라 감사 결과가 빈약할 수밖에 없다. 진짜 반복 패턴은 Step 3에서 일부러 모호한 요청을 던져 **직접 만들어 낸다**.

```bash
git add .claude/failure-audit.md
git commit -m "harness(M1): 초기 실패 패턴 감사"
```

---

## Step 3 — 베이스라인 측정 — 30분

> 원본: `raw/harness-engineering/harness-kit/module1/02_baseline_prompt.md` (Node 친화로 치환)

**목적**: 하네스 적용 **전** 에이전트 성능을 수치로 기록. Module 05에서 After와 비교해서 효과 확인.

**중요**: 이 Step은 `CLAUDE.md`도 hooks도 **없는 상태**에서 진행. Claude의 "맨몸 성능"을 본다.

실습 대상: 이미 만들어진 `~/harness-playground` (api/ + web/). 별도 셋업 불필요.

각 태스크 후 결과를 `git commit`으로 남겨 Module 5에서 diff 비교 가능하게 한다.

### 태스크 A — 모델에 필드 추가 (10분)

Claude Code (playground 루트에서) 에 **그대로 붙여넣기**:

```
[베이스라인 측정 중 — CLAUDE.md, hooks 없음. 평소처럼 작업해줘]

이 모노레포에 User에 'phone' 필드를 추가해줘.
- api/: POST /users 와 GET /users 응답에 phone 포함
- 형식 검증 (010-XXXX-XXXX 또는 +82-...)
- 필수 항목 (없으면 400)
- web/: 추가 폼에 phone 입력, 목록에 phone 표시
- 가능하면 api 테스트도
```

**완료 후 측정 (체크박스 손으로)**:

```
[태스크 A]
□ 내부 모델(in-memory users)을 API 응답에 그대로 노출했는가? (Y/N) ________
□ 입력 검증을 Zod 스키마로 했는가, 아니면 직접 if문으로? ________
□ api 테스트 작성/수정했는가? (Y/N) ________
□ 요청 안 한 코드(다른 라우트, 미사용 import, 리팩터링) 추가 줄 수: ________ 줄
□ 완료까지 주고받은 메시지 횟수: ________ 회
□ Claude가 가정을 먼저 말했는가? (Y/N) ________
□ 화면이 실제로 작동하는지 확인했는가? (Y/N) ________
```

```bash
git add -A
git commit -m "baseline(M1-A): User에 phone 필드 추가 (하네스 없이)"
```

### 태스크 B — 새 조회 API (10분)

```
[베이스라인 측정 중]

GET /users 에 다음을 추가해줘:
- q 쿼리 파라미터로 이름 부분 검색 (대소문자 무시)
- 페이징: limit (기본 20), offset (기본 0)
- 응답을 { total, items } 형태로 변경
- web/: 검색 input과 페이징 버튼 추가
```

```
[태스크 B]
□ 기존 GET /users 응답 시그니처를 깨뜨렸는가? (배열 → 객체) (Y/N) ________
□ web/이 새 응답 형식에 맞게 수정됐는가? (Y/N) ________
□ 요청 안 한 정렬/필터 기능 추가했는가? (Y/N) ________
□ 기존 코드를 "개선" 한답시고 수정했는가? (Y/N) ________
□ 페이징 경계값(limit=0, offset 음수) 처리했는가? (Y/N) ________
□ 완료까지 메시지 횟수: ________ 회
```

```bash
git add -A
git commit -m "baseline(M1-B): GET /users 검색·페이징 추가 (하네스 없이)"
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

```bash
git add -A
git commit -m "baseline(M1-C): 빈 phone 검증 버그 수정 (하네스 없이)"
```

### Step 3 체크리스트

- [ ] 태스크 A·B·C **모두 실행**했는가? (각 태스크 후 커밋했는가?)
- [ ] 측정 시트를 손으로 채웠는가?
- [ ] `git log`로 3개 커밋(M1-A, M1-B, M1-C)이 보이는가? (Module 5의 diff 비교 기준)

---

## Step 4 — baseline.md 저장 — 5분

위 측정 결과를 `.claude/baseline.md` 한 파일로 합쳐서 저장한다.

```bash
cat > .claude/baseline.md << 'EOF'
# 하네스 적용 전 베이스라인 — 2026-MM-DD

## 측정 환경
- 프로젝트: harness-playground (api + web)
- Node 버전: ____________
- Claude Code 버전: ____________
- CLAUDE.md 적용 여부: ❌ 없음
- hooks 적용 여부: ❌ 없음
- 베이스라인 커밋 범위: M1-A, M1-B, M1-C (git log 참고)

---

## Failure Audit 결과 (Step 2)

(Claude가 출력한 표 붙여넣기)

---

## 태스크 A — User phone 필드 추가 (api + web)
- 내부 모델 직접 노출: __
- Zod 스키마로 검증: __
- api 테스트 작성: __
- web 화면 동작 확인: __
- 불필요한 코드 추가 줄 수: __
- 메시지 횟수: __
- 가정 명시 여부: __

## 태스크 B — GET /users 검색·페이징 ({total,items} 변경)
- 기존 응답 시그니처 깸: __
- web이 새 형식에 맞게 수정: __
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

git add .claude/baseline.md
git commit -m "harness(M1): 베이스라인 측정 결과 저장"
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

위 표를 본인 결과에 맞게 채웠으면, Step 4에서 만든 `.claude/baseline.md` 맨 아래에 이어 붙인다. (`>>`는 기존 내용을 지우지 않고 뒤에 덧붙인다.)

```bash
cat >> .claude/baseline.md << 'EOF'

---

## Module 02로 넘길 시스템 문제 우선순위 (Step 5)

| 우선순위 | 시스템 문제 | Module 02에서 옮길 곳 | 향후 module 03 hook 가능? |
|---------|------------|---------------------|--------------------------|
| 1 | (채우기) | STOP: ____________ | ✅ / ⚠️ |
| 2 | (채우기) | STOP: ____________ | ✅ / ⚠️ |
| 3 | (채우기) | STOP: ____________ | ✅ / ⚠️ |
EOF

git add .claude/baseline.md
git commit -m "harness(M1): Module 02 입력용 시스템 문제 우선순위 정리"
```

### Step 5 체크리스트

- [ ] 시스템 문제 상위 3~5개를 우선순위 표로 골라냈는가?
- [ ] `.claude/baseline.md` 맨 아래에 우선순위 표를 추가했는가?
- [ ] 커밋했는가? (`git log`에 마지막 커밋이 보이는가?)

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
| git commit (`harness(M1): 베이스라인 측정 결과 저장` + `baseline(M1-A/B/C)`) | 추적 시작점 | Module 5에서 diff 가능 |

---

## 다음 단계

▶ [[guide-harness-module2]] — CLAUDE.md 작성. Step 5에서 골라낸 시스템 문제들을 **STOP 트리거**로 옮긴다.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 환경 셋업 + 용어 사전
- [[src-harness-engineering]] — 전체 커리큘럼
- [[concept-harness-engineering]] — 마구 비유, 시대 진화, 4원칙
- [[guide-harness-module2]] — 다음 모듈
- [[guide-harness-module5]] — Before/After 비교 시점
