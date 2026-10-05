---
title: 강의 노트 — 루프 엔지니어링 입문
type: synthesis
tags: [loop-engineering, lecture, ai-agent, claude-code, react-pattern]
sources:
  - ai-engineering/loop-engineering/loop-engineering-notes.md
  - ai-engineering/loop-engineering/primary-sources.md
  - ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md
created: 2026-10-05
updated: 2026-10-05
---

# 강의 노트 — 루프 엔지니어링 입문

이 페이지는 [[guide-loop-engineering-demo]] 실습을 입문 수강생에게 강의할 때 쓰는 노트입니다. 실습 가이드가 "무엇을 붙여넣는가"를 다룬다면, 이 노트는 "무엇을 깨달아야 하는가"를 강의 순서대로 정리합니다. 본문의 수치는 모두 `raw/ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md`에 남긴 실측값입니다.

## 한 줄 요약

**AI 에이전트의 "다 했어요"를 믿지 말고, 테스트처럼 "아니오"라고 말할 수 있는 검사가 끝을 정하게 하라.** 루프 엔지니어링은 이 검사를 중심으로 "맡기고, 확인하고, 다시 맡기는" 반복 자체를 설계하는 일입니다.

## 1. 왜 필요한가 — 실제 상황

개발자가 Claude Code에 "회문 검사 함수 좀 고쳐 줘"라고 맡기면, Claude는 파일을 고치고 "구현 완료했습니다"라고 답합니다. 이때 개발자가 고를 수 있는 길은 두 가지입니다.

| 선택 | 무슨 일이 생기나 |
|---|---|
| 그 말을 믿고 끝낸다 | 코드가 틀렸어도 "완료"로 넘어갑니다 |
| 테스트를 돌려 확인한다 | 틀렸으면 실패 내용을 보여 주고 다시 고치게 합니다 |

두 번째 길을 사람이 매번 손으로 하면 지칩니다. 루프 엔지니어링은 이 "확인하고 다시 맡기는" 일을 프로그램(루프)에 맡기는 것입니다. 개념 정의는 [[concept-loop-engineering]]에 있습니다.

## 2. 등장인물 — 왜 JS 파일이 에이전트 역할을 하나

실습에서는 진짜 Claude 대신 `agent.js`라는 작은 파일을 에이전트로 씁니다. 수강생이 가장 많이 헷갈리는 곳이므로 실습 전에 반드시 짚습니다.

비행 조종을 처음 배우는 사람은 진짜 비행기 대신 시뮬레이터로 연습합니다. 진짜 비행기는 비싸고, 고장 상황을 마음대로 만들 수도 없기 때문입니다. 시뮬레이터는 교관이 원할 때 일부러 엔진 고장을 내 주고, 연습생은 그 상황에서 어떻게 대처하는지를 공짜로 몇 번이고 되풀이합니다. 이 실습의 `agent.js`가 그 시뮬레이터입니다. 진짜 Claude처럼 파일을 고치고 "완료했습니다"라고 말하지만, 일부러 3번 중 2번은 틀린 코드를 내놓습니다.

진짜 Claude로 연습하면 곤란한 이유는 세 가지입니다. 부를 때마다 돈이 들고, Claude는 이 정도 문제를 거의 한 번에 맞히며(6-5 실험에서 9번 중 9번 정답), 매번 답이 달라 비교가 어렵습니다.

| 실제 루프의 역할 | 실제 개발에서는 | 실습에서는 |
|---|---|---|
| 코드를 고치는 AI 에이전트 | Claude Code | `agent.js` (Step 6부터 진짜 Claude) |
| 에이전트가 고치는 코드 | 프로젝트 소스 파일 | `solution.js` |
| "다 했어요" 보고 | Claude의 답 메시지 | `🤖 에이전트: … 완료했습니다` 줄 |
| 결과를 확인하는 검사(거부 신호) | 테스트·빌드·타입체크 | `test.js` |
| 에이전트에게 돌려주는 실패 내용 | 에러 메시지 붙여 주기 | `test.log` |
| 루프를 돌리는 쪽 | 사람 또는 자동화 스크립트 | 터미널의 `for`·`if` 블록 |

