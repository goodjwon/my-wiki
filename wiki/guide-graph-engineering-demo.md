---
title: 그래프 엔지니어링 실습 — 블랙박스 에이전트 vs 노드·엣지 그래프 (Node)
type: synthesis
tags: [graph-engineering, ai-agent, demo, hands-on, node, langgraph, claude-code]
sources:
  - ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md
external:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://langchain-ai.github.io/langgraph/
  - https://code.claude.com/docs/en/headless
created: 2026-08-10
updated: 2026-08-10
---

# 그래프 엔지니어링 실습 — 블랙박스 에이전트 vs 노드·엣지 그래프

> **이 실습의 목적**: [[concept-graph-engineering]] 의 핵심 두 문장 — **"단일 에이전트는 어디서 틀렸는지 모르는 블랙박스가 된다"** 와 **"하드 규칙은 LLM이 아닌 코드가 강제한다"** — 를 같은 작업을 두 방식으로 돌려 **직접 눈으로 비교**합니다. 프레임워크 없이 순수 Node 약 40줄로 노드·스테이트·조건부 엣지를 손으로 만들어 보는 게 핵심입니다.

문서 전체에서 쓰는 두 용어를 먼저 잡습니다. **블랙박스(blackbox)**는 수집·요약·검증을 한 에이전트가 내부에서 다 처리해 밖에서는 최종 보고만 보이는 구조를, **전이 추적(trace)**은 그래프 러너가 노드를 옮겨갈 때마다 남기는 `[노드] 상태 → 다음노드` 로그를 가리킵니다.

**시간**: 8분 (셋업 2분 + Before 블랙박스 2분 + 해체 결정 1분 + After 그래프 2분 + 실제 Claude 연결 1분)

**진행 흐름**: 1분 이론으로 블랙박스 문제와 그래프 4요소를 확인 → 두 방식이 공유할 mock 재료 만들기(Step 1) → 블랙박스 에이전트 체험(Step 2) → 노드·엣지로 해체 결정(Step 3) → 그래프 러너 체험(Step 4) → 차이 정리(Step 5) → 노드 하나만 진짜 Claude로 교체(Step 6).

**언제 보면 좋은가**: [[concept-graph-engineering]] 을 읽은 직후. [[guide-loop-engineering-demo]](루프 실습)의 다음 단계 — 루프가 "사이클과 거부 신호"를 설계했다면, 그래프는 **그 사이클 내부의 책임과 경로**를 설계합니다.

**전제**: Node 18+ 설치. (Step 6의 실제 Claude 연결만 Claude Code 로그인 필요 — 나머지는 토큰 0으로 누구나 재현 가능)

