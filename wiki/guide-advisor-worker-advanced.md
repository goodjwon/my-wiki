---
title: Advisor–Worker 실습 심화편 — 재위임·병렬·모델 티어링·오버헤드 예외
type: synthesis
tags: [claude-code, multi-agent, subagent, delegation, demo, hands-on]
sources:
  - ai-engineering/ai-advisor/advisor_script.md
  - ai-engineering/ai-advisor/worker_script.md
  - ai-engineering/ai-advisor/claude_script.md
  - ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md
created: 2026-07-06
updated: 2026-10-05
---

# Advisor–Worker 실습 심화편 — 재위임·병렬·모델 티어링·오버헤드 예외

> **이 실습의 목적**: [[guide-advisor-worker-demo]](기본편)는 1사이클 성공 경로만 체험합니다. 심화편은 원본 스크립트에 있지만 기본편이 다루지 않은 규율 4가지를 장면별로 재현합니다 — ① 검증 실패 → **수정 브리프 재위임** ② 독립 작업의 **병렬 위임** ③ **역할별 이종 모델** 고정과 환경변수 함정 ④ **위임 오버헤드 예외**(사소한 일은 직접).

**시간**: 25분 (셋업 5분 + 장면 1 재위임 7분 + 장면 2 병렬 5분 + 장면 3 모델 5분 + 장면 4 예외 2분 + 정리 1분)

**언제 보면 좋은가**: 기본편을 끝낸 직후. 기본편이 "게이트가 있다"를 보여줬다면, 심화편은 **게이트가 거부하는 장면**과 위임의 경제학(병렬·모델 단가·오버헤드 역전)을 봅니다.

**전제**: 기본편과 동일 (Claude Code 설치·로그인, Node 18+). 명령 붙여넣는 요령·`setopt interactivecomments`·"일반 터미널에서 실행"도 기본편의 "명령 실행 방법" 상자와 같습니다. **토큰 비용은 기본편보다 큽니다** — 위임 사이클이 2회 이상 돌고 장면 3은 세션을 두 번 띄웁니다. [[guide-loop-engineering-demo]] Step 6.5의 원칙 그대로, 무료 검증(`node *.test.js`)을 모델 호출 앞에 두고 각 장면은 1~2사이클 안에 끝냅니다.

