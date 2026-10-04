---
title: 그래프 엔지니어링 실습 — 블랙박스 에이전트 vs 노드·엣지 그래프 (Node)
type: synthesis
tags: [graph-engineering, ai-agent, demo, hands-on, node, langgraph, claude-code]
sources:
  - ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md
  - ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md
external:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://langchain-ai.github.io/langgraph/
  - https://code.claude.com/docs/en/headless
created: 2026-08-10
updated: 2026-10-05
---

# 그래프 엔지니어링 실습 — 블랙박스 에이전트 vs 노드·엣지 그래프

> **이 실습의 목적**: [[concept-graph-engineering]] 의 핵심 두 문장 — **"단일 에이전트는 어디서 틀렸는지 모르는 블랙박스가 된다"** 와 **"하드 규칙은 LLM이 아닌 코드가 강제한다"** — 를 같은 작업을 두 방식으로 돌려 **직접 눈으로 비교**합니다. 프레임워크 없이 순수 Node 약 40줄로 노드·스테이트·조건부 엣지를 손으로 만들어 보는 게 핵심입니다.

문서 전체에서 쓰는 두 용어를 먼저 잡습니다. **블랙박스(blackbox)**는 수집·요약·검증을 한 에이전트가 내부에서 다 처리해 밖에서는 최종 보고만 보이는 구조를, **전이 추적(trace)**은 그래프 러너가 노드를 옮겨갈 때마다 남기는 `[노드] 상태 → 다음노드` 로그를 가리킵니다.

**시간**: 12분 (셋업 2분 + Before 블랙박스 2분 + 해체 결정 1분 + After 그래프 3분 + 실제 Claude 연결 4분)

**진행 흐름**: 1분 이론으로 블랙박스 문제와 그래프 4요소를 확인 → 등장인물(무엇이 무엇을 대신하나) 확인 → 두 방식이 공유할 가짜 재료 만들기(Step 1) → 블랙박스 에이전트 체험(Step 2) → 노드·엣지로 해체 결정(Step 3) → 그래프 러너 체험(Step 4) → 차이 정리(Step 5) → 노드 하나만 진짜 Claude로 교체(Step 6).

**언제 보면 좋은가**: [[concept-graph-engineering]] 을 읽은 직후. [[guide-loop-engineering-demo]](루프 실습)의 다음 단계 — 루프가 "사이클과 거부 신호"를 설계했다면, 그래프는 **그 사이클 내부의 책임과 경로**를 설계합니다.

**전제**: Node 18+ 설치. (Step 6의 실제 Claude 연결만 Claude Code 로그인 필요 — 나머지는 토큰 0으로 누구나 재현 가능)

!!! tip "명령 실행 방법 (터미널이 처음이라면)"

    - 모든 `bash` 코드블록은 **터미널**(macOS는 "터미널" 앱, Windows는 WSL 또는 Git Bash)에 붙여넣어 실행합니다. Node 설치 여부는 `node -v`로 버전이 나오는지 확인합니다.
    - 코드블록 오른쪽 위의 복사 버튼으로 블록 **전체**를 복사해 붙여넣고 `Enter`를 누릅니다. 여러 줄짜리 블록도 한 번에 붙여넣으면 위에서부터 차례로 실행됩니다.
    - macOS 기본 셸(zsh)은 붙여넣은 명령의 `#` 주석을 인식하지 못해 `command not found: #` 오류가 날 수 있습니다. 실습 전에 아래 한 줄을 먼저 입력합니다. 터미널 창을 새로 열었다면 다시 입력합니다.

        ```bash
        setopt interactivecomments
        ```

    - 모든 블록은 첫 줄의 `cd ~/graph-demo`로 실습 디렉터리에 들어가서 시작합니다. 중간에 터미널을 새로 열어도 그대로 이어서 할 수 있습니다.

