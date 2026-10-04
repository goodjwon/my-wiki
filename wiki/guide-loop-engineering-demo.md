---
title: Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프 (Node + claude -p)
type: synthesis
tags: [loop-engineering, harness, demo, react-pattern, claude-code, hands-on, node]
sources:
  - ai-engineering/loop-engineering/loop-engineering-notes.md
  - ai-engineering/loop-engineering/primary-sources.md
external:
  - https://addyosmani.com/blog/loop-engineering/
  - https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/
  - https://arxiv.org/abs/2210.03629
  - https://arxiv.org/abs/2303.11366
  - https://arxiv.org/abs/2303.17651
  - https://code.claude.com/docs/en/headless
created: 2026-06-26
updated: 2026-10-04
---

# Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프

> **이 실습의 목적**: [[concept-loop-engineering]] 의 핵심 한 문장 — **"거부할 수 있는 무언가(테스트·타입체크·에러)가 없는 루프는 메아리방"** — 을 **직접 코드로 짜서 체험**합니다. "루프를 작성한다"는 감각을 손에 익히는 게 핵심입니다.

문서 전체에서 쓰는 두 용어를 먼저 잡습니다. **메아리방(echo chamber)**은 에이전트의 "다 됐어요" 자기 보고를 검증 없이 믿고 종료하는 루프를, **거부 신호(reject signal)**는 테스트·타입체크·빌드처럼 실패를 객관적으로 돌려줘 그 종료를 막는 검사를 가리킵니다.

**시간**: 8분 (셋업 2분 + Before 메아리방 2분 + 거부 신호 추가 1분 + After 검증 루프 2분 + 실제 Claude 연결 1분)

**진행 흐름**: 1분 이론으로 "관찰(Observe)이 무엇이냐"의 두 갈래를 확인 → 비교 실험용 공통 재료 만들기(Step 1) → 거부 신호 없는 메아리방 체험(Step 2) → 종료 조건 교체(Step 3) → 검증 루프 체험(Step 4) → 차이 정리(Step 5) → 가짜 에이전트를 진짜 Claude로 교체(Step 6) → 토큰 비용 심화(Step 6.5).

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

