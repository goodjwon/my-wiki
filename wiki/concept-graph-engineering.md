---
title: 그래프 엔지니어링 — 제어 흐름을 노드·엣지로 명시하기
type: concept
tags: [graph-engineering, ai-agent, langgraph, orchestration, harness]
sources: [ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md]
created: 2026-08-10
updated: 2026-08-10
---

# 그래프 엔지니어링 (Graph Engineering)

## 정의

그래프 엔지니어링은 **단일 에이전트에게 업무 전체를 맡기는 대신, 프로세스를 명확한 책임의 노드(Node)로 쪼개고 이동 규칙인 엣지(Edge)를 방향 그래프로 설계**하는 접근법입니다. 작업 실행은 에이전트 노드에 맡기되, 작업 간 이동·실패 복구 경로·최대 재시도 같은 **제어 흐름은 코드로 명시**합니다.

한 문장으로: 하나의 만능 AI에게 종합 예술을 요구하는 대신, **명확한 직무를 가진 팀원들로 조직도를 짜는 일**입니다.

## 진화 계보 — Loop의 다음 단계

[[concept-loop-engineering]]의 패러다임 표를 한 단계 연장합니다.

| 시기 | 패러다임 | 설계 단위 | 남는 문제 |
|------|----------|-----------|-----------|
| 초기 | 프롬프트 | 단어·문장 | 단일 호출로 다단계 논리 불가 |
| 2025 | 컨텍스트 ([[concept-claude-md]]) | 입력 공간 | 입력을 채워도 단일 추론의 벽 |
| 2026 초 | 하네스 ([[concept-harness-engineering]]) | 환경 | 환경 규칙도 결국 단일 루프 위 |
| 2026 중 | Loop ([[concept-loop-engineering]]) | 메커니즘(사이클) | **단일 책임 엔티티 = 블랙박스** |
| **다음** | **그래프** | **제어 흐름 구조 (노드·엣지)** | 오버엔지니어링 위험 (아래 판단 기준) |

Loop가 "사이클을 누가 돌리는가"를 시스템으로 바꿨다면, 그래프는 **그 사이클 내부의 책임과 경로를 해체해 구조로 명시**합니다. 결과물이 틀렸을 때 "검색 노드가 쿼리를 잘못 만들었는지, 검증 노드가 생략됐는지"를 노드 단위로 추적할 수 있게 됩니다.

## 4대 구성 요소

| 요소 | 정의 | 실무 대응물 |
|------|------|------------|
| 노드(Node) | 작업 수행 단위 — LLM 호출 또는 일반 함수 | "시장 조사 LLM 호출", "URL 개수 세는 Python 함수" |
| 스테이트(State) | 그래프 전체에서 공유되는 구조화 상태 | TypedDict·Pydantic Model — 단일 진실 원천 |
| 엣지(Edge) | 노드 간 이동 경로 (고정/조건부) | "생성 끝나면 무조건 검증으로" |
| 컨디션(Condition) | 조건부 엣지의 판단 함수 | "점수 80 미만 + 재시도 3회 미만 → 루프백" |

각 노드는 전체 맥락을 알 필요 없이 자기 입력만 처리해 스테이트를 갱신합니다. 책임 격리가 곧 테스트 가능성입니다.

```python
def should_retry(state: State) -> str:
    # 하드 제약 — LLM이 아닌 코드가 100% 강제
    if state["score"] >= 80 or state["retries"] >= 3:
        return "done"
    return "generate"

graph.add_conditional_edges("evaluate", should_retry,
                            {"generate": "generate", "done": END})
```

전체 실행 가능한 골격은 [[src-graph-engineering]]의 LangGraph 예제를 참조합니다.

## 4가지 설계 패턴과 적용 시나리오

| 패턴 | 언제 쓰는가 | 구조 |
|------|------------|------|
| 라우터(Router) | 요청 범주별로 전용 프롬프트·도구가 다를 때 | 분류 노드 → 특화 노드 분기 |
| 병렬 실행(Parallelization) | 의존성 없는 하위 조사·수집 작업 | 동시 실행 → Join 노드 취합 |
| 평가자-생성자(Evaluator-Optimizer) | 품질 루브릭이 명문화 가능할 때 | 생성 → 채점 → 미달 시 피드백과 함께 루프백 |
| 사용자 승인(Human-in-the-Loop) | 결제·발행 등 비가역 액션 직전 | Interrupt로 상태 보존 정지 → 승인/거부 |

## 핵심 설계 철학 — 하드 규칙은 코드, 소프트 판단은 LLM

| 구분 | 담당 | 예시 | 근거 |
|------|------|------|------|
| 하드 제약 | 코드가 강제 | 최소 개수·재시도 상한·URL 검증·예산 한도 | LLM은 확률 모델 — 프롬프트 지시를 무시하고 종료 가능 |
| 소프트 판단 | LLM에 위임 | 분위기 분석·정성 요약·설득력 비교 | 정답이 없는 영역은 코드로 못 씀 |

