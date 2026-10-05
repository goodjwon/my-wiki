---
title: Advisor–Worker 강의 노트 — 판단과 구현을 나눠 맡기기
type: synthesis
tags: [claude-code, multi-agent, subagent, delegation, lecture, hands-on]
sources:
  - ai-engineering/ai-advisor/advisor_script.md
  - ai-engineering/ai-advisor/worker_script.md
  - ai-engineering/ai-advisor/claude_script.md
  - ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md
created: 2026-10-05
updated: 2026-10-05
---

# Advisor–Worker 강의 노트 — 판단과 구현을 나눠 맡기기

> **한 줄 요약**: 판단하는 Claude(Advisor)와 구현하는 Claude(Worker)를 따로 두고, 그 경계를 지시문이 아니라 **도구 목록**으로 막은 뒤, Worker의 "완료" 보고는 Advisor가 **직접 다시 실행해 본 뒤에만** 승인합니다.

이 페이지는 실습 [[guide-advisor-worker-demo]](기본편)와 [[guide-advisor-worker-advanced]](심화편)를 입문 수강생에게 강의할 때 쓰는 노트입니다. 실습 페이지가 "무엇을 붙여넣는가"라면, 이 노트는 "무엇을 설명하고 무엇을 보여 주는가"를 강의 순서대로 정리합니다. 모든 수치는 2026-10-05 Claude Code 2.1.289 실측값입니다(증적 `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md`). 같은 형식의 강의 노트로 [[lecture-loop-engineering]], [[lecture-graph-engineering]]이 있습니다.

---

## 1. 왜 필요한가 — 실제 상황

개발자가 Claude에게 "장바구니 총액 계산 함수 만들어 줘, 다 되면 커밋도 해 줘"라고 맡깁니다. Claude는 코드를 쓰고, 테스트를 돌리고, "완료했습니다"라고 말한 뒤 커밋합니다. 이때 코드를 쓴 쪽과 "완료"를 판정한 쪽과 커밋한 쪽이 모두 같은 Claude입니다. 자기가 쓴 답안을 자기가 채점하고 자기가 성적표에 도장을 찍는 셈입니다.

"너는 검증만 해"라고 부탁으로 역할을 나눠도 오래가지 않습니다. 긴 세션에서 모델은 결국 직접 고치기 시작하고, 검증자가 구현자를 겸하는 순간 독립된 확인이 사라집니다. Advisor–Worker는 이 문제를 **사람이 아니라 구조로** 막는 방법입니다.

| 문제 | 부탁으로 막을 때 | 구조로 막을 때 (이 패턴) |
|---|---|---|
| 검증자가 직접 구현해 버림 | "구현하지 마" 지시문 | Advisor의 도구 목록에서 `Write`를 뺌 |
| 구현자가 일을 또 떠넘김 | "다시 맡기지 마" 지시문 | Worker의 도구 목록에서 위임 도구를 뺌 |
| "완료" 보고를 그대로 믿음 | "꼼꼼히 확인해" 지시문 | Advisor가 diff·테스트를 직접 재실행한 뒤에만 커밋 |

---

## 2. 등장인물 — 감리와 시공팀

이 실습에는 가짜가 없습니다. Advisor와 Worker는 둘 다 진짜 Claude입니다. 다만 한 Claude가 두 역할을 오가는 것이 아니라, **역할마다 다른 지시문과 다른 도구를 가진 Claude 두 개**가 따로 일합니다.

건축 현장에 비유하면 이렇습니다. 감리는 직접 벽돌을 쌓지 않습니다. 작업 지시서를 써서 시공팀에 넘기고, 시공팀이 "다 됐다"고 하면 직접 줄자를 대어 확인한 뒤에야 준공 도장을 찍습니다. 감리의 공구함에 흙손이 아예 없다면, 바쁜 날에도 감리가 직접 벽을 쌓아 버리는 일이 줄어듭니다.

| 실습 속 이름 | 실제로 무엇인가 | 비유 |
|---|---|---|
| `.claude/agents/advisor.md` | 메인 세션 역할 정의. `claude --agent advisor`로 실행 | 감리 |
| `.claude/agents/worker.md` | 서브에이전트 정의. Advisor가 위임 도구로 부르는 별도의 Claude | 시공팀 |
| frontmatter `tools` | 그 Claude가 쓸 수 있는 도구 목록. 없는 도구는 호출 불가 | 공구함 |
| 브리프 | Advisor가 Worker에게 넘기는 6항목 지시문 | 작업 지시서 |
| `cart.test.js` | 완료 기준 테스트 | 줄자 |
| `git commit` | 검증을 통과한 변경의 확정 | 준공 도장 |

