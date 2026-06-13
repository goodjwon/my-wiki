---
title: Loop 엔지니어링 (2026-06 커뮤니티 발화)
type: source
tags: [loop-engineering, harness, ai-agent, claude-code, react-pattern]
sources: [loop-engineering/loop-engineering-notes.md]
created: 2026-06-13
updated: 2026-06-13
---

# Loop 엔지니어링 — 2026-06 커뮤니티 발화 정리

## 출처

외부 AI 어시스턴트가 박정원에게 전달한 정리본(2026-06-13). 원본 인용·발언을 그대로 보존: `raw/loop-engineering/loop-engineering-notes.md`.

원전 링크는 아직 미확보 — 후속 조사 후보로 둠.

## 무엇이 일어났는가

| 날짜 | 인물 | 발언 |
|------|------|------|
| **2026-06-08** | Peter Steinberger (X) | "이제 코딩 에이전트에 프롬프트를 입력하지 말고, 에이전트에게 프롬프트를 주는 루프를 설계해야 한다" |
| 2026-06 | Boris Cherny (Claude Code 책임자) | "내 일은 개별 프롬프트가 아니라 루프를 작성하는 것" |
| 2026-06 | Addy Osmani | 미래의 방식일 수 있지만 초기 단계·회의적, **토큰 비용 절대 주의** |

Steinberger의 두 문장이 **650만 조회수**를 기록하며 일주일 내내 논쟁거리가 됨. 다이어그램·저장소 링크 없이 개념만 던져진 상태.

## 한 줄 정의

Loop 엔지니어링은 **에이전트에게 프롬프트를 입력하는 '당신 자신'을 시스템으로 대체**하는 일.

## 비유 — 주방 시스템

| 기존 프롬프팅 | Loop 엔지니어링 |
|---------------|-----------------|
| 요리사에게 매번 "이 요리 만들어줘" 주문 | 주방 시스템 자체를 설계 |
| 1턴 인풋 → 1턴 아웃풋 | 주문 → 재료 확인 → 조리 → 맛 검증 → 실패 시 재시도 → 서빙, 사이클 자동화 |

## 패러다임 진화 — 인간 노력의 '단위'

| 시기 | 단위 | 패러다임 |
|------|------|----------|
| 초기 | 단어 | 프롬프트 엔지니어링 |
| 2025 | 컨텍스트 | 컨텍스트 엔지니어링 |
| 2026 초 | 환경 | 하네스 엔지니어링 |
| **2026 중** | **메커니즘 그 자체** | **Loop 엔지니어링** |

→ 자세한 의미·구조는 [[concept-loop-engineering]].
→ 직전 단계 비교는 [[concept-harness-engineering]].

## 핵심 통찰 (커뮤니티 댓글에서)

> "루프를 설계하는 건 절반에 불과하고, 나머지 절반은 **루프 안에 거부할 수 있는 무언가(테스트, 타입 체크, 실제 에러)를 넣는 것**이다. 밀어내는 게 없는 루프는 에이전트가 자기 자신에게 반복해서 동의하는 것에 불과하다."

→ "메아리방 패턴"으로 [[concept-loop-engineering]]에 정리.

## 신중론 (Addy Osmani)

- 초기 단계, 본인도 회의적
- **토큰 비용에 절대적으로 주의** — 토큰이 넉넉한지 부족한지에 따라 사용 패턴이 크게 달라짐
- 비용 폭증 경고는 [[src-copilot-token-pricing]]의 종량제 전환 맥락과 직결

## 골격 — ReAct 패턴의 확장

> 행동 → 환경 피드백 → 다음 행동 결정 → 종료 조건 충족까지 반복.
> 대부분의 현대 에이전트 루프는 **Princeton + Google의 ReAct(Reason + Act)** 패턴에 뿌리.

## 관련 페이지

- [[concept-loop-engineering]] — 개념 정리·설계 질문·메아리방 패턴
- [[concept-harness-engineering]] — 직전 단계 (환경 설계)
- [[concept-claude-hooks]] — back-pressure가 "거부할 수 있는 무언가"의 구현
- [[concept-multi-agent-pattern]] — Critic이 거부 메커니즘의 다른 형태
- [[src-copilot-token-pricing]] — 토큰 종량제와 비용 폭증 위험
- [[src-harness-engineering]] — 하네스 5모듈 커리큘럼
