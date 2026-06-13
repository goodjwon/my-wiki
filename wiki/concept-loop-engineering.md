---
title: Loop 엔지니어링 — 사람을 시스템으로 대체하기
type: concept
tags: [loop-engineering, harness, ai-agent, react-pattern, claude-code]
sources: [loop-engineering/loop-engineering-notes.md]
created: 2026-06-13
updated: 2026-06-13
---

# Loop 엔지니어링 (Loop Engineering)

## 정의

**에이전트에게 프롬프트를 입력하는 '당신 자신'을 시스템으로 대체**하는 일. 사람이 매번 프롬프트를 타이핑하는 게 아니라, 에이전트를 반복적으로 구동시키는 프로그램(루프) 자체를 설계한다.

> **주방 비유**
> 기존 프롬프팅: 요리사에게 "이 요리 만들어줘" 매번 주문.
> Loop 엔지니어링: 주방 시스템 자체 설계 — 주문 → 재료 확인 → 조리 → 맛 검증 → 실패 시 재시도 → 서빙. 사람 개입 없이 사이클이 돈다.

## 직전 패러다임과의 차이

| 시기 | 패러다임 | 설계 단위 | 사람이 매번 하는 일 |
|------|----------|-----------|----------------------|
| 초기 | 프롬프트 | 단어·문장 | 더 좋은 한 줄 지시 |
| 2025 | 컨텍스트 ([[concept-claude-md]]) | 입력 공간 | 시스템 프롬프트·RAG·메모리 설계 |
| 2026 초 | 하네스 ([[concept-harness-engineering]]) | 환경 | CLAUDE.md·hooks·skills 설계 |
| **2026 중** | **Loop** | **메커니즘 그 자체** | **루프(코드) 작성 — 프롬프트는 그 안에서 자동 생성** |

인간 노력의 '단위'가 **단어 → 컨텍스트 → 환경 → 메커니즘** 한 단계씩 올라간다.

## 폭발 계기 — 2026-06

| 날짜 | 인물 | 발언 |
|------|------|------|
| 2026-06-08 | Peter Steinberger (X) | "이제 코딩 에이전트에 프롬프트를 입력하지 말고, 에이전트에게 프롬프트를 주는 루프를 설계해야 한다" — **650만 조회** |
| 2026-06 | Boris Cherny (Claude Code 책임자) | "내 일은 개별 프롬프트가 아니라 루프를 작성하는 것" |
| 2026-06 | Addy Osmani | 초기 단계·회의적, **토큰 비용 절대 주의** |

자세한 인용·맥락은 [[src-loop-engineering]].

## 골격 — ReAct 패턴의 확장

대부분의 현대 에이전트 루프는 **Princeton + Google의 ReAct(Reason + Act)** 패턴에 뿌리를 둔다.

```
[행동(Act)] → [환경 피드백(Observe)] → [추론(Reason)] → [다음 행동]
                              ↑              │
                              └──────────────┘
                          종료 조건까지 반복
```

종료 조건(작업 완료·중단 트리거)이 충족될 때까지 사이클이 돈다.

## 좋은 Loop가 답해야 할 4가지 설계 질문

| # | 질문 | 나쁜 루프 | 좋은 루프 |
|---|------|-----------|-----------|
| 1 | 에러를 어떻게 다루는가 | 첫 줄만 읽고 짐작 | 스택 트레이스 전체 읽고 추론 |
| 2 | 컨텍스트를 어떻게 유지하는가 | 매 시도마다 백지에서 다시 | 8번 전 실패를 기억해 같은 길 안 감 |
| 3 | 작업 범위를 어떻게 정하는가 | 거대 태스크를 통째로 시도 | 분해 → 단위 태스크 → 검증 → 다음 |
| 4 | 출력을 어떻게 검증하는가 | 컴파일 통과 = 완료 | 실제 동작 확인 (테스트·실행) |

→ 1·3은 [[concept-multi-agent-pattern]]의 Planner/Coder, 2는 [[concept-claude-md]]의 컨텍스트 인계, 4는 [[concept-claude-hooks]]의 back-pressure로 일부 구현됨.

## 핵심 통찰 — "아니오라고 말할 무언가"

> 루프 설계의 절반은 사이클 자체. **나머지 절반은 루프 안에 거부할 수 있는 무언가(테스트·타입 체크·실제 에러)를 넣는 것**.
> 밀어내는 게 없는 루프 = 에이전트가 자기 자신에게 반복해서 동의하는 메아리방.

이게 Loop 엔지니어링의 가장 강한 한 줄.

### 같은 인사이트 패턴 — "거부 신호 없는 자동화는 폭주한다"

| 영역 | 폭주 시나리오 | 거부 메커니즘 | 참조 |
|------|---------------|---------------|------|
| **AI 루프** | 검증 없이 LLM이 자기 출력에 동의 → 메아리방 | 테스트·타입체크·실제 에러를 루프 안에 | (이 페이지) |
| **Hooks** | 에이전트가 위험 명령 자유 실행 → 사고 | `guard.sh` 종료 코드 1 → 도구 실행 차단 | [[concept-claude-hooks]] |
| **멀티 에이전트** | 단일 에이전트 자기검증 → 통과 편향 | Critic의 `CONDITIONAL REJECT` / 모델 교차 검증 (Claude+Codex 3라운드) | [[concept-multi-agent-pattern]] |
| **선언 층** | 부정 명령("하지 마") 잊힘 | STOP 트리거 → 명시적 중단 조건 | [[concept-claude-md]] |
| **크론잡** | 잡이 끝났는지 확인 없이 `concurrencyPolicy: Forbid`만 걸어 무한 적체 | `activeDeadlineSeconds` + 실제 종료 신호 | [[concept-cronjob-concurrency-trap]] |
| **LB ↔ 서버** | Keep-Alive 타임아웃 일치 가정, 종료 신호 없음 → 502 race | LB 타임아웃 < 서버 타임아웃, FIN 명시 | [[concept-keepalive-timeout-race]] |

