# HARNESS ENGINEERING — 하네스 엔지니어링 실습 커리큘럼

**슬라이드 덱 본문 (10페이지)**

Karpathy × OpenAI × Mitchell Hashimoto
세 소스를 통합한 5모듈 이론 + 실습 과정

- 원본: `harness_engineering.pdf` (10 슬라이드)
- 상세 강의 해설은 [`하네스엔지니어링_슬라이드해설_강의교안.md`](하네스엔지니어링_슬라이드해설_강의교안.md) 참조

---

## 슬라이드 1 · 표지

> **하네스 엔지니어링 실습 커리큘럼**
>
> Karpathy × OpenAI × Mitchell Hashimoto
> 세 소스를 통합한 5모듈 이론 + 실습 과정

세 출처 배지: Karpathy CLAUDE.md · OpenAI Harness Eng. · Mitchell Hashimoto
오른쪽 모듈 번호: 01 · 02 · 03 · 04 · 05

---

## 슬라이드 2 · 세 가지 핵심 소스

| 출처 | 층위 | 질문 | 키워드 |
|------|------|------|--------|
| **Karpathy CLAUDE.md** | 선언 층 | 에이전트에게 무엇을 기대하는가 | 4원칙: Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution |
| **OpenAI Harness Eng.** | 인프라 층 | 어떤 환경을 만드는가 | Context Engineering · Architectural Constraints · Entropy Management · Lifecycle Scaffolding |
| **Mitchell Hashimoto** | 피드백 루프 | 어떻게 진화시키는가 | "실패할 때마다 시스템을 엔지니어링하라" — 실패를 규칙으로, 규칙을 코드로 |

---

## 슬라이드 3 · 5모듈 커리큘럼 로드맵

이론 설명 + 프로젝트에 직접 적용 실습.

| 모듈 | 제목 | 부제 |
|------|------|------|
| 01 | 왜 프롬프트로는 부족한가 | 등장 배경 + 베이스라인 측정 |
| 02 | CLAUDE.md 에이전트 헌법 | Karpathy 4원칙 적용 |
| 03 | Hooks — 시스템 강제 | guard.sh + 자기검증 루프 |
| 04 | 멀티 에이전트 — 컨텍스트 설계 | Planner / Coder / Critic |
| 05 | 하네스 진화 — 실패를 자산으로 | 엔트로피 관리 + Drift 방지 |

각 모듈은 **이론 + 실습** 한 쌍 구조.

---

## 슬라이드 4 · Module 01 — 왜 프롬프트로는 부족한가

하네스 엔지니어링의 등장 배경과 핵심 개념. 출처: Hashimoto · OpenAI · Karpathy.

### 이론

- **프롬프트 → 컨텍스트 → 하네스 진화** — 2023 단발 지시 / 2025 맥락 설계 / 2026 환경 설계
- **말(AI)과 마구(Harness) 비유** — "절대 하지 마" 프롬프트가 왜 실패하는가
- **Hashimoto 원칙** — "실패할 때마다 시스템을 엔지니어링하라"
- **OpenAI 5개월 실험** — 100만 줄 코드, 인간 코드 0줄. 환경이 병목이었다.

### 실습

- **실패 패턴 감사 (Failure Audit)** — 현재 Claude Code 작업에서 반복되는 실수 3가지 찾기. "프롬프트로 막을 수 있는가 vs 시스템으로 막아야 하는가" 분류.
- **베이스라인 측정** — 하네스 없이 에이전트에게 태스크 3개 맡겨보기. 성공률·불필요한 변경·방향 이탈 기록.
- **CLAUDE.md vs AGENTS.md 비교** — 두 파일의 차이와 언제 쓸지 이해, 프로젝트에 맞는 기본 골격 작성.

---

## 슬라이드 5 · Module 02 — CLAUDE.md 에이전트 헌법 작성

Karpathy 4원칙을 Spring Boot DDD 프로젝트에 적용 (학습자 스택에 맞춰 치환).

### 이론

- **Think Before Coding** — 가정 명시 / 혼란 숨기지 말기 / 더 단순한 방법 먼저 말하기
- **Simplicity First** — 요청된 것만. 200줄이 50줄이면 다시 써라.
- **Surgical Changes** — 내 변경이 만든 orphan만 정리. 기존 dead code는 언급만.
- **Goal-Driven Execution** — `[단계] → verify: [확인법]` 형식. 성공 기준을 먼저 정의하라.

### 실습

- **CLAUDE.md 초안 작성** — Karpathy 4원칙 + 프로젝트 스택 규칙 통합. 절대 금지 트리거(migration 삭제, Entity 직접 노출 등) 포함. 500줄 이하 유지.
- **Before / After 비교** — CLAUDE.md 적용 전후로 동일 태스크 실행. diff 크기와 불필요한 변경 횟수 비교.
- **실패 패턴 → 규칙 변환** — 모듈 1에서 찾은 실패 패턴을 CLAUDE.md 금지 규칙으로 전환.

---