> ✅ **실행 검증됨 (2026-10-05, Node v24, bash·zsh)**: 이 페이지의 블록을 새 디렉터리에서 그대로 추출해 실행했습니다. Step 2 블랙박스는 300번 중 209번(69.7%, 이론값 70%)이 규칙 위반인데 "완료 ✅"로 끝났고, Step 4 그래프는 300번 중 중단 55번(18.3%, 이론값 18.1%)·**규칙 위반인 채 완료 0번**이었습니다. Step 6은 Claude Code 2.1.289로 summarize 노드를 실제 실행해, 도구를 끈 경우(3번 모두 URL을 지어내지 않고 거부 → 중단)와 도구를 열어 둔 경우(2번 모두 작업 디렉터리의 예시 URL을 가져와 루브릭 통과)를 확인했습니다. 증적: `raw/ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md`

---

## 왜 이 실습인가 — 1분 이론

시장 조사 하나를 단일 에이전트에게 통째로 맡기면, 수집이 부실했는지 요약이 지시를 빼먹었는지 **밖에서는 구분하기 어렵습니다**. 최종 보고서와 "완료했습니다"라는 자기 보고만 보이기 때문입니다. [[concept-graph-engineering]] 은 이 문제를 4가지 요소로 해체합니다:

| 요소 | 역할 | 이 실습에서의 구현 |
|------|------|--------------------|
| 노드(Node) | 한 가지 책임의 작업 단위 | `gather`(수집) · `summarize`(요약) · `report`(저장) 함수 3개 |
| 스테이트(State) | 노드 간 공유되는 단일 진실 원천 | `state` 객체 하나 (items·draft·재시도 횟수) |
| 엣지(Edge) | 다음 노드를 정하는 이동 규칙 | `edges` 객체의 함수들 |
| 컨디션(Condition) | 조건부 엣지의 판단 — **코드가 강제** | "3곳 미만이면 gather 재시도, 상한 3회" |

핵심 대비는 이것입니다: 블랙박스에서 "최소 3곳·출처 1건" 규칙은 **프롬프트 속 부탁**이지만, 그래프에서는 **엣지의 `if` 문**입니다. 확률 모델은 부탁을 무시할 수 있어도 `if` 문은 무시할 수 없습니다.

---

## 이 실습의 등장인물 — 무엇이 무엇을 대신하나

이 실습의 파일들은 실제 AI 업무의 등장인물을 하나씩 대신합니다. 이 대응을 먼저 잡아 두면 이후 Step이 쉬워집니다.

실제 상황은 이렇습니다. 팀장이 AI에게 "경쟁사 시장 조사 보고서 써 줘"라고 맡깁니다. AI는 웹에서 경쟁사를 모으고, 요약을 쓰고, 보고서를 냅니다. 회사에는 "경쟁사 최소 3곳, 출처 최소 1건"이라는 규칙이 있습니다.

| 실제 상황의 역할 | 실제로는 | 이 실습에서 대신하는 것 |
|---|---|---|
| 경쟁사를 모으는 AI | 웹을 검색하는 LLM | `nodes.js`의 `gather` — 1~5곳을 무작위로 돌려줌 |
| 요약을 쓰는 AI | LLM | `nodes.js`의 `summarize` — 절반 확률로 출처를 빠뜨림 |
| 회사 규칙 | 보고서 체크리스트 | `nodes.js`의 `rubric` — 규칙 위반 목록을 돌려줌 |
| 한 AI에게 통째로 맡기는 방식 | 에이전트 하나 + 긴 프롬프트 | `blackbox.js` |
| 단계를 나눠 맡기는 방식 | LangGraph 같은 그래프 프레임워크 | `graph.js` |
| 보고서를 검토하는 사람 | 팀장의 검토 | `check.js` |

진짜 LLM 대신 가짜를 쓰는 이유는 세 가지입니다. 진짜 LLM은 부를 때마다 돈이 들고, 대체로 일을 잘해서 실패 장면을 보기 어렵고, 결과가 매번 달라 두 방식을 같은 조건에서 비교하기 어렵습니다. 그래서 실패를 확률로 일부러 섞은 가짜를 세워 공짜로 몇 번이고 실험합니다. Step 6에서는 그중 `summarize` 하나만 진짜 Claude로 바꿔 봅니다.

