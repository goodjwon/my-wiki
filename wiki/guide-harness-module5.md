---
title: 하네스 Module 05 — 진화·주간 리뷰·Rippable (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, module5, weekly-review, rippable, drift, node, step-by-step]
sources:
  - harness-engineering/harness-kit/module5/weekly-harness-review.md
  - harness-engineering/harness-kit/module5/01_repo_and_rippable_prompt.md
  - harness-engineering/harness-kit/module5/02_weekly_review_prompt.md
created: 2026-05-31
updated: 2026-05-31
---

# 하네스 Module 05 — 진화·주간 리뷰·Rippable

> **이 가이드 보기 전에**: [[guide-harness-module4]] 까지 완료. CLAUDE.md + hooks + AGENTS.md가 모두 작동 중이어야 합니다.

**이 모듈에서 얻을 것**:
1. 정리된 `.claude/` 구조 + README 온보딩 섹션
2. **첫 주간 리뷰** (`weekly-review-2026-MM-DD.md`)
3. **Rippable 점검** — 불필요해진 규칙 식별
4. **Module 01 ↔ Module 05 Before/After 비교** — 5모듈 효과 수치 확인

**시간**: 약 1시간 (구조화 20분 + 주간 리뷰 20분 + Rippable 10분 + Before/After 10분). **이후 매주 30분/회 반복**.

**핵심 인식**: 하네스는 만든 순간이 정점이 아니다. 매주 진화해야 산다. 규칙은 **더하기만 하는 게 아니라 빼기도 한다** (Rippable).

이론 배경: [[concept-harness-engineering]] (Rippable 섹션)

---

## Step 1 — 저장소 구조 정리 — 15분

지금까지 만든 파일을 한 번에 점검:

```bash
# 현재 상태
find . -maxdepth 2 -name "CLAUDE.md" -o -name "AGENTS.md" \
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

```bash
cat >> .gitignore << 'EOF'

# Claude Code 개인 캐시 (있다면)
.claude/cache/

