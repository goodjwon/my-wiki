---
title: Advisor–Worker 실습 — 판단·구현 분리 직접 체험 (claude --agent)
type: synthesis
tags: [claude-code, multi-agent, subagent, delegation, demo, hands-on]
sources:
  - ai-advisor/advisor_script.md
  - ai-advisor/worker_script.md
  - ai-advisor/claude_script.md
created: 2026-07-06
updated: 2026-07-06
---

# Advisor–Worker 실습 — 판단·구현 분리 직접 체험

> **이 실습의 목적**: [[src-ai-advisor-worker]] 의 핵심 — **"메인 세션은 판단·검증만, 구현 노동은 서브에이전트에게"** — 를 데모 프로젝트에서 직접 실행해 봅니다. 브리프가 오가고, Advisor가 Worker의 "완료" 보고를 diff·테스트로 재검증하는 장면을 눈으로 확인하는 게 핵심입니다.

**시간**: 15분 (셋업 3분 + 에이전트 설치 3분 + 실행·관찰 7분 + 정리 2분)

**언제 보면 좋은가**: [[src-ai-advisor-worker]] 를 읽은 직후. [[guide-harness-module4]](Planner/Coder/Critic)의 다음 단계 — Module 4가 역할 분리를 "문서 규정"으로 했다면, 이 실습은 **frontmatter `tools` 제한으로 구조적으로 강제**합니다.

**전제**: Claude Code 설치·로그인, Node 18+. Step 3부터는 실제 모델을 호출하므로 **토큰이 소모됩니다** — Advisor(메인) + Worker(서브에이전트) 이중 호출이라 일반 세션보다 비쌉니다.

---

## 왜 이 실습인가 — 1분 이론

역할을 "부탁"으로 나누면 새면서 섞입니다. "너는 검증만 해"라고 말해도 모델은 결국 직접 고치기 시작합니다. 이 모델의 답은 [[concept-harness-engineering]] 식 구조 강제입니다:

- Advisor의 `tools`에는 `Write`가 없습니다 → 파일을 새로 만들 수 없으니 구현 노동이 물리적으로 막힙니다.
- Worker의 `tools`에는 `Task`가 없습니다 → 재위임이 물리적으로 막힙니다.
- 커밋 권한은 Advisor에게만 → 검증 게이트를 통과한 변경만 저장소에 들어갑니다.

그리고 Advisor의 규율 한 줄이 [[concept-loop-engineering]]의 거부 신호를 구현합니다: **"Worker의 완료 보고를 그대로 믿지 마라 — diff를 직접 읽고 테스트를 직접 재실행하라."**

---

## Step 1 — 데모 프로젝트 셋업 (3분)

검증 대상이 있어야 게이트가 작동합니다. 테스트가 딸린 최소 Node 프로젝트를 만듭니다.

```bash
mkdir -p ~/advisor-demo/.claude/agents && cd ~/advisor-demo
git init -q && npm init -y > /dev/null
```

완료 기준이 될 테스트를 먼저 둡니다 (구현은 아직 없음 — 최종 목표에서 역산):

```bash
cat > cart.test.js << 'EOF'
const { totalPrice } = require('./cart');
const assert = require('node:assert');

// 수량 합산
assert.strictEqual(totalPrice([{ price: 1000, qty: 2 }]), 2000);
// 10,000원 이상 구매 시 10% 할인
assert.strictEqual(totalPrice([{ price: 6000, qty: 2 }]), 10800);
// 빈 카트는 0원
assert.strictEqual(totalPrice([]), 0);
console.log('PASS — 3개 케이스 전부 통과');
EOF
```

```bash
node cart.test.js
```

지금은 `Cannot find module './cart'`로 **실패해야 정상**입니다. 이 실패 상태가 Worker에게 넘어갈 브리프의 `[완료 기준]`이 됩니다.

---

## Step 2 — 에이전트 정의 설치 (3분)

핵심 규율만 담은 축약판을 설치합니다. 전문(全文)은 raw/ai-advisor/advisor_script.md · raw/ai-advisor/worker_script.md 참조.