식당 주방에 빗대 보면 이렇습니다. 한 요리사에게 장보기부터 조리까지 다 맡기면, 손님상에 나간 음식이 짜도 장을 잘못 봤는지 간을 잘못했는지 주방 밖에서는 알기 어렵습니다. 장보기 담당과 조리 담당을 나누고 음식이 검식대를 통과해야만 손님상에 나가게 하면, 어느 담당이 몇 번 다시 했는지가 기록으로 남고 규칙을 어긴 음식은 아예 나갈 수 없습니다. 이 실습에서 `blackbox.js`는 혼자 다 하는 요리사이고, `graph.js`는 담당을 나누고 검식대를 둔 주방입니다. 진짜 요리사를 매번 고용하면 비싸므로, 가끔 일부러 실수하는 연습용 요리사(`nodes.js`)를 세워 둔 것입니다.

---

## Step 1 — 데모 디렉터리 + 공유 가짜 재료 (2분)

두 방식을 같은 조건에서 비교하려면 공통 재료가 필요합니다. 실제 LLM 대신 **비결정성을 흉내 내는 가짜(mock) 함수** 3개를 만듭니다 — 수집 품질이 들쭉날쭉한 `gather`, 절반 확률로 출처를 빼먹는 `summarize`, 그리고 규칙을 채점하는 `rubric` 입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (이 Step에서 새로 만드는 데모 디렉터리)
    - **만들 파일**: `nodes.js` — 가짜 노드 2개(gather·summarize) + 루브릭 채점 함수
    - **실행**: 아래 코드블록 2개를 차례로 붙여넣습니다. 파일만 만들어지고 화면에는 아무것도 나오지 않는 것이 정상입니다.

먼저 실습 전용 디렉터리를 만들고 이동합니다:

```bash
mkdir -p ~/graph-demo && cd ~/graph-demo
```

**가짜 재료** — LLM의 "가끔 잘하고 가끔 빼먹음"을 확률로 흉내 냅니다. `cat > nodes.js << 'EOF'`는 다음 줄부터 `EOF` 줄 직전까지의 내용을 `nodes.js` 파일로 저장하라는 셸 문법입니다:

```bash
cd ~/graph-demo
cat > nodes.js << 'EOF'
// 공유 가짜 노드 재료: 실제 LLM 호출 대신 비결정성을 흉내 낸다.
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

!!! note "방금 본 것 — 실패를 일부러 섞은 재료"

    `nodes.js`는 실행하는 프로그램이 아니라 Step 2·4가 함께 가져다 쓰는 부품 상자입니다. 두 방식이 같은 부품, 같은 실패 확률을 쓰므로 Step 2와 Step 4의 차이는 오로지 **조립 방식**에서 나옵니다.

---

## Step 2 — Before: 단일 블랙박스 에이전트 (2분)

재료가 준비됐으니 나쁜 쪽부터 체험합니다. 수집과 요약을 **한 에이전트가 내부에서 다 처리**하고, 검증 없이 "완료"를 자기 보고하는 구조입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1에서 만든 디렉터리)
    - **만들 파일**: `blackbox.js` — 단일 에이전트 / `check.js` — 사후 루브릭 검증 (둘 다 아래 블록이 생성) / `report.json` — 에이전트가 낸 보고서 (실행하면 자동 생성)
    - **실행**: 코드블록 2개로 파일을 만들고, 세 번째 블록을 여러 번 반복 실행합니다.

**단일 블랙박스 에이전트** — 수집과 요약을 한 번에 하고, 무조건 "완료"라고 말합니다:

```bash
cd ~/graph-demo
cat > blackbox.js << 'EOF'
// 단일 블랙박스 에이전트: 내부에서 수집→요약을 다 하고, 검증 없이 자기 보고로 종료한다.
const { gather, summarize } = require('./nodes');
const items = gather();
const draft = summarize(items);
require('fs').writeFileSync('report.json', JSON.stringify({ items, draft }, null, 2));
console.log('🤖 에이전트: "시장 조사 보고서 완성했습니다 ✅ (수집·분석·검증까지 마쳤습니다)"');
EOF
```

**사후 검증자** — 팀장 역할입니다. 보고서가 규칙을 지켰는지 밖에서 채점하고, 위반이면 종료 코드 1로 끝납니다:

```bash
cd ~/graph-demo
cat > check.js << 'EOF'
// 사후 검증: 보고서가 루브릭(최소 3곳·출처 1건)을 지켰는지 밖에서 확인한다.
const { rubric } = require('./nodes');
const { items, draft } = JSON.parse(require('fs').readFileSync('report.json', 'utf8'));
const problems = rubric(items, draft);
if (problems.length) {
  console.error('💥 실제 검증 결과:');
  for (const p of problems) console.error('  ❌ ' + p);
  console.error('→ 보고서에는 결과만 남고, 어느 단계가 몇 번 시도해 무엇을 넘겼는지는 남지 않는다 (= 블랙박스)');
  process.exit(1);
}
console.log('PASS — 루브릭 통과');
EOF
```

이제 에이전트를 실행하고, 그 자기 보고를 사후 검증과 대조합니다. `A || B`는 A가 실패(종료 코드 1)했을 때만 B를 실행하라는 셸 문법입니다:

```bash
cd ~/graph-demo
node blackbox.js                       # 에이전트: 보고서를 쓰고 "완료" 보고
node check.js || echo "…그런데 에이전트는 이미 '완료'라고 보고했다"   # 팀장: 보고서 채점
```

규칙을 어긴 경우의 실제 출력입니다. 에이전트는 "검증까지 마쳤다"고 했지만, 채점하자 출처가 빠져 있습니다:

```
🤖 에이전트: "시장 조사 보고서 완성했습니다 ✅ (수집·분석·검증까지 마쳤습니다)"
💥 실제 검증 결과:
  ❌ 출처 URL 0건 — 최소 1건 필요
