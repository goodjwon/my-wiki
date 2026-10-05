---
title: Advisor–Worker 실습 — 판단·구현 분리 직접 체험 (claude --agent)
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

# Advisor–Worker 실습 — 판단·구현 분리 직접 체험

> **이 실습의 목적**: [[src-ai-advisor-worker]] 의 핵심 — **"메인 세션은 판단·검증만, 구현 노동은 서브에이전트에게"** — 를 데모 프로젝트에서 직접 실행해 봅니다. 브리프가 오가고, Advisor가 Worker의 "완료" 보고를 diff·테스트로 재검증하는 장면을 눈으로 확인하는 게 핵심입니다.

**시간**: 20분 (셋업 3분 + 에이전트 설치 3분 + 실행·관찰 10분 + 정리 2분). Step 3의 Claude 실행 한 번에 실측 기준 약 5분이 걸립니다.

**언제 보면 좋은가**: [[src-ai-advisor-worker]] 를 읽은 직후. [[guide-harness-module4]](Planner/Coder/Critic)의 다음 단계 — Module 4가 역할 분리를 "문서 규정"으로 했다면, 이 실습은 **frontmatter `tools` 제한으로 구조적으로 강제**합니다.

**전제**: Claude Code 설치·로그인, Node 18+. Step 3부터는 실제 모델을 호출하므로 **토큰이 소모됩니다** — Advisor(메인) + Worker(서브에이전트) 이중 호출이라 일반 세션보다 비쌉니다. 실측 1회 약 $0.26(API 종량제 환산).

!!! tip "명령 실행 방법 (터미널이 처음이라면)"

    - 모든 `bash` 코드블록은 터미널에 블록 **전체**를 붙여넣고 `Enter`로 실행합니다. 자세한 요령은 [[guide-loop-engineering-demo]]의 "명령 실행 방법" 상자와 같습니다.
    - macOS 기본 셸(zsh)은 붙여넣은 명령의 `#` 주석을 인식하지 못해 오류가 날 수 있습니다. 실습 전에 `setopt interactivecomments`를 한 번 입력합니다.
    - `claude` 명령은 **Claude Code 밖의 일반 터미널**에서 실행합니다. Claude Code 대화 화면 안에서(`!` 명령 등) 실행하면 바깥 세션의 설정을 물려받아 권한이 막힐 수 있습니다.

> ✅ **실행 검증됨 (2026-10-05, Claude Code 2.1.289, Node v24, bash·zsh)**: Step 1~2 블록을 새 디렉터리에서 그대로 실행하고, Step 3을 헤드리스 `claude --agent advisor -p`로 실행해 도구 호출 로그를 감사했습니다. 관찰 포인트 4장면 전부 재현 — ① Advisor가 [목표]~[범위 경계] 6항목을 모두 채운 브리프로 `worker`에 위임 ② `cart.js`의 Write는 Worker만 수행 ③ Worker의 완료 보고 후 Advisor가 `git status`·`cat cart.js`로 변경을 읽고 `node cart.test.js`를 자기 손으로 재실행 ④ 커밋은 Advisor가 검증 후 실행. 1사이클에 3/3 통과, $0.26, 280초. 증적: `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md`. (최초 검증 2026-07-06)

---

## 왜 이 실습인가 — 1분 이론

역할을 "부탁"으로 나누면 경계가 새고 결국 섞입니다. "너는 검증만 해"라고 말해도 모델은 결국 직접 고치기 시작합니다. 이 모델의 답은 [[concept-harness-engineering]] 식 구조 강제입니다:

- Advisor의 `tools`에는 `Write`가 없습니다 → 파일을 새로 쓰는 도구 자체가 없어 구현 노동을 맡기기 어렵게 됩니다. 단, Advisor에게는 검증용 `Bash`가 있어서 `cat > 파일` 같은 셸 명령으로 우회하는 길은 남아 있습니다. 도구 제한은 **기본 경로를 막는 장치**이지 완전한 차단은 아니며, 나머지는 지시문의 규율이 맡습니다. (이번 실측에서 우회는 0건이었습니다.)
- Worker의 `tools`에는 서브에이전트를 부르는 도구(`Task`, 현재 이름 `Agent`)가 없습니다 → 재위임이 막힙니다.
- 커밋 권한은 Advisor에게만 → 검증 게이트를 통과한 변경만 저장소에 들어갑니다.

