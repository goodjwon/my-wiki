---
title: 하네스 엔지니어링 실습 키트
type: source
tags:
  - harness
  - claude-code
  - ai-agent
  - ddd
  - spring-boot
sources:
  - harness-engineering/
  - harness-engineering/harness_engineering.md
  - harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md
  - harness-engineering/harness-engineering-tutor-prompt.md
  - harness-engineering/harness-kit/
created: 2026-05-30
updated: 2026-05-30
---

# 하네스 엔지니어링 실습 키트

> Karpathy CLAUDE.md × OpenAI Harness Engineering × Mitchell Hashimoto
> Spring Boot DDD 프로젝트에 하네스 엔지니어링을 적용하는 5모듈 커리큘럼.

## 개요

AI 에이전트(Claude Code 등)에게 "잘 해줘"라고 부탁(프롬프트)하는 대신, **잘못된 일을 구조적으로 못 하게 만드는 시스템(하네스)** 을 갖추는 방법론. 자료는 슬라이드 덱(PDF) + 튜터 프롬프트(MD) + 5모듈 실습 키트(harness-kit/) + 강의 교안(DOCX)로 구성.

핵심 주장:
> "모델을 탓하기 전에 하네스를 점검하라" — Mitchell Hashimoto

## 세 가지 핵심 소스

| 소스                      | 층위     | 질문               | 산출물                                                                                          |
| ----------------------- | ------ | ---------------- | -------------------------------------------------------------------------------------------- |
| **Karpathy CLAUDE.md**  | 선언 층   | 에이전트에게 무엇을 기대하는가 | 4원칙 (Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution)      |
| **OpenAI Harness Eng.** | 인프라 층  | 어떤 환경을 만드는가      | Context Engineering · Architectural Constraints · Entropy Management · Lifecycle Scaffolding |
| **Mitchell Hashimoto**  | 피드백 루프 | 어떻게 진화시키는가       | "실패할 때마다 시스템을 엔지니어링하라" — 실패를 규칙으로, 규칙을 코드로                                                   |

## 시대 진화

- **2023**: 단발 지시 (프롬프트 시대)
- **2025**: 맥락 설계 (컨텍스트 엔지니어링 시대)
- **2026**: 환경 설계 (하네스 엔지니어링 시대)

OpenAI 5개월 실험 사례: 100만 줄 코드를 생성했지만 인간이 작성한 코드는 0줄이었다. **병목은 모델이 아니었다 — 환경이었다.**

## 5모듈 커리큘럼 로드맵

| 모듈 | 주제 | 이론 | 실습 |
|------|------|------|------|
| **01** | 왜 프롬프트로는 부족한가 | 등장 배경, 마구(Harness) 비유, "절대 하지 마"가 실패하는 이유 | 실패 패턴 감사(Failure Audit), 베이스라인 측정, CLAUDE.md 초안 |
| **02** | CLAUDE.md — 에이전트 헌법 | Karpathy 4원칙, 절대 금지 트리거 | Spring Boot DDD용 CLAUDE.md 작성, Before/After 비교 |
| **03** | Claude Code Hooks | 라이프사이클 이벤트, guard.sh, lint-fix.sh, Back-pressure | Hooks 설정 구현, 자기검증 루프, Hooks 진화 |
| **04** | 멀티 에이전트 + 컨텍스트 설계 | 컨텍스트 방화벽, 3-tier 인프라, Critic 패턴, AGENTS.md | Planner/Coder/Critic 워크플로우, 세션 인계 프로토콜 |
| **05** | 하네스 진화 — 실패를 자산으로 | 엔트로피 관리, Drift 방지, Rippable Harness | 하네스 저장소 구조화, 주간 리뷰, Rippable 점검 |

자세한 개념 분리:
- [[concept-harness-engineering]] — 마구 비유, 시대 진화, 핵심 원칙 4가지
- [[concept-claude-md]] — Karpathy 4원칙 + STOP 트리거
- [[concept-claude-hooks]] — guard.sh / lint-fix.sh 시스템 강제
- [[concept-multi-agent-pattern]] — Planner/Coder/Critic 3-tier

모듈별 실습 가이드:
- [[guide-harness-module1]] — Failure Audit + 베이스라인 측정
- [[guide-harness-module2]] — CLAUDE.md 초안 + Before/After 비교
- [[guide-harness-module3]] — Hooks 설정 + 차단 검증 + 자기검증 루프
- [[guide-harness-module4]] — Planner/Coder/Critic 워크플로우 + 세션 인계
- [[guide-harness-module5]] — 저장소 구조화 + 주간 리뷰 + Rippable 점검

## 실습 키트 디렉토리 구조