→ **공통 원리**: 자동 사이클·자동 호출에는 반드시 **밀어내는 신호(reject·timeout·exit code)** 가 짝지어 있어야 한다. 신호 없는 루프는 폭주한다.

## 위키의 기존 자산이 Loop 엔지니어링에 어떻게 매핑되는가

| Loop 설계 요소 | 위키 자산 | 역할 |
|---------------|-----------|------|
| 종료 조건 정의 | [[concept-claude-md]] STOP 트리거 | 무엇이 끝인지 명시 |
| 사이클 단위 분해 | [[concept-multi-agent-pattern]] Planner | task-list.md의 원자 단위 태스크 |
| 한 사이클 실행 | [[concept-multi-agent-pattern]] Coder | verify 기준 충족까지 한 태스크만 |
| 거부 신호 | [[concept-multi-agent-pattern]] Critic | `APPROVE` / `CONDITIONAL REJECT` |
| 도구 호출 차단 | [[concept-claude-hooks]] PreToolUse | guard.sh |
| 검증 자동화 | [[concept-claude-hooks]] PostToolUse | lint-fix.sh, `./gradlew test` |
| 진화·드리프트 관리 | [[concept-harness-engineering]] Rippable 점검 | 4주 위반 0건이면 규칙 삭제 |

→ 새로 만들 게 많지 않다. 이미 흩어져 있던 조각이 "메커니즘 그 자체" 라는 단어 하나로 묶이는 셈.

## 비용 — 신중론

Addy Osmani: 토큰 비용에 **절대적으로 주의**. 토큰이 넉넉한지 부족한지에 따라 사용 패턴이 크게 달라짐.

| 단계 | 사람의 토큰 비용 | 모델의 토큰 비용 |
|------|------------------|------------------|
| 프롬프트 | 매번 사람이 입력 → 적음 | 1회 호출 |
| 컨텍스트 | 시스템 프롬프트 1회 설계 | 매 호출마다 컨텍스트 전송 |
| 하네스 | 환경 1회 설계 | 매 호출마다 hook + 컨텍스트 |
| **Loop** | **루프 1회 설계** | **사이클 1회당 N회 호출 (반복·재시도 포함)** |

→ 사람 비용은 줄지만, 모델 비용은 폭증. [[src-copilot-token-pricing]]의 종량제 전환(2026-06-01)과 정확히 같은 시점에 터진 게 우연이 아니다.

## 도메인 모델링 관점의 시작점

> 종료 조건(무엇이 목표 달성인가)을 먼저 정의 → 거기서부터 거꾸로 루프를 짠다.

체크리스트:

- [ ] 이 루프의 **종료 조건**은 무엇인가? (verify로 표현 가능한가?)
- [ ] 루프 안에 **거부할 수 있는 무언가**가 있는가? (테스트·타입체크·에러)
- [ ] 한 사이클이 **얼마나 비싸진가** (토큰)? 상한은?
- [ ] **재시도 횟수 상한**과 그때의 **다음 행동**은?
- [ ] 사이클이 **8번 전 실패를 기억**하는가, 아니면 같은 길을 다시 가는가?
- [ ] 사이클 결과가 **사람에게 어디서·어떻게** 보고되는가?

## 빠른 진단

- "프롬프트를 더 잘 쓰면 될 것 같다" → 아직 1세대. 컨텍스트·하네스부터.
- "에이전트가 같은 실수를 반복한다" → 거부 메커니즘 부재 (메아리방).
- "에이전트가 한 번 잘 됐다가 다음에 망친다" → 종료 조건이 verify가 아닌 자기보고.
- "토큰 비용이 예측 불가" → 사이클 비용·상한·재시도 정책 미설계.

## 한계·미해결

- **다이어그램·표준 구현 없음**: 2026-06 시점 개념만 풀린 상태. Steinberger도 저장소 링크 없이 두 문장만 던졌음.
- **종료 조건의 일반화 어려움**: 단순 함수는 unit test가 verify지만, 디자인·리서치 태스크는 verify를 어떻게 만들지가 열린 문제.
- **모델 비용 폭증 위험**: 종량제 전환과 맞물려 비용 통제가 새 1순위 과제.

## 원본 출처

- `raw/loop-engineering/loop-engineering-notes.md` — 박정원이 외부 AI 어시스턴트에게 전달받은 정리본 (2026-06-13)
- 원전(Peter Steinberger X, Boris Cherny 발언, Addy Osmani 글, ReAct 논문) 직접 확보는 후속 과제

## 관련 페이지

- [[src-loop-engineering]] — 출처·인용 정리
- [[concept-harness-engineering]] — 직전 단계 (환경 설계)
- [[concept-claude-md]] — 선언 층 / STOP 트리거
- [[concept-claude-hooks]] — back-pressure가 "거부할 수 있는 무언가" 의 구현
- [[concept-multi-agent-pattern]] — Critic이 거부 메커니즘의 또 다른 구현
- [[src-copilot-token-pricing]] — 토큰 비용 폭증 위험
- [[concept-cronjob-concurrency-trap]] — 인프라 영역의 같은 "거부 신호 없는 폭주" 패턴
- [[concept-keepalive-timeout-race]] — 인프라 영역의 같은 "종료 신호 가정" 패턴