## 3. 메아리방 vs 거부 신호

**메아리방(echo chamber)**은 에이전트의 자기 보고로 끝을 정하는 루프이고, **거부 신호(reject signal)**는 테스트처럼 실패를 객관적으로 돌려주는 검사입니다. 실습 Step 2와 Step 4-1이 이 둘을 같은 에이전트로 비교합니다.

| | Step 2 (메아리방) | Step 4-1 (테스트로 종료) |
|---|---|---|
| 끝낼지 정하는 줄 | `if node agent.js \| grep "완료"` | `if node test.js` |
| 판정 근거 | 에이전트의 말 (늘 "완료") | 테스트 종료 코드 0 |
| 실측 | 무작위 1회 실행 150번 중 통과 55번 — 나머지 95번은 틀린 코드가 "완료" | 40번 모두 8사이클 안에 통과 |
| 남는 문제 | 틀린 코드가 그대로 통과 | 재시도는 운에 맡겨짐 (8번 연속 실패 확률 약 4%) |

강의 포인트는 Step 3의 한 줄입니다. 루프는 결국 **숫자(종료 코드)만 읽습니다.** 에이전트의 말은 늘 0이라 아무것도 걸러 내지 못하고, 테스트만 틀린 코드를 1로 걸러 냅니다.

## 4. 피드백 루프 — 행동·관찰·추론

Step 4-1은 실패를 막기만 했습니다. Step 4-2는 실패 기록(`test.log`)을 다음 시도에 돌려주어, 에이전트가 원인을 하나씩 고치게 합니다.

<div style="display:flex;align-items:center;justify-content:center;gap:10px;flex-wrap:wrap;font-family:sans-serif;margin:20px 0;">
  <div style="padding:10px 16px;border-radius:8px;background:#dbeafe;color:#1e3a5f;font-weight:bold;">행동(Act)<br><span style="font-weight:normal;font-size:13px;">에이전트가 코드를 고친다</span></div>
  <div style="font-size:22px;color:#2563eb;">→</div>
  <div style="padding:10px 16px;border-radius:8px;background:#dbeafe;color:#1e3a5f;font-weight:bold;">관찰(Observe)<br><span style="font-weight:normal;font-size:13px;">테스트가 결과를 남긴다</span></div>
  <div style="font-size:22px;color:#2563eb;">→</div>
  <div style="padding:10px 16px;border-radius:8px;background:#dbeafe;color:#1e3a5f;font-weight:bold;">추론(Reason)<br><span style="font-weight:normal;font-size:13px;">실패 기록을 읽고 원인을 찾는다</span></div>
  <div style="font-size:22px;color:#2563eb;">↺</div>
</div>