```
harness-kit/
├── module1/  — 왜 프롬프트로는 부족한가
│   ├── 01_failure_audit_prompt.md     # 실패 패턴 감사
│   └── 02_baseline_prompt.md          # 베이스라인 측정
├── module2/  — CLAUDE.md 에이전트 헌법
│   ├── CLAUDE.md                      # ★ Spring Boot DDD용 템플릿
│   ├── 01_draft_claude_md_prompt.md
│   └── 02_before_after_prompt.md
├── module3/  — Claude Code Hooks
│   ├── guard.sh                       # ★ Pre-Tool Hook: 위험 명령 차단
│   ├── lint-fix.sh                    # ★ Post-Tool Hook: 자동 포맷
│   ├── hooks-config.json              # ★ Hooks 설정 파일 예시
│   ├── 01_hooks_setup_prompt.md
│   └── 02_self_verify_prompt.md
├── module4/  — 멀티 에이전트
│   ├── AGENTS.md                      # ★ Planner/Coder/Critic 역할 정의
│   ├── task-list.md                   # 태스크 목록 템플릿
│   ├── claude-progress.txt            # 세션 인계 파일 템플릿
│   └── 01_threettier_workflow_prompt.md
└── module5/  — 하네스 진화
    ├── weekly-harness-review.md       # 주간 리뷰 템플릿
    ├── 01_repo_and_rippable_prompt.md
    └── 02_weekly_review_prompt.md
```

## 빠른 시작 (Quick Start)

```bash
# 1. 베이스라인 측정
#    module1/02_baseline_prompt.md 열기 → 태스크 A,B,C 하네스 없이 실행 후 기록

# 2. CLAUDE.md 배포
cp raw/harness-engineering/harness-kit/module2/CLAUDE.md <프로젝트루트>/
git commit -m "feat: add CLAUDE.md agent constitution"

# 3. Hooks 설치
mkdir -p .claude/hooks
cp raw/harness-engineering/harness-kit/module3/guard.sh .claude/hooks/
cp raw/harness-engineering/harness-kit/module3/lint-fix.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
# hooks-config.json 내용을 .claude/settings.json에 머지

# 4. 멀티 에이전트 구조
cp raw/harness-engineering/harness-kit/module4/{AGENTS.md,task-list.md,claude-progress.txt} <프로젝트루트>/

# 5. 주간 루틴
#    매주 금요일 module5/02_weekly_review_prompt.md 실행
#    → 발견된 패턴을 CLAUDE.md + guard.sh에 추가 → git commit
```

## 핵심 원칙 (Summary)

| # | 원칙 | 핵심 메시지 |
|---|------|-----------|
| 1 | **부탁 대신 구조** | 프롬프트는 부탁이다. guard.sh가 막으면 에이전트는 못 한다. |
| 2 | **실패가 규칙이 된다** | 같은 실수 두 번 → 즉시 CLAUDE.md 추가. "다음엔 잘 해줘"는 없다. |
| 3 | **검증 가능한 목표** | `[단계] → verify: [확인법]`. 성공 기준이 없으면 에이전트도 멈춘다. |
| 4 | **하네스는 자산이다** | CLAUDE.md + hooks + skills = 팀이 쌓는 경쟁 우위. 모델이 바뀌어도 남는다. |

## 참고 자료

- Karpathy CLAUDE.md — https://github.com/forrestchang/andrej-karpathy-skills
- OpenAI Harness Engineering — https://openai.com/index/harness-engineering/
- Mitchell Hashimoto 블로그 — https://mitchellh.com
- Claude Code Hooks 공식 문서 — https://docs.anthropic.com/claude-code/hooks

## 원본 파일 위치

`raw/harness-engineering/` 디렉터리. 자세한 자료 구성과 추천 읽기 순서는 `raw/harness-engineering/README.md` 참고.

| 파일 | 용도 |
|------|------|
| `raw/harness-engineering/harness_engineering.md` | 슬라이드 압축본 (10페이지 한눈에) |
| `raw/harness-engineering/harness_engineering.pdf` | PDF 원본 |
| `raw/harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md` | 강의 해설 + 용어 + 이론 (가장 풍부) |
| `raw/harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.docx` | DOCX 원본 |
| `raw/harness-engineering/harness-engineering-tutor-prompt.md` | LLM 튜터 진행 프롬프트 |
| `raw/harness-engineering/harness-kit/` | 5모듈 실습 키트 (템플릿·스크립트) |

## 관련 페이지

- [[concept-harness-engineering]] — 하네스 엔지니어링 개념
- [[concept-claude-md]] — CLAUDE.md 에이전트 헌법
- [[concept-claude-hooks]] — Claude Code Hooks
- [[concept-multi-agent-pattern]] — Planner/Coder/Critic 패턴
- [[guide-project-docs-setup]] — 프로젝트 문서 시스템 셋업 (CLAUDE.md 템플릿)
- [[src-kakaopay-ddd]] — DDD 도입 사례 (Module 02 CLAUDE.md의 도메인 모델링 근거)
- [[concept-spring-core]] — Spring 코어 (DDD 실습 대상 스택)
