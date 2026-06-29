---
title: Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프 (Node + claude -p)
type: synthesis
tags: [loop-engineering, harness, demo, react-pattern, claude-code, hands-on, node]
sources:
  - loop-engineering/loop-engineering-notes.md
  - loop-engineering/primary-sources.md
external:
  - https://addyosmani.com/blog/loop-engineering/
  - https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/
  - https://arxiv.org/abs/2210.03629
  - https://arxiv.org/abs/2303.11366
  - https://arxiv.org/abs/2303.17651
  - https://code.claude.com/docs/en/headless
created: 2026-06-26
updated: 2026-06-29
---

# Loop 엔지니어링 실습 — 메아리방 vs 거부 신호 루프

> **이 실습의 목적**: [[concept-loop-engineering]] 의 핵심 한 문장 — **"거부할 수 있는 무언가(테스트·타입체크·에러)가 없는 루프는 메아리방"** — 을 **직접 코드로 짜서 체험**한다. "루프를 작성한다"는 감각을 손에 익히는 게 핵심.

**시간**: 8분 (셋업 2분 + Before 메아리방 2분 + 거부 신호 추가 1분 + After 검증 루프 2분 + 실제 Claude 연결 1분)

**언제 보면 좋은가**: [[concept-loop-engineering]] 를 읽은 직후. [[guide-harness-demo]](하네스 5분 데모)의 다음 단계 — 하네스가 "환경"을 설계했다면, 루프는 "메커니즘 자체"를 설계한다.

**전제**: Node 18+ 설치. (Step 6의 실제 Claude 연결만 Claude Code 로그인 필요 — 나머지는 토큰 0으로 누구나 재현 가능)