**서브에이전트란**: 메인 Claude가 도구 호출 한 번으로 띄우는 또 하나의 Claude입니다. 메인 세션의 대화를 보지 못하고 브리프만 받아 자기 맥락에서 일한 뒤 결과 보고만 돌려줍니다. 그래서 브리프에 필요한 맥락을 다 담아야 하고, 브리프 골격이 [목표]·[컨텍스트]·[컨벤션]·[함정]·[완료 기준]·[범위 경계] 6항목이나 됩니다.

### 위임 한 바퀴

<div style="display:flex;flex-direction:column;gap:14px;align-items:center;font-family:sans-serif;margin:24px 0;">
  <div style="display:flex;align-items:stretch;gap:10px;width:100%;">
    <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#1e3a8a;font-weight:500;">① Advisor<br><span style="font-size:13px;">파일·테스트 읽고 브리프 작성</span></div>
    <div style="display:flex;align-items:center;font-size:24px;color:#2563eb;font-weight:bold;">→</div>
    <div style="background:#fed7aa;border:2px solid #ea580c;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#7c2d12;font-weight:500;">② Worker<br><span style="font-size:13px;">구현 → 테스트 실행 → 보고</span></div>
    <div style="display:flex;align-items:center;font-size:24px;color:#2563eb;font-weight:bold;">→</div>
    <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#1e3a8a;font-weight:500;">③ Advisor<br><span style="font-size:13px;">diff 읽기 + 테스트 재실행</span></div>
  </div>
  <div style="font-size:28px;color:#999;line-height:1;">↓</div>
  <div style="display:flex;align-items:stretch;gap:10px;width:100%;">
    <div style="background:#bbf7d0;border:3px solid #16a34a;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#14532d;font-weight:500;">통과 → Advisor가 커밋</div>
    <div style="background:#fed7aa;border:2px solid #ea580c;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#7c2d12;font-weight:500;">실패 → 수정 브리프로 ②에 재위임</div>
  </div>
</div>

**글 풀이**: ① Advisor는 먼저 파일과 테스트를 읽고, 알아낸 맥락을 브리프에 담아 Worker를 부릅니다. ② Worker는 브리프 범위 안에서만 구현하고, 완료 기준 테스트를 스스로 돌린 뒤 결과를 보고합니다. ③ Advisor는 그 보고를 믿고 끝내지 않고 변경을 직접 읽고 테스트를 직접 다시 돌립니다. 통과하면 Advisor가 커밋하고, 실패하면 무엇이 왜 틀렸는지 담은 수정 브리프로 다시 맡깁니다.

---

## 3. 기본편 — 도구 제한과 검증 게이트

기본편은 빈 프로젝트에 "`cart.test.js`가 통과하도록 `cart.js`를 만들고 커밋"을 맡깁니다. 두 에이전트의 도구 목록이 핵심입니다:

| 도구 | Advisor | Worker | 이유 |
|---|---|---|---|
| `Read`·`Grep`·`Glob` | ✅ | ✅ | 둘 다 코드를 읽어야 함 |
| `Write` (새 파일 쓰기) | ❌ | ✅ | 구현 노동은 Worker만 |
| `Edit` (부분 수정) | ✅ | ✅ | Advisor는 오타 같은 사소한 마무리용 |
| `Bash` | ✅ | ✅ | Advisor는 검증(테스트·git)용 |
| `Task` (위임, 현재 이름 `Agent`) | ✅ | ❌ | 위임 사슬을 한 단으로 고정 |

실측(1회, 280초, $0.26)에서 확인한 4장면입니다:

| 관찰 포인트 | 실측 결과 |
|---|---|
| 브리프 작성 | 6항목을 모두 채움. [함정]에 "부동소수점 오차 → Math.round", "경계값 10000은 할인 대상"까지 담김 |
| 역할 준수 | `cart.js`를 쓴 Write는 Worker 1회, Advisor 0회 |
| 검증 게이트 | Worker의 "PASS" 보고 뒤 Advisor가 `git status`·`cat cart.js`·`node cart.test.js`를 직접 실행 |
| 커밋 주체 | 재검증 다음 동작이 Advisor의 `git commit` |

**강의 포인트**: Worker도 테스트를 돌리고 "PASS"라고 보고했습니다. 그런데도 Advisor가 다시 돌린 이유는, 검증의 가치가 "실행했느냐"가 아니라 **"누가 실행했느냐"**에서 나오기 때문입니다. 구현한 쪽의 확인은 자기 채점이고, 독립된 쪽의 재실행만 승인 근거가 됩니다.

---

## 4. 심화편 — 네 장면 실측

심화편은 위임의 규율이 실제로 작동하는지, 그리고 위임이 언제 손해인지를 봅니다.

