---
title: Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프 (Node + claude -p)
type: synthesis
tags: [loop-engineering, harness, demo, react-pattern, claude-code, hands-on, node]
sources:
  - ai-engineering/loop-engineering/loop-engineering-notes.md
  - ai-engineering/loop-engineering/primary-sources.md
  - ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md
external:
  - https://addyosmani.com/blog/loop-engineering/
  - https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/
  - https://arxiv.org/abs/2210.03629
  - https://arxiv.org/abs/2303.11366
  - https://arxiv.org/abs/2303.17651
  - https://code.claude.com/docs/en/headless
created: 2026-06-26
updated: 2026-10-05
---

# Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프

> **이 실습의 목적**: [[concept-loop-engineering]] 의 핵심 한 문장 — **"거부할 수 있는 무언가(테스트·타입체크·에러)가 없는 루프는 메아리방"** — 을 **직접 코드로 짜서 체험**합니다. "루프를 작성한다"는 감각을 손에 익히는 게 핵심입니다.

문서 전체에서 쓰는 두 용어를 먼저 잡습니다. **메아리방(echo chamber)**은 에이전트의 "다 됐어요" 자기 보고를 검증 없이 믿고 종료하는 루프를, **거부 신호(reject signal)**는 테스트·타입체크·빌드처럼 실패를 객관적으로 돌려줘 그 종료를 막는 검사를 가리킵니다.

**시간**: 16분 (셋업 2분 + Before 메아리방 2분 + 거부 신호 추가 1분 + After 검증 루프 3분 + 실제 Claude 연결 3분 + 토큰 비용 5분)

**진행 흐름**: 1분 이론으로 "관찰(Observe)이 무엇이냐"의 두 갈래를 확인 → 실습의 등장인물(JS 파일이 에이전트 역할을 하는 이유) → 비교 실험용 공통 재료 만들기(Step 1) → 거부 신호 없는 메아리방 체험(Step 2) → 종료 조건 교체(Step 3) → 검증 루프 체험 — 재시도만(Step 4-1)과 실패 기록 피드백(Step 4-2) → 차이 정리(Step 5) → 가짜 에이전트를 진짜 Claude로 교체(Step 6) → 토큰 비용 심화(Step 6.5).

**언제 보면 좋은가**: [[concept-loop-engineering]] 를 읽은 직후. [[guide-harness-demo]](하네스 5분 데모)의 다음 단계 — 하네스가 "환경"을 설계했다면, 루프는 "메커니즘 자체"를 설계합니다.

**전제**: Node 18+ 설치. (Step 6의 실제 Claude 연결만 Claude Code 로그인 필요 — 나머지는 토큰 0으로 누구나 재현 가능)

!!! tip "명령 실행 방법 (터미널이 처음이라면)"

    - 이 실습의 모든 `bash` 코드블록은 **터미널**(macOS는 "터미널" 앱, Windows는 WSL 또는 Git Bash)에 붙여넣어 실행합니다. Node가 설치돼 있는지는 `node -v`를 입력해 버전이 나오는지로 확인합니다.
    - 코드블록 오른쪽 위의 복사 버튼으로 블록 **전체**를 복사해 터미널에 붙여넣고 `Enter`를 누릅니다. 여러 줄짜리 블록도 한 번에 붙여넣으면 위에서부터 차례로 실행됩니다.
    - `#` 뒤의 글은 설명(주석)이라 셸이 무시합니다. 단, macOS 기본 셸(zsh)은 붙여넣은 명령의 주석을 인식하지 못해 `command not found: #` 오류가 나고 결과까지 틀어질 수 있습니다. 실습을 시작하기 전에 터미널에 아래 한 줄을 먼저 입력합니다. 터미널 창을 새로 열었다면 다시 입력합니다.

        ```bash
        setopt interactivecomments
        ```

        bash를 쓰거나 이 줄을 이미 입력했다면 주석까지 함께 붙여넣어도 됩니다.
    - 모든 명령은 `~/loop-demo` 디렉터리 안에서 실행합니다. 블록 첫 줄의 `cd ~/loop-demo`가 그 위치로 이동시킵니다.