→ 보고서에는 결과만 남고, 어느 단계가 몇 번 시도해 무엇을 넘겼는지는 남지 않는다 (= 블랙박스)
…그런데 에이전트는 이미 '완료'라고 보고했다
```

두 규칙을 다 지킨 경우에는 같은 "완료" 보고 뒤에 `PASS — 루브릭 통과`가 나옵니다. 손으로 10번 붙여넣기가 번거로우면 아래 블록으로 10번을 한꺼번에 돌려 결과만 봅니다:

```bash
cd ~/graph-demo
for i in $(seq 1 10); do                  # i에 1~10을 차례로 넣으며 10번 반복
  node blackbox.js > /dev/null            # 에이전트 실행 ("> /dev/null"은 화면 출력을 버림 — 보고는 늘 "완료"라 숨김)
  if node check.js > /dev/null 2>&1; then # 채점 ("2>&1"은 오류 출력까지 버림 → 종료 코드만 남음)
    echo "${i}회: PASS"
  else
    echo "${i}회: 규칙 위반"
  fi
done
```

!!! note "방금 본 것 — 같은 '완료', 다른 결과"

    에이전트는 10번 모두 "검증까지 마쳤다"고 보고했지만, 대략 10번 중 7번은 규칙 위반입니다(검증 때 300번 중 209번). 두 규칙을 다 지킬 확률이 3/10뿐이기 때문입니다. 그리고 보고서(`report.json`)에는 **최종 결과만** 남습니다. 이 장난감 예제는 규칙 하나가 단계 하나에 딱 대응해서 "출처가 없으니 summarize 탓"이라고 짐작은 할 수 있습니다. 하지만 수집을 몇 번 했는지, 요약이 처음부터 출처를 뺐는지 수집 단계가 출처를 못 넘겼는지 같은 **과정**은 어디에도 기록되지 않습니다. 실제 에이전트라면 출처 누락 하나에도 원인 후보가 여럿이라, 결과만 보고는 고칠 곳을 정할 수 없습니다.

---

## Step 3 — 해체 결정 (1분)

Step 2가 무너진 지점은 두 가지입니다: ① 규칙이 **에이전트 내부의 선의**에 맡겨져 있고 ② 실패가 **어느 단계 것인지 기록되지 않습니다**. 그래서 바꿀 것도 두 가지입니다:

1. **책임을 노드로 쪼갭니다** — gather·summarize·report 가 각자 자기 일만 하고 스테이트를 갱신.
2. **이동 규칙을 조건부 엣지 코드로 올립니다** — "3곳 미만이면 gather 재시도, 루브릭 위반이면 summarize 재시도, 상한 3회 넘으면 중단"을 전부 `if` 문으로.

부품(`nodes.js`)은 Step 1의 것을 그대로 쓰고, **조립 방식만** 바꿉니다. 이 Step은 실행할 명령이 없고, Step 4의 코드를 읽기 전에 무엇이 바뀌는지 잡는 단계입니다.

!!! note "방금 본 것 — 바꿀 것은 부품이 아니라 조립"

    주방 비유로 말하면, 요리사(가짜 LLM)의 실력은 그대로 두고 담당을 나누고 검식대를 세우는 결정입니다. 실력이 같아도 조립이 바뀌면 손님상에 나가는 결과가 달라진다는 것을 Step 4에서 확인합니다.

---

## Step 4 — After: 노드·엣지 그래프 (3분)

Step 3의 결정을 약 40줄 러너로 옮깁니다. 프레임워크 없이 객체 두 개(`nodes`·`edges`)와 `while` 루프면 그래프의 뼈대가 전부 나옵니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1의 `nodes.js`, Step 2의 `check.js` 그대로 사용)
    - **만들 파일**: `graph.js` — 스테이트 + 노드 + 조건부 엣지 + 러너
    - **실행**: 아래 블록으로 파일을 만들고 한 번 실행합니다. 이어서 다음 블록을 여러 번 실행합니다.

```bash
cd ~/graph-demo
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