그리고 Advisor의 규율 한 줄이 [[concept-loop-engineering]]의 거부 신호를 구현합니다: **"Worker의 완료 보고를 그대로 믿지 마라 — diff를 직접 읽고 테스트를 직접 재실행하라."**

---

## 이 실습의 등장인물 — 무엇이 무엇을 맡는가

이 실습에는 가짜가 없습니다. Advisor와 Worker는 둘 다 진짜 Claude입니다. 다만 **한 Claude가 두 역할을 오가는 게 아니라, 역할마다 다른 지시문과 다른 도구를 가진 Claude 두 개가 따로 일합니다.** 그 역할 정의를 담은 것이 Step 2에서 만드는 두 파일입니다.

건축 현장에 비유하면 이렇습니다. 감리는 직접 벽돌을 쌓지 않습니다. 작업 지시서를 써서 시공팀에 넘기고, 시공팀이 "다 됐다"고 하면 직접 줄자를 대어 확인한 뒤에야 준공 도장을 찍습니다. 감리의 공구함에 흙손이 아예 없다면, 바쁜 날에도 감리가 직접 벽을 쌓아 버리는 일이 줄어듭니다. 시공팀은 지시서에 적힌 범위만 짓고, 다른 업체에 일을 다시 넘기지 않습니다.

| 실습 속 이름 | 실제로 무엇인가 | 비유 속 역할 |
|---|---|---|
| `.claude/agents/advisor.md` | 메인 세션이 따를 역할 정의. `claude --agent advisor`로 실행하면 대화 상대인 Claude가 이 지시문대로 일함 | 감리 |
| `.claude/agents/worker.md` | 서브에이전트 정의. Advisor가 위임 도구로 부르는 **별도의 Claude**로, 자기만의 대화 맥락에서 일하고 결과 보고만 돌려줌 | 시공팀 |
| frontmatter의 `tools` 목록 | 그 Claude가 쓸 수 있는 도구 목록. 목록에 없는 도구는 호출할 수 없음 | 공구함 |
| 브리프 | Advisor가 Worker를 부를 때 넘기는 지시문 (목표·컨텍스트·컨벤션·함정·완료 기준·범위 경계) | 작업 지시서 |
| `cart.test.js` | 완료 기준. 통과해야 "끝" | 줄자 |
| `git commit` | 검증을 통과한 변경을 저장소에 확정 | 준공 도장 |

서브에이전트(subagent)는 메인 Claude가 도구 호출 한 번으로 띄우는 또 하나의 Claude입니다. 메인 세션의 대화 내용을 보지 못하고 브리프만 받기 때문에, 브리프에 필요한 맥락을 다 담아야 합니다. 그래서 브리프 골격이 6항목이나 됩니다.

---

## Step 1 — 데모 프로젝트 셋업 (3분)

검증 대상이 있어야 게이트가 작동합니다. 테스트가 딸린 최소 Node 프로젝트를 만듭니다.

!!! example "실습 위치·실행"

    - **위치**: `~/advisor-demo` (이 Step에서 새로 만드는 데모 디렉터리)
    - **만들 파일**: `cart.test.js` — 아직 없는 `cart.js`를 채점할 완료 기준 테스트
    - **실행**: 아래 블록 3개를 차례로 붙여넣습니다. 토큰은 들지 않습니다.

디렉터리를 만들고 git 저장소와 Node 프로젝트로 초기화합니다:

```bash
mkdir -p ~/advisor-demo/.claude/agents && cd ~/advisor-demo   # .claude/agents는 Step 2의 에이전트 정의가 들어갈 자리
git init -q && npm init -y > /dev/null                       # git 저장소 만들기 + package.json 만들기 (출력은 숨김)
```