# 세션 인계 — 팀 공유면 추적, 개인용이면 ignore
# claude-progress.txt
EOF
```

| 파일 | 권장 |
|------|------|
| `CLAUDE.md`, `AGENTS.md`, `task-list.md` | ✅ git 추적 (팀 공유) |
| `.claude/hooks/*.sh`, `.claude/settings.json` | ✅ git 추적 (팀 공통 하네스) |
| `.claude/baseline.md`, `.claude/critic-log.md` | ✅ git 추적 (역사) |
| `claude-progress.txt` | 팀 공유: 추적 / 개인용: `.gitignore` |

---

## Step 2 — README.md에 온보딩 섹션 추가 — 10분

```bash
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
git commit -m "docs: add Claude Code harness onboarding section"
```

---

## Step 3 — 첫 주간 리뷰 — 20분

### Step 3-1: 실패 패턴 수집 (Claude에게 위임)

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

```bash
WEEK=$(date '+%Y-%m-%d')
cat > .claude/weekly-review-$WEEK.md << 'EOF'
# 주간 하네스 리뷰 — $WEEK

기간: ____ ~ $WEEK

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
```diff
+ 추가:
- 제거:
~ 수정:
```

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
- [ ] 다음 리뷰: $WEEK + 7일
EOF
```

### Step 3-3: 새 규칙 적용 + 커밋

```bash
# CLAUDE.md 섹션 7과 .claude/hooks/guard.sh 수정 후
git add CLAUDE.md .claude/hooks/guard.sh .claude/weekly-review-*.md
git commit -m "harness: weekly review $WEEK - add N new rules

- [규칙 1 요약]
- [규칙 2 요약]"
```

---

## Step 4 — Rippable 점검 — 10분

> 모델이 좋아져서 이미 자연스럽게 지키는 규칙은 **버린다**. 하네스 군살 빼기.

### Step 4-1: Claude에게 분석 요청

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

```bash
# Claude가 권고한 규칙을 CLAUDE.md / guard.sh에서 제거
git add CLAUDE.md .claude/hooks/guard.sh
git commit -m "harness: ripple unused rules (Rippable cleanup)

Removed (4주 위반 0회):
- [규칙 1]
- [규칙 2]

Kept (위반 0회지만 안전장치):
- [규칙 3]"
```

> 처음 점검에서는 보통 삭제할 게 적다 (하네스가 아직 어림). **3개월 이상 운영 후 진가 발휘**.

---

## Step 5 — Module 01 ↔ Module 05 Before/After 비교 — 10분

5모듈 누적 효과를 수치로 본다.

### Step 5-1: Module 01의 베이스라인 태스크 재실행

`.claude/baseline.md`의 태스크 A·B·C를 **현재 상태(CLAUDE.md + hooks + AGENTS.md 모두 적용)** 로 재실행.

새 세션에서 (Module 1과 동일한 표현으로):

```
User 모델에 'phone' 필드를 추가해줘.
- 형식 검증 (010-XXXX-XXXX 또는 +82-...)
- 필수 항목 (없으면 400)
- POST /users 와 GET /users 응답에 반영
- 가능하면 테스트도
```

자기검증 루프가 자동 작동. 검증 완료 보고까지 확인.

### Step 5-2: 비교 표 작성

```bash
cat >> .claude/baseline.md << 'EOF'

---

## Module 05 After — 5모듈 누적 적용 후 (2026-MM-DD)

### 태스크 A 비교
| 항목 | M1 Before | M2 After | M5 After (5모듈) | 누적 개선 |
|------|----------|---------|----------------|----------|
| DB 모델 노출 | __ | __ | __ | __ |
| 마이그레이션 처리 | __ | __ | __ | __ |
| 테스트 작성 | __ | __ | __ | __ |
| 불필요한 코드 (줄) | __ | __ | __ | __ |
| 메시지 횟수 | __ | __ | __ | __ |
| guard.sh 차단 횟수 | 0 | 0 | __ | __ |
| Critic CONDITIONAL REJECT 횟수 | — | — | __ | __ |

### 5모듈 종합 효과
- 가장 큰 변화: ____________
- 여전히 부족한 부분: ____________
- 다음 주간 리뷰 우선 항목: ____________
EOF

git add .claude/baseline.md
git commit -m "harness: M1 vs M5 before/after comparison"
```

---

## Step 6 — 주간 루틴 캘린더 등록 — (1분)

매주 금요일 30분 블록 캘린더에 추가:
- 제목: "하네스 주간 리뷰"
- 반복: 매주 금요일
- 알림: 30분 전
- 메모: `.claude/weekly-review-YYYY-MM-DD.md` 작성 + 커밋

> 루틴을 캘린더에 박지 않으면 **2~3주 후 잊혀진다**. 이건 module5의 가장 중요한 산출물.

---

## 막힐 때 (Module 5 전용 FAQ)

### Q. 첫 주간 리뷰에서 실패 패턴이 잘 안 나와요
- 일주일이 짧으면 다음 주에 더 명확해진다.
- 의도적으로 베이스라인 태스크를 다시 던져 보라 (Module 01의 태스크 A·B·C).
- guard.sh 차단 로그를 별도 파일에 남기도록 수정하면 분석이 쉬워짐:
  ```bash
  # guard.sh의 block() 함수에 추가
  echo "$(date '+%Y-%m-%d %H:%M') BLOCKED: $1 — $COMMAND" >> .claude/guard-blocked.log
  ```

### Q. Rippable 점검에서 삭제할 게 없어요
정상. 하네스가 아직 새로워서 모든 규칙이 살아있다. **3개월쯤 후 다시** 점검하면 분명 나온다.

### Q. Module 05 After가 Module 01 Before와 거의 같아요 (효과가 미미)
가능성:
1. 하네스가 동작 안 함 — `.claude/settings.json`의 hooks 등록 다시 확인
2. CLAUDE.md를 Claude가 안 읽음 — 세션 시작 시 "CLAUDE.md 섹션 7 STOP 첫 3개 인용해줘" 테스트
3. 베이스라인 태스크가 너무 쉬워서 모델이 원래 잘 함 — 더 까다로운 태스크로 비교

### Q. 주간 리뷰가 부담돼요 (30분도 어렵다)
처음에는 10분만이라도. 핵심은 **새 STOP 트리거 1개 추가 + 1개 평가**. 형식보다 지속이 중요.

### Q. 팀원이 하네스 안 따르고 우회해요 (`--no-verify`로 hook 무시 등)
- 정책적으로 PR 리뷰 단계에서 차단
- guard.sh에 `git commit.*--no-verify` 차단 추가 (자기 차단)
- 결국은 문화 문제 — 하네스가 **도움이 됨**을 데이터로 보여주는 게 답

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

5개 모듈을 다 거쳤지만 **여기서 끝이 아니다**. Module 05의 진짜 산출물은 **매주 30분 주간 리뷰 루틴**이다. 한 달이면 4번, 1년이면 50번 — 1년 후의 CLAUDE.md는 지금과 완전히 다를 것이고 **본인 프로젝트 고유의 자산**이 된다.

> "모델을 탓하기 전에 하네스를 점검하라" — Mitchell Hashimoto

자가 점검 3가지를 매주 묻는다:
- CLAUDE.md가 이번 주의 실패를 반영하는가?
- Hooks가 새 위험을 차단하는가?
- 피드백 루프(주간 리뷰)가 돌고 있는가?

세 질문 모두 "그렇다"면, 모델을 이야기할 자격이 생긴다.

## 관련 페이지

- [[guide-harness-module1]] — Before 비교 기준 (baseline.md)
- [[guide-harness-module2]] / [[guide-harness-module3]] / [[guide-harness-module4]] — 진화 대상
- [[concept-harness-engineering]] — Drift, Rippable, Opus 4.6 사례
- [[src-harness-engineering]] — 전체 커리큘럼
- [[guide-project-docs-setup]] — 프로젝트 문서 시스템 (하네스와 별개로 보강)