> ✅ **실행 검증됨 (2026-08-10, Node v26)**: Step 1·2·4를 실제로 돌려 본문 수치를 확인했습니다 — Step 2 블랙박스는 20회 중 13회가 루브릭 위반(오답)인데 "완료 ✅"로 종료(이론값 70%), Step 4 그래프는 20회 중 통과 14회·에스컬레이션 중단 6회로 **오답인 채 "완료"로 끝난 경우는 구조적으로 0회**입니다. 에스컬레이션 이론값은 약 18% — (2/5)³ + (1−(2/5)³)×(1/2)³ ≈ 6.4% + 11.7%. (Step 6은 토큰이 들어 본 검증에서 제외 — 명령 구문은 [공식 헤드리스 docs](https://code.claude.com/docs/en/headless) 기준)

---

## 왜 이 실습인가 — 1분 이론

시장 조사 하나를 단일 에이전트에게 통째로 맡기면, 수집이 부실했는지 요약이 지시를 빼먹었는지 **밖에서는 구분할 수 없습니다**. 최종 보고서와 "완료했습니다"라는 자기 보고만 보이기 때문입니다. [[concept-graph-engineering]] 은 이 문제를 4가지 요소로 해체합니다:

| 요소 | 역할 | 이 실습에서의 구현 |
|------|------|--------------------|
| 노드(Node) | 한 가지 책임의 작업 단위 | `gather`(수집) · `summarize`(요약) · `report`(저장) 함수 3개 |
| 스테이트(State) | 노드 간 공유되는 단일 진실 원천 | `state` 객체 하나 (items·draft·재시도 횟수) |
| 엣지(Edge) | 다음 노드를 정하는 이동 규칙 | `edges` 객체의 함수들 |
| 컨디션(Condition) | 조건부 엣지의 판단 — **코드가 강제** | "3곳 미만이면 gather 재시도, 상한 3회" |

핵심 대비는 이것입니다: 블랙박스에서 "최소 3곳·출처 1건" 규칙은 **프롬프트 속 부탁**이지만, 그래프에서는 **엣지의 `if` 문**입니다. 확률 모델은 부탁을 무시할 수 있어도 `if` 문은 무시할 수 없습니다.

---

## Step 1 — 데모 디렉터리 + 공유 mock 재료 (2분)

두 방식을 같은 조건에서 비교하려면 공통 재료가 필요합니다. 실제 LLM 대신 **비결정성을 흉내 내는 mock 함수** 3개를 만듭니다 — 수집 품질이 들쭉날쭉한 `gather`, 절반 확률로 출처를 빼먹는 `summarize`, 그리고 규칙을 채점하는 `rubric` 입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (이 Step에서 새로 만드는 데모 디렉터리)
    - **만들 파일**: `nodes.js` — mock 노드 2개(gather·summarize) + 루브릭 채점 함수
    - **실행**: 아래 코드블록 2개를 차례로 붙여넣어 실행합니다.

먼저 실습 전용 디렉터리를 만들고 이동합니다:

```bash
mkdir -p ~/graph-demo && cd ~/graph-demo
```

**mock 재료** — LLM의 "가끔 잘하고 가끔 빼먹음"을 확률로 흉내 냅니다:

```bash
cat > nodes.js << 'EOF'
// 공유 mock 노드 재료: 실제 LLM 호출 대신 비결정성을 흉내 낸다.
// gather: 경쟁사 1~5곳 수집 — 조사 품질이 들쭉날쭉한 LLM 흉내
exports.gather = () => {
  const pool = ['A사', 'B사', 'C사', 'D사', 'E사'];
  const n = 1 + Math.floor(Math.random() * 5);
  return pool.slice(0, n);
};
// summarize: 요약 생성 — 절반 확률로 출처 표기를 빼먹는다 (지시 누락 흉내)
exports.summarize = (items) => {
  const withSource = Math.random() < 0.5;
  return {
    text: `${items.length}개 경쟁사(${items.join(', ')}) 분석 요약`,
    sources: withSource ? ['https://example.com/market-report'] : [],
  };
};
// rubric: 하드 제약 — 코드가 100% 강제하는 검증 규칙
exports.rubric = (items, draft) => {
  const problems = [];
  if (items.length < 3) problems.push(`경쟁사 ${items.length}곳 — 최소 3곳 미달`);
  if (draft.sources.length < 1) problems.push('출처 URL 0건 — 최소 1건 필요');
  return problems;
};
EOF
```

> 확률을 정리하면: gather가 3곳 이상을 모을 확률 3/5, summarize가 출처를 넣을 확률 1/2. 즉 **한 번에 두 규칙을 다 지킬 확률은 3/10 뿐**입니다 — 실제 에이전트가 다단계 지시를 한 번에 완수 못 하는 상황의 축소판입니다.

---

## Step 2 — Before: 단일 블랙박스 에이전트 (2분)

재료가 준비됐으니 나쁜 쪽부터 체험합니다. 수집과 요약을 **한 에이전트가 내부에서 다 처리**하고, 검증 없이 "완료"를 자기 보고하는 구조입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1에서 만든 디렉터리)
    - **만들 파일**: `blackbox.js` — 단일 에이전트 / `check.js` — 사후 루브릭 검증 (둘 다 아래 명령이 생성)
    - **실행**: 코드블록 2개로 파일을 만들고, 마지막 블록을 여러 번 반복 실행합니다.

**단일 블랙박스 에이전트**:

```bash
cat > blackbox.js << 'EOF'
// 단일 블랙박스 에이전트: 내부에서 수집→요약을 다 하고, 검증 없이 자기 보고로 종료한다.
const { gather, summarize } = require('./nodes');
const items = gather();
const draft = summarize(items);
require('fs').writeFileSync('report.json', JSON.stringify({ items, draft }, null, 2));
console.log('🤖 에이전트: "시장 조사 보고서 완성했습니다 ✅ (수집·분석·검증까지 마쳤습니다)"');
EOF
```

**사후 검증자** — 보고서가 규칙을 지켰는지 밖에서 채점합니다 (위반 시 종료 코드 1):

```bash
cat > check.js << 'EOF'
// 사후 검증: 보고서가 루브릭(최소 3곳·출처 1건)을 지켰는지 밖에서 확인한다.
const { rubric } = require('./nodes');
const { items, draft } = JSON.parse(require('fs').readFileSync('report.json', 'utf8'));
const problems = rubric(items, draft);
if (problems.length) {
  console.error('💥 실제 검증 결과:');
  for (const p of problems) console.error('  ❌ ' + p);
  console.error('→ 어느 내부 단계에서 틀어졌는지는 보고서만으론 알 수 없다 (= 블랙박스)');
  process.exit(1);
}
console.log('PASS — 루브릭 통과');
EOF
```

이제 에이전트를 실행하고, 그 자기 보고를 사후 검증과 대조합니다:

```bash
cd ~/graph-demo
node blackbox.js
node check.js || echo "…그런데 에이전트는 이미 '완료'라고 보고했다"
```

여러 번 실행해 보면 약 70% 확률로 — 두 규칙을 다 지킬 확률이 3/10 이므로 — **규칙 위반 보고서인데 "완료 ✅"로 종료**됩니다. 문서 상단 실행 검증 노트의 "20회 중 13회"가 이 확률의 실측값입니다. 더 나쁜 것은 위반이 드러나도 **gather가 부실했는지 summarize가 빼먹었는지 밖에서는 알 수 없다**는 점입니다 — 원문이 말하는 "어느 단계에서 환각·누락이 일어났는지 추적 불가"의 축소판입니다.

---

## Step 3 — 해체 결정 (1분)

Step 2가 무너진 지점은 두 가지입니다: ① 규칙이 **에이전트 내부의 선의**에 맡겨져 있고 ② 실패가 **어느 단계 것인지 보이지 않습니다**. 그래서 바꿀 것도 두 가지입니다:

1. **책임을 노드로 쪼갭니다** — gather·summarize·report 가 각자 자기 일만 하고 스테이트를 갱신.
2. **이동 규칙을 조건부 엣지 코드로 올립니다** — "3곳 미만이면 gather 재시도, 루브릭 위반이면 summarize 재시도, 상한 3회 넘으면 중단"을 전부 `if` 문으로.

코드(파일)는 Step 1의 것을 그대로 쓰고, **조립 방식만** 바꿉니다.

---

## Step 4 — After: 노드·엣지 그래프 (2분)

Step 3의 결정을 약 40줄 러너로 옮깁니다. 프레임워크 없이 객체 두 개(`nodes`·`edges`)와 `while` 루프면 그래프의 뼈대가 전부 나옵니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1의 `nodes.js` 그대로 사용)
    - **만들 파일**: `graph.js` — 스테이트 + 노드 + 조건부 엣지 + 러너
    - **실행**: 아래 블록으로 파일을 만들고 여러 번 반복 실행합니다.

