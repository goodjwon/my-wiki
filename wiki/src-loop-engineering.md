---
title: Loop 엔지니어링 (2026-06 커뮤니티 발화)
type: source
tags: [loop-engineering, harness, ai-agent, claude-code, react-pattern]
sources:
  - loop-engineering/loop-engineering-notes.md
  - loop-engineering/primary-sources.md
external:
  - https://addyosmani.com/blog/loop-engineering/
  - https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/
created: 2026-06-13
updated: 2026-06-29
---

# Loop 엔지니어링 — 2026-06 커뮤니티 발화 정리

## 출처

최초 입력은 외부 AI 어시스턴트가 전달한 **2차 정리본**(2026-06-13): `raw/loop-engineering/loop-engineering-notes.md`. 이후 2026-06-29에 **1차 출처를 직접 검증**해 `raw/loop-engineering/primary-sources.md`에 보존했다(아래 표의 출처·교정 반영).

## 무엇이 일어났는가

| 날짜 | 인물 | 발언 | 출처 검증 |
|------|------|------|----------|
| 2026-06-08* | Peter Steinberger (X, **OpenAI**) | "더 이상 코딩 에이전트에 프롬프트를 입력하지 말고, 에이전트에게 프롬프트를 주는 루프를 설계하라" | ⚠️ [X 원문](https://x.com/steipete/status/2063697162748260627) 402로 직접검증 불가, 인용은 다수 2차 매체 일치 |
| 2026-06 | Boris Cherny (Anthropic, Claude Code) | "내 일은 개별 프롬프트가 아니라 루프를 작성하는 것" | ⚠️ [Acquired](https://www.youtube.com/watch?v=RkQQ7WEor7w) (게시 06-02 / 에피소드 날짜 미확정), 자구는 매체별 편차 |
| **2026-06-07** | Addy Osmani | 미래의 방식일 수 있지만 초기 단계·회의적, **토큰 비용 절대 주의** | ✅ [블로그 원문](https://addyosmani.com/blog/loop-engineering/) 직접 확인 — 용어 명명 1차 글 |
| 2026-06-11 | Sonar (P. Sarkar) | "검증 없는 루프는 단순 자동화" · "A failing build is a fact" | ✅ [블로그 원문](https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/) 직접 확인 |

> *Steinberger 게시물은 "2026-06-08·**650만 조회수**"로 회자됐으나, 이 날짜·조회수는 **2차 매체 주장이며 X 원본에서 직접 검증되지 않았다**. 본인은 Anthropic이 아니라 OpenAI 소속(OpenClaw 제작자). 다이어그램·저장소 링크 없이 개념만 던져진 채 일주일간 논쟁거리가 됨.

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

## 신중론 (Addy Osmani) — 검증된 원문 인용

- **토큰 비용에 절대적으로 주의**: *"you absolutely have to be careful about token costs (usage patterns can vary wildly if you are token rich or poor)"*
- **검증 책임은 여전히 사람에게**: *"Verification is still on you. A loop running unattended is also a loop making mistakes unattended."*
- **서브에이전트는 토큰을 더 태운다**: *"spend them where a second opinion is worth paying for."*
- 비용 폭증 경고는 [[src-copilot-token-pricing]]의 종량제 전환 맥락과 직결

## 골격 — ReAct 패턴의 확장

> 행동 → 환경 피드백 → 다음 행동 결정 → 종료 조건 충족까지 반복.
> 대부분의 현대 에이전트 루프는 **Princeton + Google의 ReAct(Reason + Act)** 패턴에 뿌리.

## 외부 1차 출처 (2026-06-29 검증)

검증 상세·교정 체크리스트: `raw/loop-engineering/primary-sources.md`

| 출처 | URL | 상태 |
|------|-----|------|
| Addy Osmani — Loop Engineering (용어 명명) | https://addyosmani.com/blog/loop-engineering/ | ✅ 직접 확인 |
| Sonar — verification 없는 루프 = 자동화 | https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/ | ✅ 직접 확인 |
| ReAct (Yao et al. 2022) | https://arxiv.org/abs/2210.03629 | ✅ |
| Reflexion (Shinn et al. 2023) | https://arxiv.org/abs/2303.11366 | ✅ |
| Self-Refine (Madaan et al. 2023) | https://arxiv.org/abs/2303.17651 | ✅ |
| Steinberger (X) | https://x.com/steipete/status/2063697162748260627 | ⚠️ 402, 2차 매체로 교차확인 |
| Cherny (Acquired) | https://www.youtube.com/watch?v=RkQQ7WEor7w | ⚠️ 자구·날짜 매체별 편차 |

## 관련 페이지

- [[concept-loop-engineering]] — 개념 정리·설계 질문·메아리방 패턴
- [[concept-harness-engineering]] — 직전 단계 (환경 설계)
- [[concept-claude-hooks]] — back-pressure가 "거부할 수 있는 무언가"의 구현
- [[concept-multi-agent-pattern]] — Critic이 거부 메커니즘의 다른 형태
- [[src-copilot-token-pricing]] — 토큰 종량제와 비용 폭증 위험
- [[src-harness-engineering]] — 하네스 5모듈 커리큘럼
