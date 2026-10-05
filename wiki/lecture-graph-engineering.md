---
title: 그래프 엔지니어링 강의 노트 — 입문 수강생용
type: synthesis
tags: [graph-engineering, ai-agent, lecture, 강의, langgraph, claude-code]
sources:
  - ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md
  - ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md
created: 2026-10-05
updated: 2026-10-05
---

# 그래프 엔지니어링 강의 노트 — 입문 수강생용

> **한 줄 요약**: 일을 한 AI에게 통째로 맡기지 말고 **단계(노드)로 나누고, 다음 단계로 넘어가는 규칙(엣지)을 코드로 강제**하면, 규칙을 어긴 결과가 "완료"로 나가는 일이 사라지고 어느 단계에서 막혔는지가 기록으로 남습니다.

이 페이지는 [[guide-graph-engineering-demo]] 실습을 강의로 진행할 때 쓰는 노트입니다. 실습 페이지가 "따라 치는 순서"라면, 이 노트는 "무엇을 왜 보여 주는지"를 강의 흐름대로 정리합니다. 모든 수치는 2026-10-05 실측(`raw/ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md`)입니다. 같은 내용의 발표 자료(.pptx 16장)가 함께 있습니다.

---

## 1. 왜 필요한가 — 실제 상황

팀장이 AI에게 "경쟁사 시장 조사 보고서 써 줘"라고 맡깁니다. 회사 규칙은 "경쟁사 최소 3곳, 출처 최소 1건"입니다. AI는 보고서를 내고 "수집·분석·검증까지 마쳤습니다"라고 말합니다.

그런데 보고서를 열어 보니 출처가 없습니다. 이때 팀장이 알고 싶은 것은 두 가지입니다. 규칙을 어긴 보고서가 왜 "완료"로 나왔는지, 그리고 수집이 부실했는지 요약이 지시를 빼먹었는지입니다. 한 AI가 내부에서 다 처리했다면 둘 다 알 수 없습니다. 밖에서 보이는 것은 최종 보고서와 "완료했습니다"라는 말뿐이기 때문입니다. 이런 구조를 **블랙박스**라고 부릅니다.

## 2. 등장인물 — 무엇이 무엇을 대신하나

실습은 진짜 AI 대신 일부러 실수하는 가짜 부품으로 진행합니다. 진짜 AI는 부를 때마다 돈이 들고, 대체로 일을 잘해 실패 장면을 보기 어렵고, 결과가 매번 달라 두 방식을 같은 조건에서 비교하기 어렵기 때문입니다.

| 실제 상황의 역할 | 실습 파일 | 하는 일 |
|---|---|---|
| 경쟁사를 모으는 AI | `nodes.js`의 `gather` | 1~5곳을 무작위로 돌려줌 (3곳 이상일 확률 3/5) |
| 요약을 쓰는 AI | `nodes.js`의 `summarize` | 절반 확률로 출처를 빠뜨림 |
| 회사 규칙 | `nodes.js`의 `rubric` | 규칙 위반 목록을 돌려줌 |
| 한 AI에게 통째로 맡기는 방식 | `blackbox.js` | 수집·요약 후 무조건 "완료" |
| 단계를 나눠 맡기는 방식 | `graph.js` | 노드·엣지·재시도 상한 |
| 보고서를 검토하는 팀장 | `check.js` | 보고서를 밖에서 채점 |

수강생에게는 식당 주방에 빗대어 설명합니다. 한 요리사에게 장보기부터 조리까지 다 맡기면, 손님상에 나간 음식이 짜도 장을 잘못 봤는지 간을 잘못했는지 주방 밖에서는 알기 어렵습니다. 장보기 담당과 조리 담당을 나누고 음식이 검식대를 통과해야만 손님상에 나가게 하면, 누가 몇 번 다시 했는지가 기록으로 남고 규칙을 어긴 음식은 아예 나갈 수 없습니다. `blackbox.js`는 혼자 다 하는 요리사이고, `graph.js`는 담당을 나누고 검식대를 둔 주방입니다.

## 3. 블랙박스 vs 명시적 그래프

같은 부품(`nodes.js`)을 두 방식으로 조립해 300번씩 돌린 결과입니다.

| | 블랙박스 (`blackbox.js`) | 그래프 (`graph.js`) |
|---|---|---|
| "최소 3곳·출처 1건" 규칙이 사는 곳 | 프롬프트 속 부탁 | 엣지의 `if` 문 |
| 규칙 위반인데 "완료" | **300번 중 209번** (69.7%, 이론 70%) | **300번 중 0번** |
| 실패했을 때 | 조용히 "완료" | 재시도, 상한에 닿으면 명시적 중단 (300번 중 55번, 18.3%) |
| 남는 기록 | 최종 보고서뿐 | 노드마다 시도 횟수와 이동 경로 (전이 추적) |