> ✅ **실행 검증됨 (2026-10-05, Claude Code 2.1.289, Node v24)**: Step 0~장면 4를 새 디렉터리에서 그대로 실행했습니다 (장면 세션은 헤드리스 `claude --agent advisor -p` + stream-json 도구 호출 감사, 5회 합계 약 $0.96). ① 장면 1 — 수정은 Worker의 Edit 1회, Advisor는 `git diff`+재테스트 후 커밋. 단 Advisor는 위임 전에 테스트를 **실행하지 않고** 코드·테스트를 읽어 실패(기대 40000·현재 45000)를 파악했고, 그 내용을 브리프에 담았습니다. ② 장면 2 — Advisor의 한 메시지에 위임 호출 2개가 함께 나감(병렬), 브리프는 모듈별 분리, 각각 재검증 후 모듈별로 커밋. ③ 장면 3 — frontmatter로 고정한 Worker 모델(haiku)이 그대로 쓰였고, **`CLAUDE_CODE_SUBAGENT_MODEL`을 설정해도 바뀌지 않았습니다** (2.1.251부터 frontmatter가 우선한다는 [공식 문서](https://code.claude.com/docs/en/sub-agents)와 일치 — 2026-07-12 실측(2.1.197)의 "환경 변수가 덮어씀"은 옛 버전 동작). ④ 장면 4 — 위임 0회, Advisor가 직접 Edit로 오타 수정. 증적: `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md`. 참고: 위임 도구는 2.1.63부터 이름이 `Agent`이고, 예전 이름 `Task`도 별칭으로 동작합니다(이 페이지의 정의·명령은 `Task` 그대로 실측 통과).

---

## Step 0 — 기본편 완료 상태 복원 (5분)

기본편 Step 1~2([[guide-advisor-worker-demo]] 참조)를 먼저 그대로 실행해 `~/advisor-demo`에 테스트와 에이전트 2개를 만듭니다. 이미 만들어 둔 상태라면 이 문단은 건너뜁니다.

심화편은 "cart가 구현·커밋된 상태"에서 시작합니다. 모델을 부르지 않고(토큰 0) 정답 구현을 직접 넣어 그 상태를 복원합니다 — 첫 줄 주석의 오타("모둘")는 장면 4를 위해 **일부러** 심어 둡니다:

```bash
cd ~/advisor-demo
cat > cart.js << 'EOF'
// 장바구니 총액 계산 모둘
function totalPrice(items) {
  const subtotal = items.reduce((sum, { price, qty }) => sum + price * qty, 0);
  if (subtotal >= 10000) return Math.round(subtotal * 0.9);
  return subtotal;
}
module.exports = { totalPrice };
EOF
node cart.test.js
```

```text
예상 결과
PASS — 3개 케이스 전부 통과
```

기본편의 축약판 advisor에는 심화편이 관찰할 규율 2줄이 없으므로 덧붙입니다. `cat >> 파일`은 `cat >`와 달리 파일을 덮어쓰지 않고 **끝에 이어 붙입니다**:

```bash
cd ~/advisor-demo
cat >> .claude/agents/advisor.md << 'EOF'
- 서로 독립적인 작업은 한 턴에 여러 Task로 병렬 위임한다. 의존 관계가 있으면 순차로 나눈다.
- 위임 오버헤드 예외는 동작이 바뀌지 않는 수정(오타·주석·임포트 정리)에만 적용한다. 테스트 기대값이 바뀌는 로직 수정은 한두 줄이라도 위임한다.
EOF
```

> 오버헤드 예외 문구가 "한두 줄 수정은 직접 처리"처럼 **크기 기준**이면 장면 1이 재현되지 않습니다 — 할인 티어 추가는 실제로 한두 줄짜리 로직 수정이라, 실측(2026-07-12)에서 Advisor가 2회 모두 위임 없이 직접 고쳤습니다. 그래서 예외 기준을 크기가 아니라 **동작 변경 여부**로 잡습니다: 동작이 바뀌면 크기 무관 위임(장면 1), 안 바뀌면 직접 처리(장면 4).

복원한 구현과 보강한 에이전트 정의를 여기서 함께 커밋합니다 — advisor.md의 규율 추가를 커밋 밖에 남겨 두면, 장면 1에서 Advisor가 검증 통과분을 커밋할 때 에이전트 정의 변경이 잡음으로 섞여 들어갑니다:

```bash
cd ~/advisor-demo
git add cart.js cart.test.js package.json .claude && git commit -qm "cart 기본 구현 + advisor 규율 2줄 (기본편 완료 상태 복원)"
```

---

## 장면 1 — 검증 실패 → 수정 브리프 재위임 (7분)

기본편에서 재현되지 않은 유일한 규율입니다: **검증이 실패하면 Advisor는 직접 고치지 않고, 무엇이 왜 실패했는지 담은 수정 브리프로 재위임합니다.**

실패를 확정적으로 만들기 위해 요구를 바꿉니다 — 5만원 이상 구매에 20% 할인 등급을 추가합니다. 현재 구현(일괄 10%)은 이 케이스에서 반드시 실패합니다:

```bash
cd ~/advisor-demo
cat >> cart.test.js << 'EOF'
// 50,000원 이상 구매 시 20% 할인 (요구 변경으로 추가)
assert.strictEqual(totalPrice([{ price: 25000, qty: 2 }]), 40000);
console.log('PASS — 4번째 케이스(20% 할인)도 통과');
EOF
node cart.test.js || echo "→ 현재 구현은 새 케이스에서 실패한다 (45000 반환)"
```

`A || B`는 A가 실패했을 때만 B를 실행합니다. 실측 출력의 앞부분입니다. 기존 3개 케이스가 먼저 실행돼 `PASS — 3개 …` 줄이 찍힌 뒤, 새로 붙인 4번째 케이스에서 멈춥니다:

```
PASS — 3개 케이스 전부 통과
node:assert:95
  throw new AssertionError(obj);
  ^

AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:

45000 !== 40000
```

Advisor 세션을 띄우고 요구 변경을 알립니다:

```bash
cd ~/advisor-demo
claude --agent advisor
```

```
요구가 바뀌어 cart.test.js에 케이스를 추가했다 (5만원 이상 20% 할인). 전부 통과하도록 수정하고, 검증이 끝나면 커밋해줘.
```

**관찰 포인트** — 이 장면의 핵심 3가지:

- [ ] **위임 전 실패 확인** — Advisor가 브리프를 쓰기 전에 어느 케이스가 어떻게 실패하는지(기대 40000, 실제 45000) 파악하는가? 테스트를 직접 실행하는지, 코드를 읽어 추론하는지도 봅니다.
- [ ] **실패 정보가 브리프에** — 수정 브리프의 [컨텍스트]나 [함정]에 실패 케이스·기대값·현재 동작이 담기는가? "테스트 통과시켜라"만 던지면 Worker가 같은 조사를 반복합니다.
- [ ] **직접 수정 금지 준수** — 할인 등급 추가는 로직 변경이므로 Advisor가 직접 Edit하지 않고 Worker에게 가는가? (오타 수준이 아니므로 예외 규정 대상이 아닙니다)

실측(2026-10-05)에서 Advisor가 Worker에게 넘긴 수정 브리프입니다 (경로는 줄임). Advisor는 테스트를 돌리지 않고 `cat cart.js cart.test.js`로 읽어 실패를 파악했는데, 기대값과 현재 동작은 물론 고칠 위치의 함정까지 브리프에 담았습니다:

```
[목표] .../cart.js 의 totalPrice에 "소계 50,000원 이상이면 20% 할인" 구간을 추가.
[컨텍스트] 현재 구현: subtotal >= 10000 이면 Math.round(subtotal * 0.9), 아니면 subtotal. 테스트 cart.test.js(수정 금지)는 `node cart.test.js`로 실행, 마지막 케이스 [{price:25000, qty:2}] → 40000 기대.
[컨벤션] 기존 스타일 유지(early return, Math.round). 최소 diff: `if (subtotal >= 50000) return Math.round(subtotal * 0.8);` 를 10000 체크 앞에 한 줄 추가.
[함정] 50000 체크가 10000 체크 뒤에 오면 절대 도달 못 함 — 반드시 앞에. 할인 중첩 금지(20%만 적용).
[완료 기준] `node cart.test.js` 가 두 PASS 줄 출력, exit 0.
[범위 경계] cart.js만 수정. cart.test.js, package.json 건드리지 말 것. 커밋하지 말 것. 주석 오타 등 다른 정리도 하지 말 것.
```

세션 종료 후 확인합니다:

```bash
cd ~/advisor-demo
node cart.test.js && git log --oneline -2
```

`PASS — 4번째 케이스(20% 할인)도 통과`와 새 커밋이 보이면 사이클이 완주된 것입니다 (앞의 `PASS — 3개 케이스 전부 통과`는 기존 케이스가 새 케이스보다 먼저 실행돼 실패 전에도 찍히는 줄이므로, 판정은 4번째 케이스 줄로 합니다).

!!! note "방금 본 것 — 판단은 Advisor, 손은 Worker"

    한 줄짜리 로직 수정인데도 Advisor는 직접 고치지 않고 위임했습니다. Step 0에서 덧붙인 "테스트 기대값이 바뀌는 로직 수정은 한두 줄이라도 위임한다"가 작동한 것입니다. 브리프에는 고칠 줄과 위치의 함정까지 들어 있어, 판단은 Advisor가 다 하고 Worker는 그대로 옮겨 적고 검증만 했습니다. 실측에서 Advisor는 위임 전에 테스트를 직접 돌리지는 않았지만, Worker 보고 뒤에는 `git diff`와 `node cart.test.js`를 직접 다시 실행한 다음 커밋했습니다.

> Worker의 "완료" 보고가 거짓으로 판명되어 게이트가 거부하는 장면은 이 방법으로 강제할 수 없습니다 — Worker도 완료 기준을 스스로 실행해 보고하기 때문에, 성실한 Worker일수록 거부는 드뭅니다. 게이트의 가치는 거부의 빈도가 아니라 **존재**에 있습니다: 거부할 수 있는 검증이 있어야 통과가 신호가 됩니다 ([[concept-loop-engineering]]).

---

## 장면 2 — 독립 작업의 병렬 위임 (5분)

서로 의존하지 않는 두 모듈을 한 번에 요청해, Advisor가 **한 턴에 여러 Task를 동시에** 던지는지 봅니다.

독립인 두 완료 기준을 먼저 둡니다:

```bash
cd ~/advisor-demo
cat > coupon.test.js << 'EOF'
const { applyCoupon } = require('./coupon');
const assert = require('node:assert');
assert.strictEqual(applyCoupon(10000, 'WELCOME1000'), 9000); // 정액 1,000원 할인
assert.strictEqual(applyCoupon(500, 'WELCOME1000'), 0);      // 할인이 총액보다 크면 0원
assert.strictEqual(applyCoupon(10000, 'NONE'), 10000);       // 모르는 쿠폰은 무시
console.log('PASS — coupon 3개 케이스 전부 통과');
EOF
cat > shipping.test.js << 'EOF'
const { shippingFee } = require('./shipping');
const assert = require('node:assert');
assert.strictEqual(shippingFee(30000), 3000); // 기본 배송비
assert.strictEqual(shippingFee(50000), 0);    // 5만원 이상 무료
assert.strictEqual(shippingFee(0), 3000);     // 빈 주문도 기본 배송비
console.log('PASS — shipping 3개 케이스 전부 통과');
EOF
```

Advisor 세션(`claude --agent advisor`)에서 두 작업을 한 문장으로 요청합니다:

```
coupon.test.js와 shipping.test.js가 각각의 완료 기준이다. coupon.js와 shipping.js를 구현해줘. 두 모듈은 서로 의존하지 않는다. 검증이 끝나면 커밋해줘.
```

**관찰 포인트**:

- [ ] **동시 출발** — 두 Task 호출이 한 턴에 같이 나가는가? (화면에 worker 2개가 동시에 진행되면 병렬, 하나 끝나고 다음이 시작되면 순차)
- [ ] **브리프 분리** — 각 Task의 브리프가 자기 모듈의 완료 기준·범위 경계만 담는가? 한 브리프에 두 모듈을 섞으면 병렬이 아니라 한 Worker에 몰아준 것입니다.
- [ ] **검증은 합산** — Advisor가 두 결과를 각각 재검증(`node coupon.test.js`·`node shipping.test.js`)한 뒤에 커밋하는가?

실측(2026-10-05)에서는 Advisor의 한 메시지 안에 위임 호출 2개(`Implement coupon.js`, `Implement shipping.js`)가 함께 들어 있었습니다. 두 브리프의 [범위 경계]는 각각 "coupon.js만 만든다", "shipping.js만 만든다"였고, Advisor는 두 결과를 따로 재검증한 뒤 모듈별로 커밋 2개를 만들었습니다.

!!! note "방금 본 것 — 독립이면 동시에"

    두 모듈이 서로 의존하지 않는다는 판단을 Advisor가 했고, 그 판단이 "한 턴에 두 위임"으로 나타났습니다. 브리프가 모듈별로 나뉘어 있어 두 Worker는 서로의 일을 몰라도 됐습니다.

> 병렬의 값어치는 **독립성 판단**에 있습니다. 만약 "coupon이 cart의 할인 이후 금액에 적용"처럼 의존이 있었다면 순차가 맞습니다 — 병렬은 빠름이 아니라 의존 그래프의 표현입니다.

---

## 장면 3 — 역할별 이종 모델 + 환경변수 함정 (5분)

원본 스크립트는 판단(Advisor)에 상위 모델, 구현(Worker)에 한 단계 아래 모델을 frontmatter로 고정합니다 ([[concept-advisor-worker]]의 모델 티어링). 이 장면은 그 고정이 실제로 작동하는지, 그리고 `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수가 그것을 덮어쓰는지 **실측**합니다.

Worker에 하위 모델을 고정합니다 (계정에서 쓸 수 있는 다른 모델 id로 바꿔도 됩니다). 아래 블록은 파이썬으로 `worker.md`의 첫 `---` 바로 다음 줄에 `model:` 한 줄을 끼워 넣고, 바뀐 frontmatter를 출력합니다:

```bash
cd ~/advisor-demo
python3 - << 'EOF'
import re
p = '.claude/agents/worker.md'
s = open(p).read()
s = re.sub(r'^---\n', '---\nmodel: claude-haiku-4-5-20251001\n', s, count=1)
open(p, 'w').write(s)
print(open(p).read().split('---')[1])
EOF
```

관찰 채널은 헤드리스 로그입니다 — 세션을 `-p`로 돌리고 메시지마다 찍히는 `model` 필드를 셉니다. 작업은 작지만 위임 대상인 것으로 줍니다. 마지막 줄의 `grep -o … | sort | uniq -c`는 로그에서 `"model":"…"` 부분만 뽑아 종류별 개수를 셉니다:

```bash
cd ~/advisor-demo
claude --agent advisor -p "gift.test.js를 새로 만들고(wrapFee(items)가 항상 500을 반환하는지 검사) gift.js를 구현해줘. 검증 후 커밋까지." \
  --allowedTools "Read,Grep,Glob,Edit,Write,Task,Bash(node *),Bash(git *)" \
  --output-format stream-json --verbose > run-tiering.jsonl 2>&1
grep -o '"model":"[^"]*"' run-tiering.jsonl | sort | uniq -c
```

실측 출력입니다 (개수는 실행마다 다릅니다). haiku 줄이 Worker의 메시지, `claude-opus-5-5` 줄이 Advisor의 메시지이고, `[1m]`이 붙은 한 줄은 세션 시작 정보에 찍힌 메인 모델 이름입니다:

```
   6 "model":"claude-haiku-4-5-20251001"
  11 "model":"claude-opus-5-5"
   1 "model":"claude-opus-5-5[1m]"
```

이제 환경 변수와의 우선순위를 확인합니다 — 환경 변수를 메인 모델 이름으로 설정하고 같은 구조의 작업을 한 번 더 돌립니다. 첫 줄의 `$( … )`는 앞 실행 로그에서 haiku가 아닌 모델 이름을 뽑아 환경 변수 값으로 넣습니다. `변수=값 명령` 형태로 쓰면 그 명령 한 번에만 환경 변수가 적용됩니다:

```bash
cd ~/advisor-demo
CLAUDE_CODE_SUBAGENT_MODEL=$(grep -o '"model":"[^"]*"' run-tiering.jsonl | sort -u | grep -v haiku | head -1 | cut -d'"' -f4) \
claude --agent advisor -p "gift2.test.js를 새로 만들고(ribbonFee(items)가 항상 300을 반환하는지 검사) gift2.js를 구현해줘. 검증 후 커밋까지." \
  --allowedTools "Read,Grep,Glob,Edit,Write,Task,Bash(node *),Bash(git *)" \
  --output-format stream-json --verbose > run-override.jsonl 2>&1
grep -o '"model":"[^"]*"' run-override.jsonl | sort | uniq -c
```

실측 출력입니다 (2.1.289). 환경 변수 값이 `claude-opus-5-5`였는데도 Worker 메시지 7개는 여전히 haiku였습니다:

```
   7 "model":"claude-haiku-4-5-20251001"
  18 "model":"claude-opus-5-5"
   1 "model":"claude-opus-5-5[1m]"
```

**관찰 포인트**:

- [ ] 첫 실행에서 Worker 메시지의 모델이 frontmatter 지정값(haiku)인가?
- [ ] 환경 변수를 설정한 두 번째 실행에서 Worker의 모델이 바뀌었는가? 결과는 Claude Code 버전에 따라 다릅니다:

| Claude Code 버전 | 모델 우선순위 (높은 것부터) | 두 번째 실행의 Worker 모델 |
|---|---|---|
| 2.1.251 이상 (실측 2.1.289) | 호출 시 지정 → frontmatter `model` → `CLAUDE_CODE_SUBAGENT_MODEL` → 메인 모델 | haiku 그대로 (frontmatter 우선) |
| 2.1.250 이하 (실측 2.1.197, 2026-07-12) | `CLAUDE_CODE_SUBAGENT_MODEL`이 frontmatter·`inherit`까지 덮어씀 | 환경 변수 값으로 바뀜 |

우선순위는 [공식 문서](https://code.claude.com/docs/en/sub-agents)의 기술과 같습니다. 원본 스크립트의 경고("이 변수가 설정돼 있으면 Worker 지정을 덮어쓴다")는 옛 버전 기준이라, 지금은 "frontmatter에 `model`이 없는 에이전트의 기본값을 정하는 변수"로 이해하면 됩니다. 버전은 `claude --version`으로 확인합니다.

!!! note "방금 본 것 — 기본값이 버전마다 바뀐다"

    같은 설정이 버전에 따라 정반대로 동작했습니다. 모델을 역할별로 고정해 두었다면, 도구를 업데이트한 뒤에는 로그의 `model` 필드로 실제 모델을 한 번 확인하는 습관이 필요합니다. 로그 파일(`run-*.jsonl`)은 저장소 안에 생기지만, 실측에서 Advisor는 커밋할 파일을 하나씩 지정해 로그가 커밋에 섞이지 않았습니다.

> 모델 티어링이 비용에 갖는 의미: 호출 횟수가 많은 쪽(Worker)에 단가 낮은 모델을 두는 구조입니다. 종량제 환경([[src-copilot-token-pricing]])에서는 이 배치가 그대로 비용 레버가 됩니다.

---

## 장면 4 — 위임 오버헤드 예외 (2분)

Step 0에서 심어 둔 오타가 여기서 쓰입니다. 브리프를 쓰는 비용이 작업 자체보다 큰 일을 시켜, Advisor가 위임하지 않고 **직접 처리**하는지 봅니다.

Advisor 세션(`claude --agent advisor`)에서:

```
cart.js 첫 줄 주석의 오타 '모둘'을 '모듈'로 고쳐줘.
```

**관찰 포인트**:

- [ ] Task 호출 없이 Advisor가 직접 Edit로 끝내는가? (축약판 advisor의 도구 목록에 Edit가 있는 이유가 이 예외입니다)
- [ ] 반대로 이 한 글자에도 Worker를 부른다면, 예외 규정이 지시문에 있어도 작동하지 않은 것 — 규율 문구를 더 구체화할 신호입니다.

실측(2026-10-05)에서 Advisor는 위임 호출 없이 `Read` → `Edit` → `git diff`로 끝냈고, "주석만 바뀌어서 동작에는 영향이 없고, 위임하지 않고 직접 수정했어요"라고 보고했습니다. 커밋은 요청하지 않아 하지 않았고, 장면 3에서 바뀐 `worker.md`가 커밋되지 않은 채 남아 있다는 점도 짚었습니다.

!!! note "방금 본 것 — 예외의 기준은 크기가 아니라 동작"

    장면 1의 한 줄 수정은 위임했고, 장면 4의 한 글자 수정은 직접 했습니다. 둘 다 작았지만 장면 1은 테스트 결과가 바뀌는 수정이었고 장면 4는 아니었습니다. Step 0에서 예외 기준을 "동작 변경 여부"로 적어 둔 것이 이 차이를 만들었습니다.

### 막힐 때

| 증상 | 원인 | 해결 |
|---|---|---|
| 장면 1에서 Advisor가 위임 없이 직접 고침 | 오버헤드 예외 문구가 "한두 줄"처럼 크기 기준임 | Step 0의 규율 2줄이 `advisor.md` 끝에 들어갔는지 `tail -3 .claude/agents/advisor.md`로 확인 |
| 장면 3의 `grep … \| uniq -c` 결과가 비어 있음 | 실행이 실패해 로그에 메시지가 없음 | `tail -5 run-tiering.jsonl`로 오류 확인. 로그인·네트워크 문제면 기본편 Step 3부터 다시 |
| 장면 3에서 haiku가 안 보임 | 계정에서 그 모델을 쓸 수 없음 | `model:` 값을 계정에서 쓸 수 있는 다른 모델로 바꿈 (`sonnet`·`haiku` 같은 별칭도 가능) |
| 권한 거부가 반복됨 | Claude Code 대화 화면 안에서 실행 | 일반 터미널 창에서 실행 |

---

## 관찰 결과표 (직접 채워보기, 1분)

| 장면 | 관찰한 규율 | 재현됐는가 (O/X) | 메모 |
|------|------------|------------------|------|
| 1 | 검증 실패 → 수정 브리프 재위임 (직접 수정 금지) | __ | __ |
| 2 | 독립 작업 병렬 위임 + 브리프 분리 | __ | __ |
| 3 | frontmatter 모델 고정 / 환경변수 덮어쓰기 | __ / __ | __ |
| 4 | 위임 오버헤드 예외 — 직접 Edit | __ | __ |

---

## 정리 (30초)

```bash
cd ~ && rm -rf ~/advisor-demo
```

---

## 규율이 없으면 생기는 일

네 장면이 각각 막는 실패 모드입니다:

| 규율 | 없을 때 생기는 일 | 참조 |
|------|------------------|------|
| 수정 브리프 재위임 | 검증 실패 시 Advisor가 직접 고치기 시작 → 다음 검증부터 구현자가 검증자를 겸함 (독립성 붕괴) | [[concept-advisor-worker]] |
| 병렬 위임 | 독립 작업이 직렬로 늘어져 대기 시간 낭비 — 반대로 의존 작업을 병렬로 던지면 충돌 | [[concept-multi-agent-pattern]] |
| 모델 고정 | 환경 변수·기본값이 조용히 모델을 바꿔 비용 구조와 품질이 예고 없이 변함 (우선순위도 버전마다 다름 — 장면 3) — "기본값과 가정의 함정"의 에이전트판 | [[concept-advisor-worker]] |
| 오버헤드 예외 | 오타 수정에도 브리프+서브에이전트 비용 지출 — 위임이 목적이 되고 경제성이 사라짐 | [[src-ai-advisor-worker]] |

---

## 원본 출처

- `raw/ai-engineering/ai-advisor/advisor_script.md` — 병렬 위임·수정 브리프·오버헤드 예외 규율 원문
- `raw/ai-engineering/ai-advisor/worker_script.md` — Worker 보고 규율 원문
- `raw/ai-engineering/ai-advisor/claude_script.md` — `CLAUDE_CODE_SUBAGENT_MODEL` 주의 문구 원문 (2.1.250 이하 기준 — 2026-10-05 교정 주석 추가)
- `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md` — 실행 검증 증적 (장면별 도구 호출 순서·브리프 원문·모델 집계·비용)
- [Claude Code 서브에이전트 공식 문서](https://code.claude.com/docs/en/sub-agents) — 모델 우선순위(2.1.251 변경), `Task`→`Agent` 이름 변경

## 관련 페이지

- [[guide-advisor-worker-demo]] — 기본편 (셋업 Step 1~2·관찰 포인트 4장면, 실행 검증됨)
- [[concept-advisor-worker]] — 패턴 개념 (구성 요소 4가지·모델 티어링·적용 기준)
- [[src-ai-advisor-worker]] — 원본 스크립트 해설
- [[guide-loop-engineering-demo]] — 토큰 비용 원칙(Step 6.5)의 출처
- [[comparison-advisor-worker-vs-graph]] — 장면 1(프롬프트 규율의 한계)을 그래프의 코드 강제와 대조한 비교