## 슬라이드 6 · Module 03 — Claude Code Hooks, 시스템 레벨 강제

프롬프트를 '부탁'에서 '구조'로 — 에이전트 라이프사이클 제어. 출처: Hashimoto · OpenAI.

### 이론

- **에이전트 라이프사이클 이벤트** — 세션 시작 / 도구 실행 전·후 / 응답 완료 시점에 셸 스크립트 주입
- **guard.sh — 위험 명령 차단** — Bash 실행 전 → `rm -rf`, `DROP TABLE`, migration 수정 등 필터링
- **lint-fix.sh — 자동 포맷 복구** — 파일 수정 후 스타일 규칙 위반 시 자동 checkstyle 실행
- **Back-pressure 메커니즘** — 타입체크, 테스트, 커버리지를 에이전트 자기검증 도구로 연결

### 실습

- **Hooks 설정 구현** — `guard.sh` + `lint-fix.sh` 작성, Claude Code hooks 설정 파일에 연결, 차단 테스트.
- **자기검증 루프 구축** — `./gradlew test` 결과를 에이전트 검증에 포함, 실패 시 스스로 수정.
- **Hooks 진화 실습** — 새 실패를 `guard.sh` 규칙으로 추가.

---

## 슬라이드 7 · Module 04 — 멀티 에이전트 + 컨텍스트 설계

Planner / Coder / Critic 3-tier 구조와 컨텍스트 방화벽. 출처: OpenAI.

### 이론

- **컨텍스트 방화벽으로서의 서브에이전트** — 프론트/백 분리가 아니라 컨텍스트 윈도우 오염 방지가 목적
- **3-tier 컨텍스트 인프라** — CLAUDE.md(전역) / 스킬 파일(태스크) / claude-progress.txt(세션)
- **Critic 에이전트 패턴** — Claude + Codex 3라운드 토론 → CONDITIONAL REJECT 권한
- **AGENTS.md — 모델 불가지론적 표준** — CLAUDE.md를 넘어 어떤 모델이든 읽을 수 있는 공용 표준

### 실습

- **3-tier 워크플로우 설계** — `task-list.md` 기반 Planner-Coder-Critic 워크플로우, 실제 태스크로 드라이런.
- **세션 인계 프로토콜** — `claude-progress.txt` + `git log` 기반 상태 복원, 새 컨텍스트에서 5초 안에 상태 파악.
- **Critic 에이전트 실습** — 구현 계획을 Critic에게 보여주고 원칙 위반 검증, CONDITIONAL REJECT 처리 흐름.

---

## 슬라이드 8 · Module 05 — 하네스 진화, 실패를 자산으로

엔트로피 관리와 지속적 개선 루프 확립. 출처: OpenAI · Hashimoto.

### 이론

- **하네스는 저장소에 커밋되는 자산** — 팀원·모델이 바뀌어도 CLAUDE.md + hooks + skills는 남는다.
- **엔트로피 관리 — Drift 방지** — 장기 프로젝트에서 에이전트 출력이 점점 발산하는 문제 대응.
- **과적합 함정 (Rippable Harness)** — Opus 4.6: 자기 하네스 33위 → 다른 하네스 5위권. 모델 개선 시 일부 하네스는 버려야 한다.
- **주간 하네스 리뷰 루틴** — 실패 패턴 → 규칙 추가 사이클. 매주 CLAUDE.md 한 줄 이상 추가 목표.

### 실습

- **하네스 저장소 구조화** — `.claude/` 폴더에 CLAUDE.md + hooks + skills 정리. README에 사용법, 팀 온보딩 체크리스트.
- **주간 하네스 리뷰** — 지난 1주일 실패 패턴 3개 수집, 각각 CLAUDE.md 규칙 또는 `guard.sh` 항목으로 전환.
- **Rippable 하네스 점검** — 현재 CLAUDE.md 규칙 중 모델 개선으로 불필요해진 항목 제거.

---

## 슬라이드 9 · 핵심 원칙 요약

| # | 원칙 | 설명 |
|---|------|------|
| ① | **부탁 대신 구조** | 프롬프트는 부탁이다. 시스템이 강제한다. guard.sh가 막으면 에이전트는 못 한다. |
| ② | **실패가 규칙이 된다** | 같은 실수 두 번 → 즉시 CLAUDE.md 추가. "다음엔 잘 해줘"는 없다. |
| ③ | **검증 가능한 목표** | `[단계] → verify: [확인법]`. 성공 기준이 없으면 에이전트도 멈춘다. |
| ④ | **하네스는 자산이다** | CLAUDE.md + hooks + skills = 팀이 쌓는 경쟁 우위. 모델이 바뀌어도 남는다. |

---

## 슬라이드 10 · 마무리

> **모델을 탓하기 전에 하네스를 점검하라**
> — Mitchell Hashimoto

자가 점검 3가지:
- CLAUDE.md가 무엇을 담고 있는가
- 어떤 Hooks를 설정했는가
- 피드백 루프가 있는가