원문의 권장 비율은 **코드 80% : LLM 20%** 입니다. 루프 탈출 조건·실행 횟수·형식 검증까지 전부 코드로 묶고, 창의적 추론에만 LLM 노드를 배정합니다.

### 같은 인사이트 패턴 — "규칙을 확률 모델에 맡기지 말고 구조로 강제한다"

| 영역 | 부탁(프롬프트) 방식 | 구조 강제 방식 | 참조 |
|------|--------------------|---------------|------|
| **그래프** | "최대 3회만 재시도해" 지시 | 컨디션 함수의 `retries >= 3` | (이 페이지) |
| 하네스 | "위험 명령 하지 마" 부탁 | CLAUDE.md·hooks 환경 설계 | [[concept-harness-engineering]] |
| Hooks | 에이전트 자율 판단 | `guard.sh` 종료 코드로 도구 차단 | [[concept-claude-hooks]] |
| Loop | 자기보고 "완료했습니다" | 테스트·타입체크가 거부 신호 | [[concept-loop-engineering]] |
| Advisor–Worker | 역할 지시문만 | frontmatter `tools` 제한·검증 게이트 | [[concept-advisor-worker]] |

→ 공통 원리: **확률 모델의 준수 의지를 믿지 말고, 어길 수 없는 층(코드·환경·권한)에 규칙을 내립니다.** 그래프 엔지니어링은 이 원리를 "제어 흐름" 차원까지 확장한 것입니다.

## 위키 기존 자산과의 매핑

| 그래프 요소 | 위키 자산 | 비고 |
|------------|-----------|------|
| 노드 분할 | [[concept-multi-agent-pattern]] Planner/Coder/Critic | 역할 분리는 이미 실천 중 — 그래프는 전이 규칙까지 코드화 |
| 최소 그래프 | [[concept-advisor-worker]] | Advisor→Worker→검증 게이트 = 2노드 + 조건부 엣지 |
| 평가자-생성자 루프 | [[concept-multi-agent-pattern]] Critic의 `CONDITIONAL REJECT` | 루프백 엣지의 프롬프트 구현판 |
| 컨디션·하드 제약 | [[concept-claude-hooks]] guard.sh | 종료 코드 = 조건부 엣지의 환경 구현판 |
| Human-in-the-Loop | Claude Code 권한 승인 대화 | 위험 도구 호출 전 사용자 확인과 동형 |
| 스테이트 전이 협력 | [[concept-domain-event-eventual-consistency]] | 도메인 이벤트 = 백엔드 세계의 같은 구조 (노드 간 직접 참조 대신 신호) |

→ 새로 배울 것보다 **이미 흩어져 있던 실천이 "그래프"라는 형식으로 명명**되는 쪽에 가깝습니다.

## 오버엔지니어링 경계 — 도입 판단 기준

| 신호 | 판정 |
|------|------|
| 단순 요약·Q&A·도구 호출 1~2회로 종결 | 그래프 불필요 — 프롬프트·기본 루프로 충분 |
| 다단계 하위 작업 + 병렬 처리 필요 | 도입 후보 |
| 실패 시 특정 이전 단계로 선택적 복구(Rollback & Retry) | 도입 후보 |
| 결제·발행 등 사람 승인 필수 지점 존재 | 도입 후보 |
| 상태 영속화로 중간 지점 재개 필요 | 도입 후보 |

시작은 **라우터 + 특화 노드 2개** 수준의 최소 그래프부터. 처음부터 10노드 그래프를 그리면 디버깅이 불가능합니다.

## 빠른 진단

- "에이전트 결과가 틀렸는데 어디서 틀렸는지 모르겠다" → 단일 블랙박스 — 노드 분할 신호.
- "프롬프트에 '반드시 3회만'이라고 썼는데 안 지킨다" → 하드 제약을 코드로 내릴 시점.
- "간단한 요약 작업인데 그래프 프레임워크부터 골랐다" → 오버엔지니어링 — 단일 호출로 회귀.
- "실패하면 처음부터 다시 돈다" → 선택적 복구 엣지 부재.

## 원본 출처

- raw: `raw/ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md`
- 정리: [[src-graph-engineering]]

## 관련 페이지

- [[src-graph-engineering]] — 원문 구조·LangGraph 실행 골격
- [[concept-loop-engineering]] — 직전 단계 (사이클 설계) — 이 페이지는 그 사이클의 내부 해체
- [[concept-harness-engineering]] — "부탁 대신 구조" 원리의 시작점
- [[concept-multi-agent-pattern]] — 노드 분할의 선행 실천 (Planner/Coder/Critic)
- [[concept-advisor-worker]] — 최소 그래프의 실전 구현
- [[concept-claude-hooks]] — 컨디션의 환경 층 구현
- [[concept-domain-event-eventual-consistency]] — 백엔드 도메인의 같은 구조 (직접 참조 대신 신호·상태 전이)