```bash
cat > graph.js << 'EOF'
// 같은 재료(nodes.js)를 그래프로 재조립: 스테이트 + 노드 + 조건부 엣지 + 러너.
const { gather, summarize, rubric } = require('./nodes');

// ── 스테이트: 그래프 전체가 공유하는 단일 진실 원천 ──
const state = { items: [], draft: null, gatherTries: 0, summarizeTries: 0 };

// ── 노드: 각자 자기 책임만 수행하고 스테이트를 갱신 ──
const nodes = {
  gather:    (s) => { s.gatherTries++;    s.items = gather(); },
  summarize: (s) => { s.summarizeTries++; s.draft = summarize(s.items); },
  report:    (s) => { require('fs').writeFileSync('report.json', JSON.stringify(s, null, 2)); },
};

// ── 조건부 엣지: 이동 규칙 + 재시도 상한을 코드가 100% 강제 ──
const edges = {
  gather:    (s) => s.items.length >= 3                   ? 'summarize'
                  : s.gatherTries < 3                     ? 'gather' : 'ABORT',
  summarize: (s) => rubric(s.items, s.draft).length === 0 ? 'report'
                  : s.summarizeTries < 3                  ? 'summarize' : 'ABORT',
  report:    ()  => 'END',
};

// ── 러너: 전이 로그가 곧 실행 추적이 된다 ──
let cur = 'gather';
while (cur !== 'END' && cur !== 'ABORT') {
  nodes[cur](state);
  const next = edges[cur](state);
  const why = cur === 'gather'    ? `경쟁사 ${state.items.length}곳 (시도 ${state.gatherTries}/3)`
            : cur === 'summarize' ? `${rubric(state.items, state.draft).join('; ') || '루브릭 통과'} (시도 ${state.summarizeTries}/3)`
            : '보고서 저장';
  console.log(`[${cur}] ${why} → ${next}`);
  cur = next;
}
console.log(cur === 'END'
  ? '✅ 완료 — 어느 노드가 몇 번 재시도했는지 추적에 다 남아 있다'
  : '🛑 중단 — 재시도 상한 도달, 사람에게 에스컬레이션 (조용한 오답 대신 명시적 중단)');
process.exit(cur === 'END' ? 0 : 1);
EOF
node graph.js
```