**코드 읽는 법** — `edges`의 `조건 ? A : 조건2 ? B : C`는 JavaScript의 조건 연산자를 이어 붙인 것으로, "조건이 참이면 A, 아니고 조건2가 참이면 B, 둘 다 아니면 C"라는 뜻입니다. 엣지 규칙을 말로 풀면 다음 표와 같습니다:

| 방금 끝난 노드 | 조건 | 다음 노드 |
|---|---|---|
| gather | 경쟁사 3곳 이상 | summarize |
| gather | 3곳 미만, 시도 3번 미만 | gather (다시 수집) |
| gather | 3곳 미만, 이미 3번 시도 | ABORT (중단) |
| summarize | 루브릭 위반 없음 | report |
| summarize | 위반 있음, 시도 3번 미만 | summarize (다시 요약) |
| summarize | 위반 있음, 이미 3번 시도 | ABORT (중단) |
| report | 항상 | END (완료) |

러너의 `while` 문은 "지금 노드를 실행하고, 엣지에게 다음 노드를 물어 옮겨 가기"를 END나 ABORT가 나올 때까지 반복합니다. 옮겨 갈 때마다 한 줄씩 찍는 것이 전이 추적입니다.

실행 결과는 매번 다르고, 크게 세 가지로 끝납니다. 아래는 모두 실제 출력입니다.

**① 재시도 끝에 완료** — 수집을 두 번 다시 하고, 요약을 한 번 다시 했습니다:

```
[gather] 경쟁사 2곳 (시도 1/3) → gather
[gather] 경쟁사 1곳 (시도 2/3) → gather
[gather] 경쟁사 5곳 (시도 3/3) → summarize
[summarize] 출처 URL 0건 — 최소 1건 필요 (시도 1/3) → summarize
[summarize] 루브릭 통과 (시도 2/3) → report
[report] 보고서 저장 → END
✅ 완료 — 어느 노드가 몇 번 재시도했는지 추적에 다 남아 있다
```

**② 수집 단계에서 중단** — 3번 모두 3곳 미만이라 요약으로 넘어가지 못했습니다:

```
[gather] 경쟁사 2곳 (시도 1/3) → gather
[gather] 경쟁사 1곳 (시도 2/3) → gather
[gather] 경쟁사 2곳 (시도 3/3) → ABORT
🛑 중단 — 재시도 상한 도달, 사람에게 에스컬레이션 (조용한 오답 대신 명시적 중단)
```

**③ 요약 단계에서 중단** — 수집은 통과했지만 요약이 3번 모두 출처를 빠뜨렸습니다:

```
[gather] 경쟁사 4곳 (시도 1/3) → summarize
[summarize] 출처 URL 0건 — 최소 1건 필요 (시도 1/3) → summarize
[summarize] 출처 URL 0건 — 최소 1건 필요 (시도 2/3) → summarize
[summarize] 출처 URL 0건 — 최소 1건 필요 (시도 3/3) → ABORT
🛑 중단 — 재시도 상한 도달, 사람에게 에스컬레이션 (조용한 오답 대신 명시적 중단)
```

Step 2와 같은 방식으로 10번을 한꺼번에 돌려, "완료인데 규칙 위반"이 한 번이라도 나오는지 확인합니다. 완료(종료 코드 0)로 끝난 회차만 `check.js`로 다시 채점합니다:

```bash
cd ~/graph-demo
for i in $(seq 1 10); do
  if node graph.js > /dev/null; then         # 그래프 실행 — 완료면 종료 코드 0, 중단이면 1
    if node check.js > /dev/null 2>&1; then  # 완료한 보고서를 팀장이 다시 채점
      echo "${i}회: 완료 (루브릭 통과)"
    else
      echo "${i}회: 완료인데 규칙 위반 ← 나오면 안 되는 결과"
    fi
  else
    echo "${i}회: 중단 (사람에게 에스컬레이션)"
  fi
done
```

!!! note "방금 본 것 — 같은 부품, 다른 조립"

    - **오답 완료가 사라졌습니다.** `report` 노드 앞의 엣지가 루브릭 통과를 요구하므로, 규칙 위반 보고서는 저장 단계에 **도달 자체가 불가능**합니다. 검증 때 300번 돌려 "완료인데 규칙 위반"은 0번이었습니다.
    - **실패의 좌표가 보입니다.** ①에서 "수집은 3번째에, 출처는 요약 2번째에 해결"이 전이 추적에 그대로 남았습니다. Step 2의 보고서에는 없던 과정 기록입니다.
    - **가끔 🛑 중단으로 끝납니다 (약 18%, 검증 때 300번 중 55번).** 이것은 실패가 아니라 **재시도 상한이라는 하드 제약의 정상 작동**입니다. 무한 재시도로 토큰을 태우거나 틀린 보고서를 내는 대신, 명시적으로 멈추고 사람을 부릅니다. [[guide-loop-engineering-demo]] Step 6.5의 "상한 없는 루프는 조용히 비용을 흘린다"와 같은 원리입니다. 이론값 18.1%는 수집 3번 실패 (2/5)³ ≈ 6.4%와, 수집은 통과했지만 요약 3번 실패 (1−6.4%)×(1/2)³ ≈ 11.7%를 더한 값입니다.

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

## Step 6 — 노드 하나만 실제 Claude로 (선택, 4분)

그래프의 책임 격리가 주는 실전 보너스를 확인합니다: **노드 하나를 교체해도 엣지·러너·다른 노드는 한 줄도 안 바뀝니다.** 가짜 summarize를 진짜 Claude Code 헤드리스(headless) 호출 — 대화 화면 없이 터미널 명령 한 줄로 실행하고 결과만 받는 방식 — 로 바꿉니다.

!!! example "실습 위치·실행"

    - **위치**: `~/graph-demo` (Step 1의 `nodes.js` 그대로 사용)
    - **만들 파일**: `graph-claude.js` — `graph.js`에서 summarize 노드의 몸통만 교체한 판
    - **실행**: Claude Code가 설치·로그인돼 있어야 합니다 — 확인 방법은 [[guide-loop-engineering-demo]] Step 6의 "6-1. 준비 확인"과 같습니다. **토큰이 듭니다** — 실측 기준 6-1은 Claude 호출 최대 3번(합계 약 $0.7, 호출당 약 2분), 6-2는 1번($0.06~0.17).

### 6-1. 도구 없이 요약만 맡기기