> ✅ **실행 검증됨 (2026-06-29, Node v26)**: Step 1·2·4를 실제로 돌려 본문 수치를 확인했습니다 — 후보 (A)·(B)는 실패하고 (C)만 통과(결정적), Step 2 메아리방은 20회 중 13회(≈2/3)가 깨진 채 "완료" 종료, Step 4 검증 루프는 통과 시 정상 종료. "드물게 약 4%"는 이론값 (2/3)⁸=3.9%로 정확합니다. 2026-10-04에 Step 2·3을 다시 쓰면서 재실측했습니다: 1회 실행 150번 중 55번 통과(≈1/3), Step 4 루프 40번 모두 8사이클 안에 통과. (Step 6은 토큰이 들어 본 검증에서 제외 — 명령 구문은 [공식 헤드리스 docs](https://code.claude.com/docs/en/headless) 기준)

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

**가짜 코딩 에이전트** — 실제 코딩 에이전트처럼 파일을 직접 고치고 끝나면 "완료"라고 보고합니다. 고치는 내용은 후보 3개 중 무작위 하나라 1개만 정답이지만, 보고는 무엇을 골랐든 늘 "완료"입니다. 자기 결과를 확인하지 않고 자신 있게 말하는 에이전트를 흉내 낸 것입니다:

```bash
cat > agent.js << 'EOF'
// 가짜 코딩 에이전트: isPalindrome 후보 하나를 골라 solution.js에 쓰고 "완료"라고 보고한다.
// 후보 3개 중 (C)만 모든 케이스를 통과한다 — 실제 에이전트의 "가끔 맞고 가끔 틀림"을 흉내.
// 보고는 어떤 후보를 골랐든 늘 "완료" — 자기 결과를 검증하지 않는 에이전트를 흉내.
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
const pick = candidates[Math.floor(Math.random() * candidates.length)];
fs.writeFileSync(path.join(__dirname, 'solution.js'), pick + '\n');
console.log('🤖 에이전트: solution.js에 isPalindrome 구현 완료했습니다 ✅');
EOF
```

**거부 신호 역할의 검증자** — 객관적으로 pass/fail 을 돌려줍니다. 채점 대상은 `solution.js`(에이전트가 고친 후보 구현 — Step 2에서 `agent.js`가 처음 생성)이고, 통과 못 하면 종료 코드 1:

```bash
cat > test.js << 'EOF'
const isPalindrome = require('./solution');
const cases = [
  ['racecar', true],
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
console.log('PASS — 5개 케이스 전부 통과');
EOF
```

> 후보 (A)·(B)는 `"A man, a plan…"` 같은 케이스에서 깨지고, (C)만 전부 통과합니다. 즉 **에이전트가 (C)를 뽑을 때까지가 "정답"**입니다.

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

결과는 ②의 출력으로 갈립니다:

| ②의 출력 | 뽑힌 후보 | 뜻 |
|---|---|---|
| `PASS — 5개 케이스 전부 통과` | (C) | 정답이 나와 보고가 사실과 일치함 |
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

[[concept-loop-engineering]]의 설계 질문 4 "출력을 어떻게 검증하는가"에서 나쁜 답에 해당하는 루프입니다. 결과를 확인하지 않고 "끝났다"는 말로 완료를 판정합니다.

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

이것이 ReAct의 관찰(Observe)을 에이전트의 말에서 객관적인 사실로 바꾸는 일입니다.

---

## Step 4 — After: 검증 루프 (통과까지 재시도) (2분)

Step 3의 한 줄짜리 결정을 실제 루프로 옮깁니다. 재료는 Step 1의 두 파일 그대로이고, 종료 조건만 테스트의 종료 코드로 바뀌었습니다.

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 1의 `agent.js`·`test.js` 그대로 사용)
    - **실행**: 아래 for 루프를 붙여넣어 실행합니다.

Step 2와 골격은 같고, 종료만 `node test.js`의 종료 코드 0에 걸어 둔 루프입니다. 에이전트는 사이클마다 "완료"라고 보고하지만 루프는 그 말을 끝낼 근거로 쓰지 않고 테스트만 봅니다. `echo` 줄은 몇 번째 사이클인지와 통과·재시도 여부를 보여 주는 진행 표시입니다:

```bash
cd ~/loop-demo
for i in $(seq 1 8); do
  echo "── 사이클 $i ──"
  node agent.js                        # Act:     에이전트가 solution.js를 고치고 "완료" 보고
  if node test.js; then                # Observe: 거부 신호(테스트)가 '사실'을 반환
    echo "✅ 사이클 $i 에서 통과 — 종료 조건 충족, 루프 종료"
    break
  fi
  echo "↻ 실패 — 거부 신호가 루프를 한 번 더 돌린다 (Reason → 다음 Act)"
done
```

Step 2의 10회 반복 블록과 같은 `for` 문인데, 두 가지가 다릅니다. 첫째, `> /dev/null`이 없어서 에이전트의 보고와 테스트 결과가 모두 화면에 보입니다. 둘째, 테스트가 통과하면 `break`가 남은 반복을 건너뛰고 루프를 바로 빠져나갑니다. 그래서 `seq 1 8`은 "8번 돌린다"가 아니라 "많아야 8번까지 시도한다"는 뜻입니다.

이번엔 **통과하는 구현이 나올 때까지** 루프가 반복됩니다. 거부 신호(테스트의 exit code)가 사이클을 제어합니다.

> 가짜 에이전트가 무작위라, 드물게(약 4%) 8 사이클 안에 (C)가 안 나올 수 있습니다 — 사이클당 실패 확률 2/3이 8번 연속될 확률 (2/3)⁸ ≈ 3.9%입니다. 그땐 다시 실행하세요. 실제 에이전트라면 **실패를 피드백받아** 다음 시도가 개선됩니다 → Step 6.

`seq 1 8` 이라는 **반복 상한**(최대 8사이클)에 주목합니다. 상한 값은 한 사이클의 비용에 맞춰 정하며(이 실습은 8회), 상한 없는 루프는 토큰·시간을 폭주시킵니다. 종료 조건은 ① 검증 통과(goal) ② 반복 상한(resource)이 함께 있어야 하고, ③ 토큰 예산(budget)은 Step 6.5에서 더합니다.

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

## Step 6 — 실제 Claude로 (선택, 1분)

Step 4의 가짜 에이전트는 무작위라 실패해도 다음 시도가 나아지지 않고 주사위를 다시 던질 뿐입니다. 이제 가짜 에이전트를 **진짜 Claude Code 헤드리스(headless) 호출**로 바꿉니다 — 헤드리스는 대화 화면 없이 터미널 명령 한 줄로 Claude를 실행하고 결과만 돌려받는 방식입니다. 핵심은 **실패한 테스트 출력을 stdin 으로 피드백**해 다음 시도가 실제로 개선되게 하는 것입니다 (공식 패턴: `cat … | claude -p "…"`).

!!! example "실습 위치·실행"

    - **위치**: `~/loop-demo` (Step 1의 `test.js` 그대로 사용)
    - **만들 파일**: `solution.js` — 일부러 틀린 구현으로 덮어쓰고 루프가 고치게 합니다
    - **실행**: Claude Code 로그인 상태에서 아래 블록을 붙여넣어 실행합니다 (토큰이 소모됩니다).

루프 골격은 Step 4 그대로이고, 에이전트 호출 자리만 `claude -p` 파이프라인으로 바뀌었습니다:

```bash
cd ~/loop-demo
# 일부러 틀린 구현으로 시작 (정규화 없음 → 공백·구두점 케이스 실패)
echo "module.exports = (s) => s === [...s].reverse().join('');" > solution.js

for i in $(seq 1 5); do
  echo "── 사이클 $i ──"
  if node test.js > test.log 2>&1; then
    echo "✅ 통과 — 종료"; cat test.log; break
  fi
  echo "↻ 실패 — 에러를 Claude 에 피드백해 수정 요청"
  cat test.log | claude -p "solution.js 의 isPalindrome 구현이 아래 테스트에서 실패한다. 근본 원인을 찾아 solution.js 만 수정하라. 에러를 숨기지 말 것. 대소문자·공백·구두점은 무시해야 한다." \
    --allowedTools "Read,Edit,Bash(node *)"
done
```

- `claude -p`(=`--print`)는 **비대화형으로 1회 실행 후 종료**하므로 `for` 루프로 감싸기에 딱 맞습니다 ([공식 docs](https://code.claude.com/docs/en/headless)).
- `--allowedTools` 로 도구를 좁혀 자동 승인합니다 — 프롬프트 없이 무인 실행됩니다.
- 이게 **Reflexion·Self-Refine** 의 핵심입니다: 실패 신호를 언어로 받아 다음 시도를 개선 ([Reflexion](https://arxiv.org/abs/2303.11366) · [Self-Refine](https://arxiv.org/abs/2303.17651)).

> ⚠️ **토큰 비용**: 사이클마다 모델을 호출합니다. Addy Osmani 의 신중론 — *"토큰 비용에 절대적으로 주의"*. 반드시 반복 상한(위 코드의 `seq 1 5`)과 검증 게이트를 두고, 무인 루프는 비용을 모니터링해야 합니다. [[src-copilot-token-pricing]] 의 종량제 전환과 같은 맥락입니다.

---

## Step 6.5 — 토큰 비용 심화 (무인 루프의 진짜 리스크)

검증 루프의 장점("사람 없이 통과까지 돈다")은 그대로 비용 리스크입니다 — **약한 게이트 + 높은 상한이 만나면 루프가 헛돌며 토큰을 태웁니다.** Osmani의 검증된 경고:

> *"Verification is still on you. A loop running unattended is also a loop making mistakes unattended."*
> *"you absolutely have to be careful about token costs (usage patterns can vary wildly if you are token rich or poor)."*

### 봉투 뒷면 비용 모델

무인 루프 1회 비용 ≈ **(사이클 수) × (사이클당 토큰)**. 사이클당 토큰을 키우는 3대 요인:

| 요인 | 폭증 형태 | 줄이는 법 |
|------|----------|----------|
| **컨텍스트 크기** | 매 사이클 전체 저장소·전체 로그를 다시 첨부 | 실패 **diff·로그 꼬리**만 전달 (이 실습의 `cat test.log`처럼) |
| **사이클 수** | 게이트가 약해 통과 판정이 안 나 무한 근접 | 하드 상한(`max N`) + 토큰 예산, K회 실패 시 사람 에스컬레이션 |
| **서브에이전트** | 사이클마다 추가 모델 호출 | *"두 번째 의견이 값어치 할 때만"* (Osmani) |

### 핵심 완화책 — 게이트를 모델 앞에 두기

이 실습 Step 6의 형태가 이미 정답을 담고 있습니다: **결정적 검증(`node test.js`)을 먼저 실행하고, 실패할 때만 모델을 호출**합니다. 로컬 테스트·타입체크·린트는 **토큰 0**입니다.

```bash
# 비용 최적 패턴: 무료 게이트 통과면 모델을 아예 안 부른다
if node test.js > test.log 2>&1; then
  echo "✅ 이미 통과 — 모델 호출 0회, 토큰 0"
else
  cat test.log | claude -p "…수정…" --allowedTools "Read,Edit,Bash(node *)"
fi
```

→ "모델을 매 사이클 부릅니다"가 아니라 **"무료 검증이 거부했을 때만 부릅니다"**. 거부 신호는 루프 품질만이 아니라 **토큰 절약 장치**이기도 합니다.

> 종료 조건은 ① 검증 통과(goal) ② 반복 상한(resource) ③ **토큰 예산(budget)** 세 가지여야 합니다. 셋 중 하나라도 빠지면 무인 루프는 조용히 비용을 흘립니다 — Sonar: *"a loop doesn't fail loudly, it fails quietly."*

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