**Advisor** — 판단 역할. `Write` 없음, `Task` 있음:

```bash
cat > .claude/agents/advisor.md << 'EOF'
---
name: advisor
description: 판단·설계·검증 오케스트레이터. 구현 노동은 worker 서브에이전트에 위임한다.
tools: Read, Grep, Glob, Bash, Edit, Task
---

너는 Advisor다. 판단에 집중하고, 구현 노동은 Worker에게 위임한다.

- 코드 작성·수정, 테스트 작성 등 구현 작업 전부를 `Task` 도구로 `worker`에게 위임한다.
- 브리프 골격: [목표] [컨텍스트] [컨벤션] [함정] [완료 기준] [범위 경계] — 네가 파악한 컨텍스트를 담아 Worker가 재탐색하지 않게 하라.
- Worker의 "완료" 보고를 그대로 믿지 마라. 승인 전에 반드시 ① git diff로 변경을 직접 읽고 ② 완료 기준 테스트를 직접 재실행한다.
- 검증 실패는 수정 브리프로 재위임한다. 직접 수정은 오타·임포트 누락 같은 사소한 마무리만.
- 커밋은 검증 통과분만, git commit은 너의 몫이다.
EOF
```

**Worker** — 실행 역할. `Write` 있음, `Task` 없음:

```bash
cat > .claude/agents/worker.md << 'EOF'
---
name: worker
description: 구현 전담 서브에이전트. Advisor의 브리프대로 구현하고 정직하게 보고한다.
tools: Read, Write, Edit, Bash, Glob, Grep
---

너는 Worker다. 브리프대로 구현하고, 결과를 정직하게 보고한다.

- 브리프의 완료 기준(테스트/명령어 통과)이 "끝"의 정의다.
- 범위 경계 밖 파일은 건드리지 않는다. 겸사겸사 리팩터링 금지.
- 보고 전에 완료 기준 명령을 직접 실행하고, 실패했으면 숨기지 말고 그대로 보고한다.
- 커밋하지 않는다. git add/commit은 Advisor의 몫이다.
- 보고 형식: 변경 요약 / 검증(실행 명령·PASS·FAIL·핵심 출력) / 가정·블로커 / 브리프 대비 이탈.
EOF
```