> ✅ **실행 검증됨 (2026-06-29, Node v26)**: Step 1·2·4를 실제로 돌려 본문 수치를 확인했다 — 후보 (A)·(B)는 실패하고 (C)만 통과(결정적), Step 2 메아리방은 20회 중 13회(≈2/3)가 깨진 채 "완료" 종료, Step 4 검증 루프는 통과 시 정상 종료. "드물게 약 4%"는 이론값 (2/3)⁸=3.9%로 정확. (Step 6은 토큰이 들어 본 검증에서 제외 — 명령 구문은 [공식 헤드리스 docs](https://code.claude.com/docs/en/headless) 기준)

---

## 왜 이 실습인가 — 1분 이론

현대 에이전트 루프는 Princeton·Google의 **ReAct(Reason + Act)** 패턴에 뿌리를 둔다 ([arXiv 2210.03629](https://arxiv.org/abs/2210.03629)):

```
[행동(Act)] → [관찰(Observe)] → [추론(Reason)] → [다음 행동] → …  (종료 조건까지)
```

여기서 **관찰(Observe)이 무엇이냐**가 루프의 운명을 가른다.

- 관찰이 **에이전트 자기 보고**("다 됐어요")면 → 모델이 자기 출력에 동의하는 **메아리방**. Sonar의 표현대로 *"두 낙관주의자가 서로 동의하는 것"*.
- 관찰이 **객관적 거부 신호**(테스트·타입체크·빌드)면 → 사실에 부딪혀 교정된다. *"A failing build is a fact; an opinion is a starting point"* (실패한 빌드는 사실이고, 의견은 출발점일 뿐).

이 실습은 같은 루프를 **거부 신호 없이 / 있게** 두 번 돌려 그 차이를 눈으로 본다.

---

## Step 1 — 데모 폴더 + 검증 대상 (2분)

풀 문제: **회문(palindrome) 검사 함수**. 가짜 "에이전트"가 후보 구현을 내놓고, 테스트가 그것을 채점한다.

```bash
mkdir -p ~/loop-demo && cd ~/loop-demo
```

**가짜 코딩 에이전트** — 실제 LLM의 비결정성을 흉내 내, 후보 3개 중 하나를 무작위로 출력한다 (1개만 정답):

```bash
cat > agent.js << 'EOF'
// 가짜 코딩 에이전트: isPalindrome 후보를 무작위로 하나 출력한다.
// 후보 3개 중 (C)만 모든 케이스를 통과한다 — 실제 에이전트의 "가끔 맞고 가끔 틀림"을 흉내.
const candidates = [
  // (A) 정규화 없음 — 대소문자·공백·구두점이 있으면 틀림
  "module.exports = (s) => s === [...s].reverse().join('');",
  // (B) 소문자화만 — 공백·구두점이 있으면 여전히 틀림
  "module.exports = (s) => { const t = s.toLowerCase(); return t === [...t].reverse().join(''); };",
  // (C) 완전 정규화 — 통과
  "module.exports = (s) => { const t = s.toLowerCase().replace(/[^a-z0-9]/g, ''); return t === [...t].reverse().join(''); };",
];
const pick = candidates[Math.floor(Math.random() * candidates.length)];
process.stdout.write(pick + "\n");
EOF
```

**거부 신호(reject signal)** — 객관적으로 pass/fail 을 돌려주는 검증자. 통과 못 하면 종료 코드 1:

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

> 후보 (A)·(B)는 `"A man, a plan…"` 같은 케이스에서 깨지고, (C)만 전부 통과한다. 즉 **에이전트가 (C)를 뽑을 때까지가 "정답"**.

---

## Step 2 — Before: 거부 신호 없는 루프 (메아리방) (2분)

에이전트를 1회 호출하고, **검증 없이** 그 말을 믿고 끝낸다.

```bash
cd ~/loop-demo
node agent.js > solution.js
echo "🤖 에이전트: '구현 완료했습니다 ✅'"
echo "→ 거부 신호가 없는 루프는 이 보고를 그대로 믿고 종료한다."
echo "--- 생성된 코드 ---"; cat solution.js
echo "--- 그런데 실제로 돌려보면? ---"
node test.js || echo "💥 깨져 있다 — 그러나 루프는 이미 '완료'라고 보고했다 (= 메아리방)"
```

여러 번 실행해 보라. 약 2/3 확률로 **깨진 코드인데 "완료"로 종료**된다. 종료 조건이 *자기 보고*이기 때문 — [[concept-loop-engineering]] 의 "8번 전 실패를 기억 못 하고 같은 길을 가는" 나쁜 루프.

---

## Step 3 — 거부 신호를 루프에 넣기 (1분)

바꿀 것은 단 하나: **종료 조건을 "에이전트의 말" → "테스트의 종료 코드"로**. `node test.js` 가 `exit 0` 이어야만 끝낸다. 이게 ReAct 의 *관찰(Observe)* 을 객관화하는 것.

---

## Step 4 — After: 검증 루프 (통과까지 재시도) (2분)

```bash
cd ~/loop-demo
for i in $(seq 1 8); do
  echo "── 사이클 $i ──"
  node agent.js > solution.js          # Act:     에이전트가 코드 생성
  if node test.js; then                # Observe: 거부 신호(테스트)가 '사실'을 반환
    echo "✅ 사이클 $i 에서 통과 — 종료 조건 충족, 루프 종료"
    break
  fi
  echo "↻ 실패 — 거부 신호가 루프를 한 번 더 돌린다 (Reason → 다음 Act)"
done
```

이번엔 **통과하는 구현이 나올 때까지** 루프가 돈다. 거부 신호(테스트의 exit code)가 사이클을 제어한다.

> 가짜 에이전트가 무작위라, 드물게(약 4%) 8 사이클 안에 (C)가 안 나올 수 있다 — 그땐 다시 실행. 실제 에이전트라면 **실패를 피드백받아** 다음 시도가 개선된다 → Step 6.

`max 8` 이라는 **반복 상한**에 주목. 업계 권고는 보통 15~25 스텝이며, 상한 없는 루프는 토큰·시간을 폭주시킨다. 종료 조건은 ① 검증 통과(goal) ② 반복 상한(resource) 둘 다 있어야 한다.

---

## Step 5 — 차이 표 (직접 채워보기, 30초)

|  | Before (거부 신호 없음) | After (테스트 = 거부 신호) |
|---|---|---|
| 깨진 코드로 종료될 수 있나 | __ | __ |
| 종료 조건의 정체 | __ (에이전트 자기 보고?) | __ (객관적 검증?) |
| 같은 실수를 반복하나 | __ | __ |
| 사람이 매번 확인해야 하나 | __ | __ |

**한 줄 소감**: ____________________________________________

---

## Step 6 — 실제 Claude로 (선택, 1분)

가짜 에이전트를 **진짜 Claude Code 헤드리스 호출**로 바꾼다. 핵심은 **실패한 테스트 출력을 stdin 으로 피드백**하는 것 (공식 패턴: `cat … | claude -p "…"`).

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

- `claude -p`(=`--print`)는 **비대화형으로 1회 실행 후 종료**하므로 `for` 루프로 감싸기에 딱 맞다 ([공식 docs](https://code.claude.com/docs/en/headless)).
- `--allowedTools` 로 도구를 좁혀 자동 승인 — 프롬프트 없이 무인 실행.
- 이게 **Reflexion·Self-Refine** 의 핵심: 실패 신호를 언어로 받아 다음 시도를 개선 ([Reflexion](https://arxiv.org/abs/2303.11366) · [Self-Refine](https://arxiv.org/abs/2303.17651)).

> ⚠️ **토큰 비용**: 사이클마다 모델을 호출한다. Addy Osmani 의 신중론 — *"토큰 비용에 절대적으로 주의"*. 반드시 반복 상한(`max 5`)과 검증 게이트를 두고, 무인 루프는 비용을 모니터링하라. [[src-copilot-token-pricing]] 의 종량제 전환과 같은 맥락.

---

## Step 6.5 — 토큰 비용 심화 (무인 루프의 진짜 리스크)

검증 루프의 장점("사람 없이 통과까지 돈다")은 그대로 비용 리스크다 — **약한 게이트 + 높은 상한이 만나면 루프가 헛돌며 토큰을 태운다.** Osmani의 검증된 경고:

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

이 실습 Step 6의 형태가 이미 정답을 담고 있다: **결정적 검증(`node test.js`)을 먼저 돌리고, 실패할 때만 모델을 호출**한다. 로컬 테스트·타입체크·린트는 **토큰 0**이다.

```bash
# 비용 최적 패턴: 무료 게이트 통과면 모델을 아예 안 부른다
if node test.js > test.log 2>&1; then
  echo "✅ 이미 통과 — 모델 호출 0회, 토큰 0"
else
  cat test.log | claude -p "…수정…" --allowedTools "Read,Edit,Bash(node *)"
fi
```

→ "모델을 매 사이클 부른다"가 아니라 **"무료 검증이 거부했을 때만 부른다"**. 거부 신호는 루프 품질만이 아니라 **토큰 절약 장치**이기도 하다.

> 종료 조건은 ① 검증 통과(goal) ② 반복 상한(resource) ③ **토큰 예산(budget)** 세 가지여야 한다. 셋 중 하나라도 빠지면 무인 루프는 조용히 비용을 흘린다 — Sonar: *"a loop doesn't fail loudly, it fails quietly."*

---

## 정리 (30초)

```bash
cd ~ && rm -rf ~/loop-demo
```

---

## 좋은 루프가 답해야 할 체크리스트

[[concept-loop-engineering]] 의 4가지 설계 질문 + 외부 조사로 보강:

- [ ] 이 루프의 **종료 조건**은 무엇인가? verify(테스트·타입체크)로 표현되는가, 아니면 자기 보고인가?
- [ ] 루프 안에 **거부할 수 있는 무언가**가 있는가? (실패를 반환할 수 있는 객관적 검사)
- [ ] **반복 상한**(max iterations)과 **토큰 예산**이 있는가? (업계 권고 15~25 스텝)
- [ ] 한 사이클이 **8번 전 실패를 기억**하는가, 아니면 같은 길을 다시 가는가? (피드백 전달)
- [ ] **재시도해도 안 될 때**의 다음 행동(사람에게 에스컬레이션)은?
- [ ] 사이클 결과가 **사람에게 어디서·어떻게** 보고되는가?

---

## 같은 인사이트 패턴 — "거부 신호 없는 자동화는 폭주한다"

이 실습이 보여준 원리는 위키 전반에 반복된다 ([[concept-loop-engineering]] 에 누적):

| 영역 | 폭주 시나리오 | 거부 메커니즘 | 참조 |
|------|---------------|---------------|------|
| **AI 루프** | 검증 없이 자기 출력에 동의 → 메아리방 | 테스트·타입체크를 루프 안에 (이 실습) | [[concept-loop-engineering]] |
| **Hooks** | 위험 명령 자유 실행 → 사고 | `guard.sh` exit 1 → 도구 차단 | [[concept-claude-hooks]] |
| **멀티 에이전트** | 단일 에이전트 자기검증 통과 편향 | Critic 의 `CONDITIONAL REJECT` | [[concept-multi-agent-pattern]] |
| **선언 층** | 부정 명령이 잊힘 | STOP 트리거 → 명시적 중단 조건 | [[concept-claude-md]] |

→ **공통 원리**: 자동 사이클에는 반드시 **밀어내는 신호(reject·timeout·exit code)** 가 짝지어 있어야 한다.

---

## 원본·외부 출처

**개념·발화 (2026-06)**: [[concept-loop-engineering]] / [[src-loop-engineering]] · 1차 출처 검증본 `raw/loop-engineering/primary-sources.md` (2026-06-29)
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