강의에서 강조할 문장은 하나입니다. **확률 모델은 부탁을 무시할 수 있어도 `if` 문은 무시할 수 없습니다.**

그래프의 18% 중단은 실패가 아닙니다. 재시도 상한이라는 규칙이 정상으로 작동해, 틀린 보고서를 내는 대신 멈추고 사람을 부른 것입니다.

## 4. 노드·엣지·규칙 — 그래프의 네 요소

<div style="display:flex;flex-direction:column;gap:12px;align-items:center;font-family:sans-serif;margin:24px 0;">
  <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:center;">
    <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:12px 16px;color:#1e3a8a;font-weight:600;">gather<br><span style="font-weight:400;font-size:13px;">경쟁사 수집</span></div>
    <div style="color:#2563eb;font-size:13px;text-align:center;">3곳 이상<br>→</div>
    <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:12px 16px;color:#1e3a8a;font-weight:600;">summarize<br><span style="font-weight:400;font-size:13px;">요약 작성</span></div>
    <div style="color:#2563eb;font-size:13px;text-align:center;">루브릭 통과<br>→</div>
    <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:12px 16px;color:#1e3a8a;font-weight:600;">report<br><span style="font-weight:400;font-size:13px;">보고서 저장</span></div>
    <div style="color:#2563eb;font-size:20px;">→</div>
    <div style="background:#f3f4f6;border:2px solid #6b7280;border-radius:8px;padding:12px 16px;color:#374151;font-weight:600;">END ✅</div>
  </div>
  <div style="display:flex;gap:16px;flex-wrap:wrap;justify-content:center;">
    <div style="background:#fef2f2;border:2px dashed #dc2626;border-radius:8px;padding:10px 14px;color:#991b1b;font-size:13px;">미달이면 같은 노드 재시도 (각 최대 3번)</div>
    <div style="background:#fef2f2;border:2px solid #dc2626;border-radius:8px;padding:10px 14px;color:#991b1b;font-size:13px;font-weight:600;">3번 모두 미달 → ABORT 🛑 사람에게</div>
  </div>
</div>

**그림 풀이**: 파란 상자 셋이 노드이고, 상자 사이 화살표 위의 조건이 엣지입니다. gather가 3곳 이상을 모아야 summarize로, summarize의 결과가 루브릭을 통과해야 report로 넘어갑니다. 조건을 못 채우면 같은 노드를 다시 실행하고(빨간 점선), 3번 모두 못 채우면 ABORT로 멈춥니다(빨간 실선). report 앞의 엣지가 루브릭 통과를 요구하므로, 규칙을 어긴 보고서는 저장 단계에 도달할 길이 아예 없습니다.

| 요소 | 뜻 | 실습 코드 |
|---|---|---|
| 노드(Node) | 한 가지 책임의 작업 단위 | `nodes` 객체의 `gather`·`summarize`·`report` |
| 스테이트(State) | 노드가 함께 보는 단일 기록장 | `state` 객체 (items·draft·시도 횟수) |
| 엣지(Edge) | 다음 노드를 정하는 이동 규칙 | `edges` 객체의 함수 |
| 컨디션(Condition) | 엣지의 판단 — **코드가 강제** | "3곳 미만이면 재시도, 상한 3회" |

수강생이 가장 헷갈리는 코드는 엣지의 `조건 ? A : 조건2 ? B : C` 한 줄입니다. "조건이 참이면 A, 아니고 조건2가 참이면 B, 둘 다 아니면 C"로 읽게 하고, 실습 페이지 Step 4의 엣지 규칙 말풀이 표를 함께 띄웁니다. 이 손 러너는 LangGraph의 `add_node()`·`add_conditional_edges()`·`State`와 1:1로 대응합니다.

## 5. 진짜 Claude로 — 노드 하나만 바꾸기

가짜 `summarize`를 진짜 Claude 호출(`claude -p`)로 바꿉니다. 엣지·러너·다른 노드는 한 줄도 바꾸지 않습니다. 실측 결과는 예상과 달랐고, 그래서 강의 재료로 더 좋습니다.

| 조건 | 실측 결과 | 비용·시간 |
|---|---|---|
| 도구를 모두 끔 (`--tools ""`) | 3번 모두 Claude가 URL을 지어내지 않고 요약을 거절 → 루브릭 거부 → 🛑 중단 | 첫 호출 $0.58, 이후 $0.05, 호출당 약 2분 |
| 도구를 열어 둠 | 2번 모두 첫 시도에 ✅ 완료. 그런데 URL은 작업 디렉터리의 `nodes.js`에 있던 예시 주소 | 호출당 $0.06~0.17 |

Claude는 도구를 열어 둔 경우 스스로 이렇게 밝혔습니다: "`nodes.js`의 예시 주소인 https://example.com/market-report 로, 실제 근거가 아닌 자리표시자입니다."

이 결과에서 수강생이 가져갈 교훈은 세 가지입니다.