실행할 때마다 이런 전이 추적이 남습니다 (실행 검증에서 나온 실제 출력):

```
[gather] 경쟁사 2곳 (시도 1/3) → gather
[gather] 경쟁사 5곳 (시도 2/3) → summarize
[summarize] 출처 URL 0건 — 최소 1건 필요 (시도 1/3) → summarize
[summarize] 루브릭 통과 (시도 2/3) → report
[report] 보고서 저장 → END
✅ 완료 — 어느 노드가 몇 번 재시도했는지 추적에 다 남아 있다
```

세 가지를 관찰합니다:

- **오답 완료가 사라졌습니다.** `report` 노드 앞의 엣지가 루브릭 통과를 요구하므로, 규칙 위반 보고서는 저장 단계에 **도달 자체가 불가능**합니다 (실측 20회 중 0회).
- **실패의 좌표가 보입니다.** "출처 누락은 summarize 2번째 시도에서 해소" — 블랙박스에서 불가능했던 추적이 전이 로그에 그대로 남습니다.
- **가끔 🛑 중단으로 끝납니다 (약 18%).** 이것은 실패가 아니라 **재시도 상한이라는 하드 제약의 정상 작동**입니다 — 무한 재시도로 토큰을 태우는 대신 명시적으로 멈추고 사람을 부릅니다. [[guide-loop-engineering-demo]] Step 6.5의 "상한 없는 루프는 조용히 비용을 흘린다"와 같은 원리입니다.

> **LangGraph 대응**: 이 데모의 `nodes` ↔ `add_node()`, `edges`의 함수 ↔ `add_conditional_edges()`, `state` 객체 ↔ `State(TypedDict)` 로 1:1 대응됩니다. 프로덕션에서는 손 러너 대신 프레임워크가 상태 영속화·중단 재개·시각화를 얹어 줍니다 — [[src-graph-engineering]]의 LangGraph 골격 참조.

