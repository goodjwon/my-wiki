---
title: Advisor–Worker 에이전트 스크립트 (판단·구현 분리)
type: source
tags: [claude-code, multi-agent, subagent, harness, delegation]
sources: [ai-advisor/]
created: 2026-07-06
updated: 2026-07-06
---

# Advisor–Worker 에이전트 스크립트 (판단·구현 분리)

## 개요

Claude Code에서 **메인 세션(Advisor)이 판단·설계·검증을 맡고, 구현 노동은 서브에이전트(Worker)에게 위임**하는 2-역할 협업 모델의 스크립트 세트입니다. 감리자가 도면을 읽고 지시서를 쓰고 시공 결과를 검측한 뒤 준공 도장을 찍는 비유로 역할을 나눕니다. `claude --agent advisor`로 세션 전체를 Advisor로 실행합니다.

| 역할 | 담당 | 모델 | 원본 파일 |
|------|------|------|-----------|
| **Advisor** | 요구사항 분석 · 작업 분해 · 설계 결정 · 브리프 작성 · 검증 · 커밋 승인 · 사용자 보고 | Fable 5 (`claude-fable-5`) | raw/ai-advisor/advisor_script.md |
| **Worker** | 코드 작성·수정 · 테스트 작성 등 구현 노동 · 자체 검증 · 구조화 보고 | Opus 4.8 (`claude-opus-4-8`) | raw/ai-advisor/worker_script.md |

프로젝트 지침 템플릿(raw/ai-advisor/claude_script.md)은 이 모델을 프로젝트 `CLAUDE.md`에 심는 버전입니다. 자료 구성은 raw/ai-advisor/README.md 참조.

## 에이전트 정의 — frontmatter로 역할·모델 고정

역할별 모델과 도구를 `.claude/agents/*.md`의 frontmatter에 고정합니다. Worker에게는 `Task`를 주지 않아 재위임을 구조적으로 차단하고, Advisor에게는 `Write`를 주지 않아 구현 노동을 구조적으로 막습니다.

```yaml
# .claude/agents/advisor.md — 판단 역할
name: advisor
tools: Read, Grep, Glob, Bash, Edit, Task   # Write 없음 — 사소한 마무리는 Edit만
model: claude-fable-5

# .claude/agents/worker.md — 실행 역할
name: worker
tools: Read, Write, Edit, Bash, Glob, Grep  # Task 없음 — 재위임 불가
model: claude-opus-4-8
```

함정: `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수가 설정돼 있으면 Worker의 frontmatter 모델 지정을 덮어쓰므로 비워 둡니다.

## 작업 브리프 형식 — 위임의 핵심 인터페이스

Advisor가 Worker에게 주는 지시서는 항상 6개 항목을 채웁니다. Worker가 재탐색하지 않도록 Advisor가 이미 파악한 컨텍스트를 담는 것이 요점입니다.

```
[목표]      한 문장. 무엇을 만들/고칠 것인가.
[컨텍스트]  관련 파일 경로. 이미 파악한 구조·도메인 모델·관계.
[컨벤션]    이 프로젝트의 규칙 — 네이밍, 레이어, 패턴, 보안/세션 방식 등.
[함정]      알려진 주의점. 밟으면 안 되는 지뢰. 과거에 깨진 지점.
[완료 기준] 통과해야 할 테스트/명령어와 기대 동작. (검증 기준선 = 최종 목표)
[범위 경계] 건드리지 말 것. 이번 작업에서 제외할 것.
```

## 검증 게이트 — "완료" 보고를 믿지 않는다

Advisor의 승인 절차가 이 모델의 안전판입니다.

1. `git diff`로 **변경을 직접 읽는다** — 범위 밖 변경, 몰래 낀 리팩터링, 빠진 부분 확인.
2. 완료 기준 테스트/빌드/린트를 **직접 재실행한다** — Worker가 돌렸다고 해도 다시 돌린다.
3. 실패하면 직접 고치지 않고 **수정 브리프로 재위임**한다. 예외는 오타·임포트 누락 같은 사소한 마무리와, 브리프 작성이 더 비싼 한두 줄 수정뿐.
4. 커밋은 검증 통과분만. `git commit`은 Advisor의 몫이고 Worker는 작업 트리만 변경한 채 둔다.

Worker 쪽 규율이 게이트를 받칩니다: 보고 전 완료 기준 명령을 직접 실행하고, 변경 요약 / 검증(명령·PASS·FAIL·핵심 출력) / 가정·블로커 / 브리프 대비 이탈의 4절 형식으로 검증 가능한 사실만 보고합니다.

## 같은 인사이트 패턴 — 역할 분리 멀티 에이전트 비교

| | Advisor–Worker (이 소스) | Planner / Coder / Critic ([[concept-multi-agent-pattern]]) |
|---|---|---|
| 역할 수 | 2 (판단 / 실행) | 3 (계획 / 구현 / 검증) |
| 검증 주체 | Advisor가 diff·테스트 직접 재실행 | 독립 Critic이 APPROVE / CONDITIONAL REJECT 판정 |
| 거부 신호 | 검증 실패 → 수정 브리프 재위임 | CONDITIONAL REJECT / REJECT |
| 모델 배치 | 역할별 이종 모델 (판단 Fable 5, 구현 Opus 4.8) | 동일 모델 또는 모델 교차 검증 (Claude + Codex) |
| 위임 인터페이스 | 6항목 작업 브리프 | task-list.md 원자 태스크 (ID·복잡도·verify) |
| 구조적 강제 | frontmatter tools 제한 (Worker에 Task 없음) | AGENTS.md 역할 규정 |

두 패턴 모두 [[concept-loop-engineering]]의 **"루프 안의 거부 신호"** 를 구현합니다 — Advisor의 검증 게이트와 Critic의 REJECT는 같은 자리의 다른 형태입니다. "브리프에 컨텍스트를 담아 재탐색을 막는" 규율은 [[concept-multi-agent-pattern]]의 컨텍스트 방화벽(서브에이전트가 결과만 반환)과 짝을 이루고, 부탁 대신 tools 제한으로 역할을 강제하는 방식은 [[concept-harness-engineering]]의 핵심 원칙입니다.

## 원본 출처

- raw/ai-advisor/advisor_script.md — Advisor 에이전트 정의
- raw/ai-advisor/worker_script.md — Worker 에이전트 정의
- raw/ai-advisor/claude_script.md — 프로젝트 CLAUDE.md 템플릿
- raw/ai-advisor/README.md — 자료 구성·읽기 순서

## 관련 페이지

- [[guide-advisor-worker-demo]] — 이 모델을 데모 프로젝트에서 직접 실행하는 실습
- [[concept-multi-agent-pattern]] — 3-tier(Planner/Coder/Critic) 패턴과의 비교
- [[concept-harness-engineering]] — 부탁 대신 구조(tools 제한·게이트)로 제어하는 상위 개념
- [[concept-loop-engineering]] — 검증 게이트 = 루프 안의 거부 신호
- [[concept-claude-md]] — 협업 모델을 프로젝트 CLAUDE.md에 심는 방식