`-q`는 출력을 줄이는 옵션이고, `> /dev/null`은 화면 출력을 버린다는 뜻입니다. `&&`는 앞 명령이 성공했을 때만 뒤 명령을 실행합니다.

완료 기준이 될 테스트를 먼저 둡니다 (구현은 아직 없음 — 최종 목표에서 역산). `cat > 파일 << 'EOF'` … `EOF`는 두 `EOF` 줄 사이의 내용을 그대로 파일에 쓰는 셸 문법입니다:

```bash
cd ~/advisor-demo
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

방금 만든 테스트를 실행해 봅니다:

```bash
cd ~/advisor-demo
node cart.test.js
```

지금은 실패해야 정상입니다. 실측 출력의 앞부분입니다:

```
node:internal/modules/cjs/loader:1408
  throw err;
  ^

Error: Cannot find module './cart'
Require stack:
- /Users/you/advisor-demo/cart.test.js
```

!!! note "방금 본 것 — 실패하는 완료 기준"

    `cart.js`가 아직 없으니 테스트가 실패했습니다. 이 실패를 통과로 바꾸는 것이 Worker가 받을 일이고, 이 테스트가 브리프의 `[완료 기준]`이 됩니다. 일을 맡기기 전에 "끝"의 정의부터 실행 가능한 명령으로 만들어 둔 것입니다.

---

## Step 2 — 에이전트 정의 설치 (3분)

핵심 규율만 담은 축약판을 설치합니다. 전문(全文)은 `raw/ai-engineering/ai-advisor/advisor_script.md` · `raw/ai-engineering/ai-advisor/worker_script.md` 참조.

!!! example "실습 위치·실행"

    - **위치**: `~/advisor-demo`
    - **만들 파일**: `.claude/agents/advisor.md`, `.claude/agents/worker.md` — 두 역할의 정의
    - **실행**: 아래 블록 2개를 차례로 붙여넣습니다. 토큰은 들지 않습니다.

에이전트 정의 파일은 맨 위 `---` 사이의 설정(frontmatter)과 그 아래 지시문으로 이루어집니다:

| frontmatter 키 | 뜻 |
|---|---|
| `name` | 에이전트 이름. `claude --agent advisor`나 위임할 때 이 이름으로 부름 |
| `description` | 언제 이 에이전트를 쓰는지 한 줄 설명 |
| `tools` | 쓸 수 있는 도구 목록. 여기 없는 도구는 호출 불가 |
| `model` | (선택) 쓸 모델. 생략하면 메인 세션 모델을 따름 |

**Advisor** — 판단 역할. `Write` 없음, 위임 도구 `Task` 있음:

```bash
cd ~/advisor-demo
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
cd ~/advisor-demo
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