> 원본 스크립트는 frontmatter에 `model:`(Advisor는 Fable 5, Worker는 Opus 4.8)을 고정해 역할별 이종 모델을 씁니다. 이 실습에서는 계정 기본 모델로도 충분해 생략했습니다 — 붙일 경우 `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수가 비어 있는지 확인하세요 (설정돼 있으면 Worker의 모델 지정을 덮어씁니다).

---

## Step 3 — Advisor 세션 실행 (5분)

메인 세션 자체를 Advisor로 띄우고, 구현이 필요한 작업을 던집니다.

```bash
cd ~/advisor-demo
claude --agent advisor
```

세션 안에서:

```
cart.test.js가 완료 기준이다. 이 테스트가 통과하도록 cart.js를 구현하고, 검증이 끝나면 커밋까지 해줘.
```

---

## Step 4 — 관찰 포인트 (2분)

세션 진행을 지켜보며 다음 4장면을 확인합니다:

- [ ] **브리프 작성** — Advisor가 `Task(worker)` 호출에 [목표]~[범위 경계] 골격의 지시서를 담는가? `cart.test.js`의 케이스(수량 합산·10% 할인·빈 카트)를 [완료 기준]으로 옮겼는가?
- [ ] **역할 준수** — cart.js를 만든 것이 Worker(서브에이전트)인가? Advisor는 Write 도구가 없어 직접 만들 수 없습니다.
- [ ] **검증 게이트** — Worker가 "완료"를 보고한 뒤, Advisor가 `git diff`와 `node cart.test.js`를 **자기 손으로 다시** 실행하는가? Worker가 이미 돌렸다는 이유로 건너뛰지 않는가?
- [ ] **커밋 주체** — `git commit`을 Advisor가 검증 후에 하는가?

확인 명령 (세션 종료 후):

```bash
node cart.test.js && git log --oneline -3
```

`PASS — 3개 케이스 전부 통과`와 Advisor가 만든 커밋이 보이면 성공입니다.

---

## Step 5 — 차이 표 (직접 채워보기, 30초)

일반 단일 세션(`claude`)으로 같은 작업을 시켜본 경험과 비교합니다:

|  | 단일 세션 | Advisor–Worker 세션 |
|---|---|---|
| 구현을 누가 하나 | __ | __ (메인? 서브에이전트?) |
| "완료" 판정의 근거 | __ (자기 보고?) | __ (독립 재검증?) |
| 역할 이탈을 막는 것 | __ (지시문뿐?) | __ (tools 제한?) |
| 메인 컨텍스트에 남는 것 | __ (구현 시행착오 전부?) | __ (브리프와 결과만?) |

**한 줄 소감**: ____________________________________________

---

## 정리 (30초)

```bash
cd ~ && rm -rf ~/advisor-demo
```

---

## 역할 분리가 잘 설계됐는지 체크리스트

- [ ] 각 역할이 **하면 안 되는 일**이 지시문이 아니라 **도구 목록**으로 막혀 있는가? (Advisor에 Write 없음, Worker에 Task 없음)
- [ ] 위임 인터페이스(브리프)에 **완료 기준**이 실행 가능한 명령으로 들어 있는가?
- [ ] 검증자가 실행자의 보고를 **재실행으로** 확인하는가, 보고문을 읽고 끝내는가?
- [ ] 위임 오버헤드가 더 큰 사소한 일(오타·한 줄 수정)의 **예외 규정**이 있는가?
- [ ] 커밋(되돌리기 어려운 결정)의 권한이 **검증자 쪽에만** 있는가?

---

## 같은 인사이트 패턴 — "보고를 믿지 말고 재검증하라"

이 실습이 보여준 원리는 위키 전반에 반복됩니다:

| 영역 | 맹신 시나리오 | 재검증 메커니즘 | 참조 |
|------|---------------|----------------|------|
| **Advisor–Worker** | Worker의 "완료" 보고를 그대로 승인 | Advisor가 diff·테스트 직접 재실행 (이 실습) | [[src-ai-advisor-worker]] |
| **AI 루프** | 에이전트 자기 보고로 종료 → 메아리방 | 테스트 exit code를 종료 조건으로 | [[guide-loop-engineering-demo]] |
| **멀티 에이전트 3-tier** | Coder의 verify 없는 "완료" 선언 | Critic의 CONDITIONAL REJECT | [[concept-multi-agent-pattern]] |
| **Hooks** | "위험 명령 안 쓸게요"라는 약속 | guard.sh exit 1 → 도구 차단 | [[concept-claude-hooks]] |

→ **공통 원리**: 실행 주체의 자기 보고는 검증 대상이지 승인 근거가 아닙니다. 검증은 **독립 주체의 재실행**이어야 합니다.

---

## 원본 출처

- raw/ai-advisor/advisor_script.md — Advisor 전문 (설계 접근·병렬 위임·사용자 보고 규율 포함)
- raw/ai-advisor/worker_script.md — Worker 전문 (보고 형식 원판)
- raw/ai-advisor/claude_script.md — 프로젝트 CLAUDE.md 템플릿 (팀 공통 규율 버전)

---

## 관련 페이지

- [[src-ai-advisor-worker]] — 이 실습의 이론·원본 스크립트 해설
- [[guide-harness-module4]] — 직전 단계: Planner/Coder/Critic 실습 (문서 규정 방식)
- [[guide-loop-engineering-demo]] — 거부 신호 루프 실습 (검증 게이트의 루프 버전)
- [[concept-multi-agent-pattern]] — 역할 분리 패턴 전반
- [[concept-harness-engineering]] — 부탁 대신 구조로 강제하는 상위 개념