---

## Step 5 — 차이 표 (직접 채워보기, 30초)

두 방식을 모두 실행해 봤으니, 관찰한 차이를 직접 채워 넣으며 정리합니다.

|  | Before (블랙박스) | After (노드·엣지 그래프) |
|---|---|---|
| 규칙 위반인데 "완료"로 끝날 수 있나 | __ | __ |
| "최소 3곳" 규칙은 어디에 사나 | __ (프롬프트 속 부탁?) | __ (엣지의 if 문?) |
| 실패한 단계를 특정할 수 있나 | __ | __ |
| 재시도가 폭주하면 무엇이 막나 | __ | __ |

**한 줄 소감**: ____________________________________________

---

## Step 6 — 노드 하나만 실제 Claude로 (선택, 1분)

그래프의 책임 격리가 주는 실전 보너스를 확인합니다: **노드 하나를 교체해도 엣지·러너·다른 노드는 한 줄도 안 바뀝니다.** mock summarize를 진짜 Claude Code 헤드리스(headless) 호출 — 대화 화면 없이 터미널 명령 한 줄로 실행하고 결과만 받는 방식 — 로 바꿉니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1·4의 파일 그대로 사용)
    - **만들 파일**: `graph-claude.js` — `graph.js`에서 summarize 노드 함수만 교체한 판
    - **실행**: Claude Code 로그인 상태에서 아래 블록을 붙여넣어 실행합니다 (토큰이 소모됩니다).

```bash
cat > graph-claude.js << 'EOF'
// graph.js 와 동일 — summarize 노드의 몸통만 실제 Claude 헤드리스 호출로 교체.
const { execSync } = require('child_process');
const { gather, rubric } = require('./nodes');

const state = { items: [], draft: null, gatherTries: 0, summarizeTries: 0 };

const nodes = {
  gather:    (s) => { s.gatherTries++; s.items = gather(); },
  summarize: (s) => {   // ← 교체된 유일한 부분: mock 대신 진짜 LLM 노드
    s.summarizeTries++;
    const brief = `경쟁사 ${s.items.join(', ')} 의 시장 요약을 3문장으로 작성하라. 근거 출처 URL을 본문에 1개 이상 반드시 포함하라.`;
    const out = execSync(`claude -p ${JSON.stringify(brief)}`, { encoding: 'utf8' });
    s.draft = { text: out.trim(), sources: out.match(/https?:\/\/\S+/g) || [] };
  },
  report:    (s) => { require('fs').writeFileSync('report.json', JSON.stringify(s, null, 2)); },
};

const edges = {   // 엣지는 graph.js 와 완전히 동일 — 하드 제약은 그대로 코드가 강제
  gather:    (s) => s.items.length >= 3                   ? 'summarize'
                  : s.gatherTries < 3                     ? 'gather' : 'ABORT',
  summarize: (s) => rubric(s.items, s.draft).length === 0 ? 'report'
                  : s.summarizeTries < 3                  ? 'summarize' : 'ABORT',
  report:    ()  => 'END',
};

let cur = 'gather';
while (cur !== 'END' && cur !== 'ABORT') {
  nodes[cur](state);
  const next = edges[cur](state);
  console.log(`[${cur}] → ${next}`);
  cur = next;
}
console.log(cur === 'END' ? '✅ 완료' : '🛑 중단 — 에스컬레이션');
EOF
node graph-claude.js
```