```bash
cd ~/graph-demo
cat > graph-claude.js << 'EOF'
// graph.js 와 동일 — summarize 노드의 몸통만 실제 Claude 헤드리스 호출로 교체.
const { execSync } = require('child_process');
const { gather, rubric } = require('./nodes');
// 기본은 도구를 모두 끈다(--tools ""): 노드는 프롬프트로 받은 것만 쓴다. "node graph-claude.js open"이면 도구를 열어 둔다(6-2).
const TOOLS = process.argv[2] === 'open' ? '' : ' --tools ""';

const state = { items: [], draft: null, gatherTries: 0, summarizeTries: 0 };

const nodes = {
  gather:    (s) => { s.gatherTries++; s.items = gather(); },
  summarize: (s) => {   // ← 교체된 유일한 부분: 가짜 대신 진짜 LLM 노드
    s.summarizeTries++;
    const brief = `경쟁사 ${s.items.join(', ')} 의 시장 요약을 3문장으로 작성하라. 근거 출처 URL을 본문에 1개 이상 반드시 포함하라.`;
    const out = execSync(`claude -p ${JSON.stringify(brief)}${TOOLS}`, { encoding: 'utf8' });
    s.draft = { text: out.trim(), sources: out.match(/https?:\/\/[^\s)`<>"]+/g) || [] };
    console.log(`  └ Claude의 답 첫 줄: ${s.draft.text.split('\n')[0]}`);
    console.log(`  └ 답에서 찾은 URL: ${s.draft.sources.join(', ') || '없음'}`);
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

`graph.js`와 비교해 바뀐 곳은 summarize 노드의 몸통과, Claude의 답을 확인하는 출력 두 줄뿐입니다. `execSync`는 Node 안에서 셸 명령(`claude -p "…" --tools ""`)을 실행하고 그 출력을 문자열로 받아 오는 함수입니다. `--tools ""`는 Claude가 쓸 수 있는 도구를 모두 끄는 옵션으로, 노드가 작업 디렉터리의 다른 파일을 뒤지지 않고 프롬프트로 받은 내용만으로 일하게 합니다. 수집이 3번 모두 실패하면 Claude를 한 번도 부르지 않고 중단하니, 그때는 다시 실행합니다.

검증 때의 결과는 3번 모두 같았습니다. A사~E사는 실존하지 않는 이름이라 근거 자료가 없고, Claude는 URL을 지어내는 대신 요약을 거절했습니다. 첫 시도에서 Claude가 돌려준 답의 앞부분입니다:

```
A사~E사 시장 요약은 아직 쓰지 못했습니다. 근거로 쓸 자료가 없기 때문입니다.

- **"A사~E사"가 가리키는 회사를 알 수 없습니다.** 실제 회사명이나 사용자가 가진 자료가 없으면 내용을 정할 수 없습니다.
- **웹 검색 도구가 없습니다.** 확인된 출처 URL을 찾을 방법이 없고, URL이나 시장 데이터를 지어내면 잘못된 정보가 됩니다.
```

답에 URL이 없으니 루브릭이 거부하고, summarize를 3번 시도한 뒤 `🛑 중단 — 에스컬레이션`으로 끝났습니다.

### 6-2. 도구를 열어 두면? (선택)

같은 파일을 `open`을 붙여 실행하면 도구를 끄지 않고 Claude를 부릅니다:

```bash
cd ~/graph-demo
node graph-claude.js open
```

검증 때는 2번 모두 첫 시도에 루브릭을 통과하고 `✅ 완료`로 끝났습니다. 그런데 Claude가 넣은 URL은 작업 디렉터리의 `nodes.js`·`report.json`에서 가져온 `https://example.com/market-report`였습니다. Claude 스스로 그 점을 밝혔습니다:

```
현재 참조할 수 있는 유일한 출처는 `nodes.js`의 예시 주소인 https://example.com/market-report 로, 실제 근거가 아닌 자리표시자입니다.

이 URL은 형식만 맞춥니다. 코드의 출처 1건 이상 검사(rubric)는 통과하지만, 내용을 뒷받침하는 근거는 아닙니다.
```