| 장면 | 무엇을 시키나 | 실측 결과 | 시간·비용 |
|---|---|---|---|
| 1. 재위임 | 요구 변경(5만원 이상 20% 할인)으로 테스트가 실패하는 상태에서 수정 요청 | 한 줄 수정인데도 Advisor가 직접 고치지 않고 수정 브리프로 위임. 브리프에 기대값 40000·현재 45000·"50000 체크는 10000 체크 앞에" 함정까지 담음 | 265초 · $0.19 |
| 2. 병렬 위임 | 서로 독립인 `coupon.js`·`shipping.js` 동시 요청 | Advisor의 한 메시지에 위임 2개가 함께 나감. 브리프·재검증·커밋 모두 모듈별로 분리 | 28초 · $0.33 |
| 3. 모델 티어링 | Worker에 하위 모델(haiku)을 frontmatter로 고정 | Worker 메시지 6건 모두 haiku. 환경 변수를 설정한 재실행에서도 7건 모두 haiku 유지 | 277초 · $0.16 / 399초 · $0.20 |
| 4. 오버헤드 예외 | 주석 오타 한 글자 수정 | 위임 0회, Advisor가 직접 Edit | 129초 · $0.08 |

**장면 1과 4를 묶어서 설명합니다.** 둘 다 작은 수정이었지만 장면 1은 위임했고 장면 4는 직접 했습니다. 기준이 크기가 아니라 **동작 변경 여부**였기 때문입니다. 테스트 결과가 바뀌는 수정은 한 줄이라도 위임하고, 동작이 안 바뀌는 오타·주석만 직접 처리합니다. 이 기준을 "한두 줄 수정은 직접"처럼 크기로 적었던 2026-07 실측에서는 Advisor가 장면 1을 2번 모두 직접 고쳤습니다.

**장면 1에서 재현되지 않은 것도 말해 줍니다.** 실습 페이지는 "위임 전에 테스트를 돌려 실패를 확인하는가"를 관찰 포인트로 두었지만, 실측에서 Advisor는 테스트를 돌리지 않고 코드를 읽어 실패를 추론했습니다. 대신 그 추론 결과가 브리프에 정확히 담겼습니다.

**장면 2의 강의 포인트**: 병렬 위임의 가치는 속도보다 **독립성 판단**에 있습니다. 쿠폰이 할인 후 금액에 적용되는 식으로 의존이 있다면 순차가 맞습니다.

---

## 5. 자주 틀리는 사실 세 가지

수강생 자료나 인터넷 글에 아직 옛 정보가 많습니다. 강의에서 직접 짚어 줍니다.