- 진짜 LLM이 출처를 빼먹어도 **루브릭 엣지가 그대로 잡아 재시도**시킵니다 — 하드 제약이 mock/실물과 무관하게 작동하는 것이 핵심입니다.
- `claude -p`(=`--print`)는 비대화형 1회 실행이므로 노드 함수 몸통으로 감싸기에 딱 맞습니다 ([공식 docs](https://code.claude.com/docs/en/headless)).

> ⚠️ **토큰 비용**: summarize 재시도마다 모델을 호출합니다. 재시도 상한(3회)이 곧 비용 상한이기도 합니다 — 그래프의 하드 제약은 품질 장치이자 **예산 장치**입니다. [[guide-loop-engineering-demo]] Step 6.5와 같은 맥락입니다.

---

## 정리 (30초)

실습이 끝났으면 데모 디렉터리를 삭제합니다. 다시 해보고 싶으면 Step 1부터 2분이면 재구성됩니다.

```bash
cd ~ && rm -rf ~/graph-demo
```

---

## 그래프 도입 판단 체크리스트

이 실습의 작업(수집→요약→저장, 규칙 2개)은 사실 그래프가 필요한 **최소선**입니다. [[concept-graph-engineering]] 의 오버엔지니어링 기준으로 자기 작업을 점검합니다:

- [ ] 하위 작업이 **여러 단계**인가? 단일 호출로 끝나면 그래프 불필요.
- [ ] 지켜야 할 **하드 규칙**(최소 개수·상한·형식)이 있는가? 있다면 프롬프트가 아니라 엣지로.
- [ ] 실패 시 **처음이 아니라 특정 단계로** 되돌아가야 하는가?
- [ ] 재시도 **상한과 에스컬레이션 경로**가 정의돼 있는가?
- [ ] "어느 단계에서 틀렸는지"를 물어볼 일이 있는가? 있다면 전이 추적이 필요하다는 뜻.

---

## 같은 인사이트 패턴 — "규칙을 확률 모델에 맡기지 말고 구조로 강제한다"

이 실습이 보여준 원리는 위키 전반에 반복됩니다 ([[concept-graph-engineering]] 에 누적):

| 영역 | 부탁(프롬프트) 방식 | 구조 강제 방식 | 참조 |
|------|--------------------|---------------|------|
| **그래프** | "최소 3곳·출처 1건" 프롬프트 지시 | 엣지의 `if` + 재시도 상한 (이 실습) | [[concept-graph-engineering]] |
| Loop | 자기보고 "완료했습니다" | 테스트 exit code가 거부 신호 | [[guide-loop-engineering-demo]] |
| Hooks | "위험 명령 하지 마" 부탁 | `guard.sh` exit 1 → 도구 차단 | [[concept-claude-hooks]] |
| Advisor–Worker | 역할 지시문만 | frontmatter `tools` 제한·검증 게이트 | [[concept-advisor-worker]] |

→ **공통 원리**: 확률 모델의 준수 의지를 믿지 말고, 어길 수 없는 층(코드·환경·권한)에 규칙을 내립니다.

---

## 원본·외부 출처

**개념**: [[concept-graph-engineering]] / [[src-graph-engineering]] (원문 정리 + LangGraph 골격)

- raw: `raw/ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md`

**구현·이론 (공식)**:

- Anthropic — [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) (라우터·평가자-생성자 등 패턴의 1차 정리)
- LangGraph — [공식 문서](https://langchain-ai.github.io/langgraph/) (add_node · add_conditional_edges · State)
- Claude Code 헤드리스 모드 — [code.claude.com/docs/headless](https://code.claude.com/docs/en/headless)

---

## 관련 페이지

- [[concept-graph-engineering]] — 이 실습의 이론 (노드·엣지·스테이트·컨디션, 오버엔지니어링 기준)
- [[src-graph-engineering]] — 원문 정리 + LangGraph 실행 골격
- [[guide-loop-engineering-demo]] — 직전 단계: 루프 실습 (사이클·거부 신호·토큰 비용)
- [[guide-advisor-worker-demo]] — 역할 분할 축의 실습 (그래프 관점에서는 2노드 최소 그래프)
- [[concept-claude-hooks]] — 컨디션의 환경 층 구현 (exit code 거부)
