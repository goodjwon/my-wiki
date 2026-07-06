---
title: Advisor–Worker 실습 심화편 — 재위임·병렬·모델 티어링·오버헤드 예외
type: synthesis
tags: [claude-code, multi-agent, subagent, delegation, demo, hands-on]
sources:
  - ai-advisor/advisor_script.md
  - ai-advisor/worker_script.md
  - ai-advisor/claude_script.md
created: 2026-07-06
updated: 2026-07-06
---

# Advisor–Worker 실습 심화편 — 재위임·병렬·모델 티어링·오버헤드 예외

> **이 실습의 목적**: [[guide-advisor-worker-demo]](기본편)는 1사이클 성공 경로만 체험합니다. 심화편은 원본 스크립트에 있지만 기본편이 다루지 않은 규율 4가지를 장면별로 재현합니다 — ① 검증 실패 → **수정 브리프 재위임** ② 독립 작업의 **병렬 위임** ③ **역할별 이종 모델** 고정과 환경변수 함정 ④ **위임 오버헤드 예외**(사소한 일은 직접).

**시간**: 25분 (셋업 5분 + 장면 1 재위임 7분 + 장면 2 병렬 5분 + 장면 3 모델 5분 + 장면 4 예외 2분 + 정리 1분)

**언제 보면 좋은가**: 기본편을 끝낸 직후. 기본편이 "게이트가 있다"를 보여줬다면, 심화편은 **게이트가 거부하는 장면**과 위임의 경제학(병렬·모델 단가·오버헤드 역전)을 봅니다.

**전제**: 기본편과 동일 (Claude Code 설치·로그인, Node 18+). **토큰 비용은 기본편보다 큽니다** — 위임 사이클이 2회 이상 돌고 장면 3은 세션을 두 번 띄웁니다. [[guide-loop-engineering-demo]] Step 6.5의 원칙 그대로, 무료 검증(`node *.test.js`)을 모델 호출 앞에 두고 각 장면은 1~2사이클 안에 끝냅니다.

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
node cart.test.js && git add cart.js cart.test.js package.json .claude && git commit -qm "cart 기본 구현 (기본편 완료 상태 복원)"
```

```text
예상 결과
PASS — 3개 케이스 전부 통과
```

기본편의 축약판 advisor에는 심화편이 관찰할 규율 2줄이 없으므로 덧붙입니다:

```bash
cat >> .claude/agents/advisor.md << 'EOF'
- 서로 독립적인 작업은 한 턴에 여러 Task로 병렬 위임한다. 의존 관계가 있으면 순차로 나눈다.
- 한두 줄 수정처럼 위임 오버헤드(브리프 작성)가 더 큰 일은 위임하지 말고 직접 처리한다.
EOF
```

---

## 장면 1 — 검증 실패 → 수정 브리프 재위임 (7분)

기본편에서 재현되지 않은 유일한 규율입니다: **검증이 실패하면 Advisor는 직접 고치지 않고, 무엇이 왜 실패했는지 담은 수정 브리프로 재위임한다.**

실패를 확정적으로 만들기 위해 요구를 바꿉니다 — 5만원 이상 구매에 20% 할인 등급을 추가합니다. 현재 구현(일괄 10%)은 이 케이스에서 반드시 실패합니다:

```bash
cd ~/advisor-demo
cat >> cart.test.js << 'EOF'
// 50,000원 이상 구매 시 20% 할인 (요구 변경으로 추가)
assert.strictEqual(totalPrice([{ price: 25000, qty: 2 }]), 40000);
EOF
node cart.test.js || echo "→ 현재 구현은 새 케이스에서 실패한다 (45000 반환)"
```

Advisor 세션을 띄우고 요구 변경을 알립니다:

```bash
claude --agent advisor
```

```
요구가 바뀌어 cart.test.js에 케이스를 추가했다 (5만원 이상 20% 할인). 전부 통과하도록 수정하고, 검증이 끝나면 커밋해줘.
```

**관찰 포인트** — 이 장면의 핵심 3가지:

- [ ] **위임 전 실패 확인** — Advisor가 브리프를 쓰기 전에 `node cart.test.js`를 직접 실행해 어느 케이스가 어떻게 실패하는지(기대 40000, 실제 45000) 파악하는가?
- [ ] **실패 정보가 브리프에** — 수정 브리프의 [컨텍스트]나 [함정]에 실패 케이스·기대값·현재 동작이 담기는가? "테스트 통과시켜라"만 던지면 Worker가 같은 조사를 반복합니다.
- [ ] **직접 수정 금지 준수** — 할인 등급 추가는 로직 변경이므로 Advisor가 직접 Edit하지 않고 Worker에게 가는가? (오타 수준이 아니므로 예외 규정 대상이 아닙니다)

세션 종료 후 확인합니다:

```bash
node cart.test.js && git log --oneline -2
```

`PASS — 4개 케이스 전부 통과`와 새 커밋이 보이면 사이클이 완주된 것입니다.

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

Advisor 세션에서 두 작업을 한 문장으로 요청합니다:

```
coupon.test.js와 shipping.test.js가 각각의 완료 기준이다. coupon.js와 shipping.js를 구현해줘. 두 모듈은 서로 의존하지 않는다. 검증이 끝나면 커밋해줘.
```

**관찰 포인트**:

- [ ] **동시 출발** — 두 Task 호출이 한 턴에 같이 나가는가? (화면에 worker 2개가 동시에 진행되면 병렬, 하나 끝나고 다음이 시작되면 순차)
- [ ] **브리프 분리** — 각 Task의 브리프가 자기 모듈의 완료 기준·범위 경계만 담는가? 한 브리프에 두 모듈을 섞으면 병렬이 아니라 한 Worker에 몰아준 것입니다.
- [ ] **검증은 합산** — Advisor가 두 결과를 각각 재검증(`node coupon.test.js`·`node shipping.test.js`)한 뒤에 커밋하는가?

> 병렬의 값어치는 **독립성 판단**에 있습니다. 만약 "coupon이 cart의 할인 이후 금액에 적용"처럼 의존이 있었다면 순차가 맞습니다 — 병렬은 빠름이 아니라 의존 그래프의 표현입니다.

---

## 장면 3 — 역할별 이종 모델 + 환경변수 함정 (5분)

원본 스크립트는 판단(Advisor)에 상위 모델, 구현(Worker)에 한 단계 아래 모델을 frontmatter로 고정합니다 ([[concept-advisor-worker]]의 모델 티어링). 이 장면은 그 고정이 실제로 작동하는지, 그리고 `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수가 그것을 덮어쓰는지 **실측**합니다.