그림의 세 상자가 사이클 하나입니다. 에이전트가 코드를 고치고(행동), 테스트가 결과를 `test.log`에 남기고(관찰), 다음 사이클의 에이전트가 그 기록을 읽어 원인을 찾은 뒤(추론) 다시 고칩니다. 이 구조는 ReAct 패턴([arXiv 2210.03629](https://arxiv.org/abs/2210.03629))에서 왔습니다.

| | Step 4-1 | Step 4-2 |
|---|---|---|
| 다음 시도에 넘기는 것 | 없음 | 실패 기록 `test.log` |
| 실패 수 변화 | 운에 따라 들쭉날쭉 | 3 → 2 → 0으로 줄어듦 |
| 실측 | 8사이클을 다 쓸 수도 있음 | 60번 모두 3사이클 이내 (1사이클 17·2사이클 23·3사이클 20) |

## 5. 진짜 Claude로 — 권한과 `Write` 함정

Step 6은 루프 모양을 그대로 두고 `node agent.js test.log` 자리를 `cat test.log | claude -p "…"`로 바꿉니다. 시뮬레이터에서 내려 진짜 비행기에 타는 단계입니다.

| 실측 항목 | 결과 |
|---|---|
| 정상 실행 | 사이클 2에서 통과, 약 20초 |
| 호출 1번 비용 | $0.0498 (다른 실행에서는 $0.1541) |
| `--allowedTools "Read,Edit"`만 준 경우 | Claude가 파일 전체를 Write로 다시 쓰려다 막혀 사이클마다 "권한이 거부돼 고치지 못했습니다" 반복 |
| Claude Code 대화 화면 안에서 중첩 실행 | 바깥 세션 권한을 물려받아 수정이 막힘 → 일반 터미널에서 실행 |

**함정 강조**: 허용 도구는 `"Read,Edit,Write"`처럼 Write까지 넣어야 합니다. 이 함정은 "도구가 고장 났는데 루프는 그 사실을 모른 채 계속 돈다"는 예시로도 씁니다.

## 6. 프롬프트로 루프 맡기기 — 6-5 실험

실무에서는 셸 루프보다 대화 화면에 프롬프트를 입력하는 경우가 더 많습니다. 이때 루프를 만드는 것은 **권한과 완료 조건**입니다. 같은 시작 상태에서 세 조건을 3번씩 실행했습니다.

| 조건 | Claude의 마지막 보고 | 시간 · 비용 |
|---|---|---|
| "고쳐줘"만 + 테스트 실행 권한 없음 | "고쳤지만 테스트로 확인하지 못했다" | 127~137초 · $0.06~0.18 |
| "고쳐줘"만 + 권한 있음 | 스스로 테스트를 돌렸지만 "통과했다"는 문장만 (출력 원문 0/3) | 12~16초 · $0.06~0.10 |
| 루프 프롬프트 + 권한 있음 | `test.js`를 바로 읽고 확인, 출력 원문 첨부 3/3 | 10~14초 · $0.04~0.15 |

정리하면 확인할 수 있느냐는 권한이 가르고, 루프 프롬프트는 보고를 "말"에서 "증거"로 바꿉니다. 9번 모두 첫 수정에 정답이었으므로 반복 상한의 효과는 이 실험으로 확인하지 못했습니다.

## 7. 비용과 종료 조건 세 가지

| 상황 | 호출 수 | 합계 |
|---|---|---|
| Step 6 정상 (실측) | 1번 | $0.05~0.15 |
| `Write` 누락으로 매번 막힘 (실측, 상한 5) | 4번 | 약 $0.20~0.70, 고친 것 없음 |
| 같은 고장, 상한 없이 1분 1회로 8시간 (계산) | 480번 | 약 $24, 고친 것 없음 |

무인 루프에는 종료 조건 세 가지가 모두 있어야 합니다.

| 종료 조건 | 뜻 | 실습에서 |
|---|---|---|
| ① 검증 통과 (goal) | 테스트가 통과하면 끝 | `if node test.js` |
| ② 반복 상한 (resource) | 많아야 N번까지 | `MAX=5` |
| ③ 금액 예산 (budget) | 쓴 돈이 한도를 넘으면 멈춤 | `BUDGET`과 `total_cost_usd` 누적 |

**주의**: `claude -p --max-budget-usd 0.01`은 정확한 상한이 아닙니다. 실측에서 $0.11을 쓰고 나서야 멈췄습니다. 한 번의 호출이 폭주하지 않게 막는 안전장치로만 쓰고, 루프 전체 예산은 쓴 금액을 직접 더해 관리합니다.

## 8. 실전 프롬프트 요약

가이드의 "실전 루프 프롬프트 모음"이 기본 틀과 상황별 예제 5종을 담고 있습니다. 강의에서는 기본 틀의 다섯 빈칸만 짚습니다.

| 빈칸 | 루프에서 맡는 역할 | 예 |
|---|---|---|
| 할 일 | 행동 | "OrderServiceTest가 실패해. 고쳐줘" |
| 확인 명령 + 성공 신호 | 관찰 + 종료 조건 | `./gradlew test` → "BUILD SUCCESSFUL" |
| N번 실패하면 멈춤 | 반복 상한 | "5번 고쳐도 안 되면 멈추고 보고해" |
| 건드리면 안 되는 것 | 거부 신호 보호 | "테스트 코드 수정·@Disabled 금지" |
| 출력 원문 요구 | 증거 | "통과 출력을 그대로 보여 줘" |

TDD 예제는 실제로 돌려 봤습니다. Claude가 테스트를 먼저 쓰고 `fail 1`을 보인 뒤 구현해 `fail 0`으로 끝냈고, 27초·$0.23이었습니다.

## 9. 강의 진행 팁

**시간 배분 (50분 기준)**

| 구간 | 시간 | 내용 |
|---|---|---|
| 도입 | 5분 | 한 줄 요약, 실제 상황 |
| 등장인물 | 5분 | 시뮬레이터 비유, 역할 대응표 |
| Step 1~3 실습 | 12분 | 메아리방 체험, 종료 코드 비교 |
| Step 4 실습 | 12분 | 4-1과 4-2 비교, 행동·관찰·추론 |
| Step 6·6-5 시연 | 10분 | 강사 화면으로 진짜 Claude 실행 (토큰 비용 때문에 시연 권장) |
| 비용·프롬프트 정리 | 6분 | 종료 조건 3종, 실전 프롬프트 기본 틀 |

**수강생이 자주 막히는 곳**

| 증상 | 원인 | 안내 |
|---|---|---|
| `command not found: #` | macOS zsh가 붙여넣은 주석을 인식하지 못함 | 실습 전 `setopt interactivecomments` |
| `Cannot find module './solution'` | Step 1 직후 `node test.js` 실행 | `solution.js`는 Step 2에서 생김 |
| 출력에 🤖 보고 줄이 없음 | 예전 버전 `agent.js` | Step 1의 `cat > agent.js` 블록 다시 실행 |
| 4-2가 사이클 1에서 바로 끝남 | 첫 시도에 정답 (C)가 나옴 | 몇 번 다시 실행 |
| Claude가 "권한 거부"만 반복 | `Write` 누락 또는 중첩 실행 | 허용 도구 확인, 일반 터미널에서 실행 |

**질문 예시**

- 에이전트가 "완료"라고 할 때, 우리는 무엇을 근거로 그 말을 믿고 있나요?
- Step 2의 루프에 테스트 한 줄을 넣으면 왜 결과가 달라지나요?
- 4-1과 4-2는 둘 다 테스트로 끝을 정하는데, 무엇이 다른가요?
- 테스트를 고쳐서 통과시키는 에이전트를 막으려면 프롬프트에 무엇을 써야 할까요?
- 밤새 무인으로 돌리는 루프에 꼭 필요한 종료 조건은 무엇인가요?

## 원본 출처

- 실습: [[guide-loop-engineering-demo]]
- 실측 증적: `raw/ai-engineering/loop-engineering/verification/2026-10-04-demo-run.md`
- 개념 메모: `raw/ai-engineering/loop-engineering/loop-engineering-notes.md`, `raw/ai-engineering/loop-engineering/primary-sources.md`
- ReAct — Yao et al. 2022, [arXiv 2210.03629](https://arxiv.org/abs/2210.03629)
- Addy Osmani, [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) · [Sonar 블로그](https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/)
- [Claude Code 헤드리스 공식 문서](https://code.claude.com/docs/en/headless)

## 관련 페이지

- [[guide-loop-engineering-demo]] — 이 노트의 실습 (붙여넣을 명령·실측 출력 전체)
- [[concept-loop-engineering]] — 루프 엔지니어링 개념
- [[lecture-graph-engineering]] — 같은 시리즈 강의 노트: 그래프 엔지니어링
- [[lecture-advisor-worker]] — 같은 시리즈 강의 노트: Advisor–Worker