!!! note "방금 본 것 — 하드 제약은 진짜 LLM에서도 작동하지만, 검사한 것만 보장한다"

    - **엣지는 한 줄도 안 바꿨는데 그대로 작동했습니다.** 6-1에서 진짜 Claude가 URL 없는 답을 내자, 가짜 summarize 때와 똑같이 루브릭 엣지가 거부하고 상한에서 멈췄습니다. 근거 없는 보고서가 "완료"로 나가는 대신 사람에게 넘어간 것이 하드 제약의 정상 작동입니다.
    - **루브릭은 "URL이 있는가"만 봅니다.** 6-2에서는 예시용 가짜 주소 하나로 규칙을 통과했습니다. 규칙이 형식만 검사하면, 그래프는 형식만 보장합니다. 출처가 진짜인지까지 막으려면 "URL에 실제로 접속되는가", "허용된 도메인인가" 같은 검사를 엣지에 더해야 합니다.
    - **도구를 열면 노드 경계가 샙니다.** 6-2의 Claude는 프롬프트에 없던 다른 단계의 파일(`report.json`)과 코드(`nodes.js`)를 읽고 그 내용을 답에 섞었습니다. 노드는 스테이트로 받은 것만 써야 책임이 격리됩니다. 6-1의 `--tools ""`가 그 경계를 지키는 장치입니다.

### 6-3. 막힐 때

| 증상 | 원인 | 해결 |
|---|---|---|
| `Cannot find module './nodes'` | 다른 디렉터리에서 실행함 | 블록 첫 줄의 `cd ~/graph-demo`까지 함께 붙여넣기 |
| `command not found: claude` 또는 로그인 안내 | Claude Code 미설치·미로그인 | [[guide-loop-engineering-demo]] Step 6-1대로 준비 |
| `[gather] → gather` 다음에 아무 출력 없이 오래 멈춤 | Claude가 답을 만드는 중 (검증 때 호출당 약 2분) | 기다리거나 `Ctrl+C`로 중단 |
| Claude를 한 번도 부르지 않고 `🛑 중단` | 수집이 3번 모두 3곳 미만 (약 6%) | 다시 실행 |
| 6-1이 매번 `🛑 중단`으로 끝남 | 가상 회사라 근거가 없어 Claude가 URL을 지어내지 않음 | 정상입니다. 하드 제약이 작동한 결과입니다 |

> ⚠️ **토큰 비용**: summarize 재시도마다 모델을 호출합니다. 재시도 상한(3회)이 곧 비용 상한이기도 합니다 — 그래프의 하드 제약은 품질 장치이자 **예산 장치**입니다. 검증 때 6-1의 첫 호출은 $0.58로 이후 호출($0.05)보다 훨씬 비쌌습니다. [[guide-loop-engineering-demo]] Step 6.5와 같은 맥락입니다.

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

이 실습과 직접 맞닿은 행만 추렸습니다.

| 영역 | 부탁(프롬프트) 방식 | 구조 강제 방식 | 참조 |
|------|--------------------|---------------|------|
| **그래프** | "최소 3곳·출처 1건" 프롬프트 지시 | 엣지의 `if` + 재시도 상한 (이 실습) | [[concept-graph-engineering]] |
| Loop | 자기보고 "완료했습니다" | 테스트 exit code가 거부 신호 | [[guide-loop-engineering-demo]] |
| Hooks | "위험 명령 하지 마" 부탁 | `guard.sh` exit 2 → 도구 차단 | [[concept-claude-hooks]] |

전체 표(Advisor–Worker 포함)는 [[concept-graph-engineering]]에 있습니다.

→ **공통 원리**: 확률 모델의 준수 의지를 믿지 말고, 어길 수 없는 층(코드·환경·권한)에 규칙을 내립니다.

---

## 원본·외부 출처

**개념**: [[concept-graph-engineering]] / [[src-graph-engineering]] (원문 정리 + LangGraph 골격)

- raw: `raw/ai-engineering/grap-engineering/또다른 트렌드 Graph Engineering 알려드림_1786315251439.md`
- 실행 검증 증적: `raw/ai-engineering/grap-engineering/verification/2026-10-05-demo-run.md` — Step 2·4 각 300회 통계, 전이 추적 실제 출력, Step 6 Claude 실측(도구 끔·열어 둠)과 비용

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
- [[guide-advisor-worker-advanced]] — 대조 실측: 장면 1 "프롬프트 규율의 한계" (규율을 해석해 우회 vs 이 실습의 코드 강제)
- [[comparison-advisor-worker-vs-graph]] — 두 패턴의 축 차이·선택 기준 비교
- [[concept-claude-hooks]] — 컨디션의 환경 층 구현 (exit code 거부)