> ✅ **실행 검증됨 (2026-10-04, Node v26, bash·zsh)**: Step 1~4의 블록을 새 디렉터리에서 그대로 실행해 본문 출력과 수치를 확인했습니다 — 후보 (A)는 3개, (B)는 2개 케이스에서 실패하고 (C)만 통과(결정적), 무작위 1회 실행은 약 1/3만 통과(150번 중 55번), Step 4-2 피드백 루프는 60번 모두 3사이클 이내 통과(1사이클 17·2사이클 23·3사이클 20), 4-2 출력 예시는 실제 출력과 글자 단위로 일치. Step 6도 같은 날 Claude Code 2.1.289로 실제 실행했습니다 — 사이클 2에서 통과, 약 20초, 호출 1번 약 $0.05. 이때 `--allowedTools`에 `Write`가 없으면 수정이 막히는 함정을 발견해 본문에 반영했습니다. 6-5 프롬프트 비교(루프 없음·있음 × 권한)도 2026-10-05에 3번씩 실행했습니다. 증적: `raw/ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md`. (명령 구문은 [공식 헤드리스 docs](https://code.claude.com/docs/en/headless) 기준)

---

## 왜 이 실습인가 — 1분 이론

현대 에이전트 루프는 Princeton·Google의 **ReAct(Reason + Act)** 패턴에 뿌리를 둡니다 ([arXiv 2210.03629](https://arxiv.org/abs/2210.03629)):

```
[행동(Act)] → [관찰(Observe)] → [추론(Reason)] → [다음 행동] → …  (종료 조건까지)
```

여기서 **관찰(Observe)이 무엇이냐**가 루프의 운명을 가릅니다.

- 관찰이 **에이전트 자기 보고**("다 됐어요")면 → 모델이 자기 출력에 동의하는 **메아리방**입니다. Sonar의 표현대로 *"두 낙관주의자가 서로 동의하는 것"*.
- 관찰이 **객관적 거부 신호**(테스트·타입체크·빌드)면 → 사실에 부딪혀 교정됩니다. *"A failing build is a fact; an opinion is a starting point"* (실패한 빌드는 사실이고, 의견은 출발점일 뿐).

이 실습은 같은 루프를 **거부 신호 없이 / 있게** 두 번 실행해 그 차이를 눈으로 봅니다.

---

## 실습의 등장인물 — 왜 JS 파일이 에이전트 역할을 하나

이 실습에서 가장 헷갈리는 지점은 "`agent.js`라는 작은 JS 파일을 AI 에이전트라고 생각하라"는 부분입니다. 실습을 시작하기 전에 이 바꿔 끼우기를 먼저 짚습니다.

**실제 상황부터 봅니다.** 개발자가 Claude Code에 "회문 검사 함수 좀 고쳐 줘"라고 맡깁니다. Claude는 파일을 고치고 "구현 완료했습니다"라고 답합니다. 이제 개발자는 그 말을 믿고 끝낼지, 테스트를 돌려 확인할지 정해야 합니다. 확인했는데 틀렸다면 실패 내용을 Claude에게 다시 보여 주고 또 고치게 합니다. 이렇게 "맡기고, 고치고, 보고받고, 확인하는" 일이 되풀이되는 것이 루프입니다.

**그런데 이 장면을 진짜 Claude로 연습하면 세 가지가 곤란합니다.** 첫째, 부를 때마다 돈(토큰)이 듭니다. 둘째, Claude는 이 정도 문제를 거의 한 번에 맞히기 때문에 "틀린 코드가 '완료'로 넘어가는" 장면을 보기 어렵습니다. 6-5에서 9번 실행했더니 9번 모두 첫 수정에 정답이었습니다. 셋째, 매번 답이 달라 두 루프를 같은 조건에서 비교하기 어렵습니다.

**그래서 Claude 자리에 가짜를 앉힙니다.** 비행 조종을 처음 배우는 사람은 진짜 비행기 대신 시뮬레이터로 연습합니다. 진짜 비행기는 비싸고, 고장 상황을 마음대로 만들 수도 없기 때문입니다. 시뮬레이터는 교관이 원할 때 일부러 엔진 고장을 내 주고, 연습생은 그 상황에서 어떻게 대처하는지를 공짜로 몇 번이고 되풀이합니다. 이 실습의 `agent.js`가 그 시뮬레이터입니다. 진짜 Claude처럼 파일을 고치고 "완료했습니다"라고 말하지만, 일부러 3번 중 2번은 틀린 코드를 내놓습니다. 덕분에 "틀렸는데 완료라고 말하는 에이전트"를 상대로 루프가 어떻게 반응하는지를 토큰 없이 마음껏 시험할 수 있습니다. 그리고 Step 6에서 시뮬레이터에서 내려 진짜 Claude에 올라탑니다.

실제 루프의 각 역할을 이 실습에서는 다음 파일들이 맡습니다:

| 실제 루프의 역할 | 실제 개발에서는 | 이 실습에서는 |
|---|---|---|
| 일을 맡아 코드를 고치는 AI 에이전트 | Claude Code | `agent.js` (Step 6부터 진짜 Claude) |
| 에이전트가 고치는 코드 | 프로젝트의 소스 파일 | `solution.js` |
| 에이전트의 "다 했어요" 보고 | Claude의 답 메시지 | `agent.js`가 출력하는 `🤖 에이전트: … 완료했습니다` 줄 |
| 결과가 맞는지 확인하는 검사(거부 신호) | 테스트·빌드·타입체크 | `test.js` |
| 에이전트에게 돌려주는 실패 내용 | 에러 메시지를 복사해 붙여 주기 | `test.log` |
| 루프를 돌리고 끝낼지 정하는 쪽 | 사람, 또는 자동화 스크립트 | 터미널에 붙여넣는 `for`·`if` 블록 |

Step마다 에이전트 자리에 누가 앉고, 끝낼지를 무엇으로 정하는지는 다음과 같습니다:

| Step | 에이전트 자리 | 끝낼지 정하는 근거 | 보는 것 |
|---|---|---|---|
| 2 | `agent.js` (무작위) | 에이전트의 "완료" 보고 | 말만 믿으면 틀린 코드도 통과 |
| 4-1 | `agent.js` (무작위) | `test.js` 통과 | 틀린 코드는 걸러지지만 재시도는 운에 맡김 |
| 4-2 | `agent.js` (`test.log`를 읽고 고침) | `test.js` 통과 | 실패 내용을 돌려주면 시도마다 나아짐 |
| 6 | 진짜 Claude (`claude -p`) | `test.js` 통과 | 같은 루프에 진짜 AI를 끼움 |
| 6-5 | 진짜 Claude (대화 화면) | Claude가 직접 돌린 `test.js` | 프롬프트와 권한으로 Claude 안에 루프를 만듦 |

실습 중에 `agent.js`가 나오면 "지금 Claude가 일하는 중"이라고 바꿔 읽으면 됩니다.

---

## Step 1 — 데모 디렉터리 + 검증 대상 (2분)

위 이론의 두 루프를 같은 조건에서 비교하려면 공통 재료가 필요합니다 — 코드를 내놓는 "에이전트"와, 그 코드를 채점하는 "검증자"입니다. 이 Step에서 그 둘을 만듭니다. 풀 문제는 **회문(palindrome) 검사 함수** — 가짜 "에이전트"가 후보 구현을 내놓고, 테스트가 그것을 채점합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (이 Step에서 새로 만드는 데모 디렉터리)
    - **만들 파일**: `agent.js` — 후보 구현을 무작위로 골라 `solution.js`에 쓰고 "완료"라고 보고하는 가짜 에이전트 / `test.js` — pass/fail을 종료 코드로 돌려주는 거부 신호
    - **실행**: 아래 코드블록 3개를 차례로 붙여넣으면 디렉터리와 두 파일이 생성됩니다. 이 Step에서는 파일만 만들고, `agent.js`는 Step 2에서 `node agent.js`로 처음 실행합니다. `solution.js`가 아직 없으므로 지금 `node test.js`를 돌리면 `Cannot find module './solution'` 오류가 납니다.

먼저 실습 전용 디렉터리를 만들고 이동합니다:

```bash
mkdir -p ~/loop-demo && cd ~/loop-demo
```

**가짜 코딩 에이전트** — 실제 코딩 에이전트처럼 파일을 직접 고치고 끝나면 "완료"라고 보고합니다. 두 가지 방식으로 부를 수 있습니다:

| 부르는 법 | 하는 일 | 쓰는 곳 |
|---|---|---|
| `node agent.js` | 후보 3개 중 하나를 무작위로 골라 `solution.js`에 씀 (1개만 정답) | Step 2, Step 4-1 |
| `node agent.js test.log` | 테스트 실패 기록을 읽고, 원인 하나를 찾아 `solution.js`를 고침 | Step 4-2 |

어느 쪽이든 보고는 늘 "완료"입니다. 자기 결과를 확인하지 않고 자신 있게 말하는 에이전트를 흉내 낸 것입니다. 실패 기록을 읽는 부분은 Step 4-2에서 자세히 봅니다:

```bash
cat > agent.js << 'EOF'
// 가짜 코딩 에이전트: isPalindrome 구현을 solution.js에 쓰고 "완료"라고 보고한다.
// - 그냥 부르면(node agent.js) 후보 3개 중 하나를 무작위로 고른다 — (C)만 정답 (Step 2·4-1).
// - 실패 기록을 넘기면(node agent.js test.log) 실패한 입력과 지금 코드를 보고 원인 하나를 고친다 (Step 4-2).
// - 보고는 결과와 상관없이 늘 "완료" — 자기 결과를 검증하지 않는 에이전트를 흉내.
const fs = require('fs');
const path = require('path');
const candidates = [
  // (A) 정규화 없음 — 대소문자·공백·구두점이 있으면 틀림
  "module.exports = (s) => s === [...s].reverse().join('');",
  // (B) 소문자화만 — 공백·구두점이 있으면 여전히 틀림
  "module.exports = (s) => { const t = s.toLowerCase(); return t === [...t].reverse().join(''); };",
  // (C) 완전 정규화 — 통과
  "module.exports = (s) => { const t = s.toLowerCase().replace(/[^a-z0-9]/g, ''); return t === [...t].reverse().join(''); };",
];
const solutionPath = path.join(__dirname, 'solution.js');
const feedbackPath = process.argv[2];
let pick;

if (feedbackPath && fs.existsSync(feedbackPath)) {
  // 실패 기록의 ❌ 줄에서 입력값만 뽑는다 — 예: isPalindrome("RaceCar") → RaceCar
  const failed = [...fs.readFileSync(feedbackPath, 'utf8').matchAll(/isPalindrome\((".*?")\) =/g)]
    .map((m) => JSON.parse(m[1]));
  const current = fs.existsSync(solutionPath) ? fs.readFileSync(solutionPath, 'utf8') : '';
  const upper = failed.find((s) => /[A-Z]/.test(s));
  const symbol = failed.find((s) => /[^A-Za-z0-9]/.test(s));
  if (upper && !current.includes('toLowerCase')) {
    pick = candidates[1];
    console.log(`🤖 에이전트: 실패한 입력 "${upper}"에 대문자가 있다 → 소문자로 바꾼 뒤 비교하도록 고칩니다`);
  } else if (symbol && !current.includes('replace')) {
    pick = candidates[2];
    console.log(`🤖 에이전트: 실패한 입력 "${symbol}"에 공백·구두점이 있다 → 영문자·숫자만 남기도록 고칩니다`);
  }
}
if (!pick) {
  pick = candidates[Math.floor(Math.random() * candidates.length)];
  if (feedbackPath) console.log('🤖 에이전트: 참고할 실패 기록이 없어 처음부터 구현합니다');
}
fs.writeFileSync(solutionPath, pick + '\n');
console.log('🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅');
EOF
```

**거부 신호 역할의 검증자** — 객관적으로 pass/fail 을 돌려줍니다. 채점 대상은 `solution.js`(에이전트가 고친 후보 구현 — Step 2에서 `agent.js`가 처음 생성)이고, 통과 못 하면 종료 코드 1:

```bash
cat > test.js << 'EOF'
const isPalindrome = require('./solution');
const cases = [
  ['racecar', true],
  ['RaceCar', true],                          // 대소문자만
  ['A man, a plan, a canal: Panama', true],   // 공백·구두점·대소문자
  ['No lemon, no melon', true],               // 공백·구두점
  ['hello', false],
  ['', true],
];
let failed = 0;
for (const [input, expected] of cases) {
  let got;
  try { got = isPalindrome(input); } catch (e) { got = 'ERROR:' + e.message; }
  if (got !== expected) {
    console.error(`  ❌ isPalindrome(${JSON.stringify(input)}) = ${got} (기대값 ${expected})`);
    failed++;
  }
}
if (failed > 0) { console.error(`FAIL — ${failed}개 케이스 실패`); process.exit(1); }
console.log('PASS — 6개 케이스 전부 통과');
EOF
```

> 후보 (A)는 `"RaceCar"`·`"A man, a plan…"`·`"No lemon…"` 3개, (B)는 공백·구두점이 있는 2개 케이스에서 깨지고, (C)만 전부 통과합니다. 코드가 나아질수록 실패 수가 3 → 2 → 0으로 줄어듭니다.

---

## Step 2 — Before: 거부 신호 없는 루프 (메아리방) (2분)

재료가 준비됐으니 먼저 나쁜 쪽부터 체험합니다. 이번 루프는 에이전트에게 코드를 받고, 에이전트가 "다 됐다"고 말하면 그 말만 믿고 끝납니다. 끝낼지 말지를 에이전트의 말이 정하는 루프, 곧 메아리방입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 1에서 만든 디렉터리)
    - **만들 파일**: `solution.js` — 에이전트가 고친 후보 구현 (`agent.js`가 자동 생성)
    - **실행**: 아래 블록을 붙여넣고 5~10번 반복 실행합니다. 결과가 매번 달라집니다.

아래 블록은 두 부분으로 나뉩니다. ①이 메아리방 루프가 하는 일의 전부이고, ②는 루프가 끝난 뒤 **루프가 하지 않은 채점을 우리가 직접 해 보는** 부분입니다:

```bash
cd ~/loop-demo

# ① 메아리방 루프 — 에이전트를 부르고, 에이전트의 말로 끝낼지 정한다
if node agent.js | grep "완료"; then          # 종료 조건 = 에이전트의 보고에 "완료"가 있는가
  echo "🏁 루프 종료 — 에이전트가 완료라고 했으므로"
fi

# ② 루프 밖 — 루프가 건너뛴 채점을 우리가 직접 해 본다
node test.js
```

①의 `if` 줄이 이 루프의 종료 조건입니다. 가운데 `|`(파이프)는 앞 명령이 화면에 낼 출력을 뒤 명령에 넘겨주는 기호입니다. `node agent.js`가 `solution.js`를 고치고 보고 문장을 내놓으면, 그 문장이 파이프를 타고 `grep "완료"`로 넘어가고, `grep`은 문장에 "완료"가 있는지 봅니다. 있으면 문장을 화면에 보여 주고 참을 돌려주므로 루프가 끝납니다. `agent.js`는 무엇을 골랐든 늘 "완료"라고 말하므로 이 조건은 언제나 참입니다. `🏁` 줄은 루프가 끝났음을 알리는 진행 표시입니다. 출력 예시는 다음과 같습니다:

```
🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅
🏁 루프 종료 — 에이전트가 완료라고 했으므로
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 2개 케이스 실패
```

마지막 3줄은 실행할 때마다 다릅니다. (A)가 뽑히면 `"RaceCar"`까지 3개가 실패하고, (C)가 뽑히면 `PASS`가 나옵니다.

결과는 ②의 출력으로 갈립니다:

| ②의 출력 | 뽑힌 후보 | 뜻 |
|---|---|---|
| `PASS — 6개 케이스 전부 통과` | (C) | 정답이 나와 보고가 사실과 일치함 |
| `❌ isPalindrome(...)` 줄들 + `FAIL — N개 케이스 실패` | (A) 또는 (B) | 코드가 틀렸는데 ①은 이미 "완료"로 끝남 |

몇 번 돌려 보면 핵심이 보입니다. **①은 코드가 맞든 틀리든 매번 똑같이 "완료"라고 말합니다.** 정답은 후보 3개 중 (C) 하나뿐이라 대략 3번 중 2번은 ②에서 FAIL이 나옵니다. 이 문서를 검증할 때 20번 돌렸더니 13번이 FAIL이었습니다. 실제 루프에는 ②가 없으므로, 그 13번은 깨진 코드가 "완료"로 넘어간 셈입니다.

위 블록을 손으로 10번 붙여넣기가 번거로우면, 아래 블록을 통째로 붙여넣어 같은 일을 10번 반복하고 결과만 한 줄씩 볼 수 있습니다. 블록의 줄마다 붙은 주석이 각 줄의 역할입니다:

```bash
cd ~/loop-demo
for i in $(seq 1 10); do                  # i에 1, 2, …, 10을 차례로 넣으며 do~done 사이를 10번 반복
  node agent.js > /dev/null               # 에이전트 실행. "> /dev/null"은 화면 출력을 버린다는 뜻 (보고 문장은 늘 같으니 숨김)
  if node test.js > /dev/null 2>&1; then  # 채점. "2>&1"은 오류 출력까지 함께 버린다는 뜻 → 결과(종료 코드)만 남음
    echo "${i}회: PASS"
  else
    echo "${i}회: FAIL"
  fi
done
```

출력은 `1회: FAIL`, `2회: PASS`처럼 10줄이 나오고, 실행할 때마다 PASS와 FAIL의 배치가 달라집니다. 화면에서는 숨겼지만 10번 모두 에이전트는 "완료"라고 보고했습니다. 그런데 PASS는 대략 3~4줄뿐입니다.

!!! note "방금 본 것 — 메아리방"

    에이전트는 10번 모두 "완료"라고 했지만 실제로 맞은 것은 3~4번뿐입니다. 이 루프는 결과를 확인하지 않고 "끝났다"는 말로 완료를 판정했으므로, 나머지 6~7번은 틀린 코드가 "완료"로 넘어갔습니다. [[concept-loop-engineering]]의 설계 질문 4 "출력을 어떻게 검증하는가"에서 나쁜 답에 해당합니다.

---

## Step 3 — 거부 신호를 루프에 넣기 (1분)

Step 2가 무너진 곳은 코드 생성이 아니라 **끝내는 조건**이었습니다. 그래서 고칠 곳도 하나입니다. Step 2에서 ②로 루프 밖에 빼 두었던 `node test.js`를 루프 안으로 들여와, 테스트가 통과할 때만 끝나게 합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo`
    - **실행**: 아래 명령 한 줄로 루프가 읽게 될 "종료 코드"를 직접 눈으로 확인합니다. 코드를 고치는 일은 Step 4에서 합니다.

루프가 테스트 결과를 읽으려면 테스트가 결과를 사람용 문장이 아니라 **숫자**로 돌려줘야 합니다. 그 숫자가 종료 코드(exit code)입니다. `test.js`는 통과하면 0, 실패하면 1로 끝나도록 Step 1에서 만들어 두었습니다. `$?`는 바로 앞 명령의 종료 코드를 담는 셸 변수입니다. 아래 블록은 Step 2의 종료 조건(에이전트의 말)과 Step 4의 종료 조건(테스트)이 각각 어떤 숫자를 돌려주는지 나란히 보여 줍니다:

```bash
cd ~/loop-demo
node agent.js | grep -q "완료"; echo "에이전트의 말로 판정: $?"
node test.js > /dev/null 2>&1;  echo "테스트로 판정:       $?"
```

셸의 `if`는 이 숫자가 0일 때만 참으로 봅니다. 몇 번 실행해 보면 에이전트의 말은 매번 0(완료)인데, 테스트는 0(통과)과 1(실패)이 번갈아 나옵니다. 같은 `solution.js`를 두고 에이전트는 늘 "다 됐다"고 하고, 테스트만 틀렸다고 말해 줍니다. 그래서 Step 4에서는 Step 2의 ① 루프를 다음과 같이 바꿉니다:

| | Step 2 (메아리방) | Step 4 (검증 루프) |
|---|---|---|
| 끝낼지 정하는 줄 | `if node agent.js \| grep "완료"; then` | `if node test.js; then ... break; fi` |
| 무엇을 보고 끝내나 | 에이전트의 말 | 테스트의 종료 코드 0 |
| 틀린 코드가 나오면 | 그대로 "완료" | 종료 코드 1 → 끝내지 않고 다시 생성 |

!!! note "방금 본 것 — 루프는 숫자만 읽는다"

    루프가 끝낼지 말지는 결국 `0`이냐 아니냐로 정해집니다. 에이전트의 말은 늘 `0`이라 아무것도 걸러 내지 못하고, 테스트의 종료 코드만 틀린 코드를 `1`로 걸러 냅니다. 루프가 무엇을 관찰(Observe)하느냐를 에이전트의 말에서 객관적인 사실로 바꾸는 일이 Step 4에서 할 일입니다.

---

## Step 4 — After: 검증 루프 (통과까지 재시도) (3분)

Step 3의 결정을 실제 루프로 옮깁니다. 두 단계로 나눠 봅니다. 4-1은 끝내는 조건만 테스트로 바꾼 루프이고, 4-2는 거기에 더해 테스트의 실패 기록을 에이전트에게 돌려주는 루프입니다.

### 4-1. 테스트로만 끝내기 — 재시도는 하지만 배우지는 않는다

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 1의 `agent.js`·`test.js` 그대로 사용)
    - **실행**: 아래 블록을 붙여넣어 실행합니다. 몇 번 반복해도 좋습니다.

Step 2와 같은 에이전트를 부르지만, 끝낼지는 `node test.js`의 종료 코드로만 정합니다. 에이전트는 사이클마다 "완료"라고 보고하지만 루프는 그 말을 근거로 쓰지 않습니다. `echo` 줄은 몇 번째 사이클인지와 통과·재시도 여부를 보여 주는 진행 표시입니다:

```bash
cd ~/loop-demo
for i in $(seq 1 8); do
  echo "── 사이클 $i ──"
  node agent.js                        # Act:     에이전트가 solution.js를 고치고 "완료" 보고
  if node test.js; then                # Observe: 거부 신호(테스트)가 '사실'을 반환
    echo "✅ 사이클 $i 에서 통과 — 종료 조건 충족, 루프 종료"
    break
  fi
  echo "↻ 실패 — 거부 신호가 루프를 한 번 더 돌린다"
done
```

Step 2의 10회 반복 블록과 같은 `for` 문인데, 두 가지가 다릅니다. 첫째, `> /dev/null`이 없어서 에이전트의 보고와 테스트 결과가 모두 화면에 보입니다. 둘째, 테스트가 통과하면 `break`가 남은 반복을 건너뛰고 루프를 바로 빠져나갑니다. 그래서 `seq 1 8`은 "8번 돌린다"가 아니라 "많아야 8번까지 시도한다"는 뜻입니다.

!!! note "방금 본 것 — 거짓 '완료'는 막았지만 같은 실수를 반복할 수 있다"

    사이클마다 에이전트가 "완료"라고 해도 테스트가 FAIL이면 루프는 끝나지 않았습니다. 틀린 코드가 "완료"로 넘어가는 일은 사라졌습니다. 하지만 다음 사이클의 에이전트는 방금 무엇이 틀렸는지 모른 채 다시 무작위로 고릅니다. 운이 나쁘면 같은 (A)를 연달아 내기도 하고, 8번 내내 (C)가 안 나올 확률도 (2/3)⁸ ≈ 4% 있습니다. 이건 루프라기보다 "될 때까지 주사위 다시 던지기"에 가깝습니다.

### 4-2. 실패 기록을 돌려주기 — 진짜 루프

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo`
    - **만들 파일**: `test.log` — 테스트 결과를 담아 다음 사이클의 에이전트에게 넘기는 파일 (아래 블록이 자동 생성)
    - **실행**: 아래 블록을 붙여넣어 실행합니다. 첫 시도에 (C)가 나오면 사이클 1에서 바로 끝나므로, 고쳐 가는 모습이 보일 때까지 몇 번 다시 실행합니다.

4-1과 달라진 곳은 두 줄입니다. 테스트 결과를 화면 대신 `test.log` 파일에 남기고(`> test.log 2>&1`), 다음 사이클에서 에이전트를 부를 때 그 파일을 넘깁니다(`node agent.js test.log`):

```bash
cd ~/loop-demo
rm -f test.log                         # 지난 실행의 실패 기록을 지우고 새로 시작
for i in $(seq 1 8); do
  echo "── 사이클 $i ──"
  node agent.js test.log               # Act:     에이전트가 실패 기록을 읽고 solution.js를 고침
  if node test.js > test.log 2>&1; then  # Observe: 테스트 결과를 test.log에 남김
    cat test.log                       # 결과를 화면에도 보여 줌
    echo "✅ 사이클 $i 에서 통과 — 루프 종료"
    break
  fi
  cat test.log
  echo "↻ 실패 — 이 기록(test.log)이 다음 사이클 에이전트의 입력이 된다"
done
```

첫 시도에 (A)가 나왔을 때의 출력입니다. 사이클마다 에이전트가 실패 기록에서 원인 하나를 찾아 고치고, 실패 수가 3 → 2 → 0으로 줄어듭니다:

```
── 사이클 1 ──
🤖 에이전트: 참고할 실패 기록이 없어 처음부터 구현합니다
🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅
  ❌ isPalindrome("RaceCar") = false (기대값 true)
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 3개 케이스 실패
↻ 실패 — 이 기록(test.log)이 다음 사이클 에이전트의 입력이 된다
── 사이클 2 ──
🤖 에이전트: 실패한 입력 "RaceCar"에 대문자가 있다 → 소문자로 바꾼 뒤 비교하도록 고칩니다
🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 2개 케이스 실패
↻ 실패 — 이 기록(test.log)이 다음 사이클 에이전트의 입력이 된다
── 사이클 3 ──
🤖 에이전트: 실패한 입력 "A man, a plan, a canal: Panama"에 공백·구두점이 있다 → 영문자·숫자만 남기도록 고칩니다
🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅
PASS — 6개 케이스 전부 통과
✅ 사이클 3 에서 통과 — 루프 종료
```

에이전트가 `test.log`에서 하는 일은 단순합니다. ❌ 줄에서 실패한 입력값을 뽑고, 지금 `solution.js`에 없는 처리를 하나 찾습니다. 입력에 대문자가 있는데 소문자 변환이 없으면 그것을 넣고, 공백·구두점이 있는데 걸러 내는 처리가 없으면 그것을 넣습니다. 한 사이클에 한 가지씩만 고치는 것도 실제 에이전트가 흔히 일하는 방식입니다.

!!! note "방금 본 것 — 루프 한 바퀴의 네 동작"

    사이클 하나가 ReAct의 동작을 한 번씩 거칩니다. 에이전트가 코드를 고치고(행동, Act), 테스트가 결과를 `test.log`에 남기고(관찰, Observe), 다음 사이클의 에이전트가 그 기록을 읽고 원인을 찾아(추론, Reason) 다시 고칩니다. 4-1과 비교하면 차이가 분명합니다. 4-1은 실패를 막기만 했고, 4-2는 실패를 다음 시도의 재료로 썼습니다. 그래서 4-1은 운에 따라 8사이클을 다 쓰기도 하지만, 4-2는 많아야 3사이클이면 끝납니다.

`seq 1 8`이라는 **반복 상한**(최대 8사이클)에 주목합니다. 상한 값은 한 사이클의 비용에 맞춰 정하며, 상한 없는 루프는 에이전트가 끝내 못 고치는 문제를 만났을 때 토큰·시간을 폭주시킵니다. 종료 조건은 ① 검증 통과(goal) ② 반복 상한(resource)이 함께 있어야 하고, ③ 토큰 예산(budget)은 Step 6.5에서 더합니다.

---

## Step 5 — 차이 표 (직접 채워보기, 30초)

두 루프를 모두 실행해 봤으니, 관찰한 차이를 직접 채워 넣으며 정리합니다. 요약을 읽는 것보다 방금 본 것을 스스로 언어화해야 기억에 남습니다.

|  | Before (거부 신호 없음) | After (테스트 = 거부 신호) |
|---|---|---|
| 깨진 코드로 종료될 수 있나 | __ | __ |
| 종료 조건의 정체 | __ (에이전트 자기 보고?) | __ (객관적 검증?) |
| 같은 실수를 반복하나 | __ | __ |
| 사람이 매번 확인해야 하나 | __ | __ |

**한 줄 소감**: ____________________________________________

---

## Step 6 — 실제 Claude로 (선택, 3분)

Step 4-2의 가짜 에이전트는 미리 정해 둔 두 가지 원인(대문자, 공백·구두점)만 알아봅니다. 처음 보는 실패를 만나면 고치지 못합니다. 이 Step에서는 가짜 에이전트 자리에 **진짜 Claude**를 넣습니다. [등장인물](#실습의-등장인물--왜-js-파일이-에이전트-역할을-하나)에서 말한 대로, 시뮬레이터에서 내려 진짜 비행기에 타는 단계입니다. 루프 모양은 Step 4-2와 같고, `node agent.js test.log`로 실패 기록을 넘기던 자리가 `cat test.log | claude -p "…"`로 바뀔 뿐입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 1의 `test.js` 그대로 사용, `agent.js`는 쓰지 않음)
    - **만들 파일**: `solution.js` — 일부러 틀린 구현으로 덮어쓰고 Claude가 고치게 합니다 / `test.log` — Claude에게 넘길 실패 기록
    - **실행**: 6-1에서 준비를 확인한 뒤 6-2의 블록을 붙여넣습니다. **토큰(사용량)이 듭니다** — 실측 기준 Claude 호출 1~2번, 약 20초.

### 6-1. 준비 확인

Claude Code가 설치돼 있고 로그인돼 있어야 합니다. 아래 두 명령으로 확인합니다:

```bash
claude --version
claude -p "안녕이라고만 답해"
```

| 결과 | 뜻 | 할 일 |
|---|---|---|
| 버전 번호(예: `2.1.289 (Claude Code)`)가 나오고, 두 번째 명령이 `안녕`이라고 답함 | 준비 완료 | 6-2로 진행 |
| `command not found: claude` | Claude Code가 설치되지 않음 | [공식 설치 안내](https://code.claude.com/docs/en/setup)대로 설치 |
| 로그인하라는 안내가 나옴 | 로그인이 안 됨 | 터미널에 `claude`를 입력해 대화 화면에서 로그인한 뒤 `/exit`로 나옴 |

`claude -p`의 `-p`는 `--print`의 줄임으로, 대화 화면을 띄우지 않고 질문 하나를 처리한 뒤 답만 출력하고 끝나는 방식입니다. 이를 헤드리스(headless) 실행이라고 합니다. 한 번 실행하고 끝나므로 `for` 루프 안에 넣을 수 있습니다.

### 6-2. 루프 실행

블록을 통째로 붙여넣습니다. 줄마다 붙은 주석이 각 줄의 역할입니다:

```bash
cd ~/loop-demo
MAX=5                                  # 반복 상한 — 많아야 5번까지 시도
# 일부러 틀린 구현으로 시작한다 (후보 (A)와 같음 → 3개 케이스 실패)
echo "module.exports = (s) => s === [...s].reverse().join('');" > solution.js

for i in $(seq 1 $MAX); do
  echo "── 사이클 $i ──"
  if node test.js > test.log 2>&1; then  # 먼저 테스트 — 통과하면 Claude를 부르지 않고 끝낸다
    cat test.log
    echo "✅ 사이클 $i 에서 통과 — 루프 종료"
    break
  fi
  cat test.log
  if [ "$i" -eq "$MAX" ]; then         # 상한에 닿으면 더 부르지 않고 사람에게 넘긴다
    echo "⛔ 반복 상한($MAX회)에 도달 — 여기서 멈추고 사람이 확인한다"
    break
  fi
  echo "↻ 실패 — 실패 기록을 Claude에게 넘겨 수정을 맡긴다"
  cat test.log | claude -p "solution.js의 isPalindrome 구현이 아래 테스트에서 실패한다. 실패 원인을 찾아 solution.js만 고쳐라. 테스트 파일은 고치지 말고, 테스트는 직접 실행하지 마라. 대소문자·공백·구두점은 무시해야 한다." \
    --allowedTools "Read,Edit,Write"
done
```

Step 4-2와 순서가 조금 다릅니다. 4-2는 에이전트를 먼저 부르고 테스트했지만, 여기서는 **테스트를 먼저** 돌립니다. 테스트는 공짜이고 Claude 호출은 비용이 들기 때문에, 이미 통과한 코드라면 Claude를 아예 부르지 않기 위해서입니다. 상한에 닿았을 때도 마지막 Claude 호출을 건너뛰고 멈춥니다. 고친 결과를 확인할 기회가 없는 호출은 비용만 들기 때문입니다.

`claude -p` 줄을 나눠 읽으면 다음과 같습니다:

| 부분 | 뜻 |
|---|---|
| `cat test.log \|` | 실패 기록을 파이프로 Claude에게 넘깁니다. Claude는 따옴표 안의 지시와 함께 이 기록을 받습니다 |
| `"solution.js의 … 무시해야 한다."` | 지시문입니다. 고칠 파일을 하나로 좁히고, 테스트를 고쳐서 통과시키는 꼼수를 막습니다. 테스트 실행은 루프가 하므로 Claude에게는 맡기지 않습니다 |
| `\` | 명령이 다음 줄로 이어진다는 표시입니다 |
| `--allowedTools "Read,Edit,Write"` | Claude가 묻지 않고 쓸 수 있는 도구 목록입니다. 파일 읽기(Read)·부분 수정(Edit)·전체 쓰기(Write)만 허용하고, 셸 명령 같은 나머지는 막습니다 |

### 6-3. 출력 읽기

2026-10-04에 실제로 실행한 출력입니다. Claude가 실패 원인을 설명하고 `solution.js`를 고친 뒤, 사이클 2의 테스트가 통과를 확인했습니다. Claude의 답 문장은 실행할 때마다 조금씩 다릅니다:

```
── 사이클 1 ──
  ❌ isPalindrome("RaceCar") = false (기대값 true)
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 3개 케이스 실패
↻ 실패 — 실패 기록을 Claude에게 넘겨 수정을 맡긴다
`solution.js`만 고쳤습니다. 지시대로 테스트는 실행하지 않았습니다.

**원인:** 기존 코드는 입력 문자열을 그대로 뒤집어서 비교했습니다. 그래서 `"RaceCar"`처럼
대소문자가 섞이거나 공백·구두점이 있으면 회문이어도 `false`가 나왔습니다.

**수정:** 비교 전에 문자열을 소문자로 바꾸고, 글자와 숫자만 남기고 나머지는 모두 지우도록 했습니다.
(… 고친 코드 …)
── 사이클 2 ──
PASS — 6개 케이스 전부 통과
✅ 사이클 2 에서 통과 — 루프 종료
```

Claude가 무엇을 고쳤는지는 `cat solution.js`로 직접 봅니다. 실측에서는 아래처럼 고쳤습니다:

```js
module.exports = (s) => {
  const t = s.toLowerCase().replace(/[^\p{L}\p{N}]/gu, '');
  return t === [...t].reverse().join('');
};
```

가짜 에이전트의 정답 (C)는 `[^a-z0-9]`로 영문자와 숫자만 남겼는데, Claude는 `\p{L}\p{N}`(모든 언어의 글자와 숫자)을 써서 한글 같은 입력도 처리하게 했습니다. 정해진 후보 안에서만 고르는 가짜 에이전트와 달리, 진짜 에이전트는 실패 기록을 읽고 자기 방식으로 고칩니다.

!!! note "방금 본 것 — 같은 루프, 진짜 추론"

    루프 코드는 Step 4-2와 거의 같은데, 추론(Reason)을 맡은 쪽이 미리 짜 둔 규칙에서 언어 모델로 바뀌었습니다. 실패를 언어로 받아 다음 시도를 고치는 이 방식이 **Reflexion·Self-Refine**의 핵심입니다 ([Reflexion](https://arxiv.org/abs/2303.11366) · [Self-Refine](https://arxiv.org/abs/2303.17651)). 그리고 Claude가 "고쳤습니다"라고 말해도 루프는 그 말로 끝나지 않았습니다. 끝을 정한 것은 사이클 2의 `PASS`였습니다. Step 2의 메아리방과 갈리는 지점이 바로 여기입니다.

### 6-4. 막힐 때

| 증상 | 원인 | 해결 |
|---|---|---|
| Claude가 "파일 쓰기 권한이 거부돼 고치지 못했습니다"라고 답하고, 같은 실패가 사이클마다 반복됨 | `--allowedTools`에 `Write`가 빠짐 — Claude가 파일 전체를 다시 쓰려 하면 `Edit`만으로는 막힘 (실측) | `--allowedTools "Read,Edit,Write"`가 그대로 들어갔는지 확인 |
| 위와 같은 권한 거부가 `Write`를 넣어도 계속됨 | Claude Code 대화 화면 안에서(`!` 명령 등) 실행해 바깥 세션의 권한 설정을 물려받음 | Claude Code 밖의 일반 터미널 창에서 실행 |
| 아무 출력 없이 오래 멈춤 | Claude가 응답을 생성 중이거나 네트워크 지연 | 1분 정도 기다리고, 그래도 멈춰 있으면 `Ctrl+C`로 중단 후 6-1부터 확인 |
| 5사이클 모두 실패하고 `⛔ 반복 상한` 출력 | Claude가 끝내 못 고침 | 상한이 제 역할을 한 것입니다. `cat solution.js`로 결과를 보고 사람이 판단합니다 |

> ⚠️ **토큰 비용**: Claude를 부를 때마다 비용이 듭니다. 이 실습은 실측에서 호출 1번에 약 $0.05(API 종량제 환산, Opus 5.5 기준, 2026-10-04)였고, 구독 요금제라면 그만큼 사용량 한도를 씁니다. 저장소가 크거나 실패가 복잡하면 호출당 비용이 훨씬 커집니다. 그래서 반복 상한(`MAX=5`)과 "테스트 먼저" 순서가 필요합니다. Addy Osmani의 신중론 — *"토큰 비용에 절대적으로 주의"* — 과 [[src-copilot-token-pricing]]의 종량제 전환이 같은 맥락입니다. 다음 Step 6.5에서 이 비용을 더 자세히 봅니다.

### 6-5. 프롬프트로 루프 맡기기 — 대화 화면에서

6-2까지는 셸의 `for` 문이 루프를 돌렸습니다. 실제로는 Claude Code 대화 화면에 프롬프트를 입력해 일을 맡기는 경우가 더 많습니다. 이때 루프는 Claude 안에서 돌고, 그 루프를 만드는 것은 **프롬프트와 권한** 두 가지입니다. 여기서는 루프를 시키지 않는 프롬프트와 루프를 시키는 프롬프트를 나란히 써 보고, 실제로 무엇이 달라지는지 봅니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo`
    - **실행**: 아래 준비 블록으로 `solution.js`를 다시 틀린 코드로 되돌리고 대화 화면을 엽니다. 프롬프트 ①과 ② 중 하나를 붙여넣고, 다른 쪽을 해 보려면 `/exit`로 나와 준비 블록부터 다시 실행합니다. **토큰이 듭니다** — 실측 기준 프롬프트 1번에 $0.04~0.18.

```bash
cd ~/loop-demo
echo "module.exports = (s) => s === [...s].reverse().join('');" > solution.js   # 다시 틀린 코드로
claude                                 # 대화 화면 열기
```

**프롬프트 ① — 루프 없음.** 고쳐 달라고만 하고, 끝났는지 어떻게 확인할지는 말하지 않습니다:

```text
solution.js의 isPalindrome 함수가 제대로 동작하지 않아. 고쳐줘.
```

**프롬프트 ② — 루프 있음.** 같은 부탁에 끝내는 조건과 반복 규칙을 붙입니다:

```text
solution.js의 isPalindrome 함수가 제대로 동작하지 않아. 고쳐줘.
완료 조건: `node test.js`가 "PASS"를 출력해야 한다.
- 고친 뒤 반드시 `node test.js`를 직접 실행해 확인해.
- 실패하면 출력을 읽고 원인을 찾아 다시 고친 뒤 또 실행해. 통과할 때까지 반복해.
- 5번 고쳐도 통과하지 못하면 멈추고, 마지막 실패 출력을 보여 줘.
- test.js는 고치지 마.
- 마지막에 통과한 테스트 출력을 그대로 보여 줘.
```

②의 각 줄은 이 실습에서 셸로 짰던 루프의 부품을 말로 옮긴 것입니다:

| ②의 줄 | 루프에서 맡는 역할 | 셸 루프에서 대응하는 부분 |
|---|---|---|
| 완료 조건 (`node test.js`가 "PASS" 출력) | 종료 조건(goal) — 무엇을 보고 끝낼지 | `if node test.js; then ... break` |
| 고친 뒤 반드시 직접 실행해 확인해 | 관찰(Observe) | `node test.js > test.log` |
| 실패하면 출력을 읽고 다시 고쳐 | 추론(Reason)과 재시도 | `cat test.log \| claude -p` |
| 5번 고쳐도 안 되면 멈추고 보고해 | 반복 상한(resource)과 사람에게 넘기기 | `MAX=5`, `⛔ 반복 상한` |
| test.js는 고치지 마 | 거부 신호 보호 — 테스트를 고쳐 통과시키는 꼼수 차단 | Step 6 지시문의 같은 문장 |
| 통과한 테스트 출력을 그대로 보여 줘 | 증거 — "통과했다"는 말 대신 출력 원문 | `cat test.log` |

대화 화면에서 Claude가 `node test.js`를 실행하려 하면 실행해도 되는지 묻는 창이 뜹니다. **Yes**를 고르면 Claude가 테스트를 돌리고, **No**를 고르면 테스트 없이 진행합니다. 이 선택이 아래 실험의 "권한" 조건입니다.

#### 실험 결과 — 9번 실행해 본 것

같은 시작 상태(후보 (A), 3개 케이스 실패)에서 세 조건을 3번씩 헤드리스로 실행했습니다. 프롬프트 ①은 테스트 실행 권한이 없을 때(No를 고른 경우)와 있을 때(Yes) 두 조건으로 나눴습니다:

| 조건 | Claude가 한 일 | Claude의 마지막 보고 | 실행 후 실제 테스트 | 시간 · 비용 (3번 범위) |
|---|---|---|---|---|
| ① + 권한 없음 | 파일을 찾아 고친 뒤 `node test.js`를 실행하려다 거부됨 | "고쳤지만 테스트로 확인하지 못했다" | 3번 모두 PASS | 127~137초 · $0.06~0.18 |
| ① + 권한 있음 | `ls`·`grep`으로 확인 방법을 찾고, 고치고, 스스로 테스트 실행 | "6개 케이스가 모두 통과했다"는 문장 | 3번 모두 PASS | 12~16초 · $0.06~0.10 |
| ② + 권한 있음 | `solution.js`·`test.js`를 바로 읽고, 고치고, 테스트 실행 | 통과 사실 + `PASS — 6개 케이스 전부 통과` 출력 원문 | 3번 모두 PASS | 10~14초 · $0.04~0.15 |

!!! note "방금 본 것 — 루프를 만드는 건 권한과 완료 조건"

    이 문제는 Claude에게 쉬워서 9번 모두 첫 수정에 정답이 나왔고, "실패 → 다시 고치기" 반복은 한 번도 일어나지 않았습니다. 그런데도 세 조건은 "완료"를 보고하는 방식에서 갈렸습니다.

    - **권한이 없으면 확인할 수 없습니다.** ①+권한 없음에서 Claude는 3번 모두 스스로 테스트를 돌리려 했지만 막혔고, "확인하지 못했다"고 정직하게 말하고 끝났습니다. 코드는 맞았지만 그걸 아는 사람은 아무도 없었습니다. 확인되지 않은 "완료"라는 점에서 Step 2의 메아리방과 같은 처지입니다.
    - **권한만 줘도 요즘 Claude는 스스로 확인합니다.** ①+권한 있음에서는 루프를 시키지 않았는데도 3번 모두 테스트를 돌렸습니다. 이 실험에서 결과를 가장 크게 가른 것은 프롬프트 문구보다 테스트 실행 권한이었습니다.
    - **완료 조건은 "말"을 "증거"로 바꿉니다.** ①+권한 있음은 테스트를 돌리고도 "통과했다"는 문장으로만 보고했습니다(출력 원문 0/3). ②는 3번 모두 출력 원문을 붙였고, 무엇으로 확인할지 찾아다니지 않고 바로 `test.js`를 읽었습니다. 사람이 보고를 믿는 대신 출력을 직접 볼 수 있게 된 것입니다.
    - **상한과 "테스트 수정 금지"는 이번에 드러나지 않았습니다.** 문제가 쉬워 반복이 없었기 때문입니다. 이 둘은 Claude가 끝내 못 고치는 어려운 문제에서 루프가 헛돌거나 테스트를 고쳐 통과시키는 일을 막는 장치이고, 이번 실험으로 그 효과를 확인하지는 못했습니다.

    정리하면, 대화 화면에서 루프를 맡길 때는 **테스트를 실행할 권한을 주고**(허락 창에서 Yes), 프롬프트에 **무엇이 통과하면 끝인지와 그 출력을 보여 달라는 요구**를 넣습니다.

같은 실험을 헤드리스로 재현하려면 아래 블록을 씁니다. 프롬프트 ②는 여러 줄이라 파일로 저장해 넘기고, 각 실행 전에 `solution.js`를 되돌립니다:

```bash
cd ~/loop-demo
cat > prompt-loop.txt << 'EOF'
solution.js의 isPalindrome 함수가 제대로 동작하지 않아. 고쳐줘.
완료 조건: `node test.js`가 "PASS"를 출력해야 한다.
- 고친 뒤 반드시 `node test.js`를 직접 실행해 확인해.
- 실패하면 출력을 읽고 원인을 찾아 다시 고친 뒤 또 실행해. 통과할 때까지 반복해.
- 5번 고쳐도 통과하지 못하면 멈추고, 마지막 실패 출력을 보여 줘.
- test.js는 고치지 마.
- 마지막에 통과한 테스트 출력을 그대로 보여 줘.
EOF
reset_solution() { echo "module.exports = (s) => s === [...s].reverse().join('');" > solution.js; }

reset_solution; claude -p "solution.js의 isPalindrome 함수가 제대로 동작하지 않아. 고쳐줘." --allowedTools "Read,Edit,Write"                      # ① + 권한 없음
reset_solution; claude -p "solution.js의 isPalindrome 함수가 제대로 동작하지 않아. 고쳐줘." --allowedTools "Read,Edit,Write,Bash(node test.js)"   # ① + 권한 있음
reset_solution; claude -p "$(cat prompt-loop.txt)" --allowedTools "Read,Edit,Write,Bash(node test.js)"                                         # ② + 권한 있음
```

실행별 도구 호출 순서·턴·비용과 Claude의 최종 답 원문은 증적 파일 `raw/ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md`에 남겨 두었습니다.

---

## Step 6.5 — 토큰 비용 심화 (무인 루프의 진짜 리스크) (선택, 5분)

검증 루프의 장점은 "사람이 지켜보지 않아도 통과할 때까지 알아서 돈다"는 것입니다. 그런데 이 장점이 그대로 비용 위험이 됩니다. 사람이 안 보는 사이에도 루프는 Claude를 부르고, 부를 때마다 돈이 나갑니다. Addy Osmani는 이렇게 경고합니다:

> *"Verification is still on you. A loop running unattended is also a loop making mistakes unattended."* (검증은 여전히 당신 몫이고, 무인으로 도는 루프는 무인으로 실수하는 루프이기도 합니다.)

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 6과 같은 디렉터리)
    - **만들 파일**: `claude.json` — Claude 호출 1번의 결과와 비용이 담긴 파일 (아래 블록이 자동 생성)
    - **실행**: 6.5-1·6.5-2는 읽기만 합니다. 6.5-3의 블록은 먼저 `BUDGET=0`으로 토큰 없이 멈추는 모습을 보고, 원하면 `BUDGET=0.30`으로 실제 실행합니다.

### 6.5-1. 비용은 이렇게 계산합니다

루프 한 번의 비용은 **"Claude를 부른 횟수 × 한 번 부를 때의 비용"**입니다. 이 실습에서 실제로 잰 값으로 몇 가지 상황을 계산해 보면 다음과 같습니다:

| 상황 | Claude 호출 수 | 1회 비용 | 합계 |
|---|---|---|---|
| Step 6이 정상으로 돈 경우 (실측) | 1번 | $0.05~0.15 | $0.05~0.15 |
| `--allowedTools`에 `Write`가 빠져 매번 수정이 막힌 경우 (실측, 상한 5) | 4번 | $0.05~0.18 | 약 $0.20~0.70, 고친 것은 없음 |
| 같은 고장인데 상한 없이 1분에 1번씩 밤새 8시간 돈 경우 (계산) | 480번 | 약 $0.05 | 약 $24, 고친 것은 없음 |

두 번째 줄이 이 실습을 검증하면서 실제로 겪은 일입니다. Claude는 매 사이클 "권한이 없어 고치지 못했습니다"라고 답했고, 루프는 그 답을 읽지 않고 상한까지 Claude를 다시 불렀습니다. 상한이 없었다면 세 번째 줄처럼 아무 진전 없이 돈만 나갔을 것입니다.

### 6.5-2. 한 번 부를 때의 비용을 키우는 것

| 요인 | 어떻게 커지나 | 줄이는 법 |
|---|---|---|
| **넘기는 내용의 양** | 사이클마다 저장소 전체나 긴 로그 전체를 다시 넘김 | 실패한 부분과 로그의 끝부분만 넘깁니다. 이 실습의 `cat test.log`는 실패한 케이스 몇 줄뿐입니다 |
| **사이클 수** | 검사가 약하거나 고장이 나서 통과 판정이 나지 않고 계속 돎 | 반복 상한과 금액 예산을 둡니다. 몇 번 실패하면 사람에게 넘깁니다 |
| **추가 모델 호출** | 사이클마다 검토용 모델을 하나 더 부름 | 두 번째 의견이 값어치를 할 때만 부릅니다 (Osmani) |

### 6.5-3. 종료 조건 세 가지를 모두 갖춘 루프

이 실습은 루프를 끝내는 조건으로 ① 검증 통과(goal)와 ② 반복 상한(resource)을 썼습니다. 여기에 ③ **금액 예산(budget)**을 더하면 세 가지가 모두 갖춰집니다. 셋 중 하나라도 빠지면 무인 루프는 조용히 비용을 흘립니다 — Sonar의 표현대로 *"a loop doesn't fail loudly, it fails quietly"* (루프는 시끄럽게 실패하지 않고 조용히 실패한다).

Step 6-2의 루프에 예산을 더한 블록입니다. 달라진 곳은 세 군데입니다:

- `BUDGET`과 `spent` 변수로 예산과 지금까지 쓴 금액을 기억합니다.
- Claude를 부르기 전에 예산이 남았는지 확인합니다.
- Claude를 `--output-format json`으로 불러 결과를 `claude.json`에 저장하고, 그 안의 비용(`total_cost_usd`)을 `spent`에 더합니다.

```bash
cd ~/loop-demo
MAX=5                                  # ② 반복 상한: 많아야 5사이클
BUDGET=0                               # ③ 금액 예산(달러): 먼저 0으로 멈추는 모습을 보고, 실제로 돌릴 땐 0.30
spent=0                                # 지금까지 쓴 금액
echo "module.exports = (s) => s === [...s].reverse().join('');" > solution.js   # 틀린 코드로 시작

for i in $(seq 1 $MAX); do
  echo "── 사이클 $i (지금까지 쓴 돈: \$$spent) ──"
  if node test.js > test.log 2>&1; then  # ① 검증 통과 → 끝
    cat test.log
    echo "✅ 사이클 $i 에서 통과 — 루프 종료"
    break
  fi
  cat test.log
  if [ "$i" -eq "$MAX" ]; then         # ② 상한에 닿으면 멈추고 사람에게 넘김
    echo "⛔ 반복 상한($MAX회)에 도달 — 여기서 멈추고 사람이 확인한다"
    break
  fi
  if node -e "process.exit(Number(process.argv[1]) >= Number(process.argv[2]) ? 0 : 1)" "$spent" "$BUDGET"; then
    echo "⛔ 예산(\$$BUDGET)을 다 썼다 — Claude를 더 부르지 않고 멈춘다"   # ③ 예산이 바닥나면 멈춤
    break
  fi
  echo "↻ 실패 — 실패 기록을 Claude에게 넘겨 수정을 맡긴다"
  cat test.log | claude -p "solution.js의 isPalindrome 구현이 아래 테스트에서 실패한다. 실패 원인을 찾아 solution.js만 고쳐라. 테스트 파일은 고치지 말고, 테스트는 직접 실행하지 마라. 대소문자·공백·구두점은 무시해야 한다." \
    --allowedTools "Read,Edit,Write" --output-format json > claude.json
  node -e "console.log(require('./claude.json').result)"   # Claude의 답만 화면에 보여 줌
  spent=$(node -e "console.log((Number(process.argv[1]) + require('./claude.json').total_cost_usd).toFixed(4))" "$spent")
done
```

처음 보는 문법이 두 가지 있습니다:

| 문법 | 뜻 |
|---|---|
| `node -e "…" "$spent" "$BUDGET"` | 따옴표 안의 짧은 JavaScript를 바로 실행합니다. 뒤의 두 값은 `process.argv[1]`·`process.argv[2]`로 받습니다. 셸은 소수(0.05 같은 값)를 비교하지 못해서 Node에게 비교를 맡깁니다 |
| `spent=$( … )` | 괄호 안 명령이 출력한 값을 `spent` 변수에 넣습니다. 여기서는 "지금까지 쓴 돈 + 이번 호출 비용"을 계산해 넣습니다 |

`BUDGET=0`으로 실행하면 토큰을 쓰지 않고 이렇게 끝납니다. 사이클 1의 테스트가 실패했지만, Claude를 부르기 전에 예산을 확인해 멈춥니다:

```
── 사이클 1 (지금까지 쓴 돈: $0) ──
  ❌ isPalindrome("RaceCar") = false (기대값 true)
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 3개 케이스 실패
⛔ 예산($0)을 다 썼다 — Claude를 더 부르지 않고 멈춘다
```

`BUDGET=0.30`으로 바꿔 실행하면 Step 6처럼 Claude가 고치고 사이클 2에서 통과합니다. 이때 사이클 2의 머리말에 사이클 1에서 쓴 금액이 찍힙니다:

```
── 사이클 1 (지금까지 쓴 돈: $0) ──
  ❌ isPalindrome("RaceCar") = false (기대값 true)
  ❌ isPalindrome("A man, a plan, a canal: Panama") = false (기대값 true)
  ❌ isPalindrome("No lemon, no melon") = false (기대값 true)
FAIL — 3개 케이스 실패
↻ 실패 — 실패 기록을 Claude에게 넘겨 수정을 맡긴다
`solution.js`를 고쳤습니다. 요청대로 테스트는 실행하지 않았으니, 6개 케이스가 통과하는지는 아직 확인되지 않았습니다.
(… 원인·수정 설명과 고친 코드 …)
── 사이클 2 (지금까지 쓴 돈: $0.1541) ──
PASS — 6개 케이스 전부 통과
✅ 사이클 2 에서 통과 — 루프 종료
```

이 실행에서는 Claude 호출 1번에 $0.15가 들었습니다. Step 6에서 같은 호출이 $0.05였던 것과 비교하면 세 배입니다. 같은 프롬프트라도 Claude가 몇 번 생각하고 몇 번 도구를 쓰는지에 따라 비용이 매번 달라지므로, 예산은 한 번 잰 값보다 넉넉하게 잡습니다.

!!! warning "`--max-budget-usd`는 정확한 상한이 아닙니다"

    `claude -p`에는 한 번 호출할 때의 최대 금액을 정하는 `--max-budget-usd` 옵션이 있습니다. 실측해 보니 이 옵션은 **돈을 쓴 뒤에** 넘었는지 확인합니다. `--max-budget-usd 0.01`로 불렀는데 실제로는 $0.11을 쓰고 나서야 `Error: Exceeded USD budget (0.01)`로 멈췄고, 파일은 고치지 못했습니다. 첫 응답 한 번에 드는 비용이 이미 $0.01을 넘기 때문입니다. 그래서 이 옵션은 "한 번의 호출이 폭주하지 않게 막는 안전장치"로는 쓸 만하지만, 루프 전체의 예산은 위 블록처럼 쓴 금액을 직접 더해 가며 관리해야 합니다.

!!! note "방금 본 것 — 거부 신호는 토큰 절약 장치이기도 하다"

    Step 6부터 이 루프는 **테스트를 먼저 돌리고, 실패할 때만 Claude를 부르는** 순서였습니다. 테스트는 내 컴퓨터에서 도는 공짜 검사이므로, 이미 통과한 코드라면 Claude를 한 번도 부르지 않고 끝납니다. 거부 신호는 루프의 품질을 지키는 장치이면서 돈을 아끼는 장치이기도 합니다. 그 위에 반복 상한과 금액 예산이 "그래도 끝나지 않을 때"를 막습니다. 세 가지 종료 조건이 모두 있어야 사람이 자리를 비워도 안심하고 돌릴 수 있습니다.

---

## 정리 (30초)

실습이 끝났으면 데모 디렉터리를 삭제합니다. 다시 해보고 싶으면 Step 1부터 2분이면 재구성됩니다.

```bash
cd ~ && rm -rf ~/loop-demo
```

---

## 좋은 루프가 답해야 할 체크리스트

[[concept-loop-engineering]] 의 도메인 모델링 체크리스트 + 외부 조사로 보강:

- [ ] 이 루프의 **종료 조건**은 무엇인가? verify(테스트·타입체크)로 표현되는가, 아니면 자기 보고인가?
- [ ] 루프 안에 **거부할 수 있는 무언가**가 있는가? (실패를 반환할 수 있는 객관적 검사)
- [ ] **반복 상한**(max iterations)과 **토큰 예산**이 있는가?
- [ ] 한 사이클이 **8번 전 실패를 기억**하는가, 아니면 같은 길을 다시 가는가? (피드백 전달)
- [ ] **재시도해도 안 될 때**의 다음 행동(사람에게 에스컬레이션)은?
- [ ] 사이클 결과가 **사람에게 어디서·어떻게** 보고되는가?

---

## 같은 인사이트 패턴 — "거부 신호 없는 자동화는 폭주한다"

이 실습과 직접 맞닿은 행만 추렸습니다.

| 영역 | 폭주 시나리오 | 거부 메커니즘 | 참조 |
|------|---------------|---------------|------|
| **AI 루프** | 검증 없이 자기 출력에 동의 → 메아리방 | 테스트·타입체크를 루프 안에 (이 실습) | [[concept-loop-engineering]] |
| **Hooks** | 위험 명령 자유 실행 → 사고 | `guard.sh` exit 2 → 도구 차단 | [[concept-claude-hooks]] |
| **그래프 엔지니어링** | 프롬프트 지시("3회만 재시도")를 LLM이 무시 | 재시도 상한을 코드로 강제 (이 실습의 `seq 1 8`과 같은 원리) | [[concept-graph-engineering]] |

전체 표(멀티 에이전트·선언 층·TDD·크론잡 포함)는 [[concept-loop-engineering]]에 있습니다.

→ **공통 원리**: 자동 사이클에는 반드시 **밀어내는 신호(reject·timeout·exit code)** 가 짝지어 있어야 합니다.

---

## 원본·외부 출처

**개념·발화 (2026-06)**: [[concept-loop-engineering]] / [[src-loop-engineering]] (1차 출처 검증 2026-06-29)

- Addy Osmani [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) (2026-06-07, ✅용어 명명 1차 글) · Boris Cherny [Acquired](https://www.youtube.com/watch?v=RkQQ7WEor7w) "write loops" (⚠️자구·날짜 매체별 편차) · Peter Steinberger [X](https://x.com/steipete/status/2063697162748260627) (⚠️402, "650만 조회"는 2차 주장)

**실행 검증 증적**: `raw/ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md` — Step 1~4 셸 실측, Step 6 헤드리스 실측(`Write` 누락 함정 포함), 6-5 프롬프트 비교 실험 9회의 도구 호출 순서·비용·최종 답 원문.

**이론 (1차 출처)**:

- ReAct — Yao et al. 2022, [arXiv 2210.03629](https://arxiv.org/abs/2210.03629)
- Reflexion — Shinn et al. 2023, [arXiv 2303.11366](https://arxiv.org/abs/2303.11366)
- Self-Refine — Madaan et al. 2023, [arXiv 2303.17651](https://arxiv.org/abs/2303.17651)
- "검증 없는 루프 = 단순 자동화" — [Sonar 블로그](https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/)

**구현 (공식)**:

- Claude Code 헤드리스 모드 — [code.claude.com/docs/headless](https://code.claude.com/docs/en/headless)
- 모범 사례 (검증 게이트·Stop 훅) — [code.claude.com/docs/best-practices](https://code.claude.com/docs/en/best-practices)

---

## 관련 페이지

- [[concept-loop-engineering]] — 이 실습의 이론 (메커니즘 자체를 설계)
- [[guide-harness-demo]] — 직전 단계: 하네스 5분 데모 (환경 설계)
- [[concept-claude-hooks]] — back-pressure 가 "거부할 수 있는 무언가" 의 또 다른 구현
- [[concept-multi-agent-pattern]] — Critic 이 거부 메커니즘의 또 다른 구현
- [[concept-harness-engineering]] — 직전 패러다임 (환경)
- [[src-copilot-token-pricing]] — 루프의 토큰 비용 폭증 위험