| 흔한 설명 | 실제 (확인 방법) |
|---|---|
| "`CLAUDE_CODE_SUBAGENT_MODEL` 환경 변수가 frontmatter `model`을 덮어쓴다" | 2.1.250 이하에서만 맞습니다. 2.1.251부터는 호출 시 지정 → frontmatter `model` → 환경 변수 → 메인 모델 순이라 frontmatter가 이깁니다. 2.1.289 실측에서 Worker 7/7 haiku 유지, [공식 문서](https://code.claude.com/docs/en/sub-agents)에 "Before v2.1.251 … came first" 명시 |
| "서브에이전트 도구 이름은 `Task`" | 2.1.63에서 `Agent`로 이름이 바뀌었습니다. `Task`도 별칭으로 동작해 정의 파일은 그대로 써도 되고, 실행 로그에는 `Agent`로 찍힙니다 |
| "Advisor에 `Write`가 없으니 구현이 물리적으로 막힌다" | Advisor에게 `Bash`가 있어 `cat > 파일`로 우회할 수 있습니다. 도구 제한은 기본 경로를 막는 장치이고, 나머지는 지시문 규율이 맡습니다. 실측 우회는 0건이었습니다 |

버전에 따라 동작이 정반대로 바뀐 첫 번째 사례는 "기본값과 가정의 함정"의 에이전트판입니다. 도구를 업데이트한 뒤에는 로그의 `model` 필드로 실제 모델을 한 번 확인하라고 안내합니다.

---

## 6. 루프·그래프와 비교

세 실습은 모두 "에이전트의 자기 보고를 믿지 않는다"는 같은 원리를 다른 층에서 구현합니다.

| | Loop 엔지니어링 | Advisor–Worker | 그래프 엔지니어링 |
|---|---|---|---|
| 답하는 질문 | 언제 끝내나 | 누가 판단하고 누가 구현하나 | 흐름을 어떻게 강제하나 |
| "완료"를 판정하는 쪽 | 테스트 종료 코드 | 독립된 Advisor의 재실행 | 코드로 쓴 조건부 엣지 |
| 규칙이 사는 층 | 셸 루프·프롬프트 | 도구 목록 + 지시문 | 코드 |
| 규칙 위반이 잡히는 시점 | 테스트 실패 시 | 사후 검증 시 (장면 1의 크기 기준 문구는 사후 교정) | 위반 경로 자체가 없음 |
| 실습 | [[guide-loop-engineering-demo]] | 이 강의 | [[guide-graph-engineering-demo]] |

Advisor–Worker와 그래프의 선택 기준은 [[comparison-advisor-worker-vs-graph]]에 있습니다. 일상적인 위임은 Advisor–Worker로 충분하고, 프롬프트 규율 위반이 반복해서 아플 때 그 규칙만 코드 게이트로 올립니다.

---

## 7. 강의 진행 팁

### 시간 배분 (90분 기준)

| 구간 | 시간 | 내용 |
|---|---|---|
| 도입 | 10분 | 1절 실제 상황 + "자기 채점" 문제 제기 |
| 등장인물 | 10분 | 2절 비유·역할표·위임 한 바퀴 그림 |
| 기본편 실습 | 25분 | 셋업 6분 + Claude 실행 약 5분 + 4장면 관찰 |
| 심화편 시연 | 30분 | 장면 1·4를 묶어 시연, 2·3은 실측 표로 설명 |
| 정리 | 15분 | 5절 틀리는 사실 + 6절 비교 + 질문 |

장면 3은 세션을 두 번 띄워 10분 넘게 걸리므로 라이브보다 실측 표로 설명하는 편이 낫습니다. 한 번 실행에 4~7분이 걸리니, 수강생이 기다리는 동안 무엇을 볼지(관찰 포인트 표)를 미리 띄워 둡니다.

### 수강생이 자주 막히는 곳

| 막히는 곳 | 원인 | 안내 |
|---|---|---|
| 새 터미널에서 블록 실행 시 `No such file or directory` | 블록을 다른 디렉터리에서 실행 | 모든 블록 첫 줄의 `cd ~/advisor-demo` 확인 |
| zsh에서 `command not found: #` | macOS 기본 zsh가 붙여넣은 주석을 인식하지 못함 | 실습 전 `setopt interactivecomments` |
| 권한 거부가 반복됨 | Claude Code 대화 화면 안에서 `claude`를 실행 | 일반 터미널 창에서 실행 |
| 몇 분 동안 화면 변화가 없음 | 위임·재검증으로 모델 호출이 여러 번 일어남 | 실측 4~7분, 기다림 |

### 질문 예시

| 질문 | 기대하는 답 |
|---|---|
| Worker도 테스트를 돌렸는데 Advisor가 또 돌리는 건 낭비 아닌가요? | 검증의 가치는 실행 여부가 아니라 실행 주체의 독립성에서 나옴 |
| 한 줄 수정인데 왜 위임하나요? | 기준이 크기가 아니라 동작 변경 여부이기 때문 (장면 1 vs 4) |
| 도구 목록에서 빼면 완전히 막히나요? | `Bash` 우회가 남음. 기본 경로를 막는 장치이고, 규율과 함께 씀 |
| 비용을 줄이려면 어디를 바꾸나요? | 호출이 많은 Worker에 단가 낮은 모델을 frontmatter로 고정 (장면 3) |

---

## 원본 출처

- `raw/ai-engineering/ai-advisor/advisor_script.md` — Advisor 지시문 전문
- `raw/ai-engineering/ai-advisor/worker_script.md` — Worker 지시문 전문
- `raw/ai-engineering/ai-advisor/claude_script.md` — 팀 공통 CLAUDE.md 템플릿 (모델 우선순위 교정 주석 포함)
- `raw/ai-engineering/ai-advisor/verification/2026-10-05-demo-run.md` — 이 노트 수치의 근거 (실행 6회 도구 호출 순서·브리프·비용)
- [Claude Code 서브에이전트 공식 문서](https://code.claude.com/docs/en/sub-agents) — 모델 우선순위(2.1.251 변경), `Task`→`Agent` 이름 변경

## 관련 페이지

- [[guide-advisor-worker-demo]] — 기본편 실습
- [[guide-advisor-worker-advanced]] — 심화편 실습 (4장면)
- [[concept-advisor-worker]] — 패턴 개념 (구성 요소·모델 티어링·적용 기준)
- [[comparison-advisor-worker-vs-graph]] — 그래프 엔지니어링과의 선택 기준
- [[lecture-loop-engineering]] — Loop 엔지니어링 강의 노트
- [[lecture-graph-engineering]] — 그래프 엔지니어링 강의 노트