Worker에 하위 모델을 고정합니다 (계정에서 쓸 수 있는 다른 모델 id로 바꿔도 됩니다):

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

관찰 채널은 헤드리스 로그입니다 — 세션을 `-p`로 돌리고 메시지마다 찍히는 `model` 필드를 셉니다. 작업은 작지만 위임 대상인 것으로 줍니다:

```bash
claude --agent advisor -p "gift.test.js를 새로 만들고(wrapFee(items)가 항상 500을 반환하는지 검사) gift.js를 구현해줘. 검증 후 커밋까지." \
  --allowedTools "Read,Grep,Glob,Edit,Write,Task,Bash(node *),Bash(git *)" \
  --output-format stream-json --verbose > run-tiering.jsonl 2>&1
grep -o '"model":"[^"]*"' run-tiering.jsonl | sort | uniq -c
```

```text
예상 결과
  N "model":"claude-haiku-4-5-20251001"   ← Worker의 메시지들
  M "model":"<메인 세션 모델>"             ← Advisor의 메시지들
```

이제 함정을 재현합니다 — 환경변수를 설정하고 같은 구조의 작업을 한 번 더:

```bash
CLAUDE_CODE_SUBAGENT_MODEL=$(grep -o '"model":"[^"]*"' run-tiering.jsonl | sort -u | grep -v haiku | head -1 | cut -d'"' -f4) \
claude --agent advisor -p "gift2.test.js를 새로 만들고(ribbonFee(items)가 항상 300을 반환하는지 검사) gift2.js를 구현해줘. 검증 후 커밋까지." \
  --allowedTools "Read,Grep,Glob,Edit,Write,Task,Bash(node *),Bash(git *)" \
  --output-format stream-json --verbose > run-override.jsonl 2>&1
grep -o '"model":"[^"]*"' run-override.jsonl | sort | uniq -c
```

**관찰 포인트**:

- [ ] 첫 실행에서 Worker 메시지의 모델이 frontmatter 지정값(haiku)인가?
- [ ] 환경변수를 설정한 두 번째 실행에서 Worker의 모델이 **환경변수 값으로 바뀌었는가?** 바뀌었다면 원본 스크립트의 경고("이 변수는 비워둔다")가 실측으로 확인된 것입니다. 바뀌지 않았다면 그 결과 자체가 발견입니다 — 환경변수보다 frontmatter가 우선한다는 뜻이므로 원본 스크립트의 주의 문구를 갱신할 근거가 됩니다.

> 모델 티어링이 비용에 갖는 의미: 호출 횟수가 많은 쪽(Worker)에 단가 낮은 모델을 두는 구조입니다. 종량제 환경([[src-copilot-token-pricing]])에서는 이 배치가 그대로 비용 레버가 됩니다.

---

## 장면 4 — 위임 오버헤드 예외 (2분)

Step 0에서 심어 둔 오타가 여기서 쓰입니다. 브리프를 쓰는 비용이 작업 자체보다 큰 일을 시켜, Advisor가 위임하지 않고 **직접 처리**하는지 봅니다.

Advisor 세션에서:

```
cart.js 첫 줄 주석의 오타 '모둘'을 '모듈'로 고쳐줘.
```

**관찰 포인트**:

- [ ] Task 호출 없이 Advisor가 직접 Edit로 끝내는가? (축약판 advisor의 도구 목록에 Edit가 있는 이유가 이 예외입니다)
- [ ] 반대로 이 한 글자에도 Worker를 부른다면, 예외 규정이 지시문에 있어도 작동하지 않은 것 — 규율 문구를 더 구체화할 신호입니다.

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
| 모델 고정 | 환경변수·기본값이 조용히 모델을 바꿔 비용 구조와 품질이 예고 없이 변함 — "기본값과 가정의 함정"의 에이전트판 | [[concept-advisor-worker]] |
| 오버헤드 예외 | 한 줄 수정에도 브리프+서브에이전트 비용 지출 — 위임이 목적이 되고 경제성이 사라짐 | [[src-ai-advisor-worker]] |

---

## 원본 출처

- raw/ai-advisor/advisor_script.md — 병렬 위임·수정 브리프·오버헤드 예외 규율 원문
- raw/ai-advisor/worker_script.md — Worker 보고 규율 원문
- raw/ai-advisor/claude_script.md — `CLAUDE_CODE_SUBAGENT_MODEL` 주의 문구 원문

## 관련 페이지

- [[guide-advisor-worker-demo]] — 기본편 (셋업 Step 1~2·관찰 포인트 4장면, 실행 검증됨)
- [[concept-advisor-worker]] — 패턴 개념 (구성 요소 4가지·모델 티어링·적용 기준)
- [[src-ai-advisor-worker]] — 원본 스크립트 해설
- [[guide-loop-engineering-demo]] — 토큰 비용 원칙(Step 6.5)의 출처