| 교훈 | 근거 |
|---|---|
| 하드 제약은 진짜 AI에서도 그대로 작동합니다 | 도구를 끈 경우, 근거 없는 보고서가 "완료"로 나가는 대신 상한에서 멈춤 |
| 규칙은 검사한 것만 보장합니다 | 루브릭이 "URL이 있는가"만 봐서 가짜 주소로도 통과 — 진짜인지까지 막으려면 접속 확인·허용 도메인 검사를 엣지에 더해야 합니다 |
| 도구를 열면 노드 경계가 샙니다 | Claude가 다른 단계의 파일을 읽어 답에 섞음 — 노드는 스테이트로 받은 것만 써야 책임이 격리됩니다 |

## 6. 언제 그래프를 쓰나 — 다른 패턴과 비교

| | 루프 엔지니어링 | Advisor–Worker | 그래프 엔지니어링 |
|---|---|---|---|
| 답하는 질문 | 언제 끝내나 | 역할을 어떻게 나누나 | 흐름을 어떻게 강제하나 |
| 규칙이 사는 곳 | 테스트의 종료 코드 | 프롬프트 규율 + 도구 제한 | 엣지의 코드 |
| 규칙 위반이 잡히는 시점 | 루프가 끝나기 전 | 사후 검증 | 사전에 불가능 |
| 실습 | [[guide-loop-engineering-demo]] | [[guide-advisor-worker-demo]] | [[guide-graph-engineering-demo]] |

그래프는 무겁습니다. 다음 신호가 있을 때만 씁니다: 하위 작업이 여러 단계, 지켜야 할 하드 규칙이 있음, 실패 시 처음이 아닌 특정 단계로 되돌아가야 함, "어느 단계에서 틀렸나"를 물어볼 일이 있음. 단순 요약이나 도구 호출 한두 번이면 루프로 충분합니다. 시작은 노드 2~3개짜리 최소 그래프부터입니다.

## 7. 강의 진행 팁

**권장 시간 배분 (30분)**:

| 순서 | 내용 | 시간 |
|---|---|---|
| 1 | 실제 상황·블랙박스 문제 (1절) | 3분 |
| 2 | 등장인물·주방 비유 (2절) | 3분 |
| 3 | 실습 Step 1~2 — 블랙박스 10회 실행 | 6분 |
| 4 | 실습 Step 3~4 — 그래프 코드 읽기·10회 실행 | 10분 |
| 5 | Step 6 결과 소개 (5절) — 호출당 약 2분이라 실측 출력으로 보여 줌 | 5분 |
| 6 | 비교·도입 기준 (6절), 질문 | 3분 |

**수강생이 막히는 곳**:

| 막히는 곳 | 대처 |
|---|---|
| `command not found: #` (macOS) | 실습 시작 전 `setopt interactivecomments` 입력 |
| `Cannot find module './nodes'` | 블록 첫 줄 `cd ~/graph-demo`까지 함께 붙여넣었는지 확인 |
| 엣지 한 줄의 `? :` 연쇄 | 실습 페이지의 엣지 규칙 말풀이 표로 읽기 |
| "중단이 나왔는데 실패한 건가요?" | 상한이 정상 작동한 결과 — 틀린 완료보다 낫다는 점을 짚기 |
| Step 6에서 오래 멈춤 | Claude 호출당 약 2분, 기다리거나 `Ctrl+C` |

**수업 중 던질 질문**:

- 블랙박스가 10번 모두 "완료"라고 했는데, 실제로 믿을 수 있었던 건 몇 번인가요?
- 그래프에서 "완료인데 규칙 위반"이 왜 한 번도 나올 수 없나요? 코드의 어느 줄 때문인가요?
- Claude가 가짜 주소로 루브릭을 통과했습니다. 이건 그래프의 실패인가요, 루브릭의 실패인가요?
- 여러분의 업무에서 "프롬프트로 부탁하고 있지만 사실은 코드로 강제해야 하는 규칙"은 무엇인가요?

---

## 원본 출처

- raw: `raw/ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md`
- 실행 검증 증적: `raw/ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md` — 블랙박스·그래프 각 300회 통계, Step 6 Claude 실측(도구 끔·열어 둠)과 답 원문·비용
- Anthropic — [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- LangGraph — [공식 문서](https://langchain-ai.github.io/langgraph/)

## 관련 페이지

- [[guide-graph-engineering-demo]] — 이 강의의 실습 페이지 (따라 치는 순서)
- [[concept-graph-engineering]] — 이론 (4요소·설계 패턴·오버엔지니어링 기준)
- [[comparison-advisor-worker-vs-graph]] — Advisor–Worker와 축이 어떻게 다른가
- [[lecture-loop-engineering]] — 루프 엔지니어링 강의 노트
- [[lecture-advisor-worker]] — Advisor–Worker 강의 노트
