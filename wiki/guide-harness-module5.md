---
title: 하네스 Module 05 — 진화·주간 리뷰·Rippable (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module5, weekly-review, rippable, drift, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module5/weekly-harness-review.md
  - harness-engineering/harness-kit/module5/01_repo_and_rippable_prompt.md
  - harness-engineering/harness-kit/module5/02_weekly_review_prompt.md
created: 2026-05-31
updated: 2026-07-12
---

# 하네스 Module 05 — 진화·주간 리뷰·Rippable

> **이 가이드 보기 전에**: [[guide-harness-module4]] 까지 완료. CLAUDE.md + hooks + AGENTS.md가 모두 작동 중이어야 합니다.

**왜 마지막 모듈이 리뷰·비교인가**: Module 01~04로 하네스의 부품 — 측정 기록, CLAUDE.md, hooks, 멀티 에이전트 — 은 모두 완성됐습니다. 그러나 하네스는 만든 순간이 정점이 아닙니다. 모델과 프로젝트가 바뀌는 동안 규칙은 낡아가고, 효과를 수치로 증명하지 못하면 팀을 설득할 수도 없습니다. 그래서 마지막 모듈은 새 부품 제작이 아니라 **효과를 증명하고(Before/After) 매주 갱신하는(주간 리뷰) 운영 루프**를 만듭니다. 이때 규칙은 더하기만 하는 게 아니라 **빼기도 합니다** — 모델이 이미 잘하는 일을 계속 명령하면 하네스만 무거워지기 때문입니다. 이렇게 필요 없어진 규칙을 언제든 뜯어낼 수 있게 유지하는 원칙을 **Rippable**(뜯어낼 수 있는)이라고 부릅니다.

**이 모듈에서 얻을 것**:

1. 정리된 `.claude/` 구조 + README 온보딩 섹션
2. **첫 주간 리뷰** (`weekly-review-2026-MM-DD.md`)
3. **Rippable 점검** — 불필요해진 규칙 식별
4. **Module 01 ↔ Module 05 Before/After 비교** — 5모듈 효과 수치 확인

**진행 흐름**: 하네스 자산 구조 정리(Step 1) → 신규 팀원 온보딩 문서화(Step 2) → 첫 주간 리뷰 실행(Step 3) → 불필요 규칙 빼기(Step 4) → Module 01 대비 효과 측정(Step 5) → 루틴을 캘린더에 고정(Step 6).

**시간**: 약 1시간 (구조화 20분 + 주간 리뷰 20분 + Rippable 10분 + Before/After 10분). **이후 매주 30분/회 반복**.

이론 배경: [[concept-harness-engineering]] (Rippable 섹션)

---

## Step 1 — 저장소 구조 정리 — 15분

운영 루프의 출발점은 자산 파악입니다. 네 모듈에 걸쳐 파일이 하나씩 늘어났기 때문에, 매주 리뷰에서 무엇을 갱신하고 커밋할지 헷갈리지 않으려면 전체 구조를 한 번 정돈해 둬야 합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.gitignore` 추가 항목 — 개인 캐시 제외·인계 파일 추적 여부 결정
    - **실행**: `find` 점검 명령으로 현재 파일을 확인하고, 이상적인 구조와 대조한 뒤 `.gitignore`를 갱신합니다.

지금까지 만든 파일을 한 번에 점검합니다:

```bash
cd ~/harness-playground

# 현재 상태
find . -maxdepth 3 -name "CLAUDE.md" -o -name "AGENTS.md" \
  -o -name "task-list.md" -o -name "claude-progress.txt" \
  -o -path "./.claude/*" | grep -v node_modules
```

이상적인 구조:

```
프로젝트루트/
├── CLAUDE.md              ← Module 02 (모든 세션 자동 로드)
├── AGENTS.md              ← Module 04 (멀티 에이전트)
├── task-list.md           ← Module 04 (현재 태스크)
├── claude-progress.txt    ← Module 04 (세션 인계, Stop hook 자동)
├── .claude/
│   ├── settings.json      ← Module 03 (hooks 등록)
│   ├── hooks/
│   │   ├── guard.sh           ← Module 03
│   │   ├── lint-fix.sh        ← Module 03
│   │   └── update-progress.sh ← Module 04
│   ├── baseline.md        ← Module 01 (Before)
│   ├── failure-audit.md   ← Module 01
│   └── critic-log.md      ← Module 04 (옵션)
└── README.md              ← Step 2에서 온보딩 섹션 추가
```

### .gitignore 의사결정

구조를 확인했으면 이 파일들 중 무엇을 git으로 팀과 공유하고 무엇을 개인 로컬에만 둘지 정합니다. 아래 명령으로 `.gitignore`에 개인 캐시 제외 항목을 추가해 두고, 인계 파일의 추적 여부는 이어지는 표의 권장을 따릅니다:

```bash
cat >> .gitignore << 'EOF'

# Claude Code 개인 캐시 (있다면)
.claude/cache/

# 세션 인계 — 팀 공유면 추적, 개인용이면 ignore
# claude-progress.txt
EOF
```

파일별 추적 권장입니다 — 세션 인계 파일(`claude-progress.txt`)만 팀 상황에 따라 갈립니다:

| 파일 | 권장 |
|------|------|
| `CLAUDE.md`, `AGENTS.md`, `task-list.md` | ✅ git 추적 (팀 공유) |
| `.claude/hooks/*.sh`, `.claude/settings.json` | ✅ git 추적 (팀 공통 하네스) |
| `.claude/baseline.md`, `.claude/critic-log.md` | ✅ git 추적 (역사) |
| `claude-progress.txt` | 팀 공유: 추적 / 개인용: `.gitignore` |

---

## Step 2 — README.md에 온보딩 섹션 추가 — 10분

구조를 정돈했으니 이제 그 구조를 남에게 설명할 차례입니다. 하네스는 팀 공유 자산인데, 신규 팀원이 `.claude/` 안을 스스로 해독해야 한다면 결국 하네스를 우회하게 됩니다 — README 온보딩 한 섹션이 그 진입 장벽을 없앱니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `README.md` 온보딩 섹션 — 신규 팀원용 5분 시작 가이드
    - **실행**: 아래 명령으로 섹션을 덧붙이고 `.gitignore`와 함께 커밋합니다.

````bash
cat >> README.md << 'EOF'

## 🛡️ Claude Code 하네스 (신규 팀원용)

이 프로젝트는 AI 코딩 에이전트(Claude Code)와 협업하기 위한 **하네스**가 갖춰져 있습니다.

### 첫 셋업
1. Claude Code 설치: `npm install -g @anthropic-ai/claude-code`
2. 프로젝트 루트로 이동: `cd <이 프로젝트>`
3. hook 권한: `chmod +x .claude/hooks/*.sh`
4. Claude 실행: `claude`

### 첫 세션에서 실행할 명령
```
cat CLAUDE.md          # 프로젝트 헌법
cat claude-progress.txt # 현재 상태
cat task-list.md        # 진행 태스크
```

### 핵심 파일
- `CLAUDE.md` — 코딩 규칙, STOP 트리거, 체크리스트
- `AGENTS.md` — Planner/Coder/Critic 역할
- `.claude/hooks/` — 자동 차단/포맷 스크립트
- `claude-progress.txt` — 세션 간 인계

### 주간 루틴
매주 금요일 `.claude/weekly-review-YYYY-MM-DD.md` 작성 후 PR.
EOF

git add README.md .gitignore
git commit -m "docs(M5): Claude Code 하네스 온보딩 섹션 추가"
````

---

## Step 3 — 첫 주간 리뷰 — 20분

여기서부터가 이 모듈의 본체입니다. Module 01에서 한 번 했던 실패 수집·규칙 전환을, 이번에는 매주 반복할 수 있는 고정 형식으로 굳힙니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 파일**: `.claude/weekly-review-YYYY-MM-DD.md` — 이번 주 실패·규칙 변경·효과 기록
    - **실행**: `claude` 세션에 3-1 수집 프롬프트를 붙여넣고, 결과를 3-2 템플릿에 옮긴 뒤 3-3에서 규칙 반영·커밋합니다.

주간 리뷰는 세 단계로 진행합니다. 실패 흔적을 **수집**(3-1)하고, 그 결과를 리뷰 파일에 **분류·정리**(3-2)한 뒤, 정리된 패턴을 **규칙으로 전환해 커밋**(3-3)합니다. 앞 단계의 산출물이 다음 단계의 입력이 되는 피드백 루프입니다.

### Step 3-1: 실패 패턴 수집 (Claude에게 위임)

아래 프롬프트를 `claude` 세션에 그대로 붙여넣습니다. git 이력과 Module 03에서 만든 명령 차단 hook(guard.sh)의 로그에서 실패 흔적 4종을 모으고, 규칙 전환 가능 여부(A~D)로 분류해 규칙 초안까지 뽑아 오는 위임 프롬프트입니다:

```
지난 1주일 작업 내역을 분석해서 주간 하네스 리뷰를 도와줘.

## Step 1: 실패 흔적 수집
다음 명령을 실행하고 결과 보여줘:

# 1. 수정 반복된 파일 Top 10
git log --all --oneline --since="1 week ago" --name-only --format="" \
  | sort | uniq -c | sort -rn | head -10

# 2. revert/fix/hotfix 커밋
git log --all --oneline --since="1 week ago" \
  | grep -iE "revert|fix|hotfix|rollback"

# 3. 새 TODO/FIXME
git diff HEAD~7 HEAD --diff-filter=M 2>/dev/null \
  | grep "^\+" | grep -iE "TODO|FIXME|HACK"

# 4. guard.sh 차단 로그 (있다면)
cat .claude/guard-blocked.log 2>/dev/null || echo "차단 로그 없음"

## Step 2: 분류
발견된 패턴을 4가지로 분류:
A. CLAUDE.md 규칙으로 전환 가능
B. guard.sh 차단 규칙으로 전환 가능
C. 프롬프트 개선으로 해결
D. 에이전트 한계 (허용)

## Step 3: 규칙 초안
A·B에 해당하는 패턴에 대해 구체적 규칙(코드 형태)을 작성해줘.
```

### Step 3-2: 주간 리뷰 파일 작성

위 프롬프트를 실행해 나온 실패 패턴과 분류 결과를 아래 템플릿에 옮겨 적습니다. 즉 3-1의 출력이 이 리뷰 파일의 입력이 됩니다.

````bash
# 파일명에 오늘 날짜가 자동으로 들어간다 (예: weekly-review-2026-06-26.md).
# 본문은 따옴표 heredoc(<< 'EOF')이라 아래 $COMMAND 등 예시 코드가 그대로 보존된다.
WEEK=$(date '+%Y-%m-%d')
cat > .claude/weekly-review-$WEEK.md << 'EOF'
# 주간 하네스 리뷰

기간: ____ ~ ____ (이번 주)

## 1. 이번 주 실패 사례

### 실패 1
- 언제: 
- 상황: 
- 에이전트 행동: 
- 기대 행동: 
- 분류: A / B / C / D
- 전환:
  - [ ] CLAUDE.md 섹션 7 추가
  - [ ] guard.sh 추가
  - [ ] (없음)

### 실패 2
...

## 2. CLAUDE.md 이번 주 변경

- 추가:
- 제거:
- 수정:

## 3. guard.sh 이번 주 추가 규칙
```bash
# 새 패턴
if echo "$COMMAND" | grep -qE "[패턴]"; then
  block "[이름]" "[이유]" "[대안]"
fi
```

## 4. 효과 측정

| 지표 | 지난 주 | 이번 주 | 변화 |
|------|--------|--------|------|
| 에이전트 실패 횟수 | | | |
| 불필요한 코드 변경 줄 수 | | | |
| 테스트 누락 횟수 | | | |
| 평균 태스크 완료 메시지 수 | | | |
| guard.sh 차단 횟수 | | | |

## 5. 다음 주 액션
- [ ] CLAUDE.md 업데이트 커밋
- [ ] guard.sh 업데이트 커밋
- [ ] 팀 공유 (PR)
- [ ] 다음 리뷰일: ____ (이번 주 + 7일)
EOF
````

### Step 3-3: 새 규칙 적용 + 커밋

위 리뷰 파일에 정리한 분류 A·B 패턴을 이제 실제 규칙으로 옮깁니다. Module 02에서 STOP 트리거(에이전트가 멈추고 확인을 요청해야 하는 조건) 목록으로 채운 CLAUDE.md 섹션 7과 guard.sh에 반영한 뒤, 리뷰 파일까지 함께 커밋합니다.

```bash
# CLAUDE.md 섹션 7과 .claude/hooks/guard.sh 수정 후
WEEK=$(date '+%Y-%m-%d')   # Step 3-2와 다른 셸/시점에 붙여넣어도 안전하게 재선언
git add CLAUDE.md .claude/hooks/guard.sh .claude/weekly-review-*.md
git commit -m "harness(M5): $WEEK 주간 리뷰 — 새 규칙 N개 추가

- [규칙 1 요약]
- [규칙 2 요약]

Reviewed-by: Critic Agent"
```

---

## Step 4 — Rippable 점검 — 10분

주간 리뷰(Step 3)가 규칙을 더하는 루프라면, Rippable 점검은 빼는 루프입니다. 규칙이 쌓이기만 하면 CLAUDE.md가 길어져 에이전트가 정작 중요한 규칙을 놓치기 시작하므로, 모델이 좋아져서 이미 자연스럽게 지키는 규칙은 주기적으로 걷어냅니다. 하네스 군살 빼기입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **수정 파일**: `CLAUDE.md` · `.claude/hooks/guard.sh` — 미사용 규칙 제거
    - **실행**: `claude` 세션에 아래 분석 프롬프트를 붙여넣고, 권고에 따라 규칙을 제거한 뒤 커밋합니다.

### Step 4-1: Claude에게 분석 요청

아래 프롬프트를 `claude` 세션에 붙여넣습니다. 규칙마다 지난 4주간 실제로 위반·발동된 이력을 세어, 삭제/유지 권고 표를 받아내는 분석 프롬프트입니다:

```
현재 CLAUDE.md 섹션 7과 .claude/hooks/guard.sh를 분석해서
지난 4주간 한 번도 위반·발동 안 한 규칙을 찾아줘.

## 분석 명령
1. git log --all --oneline --since="4 weeks ago"
2. cat .claude/guard-blocked.log 2>/dev/null || echo "차단 로그 없음"
3. CLAUDE.md 섹션 7과 guard.sh의 각 규칙 리스트업

## 출력 표
| 규칙 | 위치 | 지난 4주 위반 | 판단 | 권고 |
|------|------|-------------|------|------|
| 예: @Autowired 금지 | CLAUDE.md #7 | 0회 | 자연 준수 | 삭제 검토 |
| 예: .env 커밋 | guard.sh | 0회 | 한 번이라도 위반하면 큰 피해 | 유지 |

## 권고 기준
- 위반 0회 AND 모델이 자연 준수 → 삭제
- 위반 0회 BUT 큰 피해 위험 → 유지 (안전장치)

PR 형태로 삭제 권고 N개 / 유지 권고 M개 제시해줘.
```

### Step 4-2: 삭제 PR

권고 표를 검토해 받아들인 규칙만 제거합니다. 무엇을 왜 지웠고 무엇을 왜 남겼는지를 커밋 메시지에 근거로 남깁니다:

```bash
# Claude가 권고한 규칙을 CLAUDE.md / guard.sh에서 제거
git add CLAUDE.md .claude/hooks/guard.sh
git commit -m "harness(M5): 미사용 규칙 정리 (Rippable cleanup)

삭제 (지난 4주 위반 0회):
- [규칙 1]
- [규칙 2]

유지 (위반 0회지만 안전장치):
- [규칙 3]"
```

> 처음 점검에서는 보통 삭제할 게 적습니다 (하네스가 아직 어립니다). **3개월 이상 운영 후 진가를 발휘합니다**.

---

## Step 5 — Module 01 ↔ Module 05 Before/After 비교 — 10분

마지막 측정입니다. Module 01 Step 3에서 하네스 없이 태스크 A·B·C를 실행해 `.claude/baseline.md`에 Before 수치를 기록하고 `baseline(M1-A/B/C)` 커밋으로 남겨 뒀습니다. 이제 같은 유형의 태스크를 하네스가 모두 걸린 상태로 실행해 그 기록과 대조하면, 5모듈의 누적 효과가 수치로 드러납니다. Module 02가 태스크 A(phone)와 같은 요구 구조의 태스크 D(address)로 비교했던 것과 같은 방식으로, 이번에는 **태스크 E — birthDate 필드 추가**를 사용합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-playground`
    - **만들 것**: `.claude/baseline.md` 맨 아래 "Module 05 After" 비교 표 + 커밋 1개
    - **실행**: 새 `claude` 세션에 태스크 E 프롬프트를 붙여넣고 결과를 표에 채워 커밋합니다.

### Step 5-1: 태스크 E 실행 (하네스 전체 적용)

태스크 E를 **현재 상태(CLAUDE.md + hooks + AGENTS.md 모두 적용)** 로 실행합니다. playground에는 phone(M1)·address(M2) 필드가 이미 들어가 있어 같은 태스크를 재실행할 수 없고, 커밋을 revert해 출발선을 되돌리는 방식은 태스크 커밋에 CLAUDE.md·hooks 변경이 섞여 있으면 하네스까지 함께 초기화되는 함정이 있어 쓰지 않습니다 (Module 02 Step 5-1과 같은 이유). 세 측정(M1 phone · M2 address · M5 birthDate)은 태스크 본문이 아니라 **요구 구조(필드 추가·형식 검증·필수 처리·web 반영·테스트)와 측정 항목을 고정**해 비교합니다:

```
이 모노레포에 User에 'birthDate' 필드를 추가해줘.
- api/: POST /users 와 GET /users 응답에 birthDate 포함
- 형식 검증 (YYYY-MM-DD, 실존하는 날짜만 허용)
- 필수 항목 (없으면 400)
- web/: 추가 폼에 birthDate 입력, 목록에 birthDate 표시
- 가능하면 api 테스트도
```

Module 01과 달리 이번에는 Module 03 Step 7에서 CLAUDE.md 섹션 5에 추가한 자기검증 루프("완료" 선언 전 스스로 `npm test`를 실행하고 실패하면 스스로 수정)가 걸린 상태이므로, Claude가 스스로 테스트를 실행하고 **검증 완료 보고**로 마치는지까지 확인합니다.

### Step 5-2: 비교 표 작성

태스크 E 결과를 Module 01·02 때와 같은 항목으로 측정해, Before 기록이 있는 `.claude/baseline.md` 맨 아래에 이어 붙입니다. 표의 **M2 After** 열은 Module 02 Step 5에서 CLAUDE.md만 적용해 태스크 D를 실행했을 때 기록한 수치이니 baseline.md의 기존 표에서 옮겨 적습니다. 마지막 두 행은 이번에 처음 채워집니다 — guard.sh 차단은 Module 03, Critic의 CONDITIONAL REJECT(조건부 반려) 판정은 Module 04에서 생겨 이전 측정에는 없던 항목이기 때문입니다:

```bash
cat >> .claude/baseline.md << 'EOF'

---

## Module 05 After — 5모듈 누적 적용 후 (2026-MM-DD)

### 필드 추가 태스크 비교 — M1: phone / M2: address / M5: birthDate
| 항목 | M1 Before | M2 After | M5 After (5모듈) | 누적 개선 |
|------|----------|---------|----------------|----------|
| 내부 모델(in-memory) 노출 | __ | __ | __ | __ |
| Zod 스키마 검증 | __ | __ | __ | __ |
| api 테스트 작성 | __ | __ | __ | __ |
| 불필요한 코드 (줄) | __ | __ | __ | __ |
| 메시지 횟수 | __ | __ | __ | __ |
| 가정 명시 | __ | __ | __ | __ |
| 화면 작동 확인 | __ | __ | __ | __ |
| guard.sh 차단 횟수 | 0 | 0 | __ | __ |
| Critic CONDITIONAL REJECT 횟수 | — | — | __ | __ |

### 5모듈 종합 효과
- 가장 큰 변화: ____________
- 여전히 부족한 부분: ____________
- 다음 주간 리뷰 우선 항목: ____________
EOF

git add -A
git commit -m "harness(M5-E): 태스크 E — birthDate 필드 추가 + M1↔M5 비교"
```

---

## Step 6 — 주간 루틴 캘린더 등록 — 1분

도구는 다 갖췄지만, 루틴은 의지만으로 유지되지 않습니다. 매주 금요일 30분 블록을 캘린더에 추가합니다:

- 제목: "하네스 주간 리뷰"
- 반복: 매주 금요일
- 알림: 30분 전
- 메모: `.claude/weekly-review-YYYY-MM-DD.md` 작성 + 커밋

> 루틴을 캘린더에 박지 않으면 **2~3주 후 잊혀집니다**. 이건 module5의 가장 중요한 산출물입니다.

---

## 막힐 때 (Module 5 전용 FAQ)

### Q. 첫 주간 리뷰에서 실패 패턴이 잘 안 나와요

- 일주일이 짧으면 다음 주에 더 명확해집니다.
- 의도적으로 베이스라인 태스크와 같은 유형의 새 태스크(새 필드 추가 등)를 던져 보는 것도 방법입니다 (Module 01 태스크 A·B·C의 요구 구조 재사용).
- guard.sh 차단 로그를 별도 파일에 남기도록 수정하면 분석이 쉬워집니다:

```bash
# guard.sh의 block() 함수에 추가
echo "$(date '+%Y-%m-%d %H:%M') BLOCKED: $1 — $COMMAND" >> .claude/guard-blocked.log
```

### Q. Rippable 점검에서 삭제할 게 없어요
정상입니다. 하네스가 아직 새로워서 모든 규칙이 살아있습니다. **3개월쯤 후 다시** 점검하면 분명 나옵니다.

### Q. Module 05 After가 Module 01 Before와 거의 같아요 (효과가 미미)
가능성:

1. 하네스가 동작 안 함 — `.claude/settings.json`의 hooks 등록 다시 확인
2. CLAUDE.md를 Claude가 안 읽음 — 세션 시작 시 "CLAUDE.md 섹션 7 STOP 첫 3개 인용해줘" 테스트
3. 베이스라인 태스크가 너무 쉬워서 모델이 원래 잘 함 — 더 까다로운 태스크로 비교

### Q. 주간 리뷰가 부담돼요 (30분도 어렵다)
처음에는 10분만이라도 좋습니다. 핵심은 **새 STOP 트리거 1개 추가 + 1개 평가**입니다. 형식보다 지속이 중요합니다.

### Q. 팀원이 하네스 안 따르고 우회해요 (`--no-verify`로 hook 무시 등)

- 정책적으로 PR 리뷰 단계에서 차단합니다.
- guard.sh에 `git commit.*--no-verify` 차단을 추가합니다 (자기 차단).
- 결국은 문화 문제입니다 — 하네스가 **도움이 됨**을 데이터로 보여주는 게 답입니다.

---

## 산출물 정리

| 파일 | 내용 |
|------|------|
| 정돈된 `.claude/` 디렉터리 | 모든 하네스 자산 한 곳에 |
| `README.md` 온보딩 섹션 | 신규 팀원 5분 시작 가이드 |
| `.claude/weekly-review-YYYY-MM-DD.md` | 첫 주간 리뷰 (매주 추가) |
| Rippable cleanup 커밋 | 불필요 규칙 제거 |
| `.claude/baseline.md` 최종 비교 표 | 5모듈 누적 효과 수치 |

---

## 끝 — 그리고 시작

5개 모듈을 다 거쳤지만 **여기서 끝이 아닙니다**. Module 05의 진짜 산출물은 **매주 30분 주간 리뷰 루틴**입니다. 한 달이면 4번, 1년이면 50번 — 1년 후의 CLAUDE.md는 지금과 완전히 다를 것이고 **본인 프로젝트 고유의 자산**이 됩니다.

> "모델을 탓하기 전에 하네스를 점검하라" — Mitchell Hashimoto

자가 점검 3가지를 매주 묻습니다:

- CLAUDE.md가 이번 주의 실패를 반영합니까?
- Hooks가 새 위험을 차단합니까?
- 피드백 루프(주간 리뷰)가 돌고 있습니까?

세 질문 모두 "그렇다"면, 모델을 이야기할 자격이 생깁니다.

## 관련 페이지

- [[guide-harness-module1]] — Before 비교 기준 (baseline.md)
- [[guide-harness-module2]] / [[guide-harness-module3]] / [[guide-harness-module4]] — 진화 대상
- [[concept-harness-engineering]] — Drift, Rippable, Opus 4.6 사례
- [[src-harness-engineering]] — 전체 커리큘럼
- [[guide-project-docs-setup]] — 프로젝트 문서 시스템 (하네스와 별개로 보강)
