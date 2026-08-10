---
title: 그래프 엔지니어링 — 단일 LLM 한계를 넘는 설계 기법 (원문 정리)
type: source
tags: [graph-engineering, ai-agent, langgraph, multi-agent, orchestration]
sources: [ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md]
created: 2026-08-10
updated: 2026-08-10
---

# 그래프 엔지니어링 — 원문 정리

## 개요

LLM 오케스트레이션 트렌드가 프롬프트 → 컨텍스트 → 루프를 지나 **그래프 엔지니어링(Graph Engineering)** 으로 이동하고 있다는 글입니다. 복잡한 업무 전체를 단일 에이전트 루프에 몰아넣으면 어느 단계에서 환각·데이터 누락이 일어났는지 추적할 수 없는 블랙박스가 되므로, 프로세스를 **명확한 책임을 가진 노드(Node)** 로 쪼개고 이동 규칙인 **엣지(Edge)** 를 방향 그래프(Directed Graph)로 설계하자는 주장입니다.

개념 정리·기존 위키 자산과의 연결은 [[concept-graph-engineering]]에서 다룹니다. 이 페이지는 원문의 구조와 주장을 보존합니다.

## 원문의 4단계 진화 서사

| 단계 | 패러다임 | 관심사 | 한계 |
|------|----------|--------|------|
| 1 | 프롬프트 엔지니어링 | System Prompt·Few-shot 조율 | 단일 호출로 다단계 논리 불가 |
| 2 | 컨텍스트 엔지니어링 | RAG·도구·지식 텍스트 품질 | 입력을 채워도 단일 추론의 벽 |
| 3 | 루프 엔지니어링 | Plan → Act → Observe 반복 (ReAct) | 단일 책임 엔티티 = 블랙박스 |
| 4 | **그래프 엔지니어링** | 노드·엣지·스테이트로 흐름 명시 | (도입 기준 아래 참조) |

## 4대 구성 요소

| 요소 | 역할 | 원문 포인트 |
|------|------|------------|
| 노드(Node) | 개별 작업 단위 — LLM 호출 또는 일반 함수 | 한 가지 기능에만 집중 → 모듈화·단위 테스트 용이 |
| 스테이트(State) | 노드 간 전달되는 구조화 상태 (TypedDict·Pydantic) | 단일 진실 원천(Single Source of Truth), 추적·디버깅 기반 |
| 엣지(Edge) | 다음 노드 연결선 — 고정/조건부 | 실패 복구 경로·재시도를 코드로 명시 |
| 컨디션(Condition) | 조건부 엣지의 판단 규칙 | "80점 미만이면 개선 노드로" — 무한 루프 방지 |

## 4가지 설계 패턴

| 패턴 | 구조 | 효과 |
|------|------|------|
| 라우터(Router) | 의도 분류 노드 → 전용 에이전트 분기 | 토큰 절약 + 정확도 상승 |
| 병렬 실행(Parallelization) | 독립 하위 작업 동시 실행 → Join에서 취합 | 처리 시간 단축 |
| 평가자-생성자(Evaluator-Optimizer) | 생성 → 루브릭 검증 → 미달 시 루프백 | 품질 보장 루프 |
| 사용자 승인(Human-in-the-Loop) | 위험 액션 전 Interrupt로 정지·승인 대기 | 결제·발행 등 비가역 액션 안전장치 |

## 결정론 코드 vs 확률론 AI의 역할 분담

원문에서 가장 강조하는 설계 철학입니다.

| 구분 | 담당 | 예시 |
|------|------|------|
| 하드 제약(Hard Constraints) | **일반 코드가 100% 강제** | 경쟁사 최소 10개, 최대 재시도 3회, 출처 URL 검증, 예산 상한 |
| 소프트 판단(Soft Reasoning) | **LLM 노드에 위임** | 시장 분위기 분석, 정성 요약, 아이디어 설득력 비교 |

프롬프트 지시("10개 이상 찾을 것")에 규칙을 맡기면 확률 모델인 LLM이 무시하고 종료하는 일이 잦다는 것이 핵심 근거입니다.

## 오버엔지니어링 경계 — 도입 판단 기준

- **불필요**: 단순 요약·Q&A·한두 번의 도구 호출로 끝나는 작업. 그래프를 씌우면 복잡도·레이턴시·토큰만 낭비.
- **필수**: ① 다단계 하위 작업 + 병렬 처리 ② 실패 시 특정 이전 단계로 선택적 복구(Rollback & Retry) ③ 사람 개입(승인) 필수 ④ 상태 영속화(State persistence)로 중간 재개 필요 — 이 조건들이 복합될 때.

## 원문의 실행 제안 3가지

1. **에이전트가 아닌 회사 조직도를 먼저 그려라** — 리서처·작성자·검증자·관리자로 나누고 보고 체계를 엣지로.
2. **코드 80% : LLM 20% 통제 비율** — 루프 탈출 조건·실행 횟수·형식 검증은 코드로, 창의적 추론만 LLM으로.
3. **최소 그래프에서 단계적 확장** — 라우터 + 특화 노드 2개부터 작동시킨 뒤 평가·병렬 노드를 하나씩 추가.

## 대표 구현 예 — LangGraph

원문이 참고 자료로 지목한 LangGraph의 최소 골격입니다 (노드·스테이트·조건부 엣지가 코드에 어떻게 대응되는지 확인용).

```python
from typing import TypedDict
from langgraph.graph import StateGraph, END

class State(TypedDict):
    draft: str
    score: int
    retries: int

def generate(state: State) -> dict:      # LLM 노드 (소프트 판단)
    return {"draft": llm.invoke("초안 작성"), "retries": state["retries"] + 1}

def evaluate(state: State) -> dict:      # LLM 노드 (루브릭 채점)
    return {"score": grade(state["draft"])}

def should_retry(state: State) -> str:   # 컨디션 — 하드 제약은 코드가 강제
    if state["score"] >= 80 or state["retries"] >= 3:
        return "done"
    return "generate"

graph = StateGraph(State)
graph.add_node("generate", generate)
graph.add_node("evaluate", evaluate)
graph.set_entry_point("generate")
graph.add_edge("generate", "evaluate")
graph.add_conditional_edges("evaluate", should_retry,
                            {"generate": "generate", "done": END})
app = graph.compile()
```

## 원본 출처

- raw: `raw/ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md` (블로그 발행용 원고, 동일 내용 중복 파일 1건은 정리)
- 원문이 인용한 외부 자료: [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents), [LangGraph 공식 문서](https://langchain-ai.github.io/langgraph/), [LlamaIndex Workflows](https://docs.llamaindex.ai/en/stable/module_guides/workflow/)

## 관련 페이지

- [[concept-graph-engineering]] — 개념 본체 (위키 자산 매핑·패턴 비교)
- [[guide-graph-engineering-demo]] — 🧪 직접 체험하는 실습 (블랙박스 vs 그래프)
- [[concept-loop-engineering]] — 직전 단계 (원문 서사의 3단계)
- [[concept-multi-agent-pattern]] — Planner/Coder/Critic = 노드 분할의 선행 사례
- [[concept-advisor-worker]] — 2노드 + 검증 게이트의 최소 그래프