> **`Task`와 `Agent`**: 서브에이전트를 부르는 도구는 Claude Code 2.1.63에서 `Task`에서 `Agent`로 이름이 바뀌었습니다. 예전 이름 `Task`도 별칭으로 계속 동작하며([공식 문서](https://code.claude.com/docs/en/sub-agents)), 이 실습의 실측(2.1.289)도 `Task`로 적은 정의 그대로 위임이 됐습니다. 실행 로그에는 `Agent`로 찍힙니다.

> **모델 지정**: 원본 스크립트는 frontmatter에 `model:`을 넣어 역할별로 다른 모델을 고정합니다(작성 당시 Advisor는 Fable 5, Worker는 Opus 4.8 — 지금 쓸 수 있는 모델 이름은 계정에서 확인합니다). 이 실습에서는 계정 기본 모델로도 충분해 생략했습니다. `CLAUDE_CODE_SUBAGENT_MODEL` 환경 변수와의 관계는 Claude Code 버전에 따라 다릅니다 — 2.1.251부터는 frontmatter `model`이 환경 변수보다 우선하고, 그 이전 버전에서는 환경 변수가 frontmatter를 덮어썼습니다. 실측은 [[guide-advisor-worker-advanced]] 장면 3에 있습니다.

!!! note "방금 본 것 — 역할을 파일로 정의"

    두 Claude가 무엇을 할 수 있는지가 이제 파일로 고정됐습니다. Advisor는 위임(`Task`)과 검증(`Bash`)은 할 수 있지만 파일을 새로 쓰는 `Write`가 없고, Worker는 파일을 쓸 수 있지만 다시 위임할 수 없습니다. 지시문은 "부탁"이고, `tools` 목록은 "구조"입니다.

---

## Step 3 — Advisor 세션 실행 (5분)

메인 세션 자체를 Advisor로 띄우고, 구현이 필요한 작업을 던집니다.

!!! example "실습 위치·실행"

    - **위치**: `~/advisor-demo`
    - **실행**: 아래 명령으로 대화 화면을 열고, 그다음 블록의 요청을 붙여넣습니다. **토큰이 듭니다** (실측 약 $0.26, 약 5분).

```bash
cd ~/advisor-demo
claude --agent advisor                 # 메인 세션을 advisor.md의 지시문으로 실행
```

`--agent advisor`는 이 세션의 Claude가 기본 지시문 대신 `advisor.md`의 지시문과 도구 목록으로 일하게 합니다. 대화 화면에 아래 요청을 붙여넣습니다:

```
cart.test.js가 완료 기준이다. 이 테스트가 통과하도록 cart.js를 구현하고, 검증이 끝나면 커밋까지 해줘.
```

진행 중에 `node`·`git` 명령이나 파일 쓰기를 해도 되는지 묻는 창이 뜨면 **Yes**를 고릅니다. 화면에 worker 서브에이전트가 일하는 표시가 나타났다가 사라지고, 마지막에 Advisor의 보고가 나옵니다. 끝나면 `/exit`로 나옵니다.

!!! note "도구 호출 순서를 기록으로 남기고 싶다면 (선택)"

    대화 화면 대신 헤드리스로 실행하면 누가 어떤 도구를 불렀는지 로그로 남길 수 있습니다. 검증 증적은 이 방식으로 얻었습니다:

    ```bash
    cd ~/advisor-demo
    claude --agent advisor -p "cart.test.js가 완료 기준이다. 이 테스트가 통과하도록 cart.js를 구현하고, 검증이 끝나면 커밋까지 해줘." \
      --allowedTools "Read,Grep,Glob,Edit,Write,Agent,Bash(node *),Bash(git *)" \
      --output-format stream-json --verbose > ../advisor-run.jsonl
    ```

    `--allowedTools`는 묻지 않고 허용할 도구 목록입니다. Advisor의 `tools`에 `Write`가 없으므로 여기서 `Write`를 허용해도 Advisor는 쓸 수 없고, Worker만 씁니다. 로그는 저장소 밖(`../`)에 두어 커밋에 섞이지 않게 합니다.

---

## Step 4 — 관찰 포인트 (2분)

세션 진행을 지켜보며 다음 4장면을 확인합니다. 각 항목 아래는 2026-10-05 실측에서 실제로 일어난 일입니다:

- [ ] **브리프 작성** — Advisor가 위임 호출에 [목표]~[범위 경계] 골격의 지시서를 담는가? `cart.test.js`의 케이스를 [완료 기준]으로 옮겼는가?
    - 실측: 6항목을 모두 채웠습니다. [함정]에는 "0.9 곱셈은 부동소수점 오차 가능 → Math.round", "경계값 10000은 할인 대상"까지 담겼습니다.
- [ ] **역할 준수** — `cart.js`를 만든 것이 Worker(서브에이전트)인가?
    - 실측: Write는 Worker 1회뿐, Advisor는 0회였습니다.
- [ ] **검증 게이트** — Worker가 "완료"를 보고한 뒤, Advisor가 변경과 `node cart.test.js`를 **자기 손으로 다시** 확인하는가?
    - 실측: Worker 보고 직후 Advisor가 `git status --short && cat cart.js && node cart.test.js`를 직접 실행했습니다. 규율은 `git diff`라고 했지만 새 파일은 아직 git이 추적하지 않아 `git diff`에 나오지 않으므로, `cat`으로 내용을 읽은 것이 맞는 판단입니다.
- [ ] **커밋 주체** — `git commit`을 Advisor가 검증 후에 하는가?
    - 실측: 재검증 다음 동작이 Advisor의 `git add cart.js cart.test.js package.json && git commit`이었습니다. `.claude/`는 로컬 설정이라며 커밋에서 뺐습니다.

실측에서 Advisor가 Worker에게 넘긴 브리프 원문입니다 (경로는 줄임):

```
[목표] .../advisor-demo/cart.js 를 새로 만들어 `totalPrice(items)`를 export한다.
[컨텍스트] 같은 디렉터리의 cart.test.js가 완료 기준. 요구사항:
- items: [{ price, qty }] 배열. 합계 = Σ price*qty
- 합계가 10,000원 이상(>=)이면 10% 할인
- 빈 배열 → 0
[컨벤션] CommonJS: `module.exports = { totalPrice }`. 의존성 추가 금지. 최소 코드(10줄 내외).
[함정] 0.9 곱셈은 부동소수점 오차 가능 → 정수 연산(예: sum - sum / 10) 또는 Math.round 사용. 경계값 10000은 할인 대상.
[완료 기준] `node cart.test.js` 가 "PASS" 출력, exit 0.
[범위 경계] cart.js만 생성. cart.test.js, package.json 수정 금지. git 커밋 금지.
```

확인 명령 (세션 종료 후):

```bash
cd ~/advisor-demo
node cart.test.js && git log --oneline -3
```

실측 출력입니다. `PASS`와 Advisor가 만든 커밋이 보이면 성공입니다 (커밋 해시와 메시지는 실행마다 다릅니다):

```
PASS — 3개 케이스 전부 통과
2f53ad6 Add cart totalPrice with 10% discount at 10,000+
```

!!! note "방금 본 것 — 보고를 믿지 않는 검증자"

    Worker는 보고에 "`node cart.test.js`: PASS"라고 적었습니다. 그래도 Advisor는 그 문장을 근거로 커밋하지 않고, 파일을 직접 읽고 테스트를 직접 다시 돌린 뒤에야 커밋했습니다. 실행한 쪽의 "완료"는 검증 대상이고, 승인 근거는 독립된 쪽의 재실행입니다. [[guide-loop-engineering-demo]]에서 테스트 종료 코드가 루프를 끝냈던 것과 같은 원리가 이번에는 두 역할 사이에서 작동했습니다.

### 막힐 때

| 증상 | 원인 | 해결 |
|---|---|---|
| `claude --agent advisor`가 에이전트를 찾지 못함 | `~/advisor-demo`가 아닌 곳에서 실행했거나 Step 2 파일이 없음 | `cd ~/advisor-demo` 후 `ls .claude/agents`로 두 파일 확인 |
| Advisor가 위임하지 않고 직접 구현함 | 도구 제한은 `Write`만 막음 — `Bash`로 파일을 쓰는 우회가 가능 | 그 장면 자체가 관찰 결과입니다. 지시문 규율을 더 구체화하거나 Advisor의 `Bash`를 `Bash(node *)`·`Bash(git *)`처럼 좁힐 수 있음 |
| 권한을 묻는 창이 계속 뜸 | 대화 화면은 도구마다 허락을 받음 | 이 실습에서는 Yes로 진행. 반복을 줄이려면 "Yes, and don't ask again" 선택 |
| 권한 거부가 반복되고 진행이 안 됨 | Claude Code 대화 화면 안에서 실행해 바깥 세션 설정을 물려받음 | 일반 터미널 창에서 실행 |
| 몇 분 동안 화면 변화가 적음 | 위임·재검증으로 모델 호출이 여러 번 일어남 (실측 약 5분) | 기다립니다. 10분 넘게 멈추면 `Ctrl+C` 후 다시 시도 |

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

심화편([[guide-advisor-worker-advanced]])으로 이어서 할 거라면 지우지 않습니다. 끝낼 때는 데모 디렉터리를 지웁니다:

```bash
cd ~ && rm -rf ~/advisor-demo
```

---

## 역할 분리가 잘 설계됐는지 체크리스트

- [ ] 각 역할이 **하면 안 되는 일**이 지시문이 아니라 **도구 목록**으로 막혀 있는가? (Advisor에 Write 없음, Worker에 위임 도구 없음) 남은 우회로(`Bash`)는 범위를 좁혔는가?
- [ ] 위임 인터페이스(브리프)에 **완료 기준**이 실행 가능한 명령으로 들어 있는가?
- [ ] 검증자가 실행자의 보고를 **재실행으로** 확인하는가, 보고문을 읽고 끝내는가?
- [ ] 위임 오버헤드가 더 큰 사소한 일(동작이 바뀌지 않는 수정 — 오타·주석)의 **예외 규정**이 있는가?
- [ ] 커밋(되돌리기 어려운 결정)의 권한이 **검증자 쪽에만** 있는가?

---

## 같은 인사이트 패턴 — "보고를 믿지 말고 재검증하라"

이 실습이 보여준 원리는 위키 전반에 반복됩니다:

| 영역 | 맹신 시나리오 | 재검증 메커니즘 | 참조 |
|------|---------------|----------------|------|
| **Advisor–Worker** | Worker의 "완료" 보고를 그대로 승인 | Advisor가 diff·테스트 직접 재실행 (이 실습) | [[src-ai-advisor-worker]] |
| **AI 루프** | 에이전트 자기 보고로 종료 → 메아리방 | 테스트 exit code를 종료 조건으로 | [[guide-loop-engineering-demo]] |
| **멀티 에이전트 3-tier** | Coder의 verify 없는 "완료" 선언 | Critic의 CONDITIONAL REJECT | [[concept-multi-agent-pattern]] |
| **Hooks** | "위험 명령 안 쓸게요"라는 약속 | guard.sh exit 2 → 도구 차단 | [[concept-claude-hooks]] |

→ **공통 원리**: 실행 주체의 자기 보고는 검증 대상이지 승인 근거가 아닙니다. 검증은 **독립 주체의 재실행**이어야 합니다.

---

## 원본 출처

- `raw/ai-engineering/ai-advisor/advisor_script.md` — Advisor 전문 (설계 접근·병렬 위임·사용자 보고 규율 포함)
- `raw/ai-engineering/ai-advisor/worker_script.md` — Worker 전문 (보고 형식 원판)
- `raw/ai-engineering/ai-advisor/claude_script.md` — 프로젝트 CLAUDE.md 템플릿 (팀 공통 규율 버전)
- `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md` — 실행 검증 증적 (Step 3 도구 호출 순서·브리프·Worker 보고 원문·비용)
- [Claude Code 서브에이전트 공식 문서](https://code.claude.com/docs/en/sub-agents) — `Task`→`Agent` 이름 변경, `--agent`, `model` 우선순위

---

## 관련 페이지

- [[guide-advisor-worker-advanced]] — 다음 단계: 심화편 (재위임·병렬 위임·모델 티어링·오버헤드 예외)
- [[lecture-advisor-worker]] — 강의 노트: 기본편·심화편을 입문 수강생 강의 순서로 정리
- [[concept-advisor-worker]] — 이 실습이 체험하는 패턴의 개념 (원리·적용 기준)
- [[src-ai-advisor-worker]] — 이 실습의 이론·원본 스크립트 해설
- [[guide-harness-module4]] — 직전 단계: Planner/Coder/Critic 실습 (문서 규정 방식)
- [[guide-loop-engineering-demo]] — 거부 신호 루프 실습 (검증 게이트의 루프 버전)
- [[concept-multi-agent-pattern]] — 역할 분리 패턴 전반
- [[comparison-advisor-worker-vs-graph]] — 그래프 엔지니어링과의 축 차이·선택 기준 비교
- [[concept-harness-engineering]] — 부탁 대신 구조로 강제하는 상위 개념
