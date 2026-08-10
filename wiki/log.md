---
title: Wons Wiki 로그
---

# Wiki Log

## [2026-08-10] refactor | AI 트렌드 파편 주제 7개를 raw/ai-engineering/ 우산으로 통합
- **배경**: 사용자 판단 "트렌드 주제는 각각 글 10개를 못 넘김 — 합치자". 최상위 raw/에 1~8개짜리 AI 관련 디렉터리가 7개로 흩어져 있던 것을 하나로 묶음.
- **이동** (`git mv`, 파일 내용·파일명 무변경 — raw 불변 원칙 유지, 위치만 이동): `harness-engineering`(7) `2bun-coding`(8) `ai-advisor`(4) `loop-engineering`(2) `grap-engineering`(1, untracked→add) `llm-wiki-pattern`(1) `claude-design`(1) → `raw/ai-engineering/<옛주제명>/`. 출처 그룹은 서브디렉터리로 보존.
- **`raw/ai-engineering/README.md` 신설**: 우산 취지 + 서브디렉터리 7개별 주제·자료 수 표. 각 서브디렉터리의 기존 README는 그대로 유지.
- **경로 참조 일괄 치환**: wiki/ 26개 파일의 `raw/<옛주제>` 85건을 `raw/ai-engineering/<옛주제>`로 치환 (frontmatter `sources` 포함). 경로가 아닌 본문 산문의 주제명은 무변경.
- **무영향 확인**: `mkdocs.yml`·`wiki/index.md`에는 raw/ 경로 노출 없음 (raw/는 비공개, 빌드 대상 아님).

## [2026-08-02] ingest | raw/object-dependency/ 적재 — 블로그 글에서 영속 개념 3개 추출 (2단계 연동 실전 1회)
- **배경**: blogger-daemon ↔ my-wiki 2단계 연동. 검수 PASS 블로그 글의 영속 개념을 raw/ 소스 노트로 공급하는 수동 절차 검증. blogger-daemon은 raw 공급자 역할만 — raw→wiki 승격은 이 위키 세션 몫.
- **출처 글**: [객체 참조의 덫을 깨다: ID 참조와 이벤트로 진화하는 의존성 설계](https://blog.wonslab.dev/2026-07-19-object-dependency-id-reference/) (원 트리거 영상: 조영호 우아한객체지향 세미나 dJ5C4qRqAgA).
- **생성**: `raw/object-dependency/` — README.md + 소스 노트 3개
  - `id-reference-vs-object-reference.md` — 경계 넘는 협력은 ID 참조로
  - `aggregate-boundary-lifecycle.md` — 애그리거트 경계를 라이프사이클로 긋기
  - `domain-event-eventual-consistency.md` — 도메인 이벤트로 최종 일관성
- **비고**: 기존 `raw/object/`(오브젝트 강의 교재)와 소스가 달라 디렉터리 분리. wiki/ 승격(concept-* 생성·교차참조)은 후속 위키 세션 대기. 트렌드성 본문 서사(측정 수치 등)는 제외하고 재참조 가능한 영속 개념만 선별.

## [2026-07-12] verify | Advisor–Worker 심화편 장면 1~4 실행 검증 — 규율 교정 + 배너 (Pending 종결)
- **방법**: Step 0 검증 상태의 스크래치패드 데모에서 장면별 헤드리스 `claude --agent advisor -p` + stream-json 도구 호출 감사 (메인/서브에이전트는 `parent_tool_use_id`로 분리).
- **장면 1 (재위임)**: 초판 규율("한두 줄 수정은 직접 처리")에서는 **2회 모두 Advisor가 직접 Edit** — 할인 티어 수정이 실제로 1~2줄이라 크기 기준 예외가 정당하게 덮음. 규율을 **동작 변경 기준**("테스트 기대값이 바뀌는 로직 수정은 한두 줄이라도 위임")으로 구체화한 3차에서 재현: 위임 전 실패 확인 → 실패 케이스(40000/45000) 담긴 브리프([목표]~[범위 경계] 5항목) → Worker만 Edit → Advisor가 diff+재테스트 → 커밋.
- **장면 2 (병렬)**: 한 턴(같은 메시지 id)에 Task 2개 동시 발사, 브리프 모듈별 분리(상대 모듈은 [범위 경계] 제외로만), coupon·shipping 각각 재검증 후 커밋.
- **장면 3 (모델 티어링)**: frontmatter 고정 → Advisor 17건·Worker(haiku) 14건 분리 집계. `CLAUDE_CODE_SUBAGENT_MODEL` 설정 → Worker 서브에이전트 메시지까지 전부 환경변수 값(haiku 0건). **원본 경고 실측 확인**.
- **장면 4 (오버헤드 예외)**: Task 0회, Advisor 직접 Edit ('모둘'→'모듈') — 동작 변경 기준 규율에서도 예외 쪽 정상 작동.
- **문서 교정**: ① Step 0 규율 문구 교체 + 크기 기준 함정 상자 신설 ② 장면 1 판정 결함 수정 — 추가 블록이 console.log를 안 바꿔 "PASS — 4개 케이스" 문구가 출력 불가였던 것 → 4번째 케이스 로그 줄 추가·판정 문구 갱신 ③ raw 원본 교정 주석 3건(advisor_script 크기 기준, claude_script 크기 기준 + 환경변수 경고 실측 확인) ④ CLI 2.1.197 stream-json의 Task→`Agent` 표기 주기.
- 배너 부착, backlog Pending 종결.

## [2026-07-12] verify | 태스크 D·E 전환 실습 실제 실행 검증 (헤드리스) — M2·M5 배너 부착
- **방법**: 사용자 playground(Module 00 상태)를 스크래치패드에 복사(원본 무변경) → M1-A 상태(phone 구현·`baseline(M1-A)` 커밋)와 M2 완성 CLAUDE.md(섹션 6·7 채움)를 토큰 0으로 구성 → 태스크 D·E를 `claude -p` + stream-json으로 실행·감사.
- **태스크 D (M2 Step 5)**: CLAUDE.md 선독 후 섹션 8·7 대조·계획 제시, Zod Address(roadAddress 필수·detailAddress 선택·zipCode `^\d{5}$`) 400 검증, api·web 동시 수정(섹션 6 모노레포 원칙 작동 확인), 테스트 5→11개 통과.
- **태스크 E (M5 Step 5)**: M3 자기검증 루프 블록을 섹션 5에 추가한 상태에서 실행 — phone·address 기구현 상태와 충돌 없음, YYYY-MM-DD+실존 날짜 refine(윤일 201·2001-02-30 400), **자기검증 루프 4단계 작동**(`node --check`→`npm test` 자가 실행→"---검증 완료 보고---" 종료), 테스트 17개 통과. 커밋 체인 baseline(M1-A)→docs(M2)→harness(M2-D)→harness(M3)→harness(M5-E) 새 규약 그대로 재현.
- **advisor-worker 심화 Step 0 (수정판)**: 토큰 0 실행 — 커밋에 에이전트 파일 2개+규율 2줄 포함, 워킹트리 클린, 테스트 PASS. (장면 1~4 전체 검증은 backlog Pending 유지)
- **부수 발견**: 사용자 playground의 `web/src/App.jsx` 커밋본에 붙여넣기 아티팩트(`'...3000'\;`)가 있고 미커밋 수정으로 고쳐져 있음 — 위키 원문(module 00)은 정상, 환경 잡음으로 판정.
- M2·M5에 "✅ Step 5 실행 검증됨 (2026-07-12)" 배너 부착.

## [2026-07-12] lint | 실습 가이드 12편 절차 결함 전수 점검 (에이전트 3병렬) + 수정
- **점검 범위**: harness 00·demo·M1~M5, loop 실습, advisor-worker 기본·심화, java-book-study-lab — 오늘 발견한 결함 유형(상태 오염·되돌리기 함정·모듈 간 정합·복붙 안정성) 관점. 이스케이프 펜스(`\`\`\``)는 위키 전체 grep 잔존 0.
- **수정 3건**: ① [[guide-harness-module5]] 비교표에 "가정 명시" 행 누락(M1·M2는 7항목, M5만 6항목 — 측정 항목 고정 원칙 위반) 추가 ② M5의 "자기검증 루프" 참조에 M3 Step 7 출처·역할 반문장 보강(§7-8) ③ [[guide-advisor-worker-advanced]] Step 0 — advisor 규율 2줄을 커밋 후 append해 미커밋 잔여로 남던 것을 커밋 앞으로 재배열(장면 1 Advisor 커밋에 잡음 섞임 방지).
- **보완 1건**: [[guide-harness-module4]] Planner 시연의 인증 기능이 M1·M2 필드 추가 태스크와 독립(기존 User CRUD 무영향)임을 명시.
- **기각 2건**: M1 태스크 D·E 선행 정의 부족 지적은 인라인 정의(필드명·유형·이유) 존재로 기각. 심화편 Step 0 "커밋 시점 .claude 비어 있음" 지적은 기본편 Step 1~2 선행 전제로 절반 기각(잔여 결함만 수정). 나머지 8편 이상 없음.

## [2026-07-12] fix | harness M2·M5 — Before/After 검증을 revert 재실행에서 "같은 유형 새 태스크"로 전환
- **문제 (사용자 피드백)**: ① M2 Step 3 프롬프트 안의 중첩 코드펜스가 `\`\`\``로 이스케이프돼 있어 학습자가 복사하면 역슬래시가 그대로 붙음 ② M2 Step 5-1의 `git revert` 출발선 되돌리기가 태스크 커밋에 섞인 CLAUDE.md 변경(`git add -A`)까지 되돌려 방금 만든 CLAUDE.md가 초기화됨 ③ 섹션 6 가이드에 playground가 web/api 분리 모노레포라는 사실이 없음.
- **수정 (M2)**: Step 3 프롬프트를 4-backtick 외부 펜스로 바꿔 내부 ``` 원문 유지, 출력 형식 트리를 실제 playground 구조(api/+web/)로 교체, 원칙에 "모노레포 분리 명시·양쪽에 걸치는 변경은 함께 수정" 추가. Step 5는 revert 폐기 — 태스크 A(phone)와 요구 구조가 같은 **태스크 D(address 필드, 행정안전부 도로명주소: roadAddress·detailAddress·zipCode 5자리)**를 새로 실행해 비교. 커밋 규약 `harness(M2-A)` → `harness(M2-D)`.
- **연쇄 수정 (M5)**: M2-A revert 단계 제거, **태스크 E(birthDate 필드)**로 5모듈 누적 측정. 비교표 제목 "필드 추가 태스크 비교 — M1: phone / M2: address / M5: birthDate". [[guide-wiki-authoring-standards]] §7-8 예시 커밋명도 M2-D로 동기화.
- 비교 유효성 논리 교체: "원문 그대로 재실행" → "요구 구조(필드 추가·형식 검증·필수 처리·web 반영·테스트)와 측정 7항목 고정". 두 파일 style-lint 0건.
- **후속 소탕 (M1)**: 사용자 확인 요청으로 Module 01의 옛 논리 4곳 발견·교체 — Step 3 목적 문장, `[베이스라인 측정 중]` 해설의 "같은 태스크를 재실행", Step 4 리드인, baseline.md 템플릿 꼬리 주석("동일 태스크를 같은 표현으로 다시 요청해야 비교가 유효"). 모두 태스크 D·E 선행 소개와 "요구 구조·측정 항목 고정" 논리로 갱신. 나머지 하네스 페이지 전수 grep 결과 잔재 없음.
- **후속 소탕 (raw/)**: 원본 킷 2개 파일에 교정 주석 추가(원문 보존, "원본 불신 검증" 정책) — `raw/harness-engineering/harness-kit/module1/02_baseline_prompt.md` 끝의 "동일 태스크를 다시 실행" 안내, `module2/02_before_after_prompt.md`의 "태스크 A 재실행" 절차. 강의교안·요약본 3곳의 "동일 태스크 실행"은 측정 방법론의 개념 서술이라 원문 유지(절차 아님). module3·5 킷의 "재실행"·"revert"는 테스트 루프·주간 리뷰 grep 용법이라 무관.

## [2026-07-12] chore | nav 제목 괄호 부연 설명 제거
- 좌측 메뉴에서 두 줄로 꺾이는 괄호 부연 3건 제거 — "Loop 엔지니어링 실습 (메아리방 vs 거부 신호)" → "Loop 엔지니어링 실습", "Advisor–Worker 실습 (판단·구현 분리)" → "Advisor–Worker 실습", "Advisor–Worker 심화 (재위임·병렬·모델)" → "Advisor–Worker 심화" (모바일 화면 캡처 피드백).
- 날짜·정식 명칭 괄호(2026-06, OOP, GRASP, HikariCP 등)는 성격이 달라 유지.

## [2026-07-06] guide | Advisor–Worker 실습 심화편 신설
- [[guide-advisor-worker-advanced]] — backlog Pending 4장면 그대로 25분 실습: ① 요구 변경(5만원 이상 20% 할인 케이스)으로 확정 실패를 만들어 **수정 브리프 재위임** 관찰 ② coupon+shipping 독립 모듈 **병렬 위임**(한 턴 두 Task·브리프 분리) ③ worker frontmatter `model:` 고정 + `CLAUDE_CODE_SUBAGENT_MODEL` 덮어쓰기를 stream-json `model` 필드 grep으로 **실측** ④ Step 0에 심은 오타("모둘")로 **위임 오버헤드 예외**(직접 Edit) 관찰.
- Step 0은 모델 호출 없이(토큰 0) 기본편 완료 상태 복원 + 축약판 advisor에 규율 2줄(병렬·예외) 추가. "규율이 없으면 생기는 일" 표 4행, 관찰 결과표.
- 교차참조: 기본편·concept·src 관련 페이지 양방향, nav(실습)·index 등록. backlog Pending은 "실행 검증"으로 이월.

## [2026-07-06] concept | Advisor–Worker 패턴 개념 페이지 신설
- 사용자 지적 "개념에도 내용이 있어야지" — src(스크립트 요약)·guide(실습)만 있고 개념층이 빠져 있던 것을 보완. [[concept-advisor-worker]] 신설(약 140줄): 정의·부탁 vs 구조·구성 요소 4가지(tools 고정·브리프·검증 게이트·승인 권한)·모델 티어링·적용/비적용 기준·"검증 주체의 독립성" 패턴 비교표 5행·도입 체크리스트.
- src와 중복 회피 분담: src=스크립트에 뭐가 있나(브리프 6항목 원문·frontmatter 예시·3-tier 비교표), concept=패턴의 원리·언제 쓰나.
- 교차참조 양방향: src·guide 관련 페이지 최상단, [[concept-multi-agent-pattern]] "2-역할 변형" 절이 concept를 1차 링크로. nav(하네스 > 개념)·index 등록.

## [2026-07-06] backlog·style | 심화편 후속 등록 + 새 페이지 톤앤매너 점검
- [[backlog]] Pending에 **Advisor–Worker 실습 심화편** 등록 — 후보 4장면: ① 병렬 위임 ② 검증 실패→수정 브리프 재위임(기본편에서 재현 안 된 유일한 규율) ③ 이종 모델 고정+`CLAUDE_CODE_SUBAGENT_MODEL` 함정 실측 ④ 위임 오버헤드 예외. 완료 섹션에 2026-07-06 3건(ingest·실습·실행 검증) 기록.
- **톤앤매너 점검** (src-ai-advisor-worker·guide-advisor-worker-demo, §7 대조): src 검증 게이트 목록 4행 한다체→합니다체, 금칙어 "돌리다" 2건 교정(§7-5), guide Step 1 `node cart.test.js` 블록 리드인 추가(§7-8), "새면서 섞입니다" 문장 정돈. 배너 안 "돌려"는 blockquote 허용 슬롯이라 유지. 두 파일 style-lint 0건.

## [2026-07-06] verify | Advisor–Worker 실습 실행 검증 (헤드리스)
- [[guide-advisor-worker-demo]] Step 1~4를 실제 실행해 검증 — Step 3은 `claude --agent advisor -p` + `--output-format stream-json`으로 돌려 도구 호출 시퀀스 감사.
- **4장면 전부 재현**: ① 브리프 6항목([목표]~[범위 경계]) 완비 + `subagent_type: worker` 위임 ② cart.js Write는 Worker만 수행 (Advisor는 탐색·Read만) ③ Worker 보고 후 Advisor가 변경 확인과 `node cart.test.js` 재실행을 직접 수행 ④ 검증 후 Advisor가 커밋. 1사이클 3/3 통과, 재위임 불필요.
- 페이지에 "✅ 실행 검증됨 (2026-07-06)" 배너 추가. 데모 디렉터리 정리 완료.

## [2026-07-06] guide | Advisor–Worker 실습 페이지 (판단·구현 분리 직접 체험)
- **생성**: [[guide-advisor-worker-demo]] — 데모 프로젝트(`~/advisor-demo`, cart 할인 테스트)에 축약판 advisor/worker 에이전트를 설치하고 `claude --agent advisor`로 위임·검증 게이트를 관찰하는 15분 실습. 관찰 포인트 4장면·차이 표·역할 분리 체크리스트 포함.
- **패턴 누적**: "보고를 믿지 말고 재검증하라" 비교표 (Advisor–Worker · Loop 실습 · Critic REJECT · guard.sh) — [[src-ai-advisor-worker]]·[[guide-loop-engineering-demo]]와 양방향.
- index.md·mkdocs.yml nav(하네스·AI 에이전트 > 실습) 등록. a.md 삭제·ingest분 커밋(8e63285) 후속.

## [2026-07-06] ingest | Advisor–Worker 에이전트 스크립트 (raw/ai-advisor/)
- **소스**: `raw/ai-advisor/` — advisor_script.md(Advisor 에이전트 정의, Fable 5), worker_script.md(Worker 에이전트 정의, Opus 4.8), claude_script.md(프로젝트 CLAUDE.md 템플릿). 판단·구현 분리 협업 모델.
- **생성**: [[src-ai-advisor-worker]] (frontmatter tools 제한, 6항목 브리프, 검증 게이트, Planner/Coder/Critic 비교표), `raw/ai-advisor/README.md`(자료 인덱스)
- **교차참조**: [[concept-multi-agent-pattern]]에 "2-역할 변형: Advisor–Worker" 절 + 관련 페이지 링크, [[concept-claude-md]] 관련 페이지 링크 (모두 양방향)
- **index.md·mkdocs.yml nav** (하네스·AI 에이전트 > 소스) 등록
- **보류**: `raw/ai-advisor/a.md`는 빈 파일 — 삭제 여부 사용자 확인 필요

## [2026-07-05] lint | §2-6 전면 소탕 — 코드블록 ASCII 대응표 36곳 → 마크다운 표 (35파일)
- 사용자 지시 "비슷한 부분 더 찾아봐" + "스텝별로 맥락이 중요" → §2-6에 **전환 지침 표 신설**(비교형=열이 대안 / 진행형=행이 단계 / 대응형=조건|결과 — 블록이 담던 의미 축을 보존해야 함) 후 인벤토리 전체 소탕.
- **강의 교재 32곳 (4계열 에이전트 병렬)**: Clean Code 5(전부 비교형) / EJ 6(진행형 3 — 생애주기·입구몸통출구·예외 라이프사이클은 "단계|해당 아이템" 축, 대응형 1 — 예외 결정 가이드 "상황|던질 예외") / 오브젝트 13(사다리형은 열 순서=단계 의미를 리드인에 명시, ch5·ch14는 굵은 리드인 번호 목록, appendixC "영화 예매" 추가 발견분 포함) / TDD·리팩터링 8(tdd-ch6·9 진행형 "단계|내용", ch29 용어 대응).
- **entity·concept 4곳 (직접)**: entity-jvm GC 흐름(진행형 "단계|사건|결과"), entity-spring-boot 스택("계층(아래→위)|역할"), concept-claude-md·guide-harness-module2 복붙 템플릿 2곳은 §2-6 예외 유지 + 한글 열 맞춤 공백만 단일 공백으로 축소.
- 전 블록 §7-8 리드인 부여, 표 직후 리스트 접합 버그 전수 점검(해당 없음), frontmatter updated 갱신. 부수: tdd-ch29 기존 곡선따옴표 2건 교정.
- **재스캔 잔존 0** (다열 한글 정렬 기준). 유지 확정: 디렉터리 트리 ~12곳, ASCII 다이어그램 6곳(http-hol 3·refactoring-ch2 2·tdd-ch1 1 — 장기 HTML flexbox 전환 후보), 코드 주석 화살표.
- 35파일 style-lint 0건(표준 문서 자기참조 오탐 제외), 빌드 통과.

## [2026-07-05] fix | harness module2 Step 2 "변환 공식" 개연성 보강 (§7-8)
- 사용자 피드백 "Step 2에서 설명이 막힘 — 변환 공식이 왜 나오는거야?". 원인: Module 01 Step 5 표에 이미 `STOP: 환경 파일 커밋` 메모 열이 있어 "이미 STOP인데 왜 또 변환?"이 되는데, 두 STOP의 차이(회고용 한 줄 메모 vs 에이전트가 판정할 완성형 조건)를 문서가 설명하지 않았음.
- 수정: ① "### 변환 공식" → "### 변환 예시"로 개명(실제 내용은 예시 대응표 5쌍 — "공식"이 오해 유발) ② 새 절 "왜 그대로 복사하지 않고 '변환'하는가" 신설 — 읽는 주체 차이(사람 회고 vs 에이전트 판정) + 변환 시 붙이는 2요소(판정 가능한 패턴·멈춘 뒤의 대안) ③ 본문 "변환 공식" 지칭 2곳 정합 ④ 사용자 추가 지적("줄이 안 맞음")으로 ASCII 대응표(코드블록·한글 폭 때문에 정렬 불가) → 마크다운 2열 표로 전환.
- raw에는 해당 표현 없음(wiki 서술층) — wiki만 수정. style-lint 0건, 빌드 통과.
- 부수: 프로젝트 이동(Documents/→VsCodeProjects/) 여파로 깨진 `.venv` 재생성 (bad interpreter).

## [2026-07-05] policy | §2-6 신설 — 대응·비교는 마크다운 표로 (코드블록 ASCII 정렬 금지)
- 위 module2 수정에서 일반화(사용자 "줄 맞추는 것도 대응표면 표로 만들면 좋겠지? 정책에 적용해줘"). 근거: 한글은 고정폭 폰트에서도 영문 폭 정수배가 아니라 코드블록 열 맞춤이 폰트·환경마다 어긋남.
- [[guide-wiki-authoring-standards]] §2-6 신설(규칙·이유·판별 기준·예외) + §8 셀프체크 1행. 예외: 실행 명령·출력 로그·트리·diff 등 모노스페이스 산출물은 코드블록 유지(단 한글 열 맞춤 시도 금지).
- CLAUDE.md 요약(다이어그램 기준)·셀프체크에도 1행씩 반영.
- 1차 스캔으로 기존 위반 후보 ~12파일 검출 → backlog Pending 등록(복붙 템플릿 내부는 예외 판별 필요).

## [2026-07-04] ingest | Clean Code 3 + 오브젝트 4 concept 신설 — 책 기반 concept 11개 완성
- backlog "즉시 가능" 잔여 7개 실행(7병렬 에이전트, 재료: lecture 교재 발췌 + 원전 검증). EJ 4개와 합쳐 책 기반 concept 페이지 11개 전부 완성.
- **Clean Code**: [[concept-naming-conventions]](158줄, Spring Data JPA 쿼리 메서드=이름이 계약 — 공식 문서 검증) / [[concept-tdd-laws-and-first]](169줄, **귀속 오류 발견·교정**: 교재의 "Kent Beck의 3법칙"은 Martin 정식화가 정확 — Martin 본인 술회 확인, lecture-ch9·raw 동시 교정) / [[concept-simple-design-rules]](162줄, Fowler 순서 논쟁·4번 규칙 오독 주의).
- **오브젝트**: [[concept-solid]](223줄, Liskov & Wing 1994 원문 인용, SRP·ISP는 Martin 원전 보완 명시) / [[concept-grasp]](242줄, Larman 원전·초판 5→2판 9패턴) / [[concept-design-by-contract]](194줄, Meyer·Eiffel·상표 사실 확인, Java 실현 수단 5종 매핑) / [[concept-domain-model-kinds]](160줄, 부록 C 4모델 실확인, 카카오페이 DDD 사례 연결).
- **통합**: entity 3권 매핑 표 실링크화, lecture 소스 9곳 "개념 정리판" 링크, 패턴 비교표 양방향(loop-engineering 거부 신호 표에 TDD 행, functional↔naming, solid↔design-patterns/pecs, DbC↔jspecify, domain-model↔kakaopay), nav·index 7항.
- 신설 7 + 수정 20파일 lint 통과, 빌드 통과. wiki 페이지 191→198.

## [2026-07-04] ingest | EJ concept 4개 신설 — enum 매핑·함수형 인터페이스·PECS·직렬화 위험
- backlog "즉시 가능" EJ 항목 실행 (재료: lecture-effective-java ch5·6·7·12 발췌 + 공식 문서 검증). 4병렬 에이전트로 페이지 생성, nav·index·역링크는 일괄 통합.
- **concept-jpa-enum-mapping** (198줄) — Item 34·35 + `@Enumerated` 기본 ORDINAL 함정(Jakarta Persistence javadoc 검증, Hibernate 6 저장 타입 확인). "기본값과 가정의 함정" 패턴 **7번째 사례**로 비교표 양방향 합류.
- **concept-functional-interfaces** (175줄) — 표준 6종 표·박싱 비용·Item 44 예외 3조건·Spring 예제 3개. java.util.function 43개를 Oracle API로 검증.
- **concept-generics-pecs** (161줄) — PECS 장면 비유·상황별 선택표·JDK 시그니처 5개 원문 대조·컴파일 오류→원인 자족 표.
- **concept-java-serialization-risk** (225줄) — Item 85·88·90 + Commons Collections 사건(CVE-2015-4852/7501·3.2.2 패치·JEP 290 백포트 교차 확인). 방어 관점 서술, 공격 재현 코드 배제.
- **양방향 통합**: entity-effective-java 매핑 표 4행 링크화, lecture ch5·6·7·12 심화 링크, 패턴 비교표(api-backward-compatibility) 2행 추가, concept-design-patterns·jspecify·java-study-ch03 역링크, mkdocs nav·index 4항.
- 신설 4 + 수정 10파일 lint 0건, 빌드 통과. wiki 페이지 187→191.

## [2026-07-04] style | 글쓰기 스타일 2차 확장 완료 — 5권 entity·concept 2·guide 1 (8편)
- backlog 최우선 Pending이던 2차 확장(1차 13편은 2026-06-27) 실행. 대상: entity-object/effective-java/refactoring/clean-code/tdd + concept-oop + concept-design-patterns + guide-code-authoring-and-review.
- **장면+매핑 2문단 재구성 3곳**: concept-oop 도입(극장 장면 — 사용자 모범 문장 활용 + lecture-object-ch1 링크), entity-effective-java "본질"("정비사의 매뉴얼" 장면 신설), entity-tdd "빨강=거부 신호" 괄호 매핑 분리.
- **명사구 단편→능동 완결문 약 35곳**: guide-code-authoring 15, entity-clean-code 6, entity-object 5, 나머지 소량. entity-refactoring "이 책의 자리" 말미 단편(24 악취 + 66+ 기법.)도 완결문화 — 5권 통일은 형식이므로 유지됨.
- **과잉 금지 판정**: concept-design-patterns·entity-clean-code·entity-object·guide-code-authoring은 장면형 비유가 원래 없어 신설하지 않음(1차 선례와 동일 기준). 5권 오각형 비교표·표·코드·체크리스트·절 헤더 캡션 불변.
- 8편 style-lint 0건, 빌드 통과.

## [2026-07-04] fix | ch03 3.9 공식 문서 링크 4건 URL 복원 (보류분 종결)
- 원본 대조 감사에서 보류했던 링크 4건 — Notion 렌더 시 텍스트만 뽑고 링크 속성이 버려진 것이 원인. 블록의 **링크 주석(annotation: `['a', url]`)을 직접 추출**해 복원: Lambda Expressions(dev.java)·Stream Package Summary·Stream Interface·Optional Interface(JDK 21 API). 4건 전부 HTTP 200 확인.
- wiki(설명 부기 포함)·raw(교정 노트) 동시 반영. 이로써 원본 블록 대조 감사의 보류 항목 0건 — **97개 문서 전수 감사 완전 종결**.

## [2026-07-04] fix | 원본 블록 수 전수 대조 — 97개 문서 감사, 개정·유실분 8개 챕터 병합 + 원본 불신 검증 정책
- 사용자 요청 "다른 챕터도 잘림 없는지 원본 블록 수와 대조". Notion 97개 문서 전부를 loadPageChunk로 재수집해 **블록 수·꼬리 3블록·전체 커버리지 3단 감사**: 이상 없음 65 / 의도된 차이 12(raw 스텁·미이관·재작성) / 실누락 17건 검출.
- **누락 병합 (챕터별 6에이전트, 아래 개별 기록 참조)**: ch02 결론 문장 / ch03 3.9 체크포인트 절단+정리 절 / ch05 5.5·5.6 꼬리 + 5.8 문제·풀이 원문 전체(raw ~340줄) + 5.9 문제 23개 상세 / ch06 6.1 기동 로그·테스트 실행·막히는 지점(demo 번안) / ch08 8.0 10.4 절단+§11+링크 6 / ch09 9.3 curl 꼬리(재배치 위치 정정 병합) / ch10 10.2 §8~§11 통째 복원(+124줄) / ch11 11.23 §11~17+맺음말(+307줄).
- **원본 불신 검증 정책 신설·적용** (사용자 지시 "raw도 잘못될 수 있어 — 공식 문서·유명 도서와 대조"): CLAUDE.md 보강 정책 6번 명문화. 이번 적용 사례 — ch01 Java/C++ 표 3건("C는 함수형"→절차적 등), ch06 Spring Boot 3.x 로그 문구·순서(소스코드 대조), ch10 UseContainerSupport 기본 활성·MaxRAMPercentage 검증(JDK 21 매뉴얼), ch11 인덱스 중복·static 캐시 동기화 부기, ch05 BufferedReader 원본 버그 근거 주석, 링크 URL 17건 실접속 확인.
- 잔여 보류: ch03 3.9 공식 문서 링크 4건(원본에서 URL 자체 유실 — Notion에서 URL 추출 재시도 후보).
- 9개 챕터 양 lint 0건·붙은 리스트 0·펜스 균형·빌드 통과.

## [2026-07-04] fix | ch11 11.23 Notion 원본 꼬리 잘림 복구 — §11~17+맺음말 (raw+wiki 동시)
- Notion 재수집 덤프(p1123-full, 276블록) 절 단위 대조 — raw·wiki 모두 §10 필요 산출물에서 끊겨 §11~17 전체가 결손이었음을 확인 후 병합.
- **병합 블록**: §1 실습 프로세스 하위 불릿(7단계 세부), §10 "초기 데이터 삽입 SQL" 불릿, §11 보안 고려사항(BCrypt·XSS `<c:out>`·CSRF 토큰·PreparedStatement), §12 실습 단계별 가이드(1~7단계), §13 확장 기능 아이디어, §14 성능 최적화 팁(인덱스·페이징·캐싱), §15 디버깅 및 트러블슈팅(한글 깨짐·세션 타임아웃 확인·DBConnection 테스트·catalina.out), §16 프로젝트 구조 비유(도서관), §17 최종 체크리스트(기능·보안·성능 `- [ ]`), 맺음말. wiki는 기존 "11. 빌드·실행"(위키 자체 신설 절)을 유지하고 12~18번으로 번호 이어붙임.
- **원본 검증 2건** (MySQL·서블릿 공식 동작 기준, wiki 검증 노트+raw 검증 주석): ① §14 인덱스 4개는 이 스키마에선 사실상 중복 — `users.email` UNIQUE가 유니크 인덱스를 이미 만들고 InnoDB는 FK 컬럼 인덱스를 자동 생성(패턴 예시로만 유효) ② §14 static 캐시는 서블릿 멀티스레드 환경에서 동기화 부재(volatile/synchronized 보완 필요) 부기. BCrypt 권장·`<c:out>` 이스케이핑·PreparedStatement 바인딩은 타당 확인.
- **§16 비유는 wiki에서 산문 번안**: 괄호 매핑 대신 장면(사서 한 명이 모든 일을 하는 작은 도서관)+매핑 완결 문장으로 재서술, raw는 원문 그대로.
- p119(11.9)·p1117(11.17)·p114(11.4)도 대조 — 실질 결손 없음(차이는 위키 챕터 번호 번안·`‣` 링크 평문화 등 의도된 재작성뿐)이라 병합 생략.
- raw는 원문 그대로 + `<!-- 복구 노트: 2026-07-04 Notion 재수집으로 원본 개정분 병합 -->`. 두 lint 0건, 빌드 통과.

## [2026-07-04] fix | ch10 10.1·10.2 Notion 원본 꼬리 잘림 복구 (raw+wiki 동시)
- Notion 재수집 덤프(p91·p92) 대조 — 10.1은 "자주 헷갈리는 지점" 셋째 불릿부터, 10.2는 7.3 마지막 불릿부터 꼬리 결손 확인 후 병합.
- **10.1 (p91)**: 자주 헷갈리는 지점 불릿 3개(`= null` 포함) + 공식 문서 5링크(GC Tuning Guide 등) + 정리·한 줄 정리. wiki는 10.0과 같은 패턴(공식 문서 → ✏️ 실습 → 정리)으로 배치.
- **10.2 (p92)**: 7.3 컨테이너 불릿 1개 + §8 흔한 문제와 기본 대응(8.1~8.4) + §9 JFR + §10 잘못된 접근 + §11 운영용 기본 템플릿(GC 로그 템플릿·컨테이너 기본값 코드·예상 결과 펜스) + 공식 문서 4링크 + 정리·한 줄 정리. "현재 저장소"는 wiki에서 실무 저장소 참고 문맥으로 번안. 템플릿의 `-Xlog:'gc*':file=...`은 파일 출력형도 `*`를 포함해 zsh nomatch가 나므로 2026-07-01 교정과 동일하게 따옴표 표기 적용(raw는 원문 그대로).
- **원본 검증** (JDK 21 공식 문서): `UseContainerSupport`는 JDK 10+ 리눅스 기본 활성(default true) → 명시는 동작 변경이 아닌 의도 문서화임을 wiki 본문·raw 주석에 부기. `MaxRAMPercentage` 기본값 25.0(75.0 지정은 실효 있음), G1 `MaxGCPauseMillis` 기본 200ms, `-Xlog:<selector>:<output>:<decorators>` 문법 유효 확인. 덤프는 링크 URL 유실 → 공식 문서 URL 신규 4건(java·jcmd man, NMT, GC Tuning Guide) 실재 확인, jvms-2는 기존 10.0에서 사용 중인 URL 재사용.
- raw는 원문 그대로 + `<!-- 복구 노트: 2026-07-04 Notion 재수집으로 원본 개정분 병합 -->`. 두 lint 0건, 빌드 통과.

## [2026-07-04] fix | ch08 8.0·ch09 9.3 Notion 원본 꼬리 잘림 복구 (raw+wiki 동시)
- **8.0 Tomcat (p70 대조)**: raw·wiki 모두 10.4 첫 불릿에서 잘려 있던 꼬리 복구 — 10.4 나머지 불릿 2개+해석 문장, §11 "인증 절로 넘어가기 전에 잡아야 할 연결점"(연결 불릿 4개), "공식 문서 기준으로 더 보면 좋은 자료" 6링크, 정리·한 줄 정리. wiki는 정리·한 줄 정리를 8.1·8.3과 같은 패턴(✏️ 실습 뒤)으로 배치.
- **9.3 curl (p83 대조)**: Notion 8.3 curl 문서는 챕터 재번호 부여로 현재 ch09 9.3 — ch08이 아니라 ch09 raw·wiki에 병합. 공식 문서 링크 3개 추가(curl Documentation·Spring Boot Testing Reference·HTTP Semantics/RFC 9110) + 정리·한 줄 정리 복구.
- **링크 검증**: 덤프에는 링크 제목만 남아 URL 유실 → 공식 문서 실제 URL 9건 전부 HTTP 200 확인 후 표기(Tomcat은 Spring Boot 3.x 내장 계열인 10.1 문서 기준).
- raw는 원문 그대로 + `<!-- 복구 노트: 2026-07-04 Notion 재수집으로 원본 개정분 병합 -->` 주석. 두 lint 0건.

## [2026-07-04] fix | ch06 6.1 Notion 원본 개정분 병합 — 기동 로그·테스트 실행·막히는 지점·체크리스트 (raw+wiki 동시)
- Notion 재수집 덤프(p51 "5.1 Spring 실습 환경 구성 가이드") 대조 — 6.1 꼬리 결손(§6 예상 결과 이후 전량) 확인 후 병합.
- **raw**: §6 예상 결과(Spring 배너·Swagger 확인), §7 테스트 실행, §8 자주 막히는 지점 5불릿, 자주 하는 실수 4불릿, 체크리스트 5항목, 정리·한 줄 정리를 원문 그대로 병합 + 복구 노트.
- **원본 오류 교정 2건** (Spring Boot 3.5.5 소스로 검증): ① `(JVM running for ...)` → `(process running for ...)`(StartupInfoLogger, 2.6까지가 JVM 표기), ② `Started ...` 줄이 `Tomcat started ...`보다 먼저이던 로그 순서 → 실제 출력 순서로 교정. raw에 교정 주석.
- **wiki 번안**: demo 자족형 기준 — 기동 로그는 `Started DemoApplication`으로, Swagger UI는 demo에 springdoc이 없으므로 "참고 — 실무 프로젝트라면" 인용으로 격하. §7 테스트 실행은 start.spring.io 기본 생성 `contextLoads` 기준으로 재서술(+예상 결과 펜스), §8은 증상→확인·해결 표로 전환하고 DB 설정 항목은 6.3 "자주 나는 에러" 표로 연결. 체크리스트·자주 하는 실수·정리·한 줄 정리 추가. style-lint·scaffold-lint 0건, 빌드 통과.

## [2026-07-04] fix | ch02·ch03 Notion 원본 꼬리 누락 병합 (raw+wiki 동시)
- Notion 재수집 덤프(p25·p39) 대조 — ch02 2.5·ch03 3.9 절 꼬리 결손 확인 후 병합.
- **ch02 2.5 결론**: 둘째 문장("다양한 상황에서 추상 클래스를 활용하여 구조적인 설계를…") 1블록이 raw·wiki 모두 미존재 → raw는 원문 그대로 추가, wiki는 기존 재작성 결론 유지한 채 합니다체 문장으로 이어붙임(기존 문장 종결도 "향상시킴."→"향상시킵니다."로 §7-1 정합).
- **ch03 3.9 꼬리**: raw·wiki 모두 "풀이 전 체크 포인트" 3항에서 끊겨 있었음 → 체크 항목 2개(`Optional` null 감추기·람다 한 줄 판단) + "정리"·"한 줄 정리" 2블록 병합. 덤프의 "공식 문서" 목록(4항)은 Notion 내보내기에서 URL이 소실돼 빈 제목만 남은 상태라 병합 보류(보고만).
- raw 병합 지점에 `<!-- 복구 노트: 2026-07-04 Notion 재수집으로 원본 개정분 병합 -->` 마킹. style-lint·scaffold-lint 0건.

## [2026-07-04] fix | 표 유실 전수 점검 — 11.25 표 8개 복구 + raw 마커 23건 소거 (저장소 전체 결손 0)
- 12챕터 wiki+raw 24파일 기계 스캔(빈 절·`<!-- table -->`·`‣`·펜스 불균형·토글 잔재) → 걸린 곳만 Notion 원본 대조.
- **11.25 요구사항·기능 명세 비교 표 8개 복구 (진짜 유실)**: raw엔 마커만, wiki엔 절 자체가 없던 서브트리(사용자·게시글·관리자·댓글 요구사항 4표 + 기능 비교 4표 + 종합 분석 2벌) → Notion 재수집으로 raw 원위치 복원 + wiki 11.25 말미에 "참고 답안" 절로 삽입(숙제 먼저 권장 리드인).
- **raw 마커 역이식**: wiki는 이미 복구됐지만 raw에 마커로 남아 있던 ch07 스키마 표 22개·ch08 핵심 용어 표 1개를 wiki 복구본에서 헤딩 매칭으로 raw에 역이식(대소문자 차이 1건 수동). 저장소 전체 `<!-- table -->` 잔존 0.
- **오탐·의도 공백 판정**: ch01 2.5(내용이 동급 헤딩으로 존재), 11.25 객체 모델링·주요 SQL 쿼리(원본도 빈 숙제 칸), 11.22 연결된 실험 DB(하위 DB 의도적 미이관) — 수정 불요 확인.
- 두 lint 0건, 빌드 통과.

## [2026-07-04] fix | ch01 [참고 1] 2.1 빈 절 복구 — Java vs C/C++ 특징 비교표 (raw+wiki)
- ch11 복구와 같은 방법(Notion published API loadPageChunk)으로 [참고 1] 원본 페이지 대조 — 빈 절의 정체는 **8행 Notion 표 유실**(ch07 표 유실과 같은 계열). 표 블록의 `format.table_block_column_order`로 컬럼 ID를 얻어 행별 셀 텍스트 추출.
- 특징 7행(컴파일 과정·플랫폼 독립성·메모리 관리·포인터·속도·멀티스레딩·객체 지향) 비교표를 raw(+복구 노트)와 wiki에 동시 복원. 두 lint 0건, 빌드 통과.
- 이로써 §7-8 점검에서 나온 결손 후보(ch01 빈 절, ch11 3종) **전부 종결**.

## [2026-07-04] fix | ch11 Notion 변환 결손 복구 — 11.90 잘림·11.23 코드 유실·‣ 링크 (raw+wiki 동시)
- **복구 방법**: Notion published API 재수집. queryCollection(spaceId 필수, `value.value` 중첩 주의)으로 페이지 ID 특정 → loadPageChunk **커서 페이지네이션**(cursor.stack 재전달, chunkNumber만 올리면 같은 청크 반복)으로 전체 블록 수집. 접힌 토글은 토글 블록 ID를 pageId로 재요청. syncRecordValues는 익명 403.
- **11.90 JVM 워크북 잘림**: 2026-06-29 추출 때 "시나리오 1 문제"에서 파일이 끊겨 있던 것(raw도 동일) → 시나리오 1 해결 + 시나리오 2~5(파일 리소스·캐시 상한·StringBuilder·컬렉션 초기 크기) + "4. 핵심 정리"(5대 원칙·체크리스트·다음 단계) 전량 복원. wiki에는 §7-8 리드인 부착, raw에는 원문 그대로 + 복구 노트 주석.
- **11.23 공통 헤더·인증 체크·관리자 체크 코드 유실**: 변환 때 코드 본문(`<% %>` 안)이 비고 펜스가 뒤섞여 헤딩이 코드블록 안에 렌더되던 구간 → header.jsp(JSTL 메뉴 분기)·auth_check.jsp(returnUrl 리다이렉트)·admin_check.jsp 원본 코드 전량 복원, 펜스 정상화 (raw+wiki).
- **‣ 깨진 내부 링크 10건**(wiki 6·raw 4) → `제목(→ 11.NN)` 평문 참조로 전환(2026-07-01 notion.so 링크 처리와 같은 방식). 빌드의 unrecognized link 경고 소멸.
- **잔재 2건**: 11.25 `구현+++——` 토글 아티팩트 제거(원본에도 자식 없음 확인), 11.26 매달린 "힌트" 불릿 → 원본 토글 내용(클래스 구조·기능 구현·확장 포인트) 복구해 정식 절로 승격.
- ch11 style-lint·scaffold-lint 0건, 펜스 균형 확인, 빌드 통과. 남은 결손: ch01 [참고 1] "2.1 언어의 특징 비교" 빈 절(원본에도 없을 가능성 — 확인 필요).

## [2026-07-04] feat | java-study 12챕터 §7-8 전수 점검 + 붙은 리스트 89건 일괄 수정
- §7-8 신설 직후 사용자 요청("java-study도 점검")으로 12챕터(2.1만 줄) 챕터당 1에이전트 병렬 점검. 교재 특칙 적용: 전방 참조는 정의 대신 "(N.N에서 다룹니다)" 안내, §7-7 스캐폴드·실측 예상 결과 불변.
- **§7-8 보강 약 120곳**: 용어 첫 등장 정의(아키타입·pom.xml·Lombok·HikariPool·N+1·BooleanBuilder·JWT·서블릿·클레임·jq·JUnit/Mockito/MockMvc·Young/Old/Full GC 등), 예제 의도 리드인(ch02 2.5 예제 10개, ch10 jcmd 5절 명령→설명 구조 역전), `hello-java`/`demo` 첫 사용 지점 반문장 재소개(§7-7 이름 명시 규칙 정합), 빈 절·댕글링 참조 정리(ch09 존재하지 않는 코드 지시문, ch05 SimpleTCPServer 유령 이름, ch07 7.7↔7.9 참조 불일치, ch04 문제 구성 예고↔실제 5문제 불일치, ch07 장 번호 리넘버링 잔재 2곳).
- **붙은 리스트 렌더 버그 89건 일괄 수정**: 실제 렌더러(markdown+superfences)로 실증 — 문단·닫는 펜스·표 직후 리스트는 한 줄로 붙고 **헤딩 직후만 정상**. 헤딩 케이스 제외 자동 스크립트(4-backtick 펜스 추적)로 12챕터 89건 빈 줄 삽입, 잔존 0.
- **ch00 daybyspring 잔재 정합**: 교재 일반화(fd72cab) 때 남은 `jdbc:...daybyspring` URL 2곳·`spring-0.0.1-SNAPSHOT.jar` 4곳을 demo 기준으로, 존재하지 않는 `src/test/resources` 전제 서술을 ch06 §5 확정 문안(demo에는 없음 + 실무 저장소는 참고 인용)으로 미러링.
- module1 도입부 추가 보강(사용자 문답 반영): 측정=체크시트 채우기, 따라하는 사람 관점(모의고사 비유), `[베이스라인 측정 중]` 주어 명시(측정 주체=사용자, 대상=Claude, 할 일=붙여넣기뿐).
- 미해결 발견(별도 작업 후보): ch01 [참고 1] "2.1 언어의 특징 비교" 빈 절, ch11 11.90 시나리오 5문제 중 1번만 존재(잘림)·11.23 코드펜스 깨짐 구간·`‣` 잔재.
- 13파일(12챕터+module1) style-lint·scaffold-lint 0건, 빌드 통과.

## [2026-07-04] feat | §7-8 "불쑥 등장 금지" 신설 + harness 8편 선행 소개 전수 보강
- 사용자 피드백 2건: ① "태스크 B — 새 조회 API"가 왜 만드는지 설명 없이 등장, `[베이스라인 측정 중]`이 정의 없이 튀어나옴 ② "독자가 안다고 가정하고 불쑥 내미는 패턴이 많다 — 전반 보강하고 정책에 명시하라".
- **§7-8 신설** (guide-wiki-authoring-standards): 선행 소개 4규칙 — 블록 리드인 / 표기·규약 첫 등장 정의 / 태스크 의도 문장 / 산출물 반문장 재소개. 판정 기준 "절만 떼어 읽어도 '이게 뭐지?'가 없는가". §8 셀프체크 + CLAUDE.md 셀프체크에 항목 추가.
- **§7-7 언어 무관 원칙 추가**: 향후 Python·C 등 새 자료 트랙도 스캐폴드 4요소 동일 적용, 실행 명령 표준형만 언어별 확장 (사용자 방침: "계속 업데이트할 것이므로 구성 규칙이 중요"). backlog 결정 사항에도 기록.
- **harness 8편 전수 보강** (module1 직접 + 7편 병렬 에이전트, 총 70여 곳): module1 태스크 A·B·C 의도 문장·`[베이스라인 측정 중]` 표시 정의 / demo hook·guard.sh·PreToolUse 정의 / prerequisites 리드인 8·용어 5(Zod·Conventional Commits 등) / module2 STOP·12섹션 정의 / module3 PreToolUse·stdin JSON·exit 2·matcher 정의 / module4 Planner·Coder·Critic·판정 용어·커밋 접두어 규약 정의 / module5 Rippable 정식 정의·"M2 After" 열 선행 소개 / loop 메아리방·거부 신호·헤드리스 정의·실측 수치 유래 재소개.
- 9개 파일 style-lint 0건(표준 문서 자기참조 3건은 기존 의도 표기), 붙은 리스트 0건, 빌드 통과.

## [2026-07-04] feat | harness 가이드 8편 실습 정비 — 박스·리스트 렌더·배너 제거·개연성·모순 교정
- 사용자 피드백 3건 반영: ① "이 모듈에서 얻을 것" 등 번호 리스트가 한 줄로 붙어 렌더됨 ② `> 원본: raw/...` 배너가 위키에 노출 ③ "본인 기존 프로젝트는 이 시점에 쓰지 않습니다" 같은 뜬금 문장·Step 간 개연성 부족.
- 대상 8편: prerequisites·demo·module1~5·loop-engineering-demo (module1 직접 수정으로 기준 수립 → 나머지 7편 병렬 에이전트).
- **박스 형식 이식**: java-study의 `!!! example` admonition을 harness용 `"실습 위치·실행"`(위치·만들 파일·실행 라벨, 인라인 코드만)으로 변형해 손 움직이는 Step마다 부착, 총 44개.
- **붙은 리스트 분리 25건+**: 문단 직후 빈 줄 없는 리스트(MkDocs에서 한 줄 렌더) 전수 수정 + 전 파일 재스캔 0건.
- **raw 배너 제거 4건**: module1 2·module3 1·loop 1 제거, prerequisites 1은 경로만 빼고 정보(Spring 원본→Node 이식) 유지. frontmatter sources 불변.
- **개연성 보강**: 8편 도입부에 "왜 이 모듈인가"+"진행 흐름" 문단, 모든 Step 첫머리에 앞 단계 산출물과 잇는 연결문. 뜬금 문장은 이유 부착(예: 기존 프로젝트 금지 → "실수를 일부러 만들며 배우므로 아끼는 코드에 위험, 5모듈 후 이식").
- **실습 모순 교정 (적대적 점검 부수 수확)**: demo guard.sh `exit 1`→`exit 2`(차단 규약 위반으로 데모 자체가 실패하던 결함)·`.gitignore` 전제·cleanup reset 견고화 / **M2 태스크 A 재실행 불가**(M1에서 이미 phone 구현됨 → `git revert` 출발선 되돌리기 신설) + **M2→M5 연쇄**(M2 재실행 커밋 `harness(M2-A)` 명시 → M5가 그걸 revert) / module3 시간 배분·"8종 차단"→"6종+2경고" / module4 실습 대상 playground 원칙 정합·미커밋 산출물 커밋 추가 / prerequisites 시간표·헤딩 종속 오류.
- 8편 style-lint 0건, 빌드 통과, admonition HTML 렌더 확인(모듈당 4~8박스).

## [2026-07-03] style | 직접 해보기 마감 2건 — 단계 순서 교체 + 헤딩에 절 주제 부착
- 사용자 피드백 2건: ① 실습 순서 3·4단계 교체 — "실행 → 하나씩 추가"를 **"하나씩 구현 → 실행·확인"**으로(구현 먼저가 자연스러움), 22개 박스 교체 ② 헤딩 `### ✏️ 직접 해보기` → **`### ✏️ <절 주제> 직접 해보기`**(예: "✏️ 메서드와 배열, 문자열 직접 해보기"), 49개 전부 절 제목(부제 제외) 접두.
- §7-7 템플릿·헤딩 형식 동기화. 12챕터 두 lint 0건, 배포 완료.

## [2026-07-03] style | 직접 해보기 "실습 순서" 형식 확정 — 뼈대 인박스·프로젝트명 명시·글자 확대
- 사용자 피드백 3건: ① 대명사 지칭 금지 → `hello-java`/`demo` 프로젝트명 명시 ② 파일 생성부터 번호 단계 + **뼈대 코드를 "뼈대 입력" 단계 바로 아래 박스 안으로**(코드가 따라와야 보기 편함) ③ main 없는 실행 불가 문제 → main 포함 뼈대 전체 + 과제 번호 주석(하나씩 구현→재실행→출력 확인). 추가: admonition 글자가 작다 → CSS .8rem(본문 동일)로 확대.
- 49슬롯 전부 3병렬 배치 + 인박스 변환 스크립트로 재구성. §7-7 개정(박스 안 코드블록은 §2-5 top-level의 유일한 admonition 예외, 박스 단계 문장은 합니다체).
- **scaffold-lint 버그 2건 수정**: parse_fence가 들여쓴 닫는 펜스를 인식 못 해 다음 절까지 삼키던 것(오탐 4건 유발), 인박스 뼈대 본문 디덴트로 클래스명 검사 유지. style-lint 펜스 인식도 들여쓴 펜스 포함.
- 12챕터 두 lint 0건, 배포 완료(admonition 렌더·글자 크기 라이브 확인).

## [2026-07-03] style | 직접 해보기 49슬롯 콜아웃 박스화 (`!!! example "실습 위치·실행"`)
- 사용자 요구 "파일·실행 안내를 박스에 넣어 잘 보이게" 반영. §7-7 직접 해보기 규칙을 admonition 콜아웃 형식(4칸 들여쓴 `- **파일**:`/`- **실행**:` 라벨 행, 인라인 코드만 — §2-5 들여쓴 펜스 금지 준수)으로 개정.
- 12챕터 49슬롯 전부 변환(3병렬 배치): 과제 문장 유지, 산문에 섞여 있던 경로·package·실행 명령을 박스로 분리. 수정형 과제는 "위 파일 수정 + 실행 명령 재사용" 형태. 위키 첫 admonition 도입(mkdocs admonition 확장 기활성 확인).
- 전 파일 scaffold-lint·style-lint 통과, HTML 렌더에서 admonition 박스 생성 확인.

## [2026-07-03] feat | 교재 자족화 — 배너·저장소명 제거 + 직접 해보기 49슬롯 보강 + 단 어긋남 수정
- 사용자 결정 "day_by_spring 공개 없이 수업 진행, 직접 만드는 레파지토리 권장" 확정 반영:
  - **Notion 계보 배너 제거**: 12챕터 상단 `> 📘 [[src-java-study-2024-2025]] 원본 교재 본문…` 라인 전부 삭제 (frontmatter sources 추적층은 유지).
  - **저장소명 일반화 42곳**: `day_by_spring`·`day-by-java`를 "실무 저장소" 등으로 일반화(교육 내용 유지, 이름만 제거). ch01 "이번 원고에서 참고하는 저장소" 섹션을 **"이 교재의 실습 프로젝트"**(1.2 Java 프로젝트 + 6.1 Spring demo, 직접 만든 저장소로 처음부터 끝까지)로 재작성. 잔존 grep 0.
- 사용자 지적 2건 수정:
  - **단 어긋남**: 글머리 줄과 코드펜스 사이 빈 줄 누락으로 펜스가 리스트에 흡수돼 들여쓰기 렌더되던 것(ch02 산술 연산자 등 31곳) 빈 줄 삽입으로 풀 와이드 정상화. scaffold-lint 규칙 ⑤로 재발 방지.
  - **직접 해보기 실습 안내 부재**: 49슬롯 중 파일·실행 안내가 2개뿐이었음 → §7-7에 "✏️ 직접 해보기도 실습 안내 필수" 명문화 후 3병렬 배치로 49슬롯 전부 보강(작업 위치 — 본문 예제 파일 수정 또는 `com.example.chNN.practice` 경로 제안 — + 실행 명령).
- 11챕터+src 전부 scaffold-lint·style-lint 위반 0건, 빌드 통과.

## [2026-07-03] feat | 실습 스캐폴드 Phase C+D — 11개 챕터 4요소 부착 + 실측 검증 완료
- [[plan-practice-scaffold]] 프롬프트 B(배치 3개+ch08·10)·C(컴파일 스모크)·D(적대적 검수) 전부 실행. **11개 챕터 전체 scaffold-lint·style-lint 위반 0건** 달성.
- **Phase C** (챕터별 병렬 에이전트): ch02 예제 23개 부착+Main 18개 개명+클래스명 충돌 해소 / ch03 전면 실행형화(Demo 10개 신설, javac 실측으로 예상 결과 대조) / ch04 8패턴 실습화(Spring 3패턴은 demo 배치) / ch05 컴파일 실패 버그 수정+리드인 30개+의존성 블록 / ch06 demo 승격(yml 리드인 7개, day_by_spring 참고 격하) / ch07 "7.4-1 Querydsl 실습 환경" 신설(엔티티 5·QuerydslConfig·스캐폴드 14파일, LoanRepository 이중 정의 통합) / ch09 package 누락 보완 / ch01 Hello 단일 파일 실습화 / ch11 §11.23 빌드·실행 신설 / ch08·10 전제 문구 정리.
- **Phase D 스모크**(실제 Maven 프로젝트에 문서 그대로 생성·실행, 20체크): 예제 코드 17건 문자 단위 일치. 치명 2건 발견 — ① ch01 archetype pom이 1.7 고정이라 Java 21에서 `mvn compile`부터 실패(Core 실습 전체 차단) ② ch07 Q타입 미생성(Boot 4.x는 Lombok annotationProcessorPaths 명시로 프로세서 자동 발견이 꺼짐). ch09 `./mvnw`(래퍼 없음) 오용, ch05 샘플 데이터 부재도 발견.
- **Phase D 적대적 검수**: lint 사각지대(4요소 중 실행명령·예상결과 미검사)를 짚음 — ch05 Excel 11·JSON 10 예제 실행명령·예상결과 누락, 참고 코드 라벨 누락 8곳, ch11 MemoryMonitor 리드인 누락.
- **수정 라운드**(3병렬): 전부 반영. scaffold-lint에 규칙 ④(java 리드인 있는 h2 절에 실행 bash·예상 결과 요구) 보강 + `./mvnw`가 `\b`에 안 걸리던 정규식 버그 수정. ch05는 25개 예제 전량 실측 — 실측 중 **실제 코드 버그 2건 추가 발견·수정**(5.8-1 BufferedReader 3-pass, JSON 풀이 Jackson getter 6클래스).
- 커밋: Phase C 10개 + 수정 라운드 4개. 파일별 개별 커밋, 매 단계 빌드 통과.

## [2026-07-03] feat | 실습 스캐폴드 Phase B — §7-7 명문화 + scaffold-lint.sh 게이트
- [[plan-practice-scaffold]] 프롬프트 A 실행. guide-wiki-authoring-standards에 **§7-7 실습 스캐폴드** 신설: 스니펫/실습 예제 구분 원칙, 4요소(파일 리드인·package·한 블록=한 파일·실행 명령+예상 결과), 챕터→프로젝트 매핑 표, `public class Main` 금지(→`<주제>Demo`), 실행 명령 표준형(Maven 우선), **자족성 규칙**(실습 절 끝 "자주 나는 에러→원인" 부기 — 사용자: "GitHub 안 보더라도 문서만으로 막힘 복구").
- `scripts/scaffold-lint.sh` 신작(bash+python3) — ① 파일 리드인(`**파일**:`·`**파일명 N:**`·`파일명:` 3형식)↔package↔public 클래스명 정합 ② 리드인 블록의 다중 public 타입 ③ `public class Main` 전역 검사.
- 캘리브레이션: ch02 Main 18건·ch05 파일명/package 불일치 3건(L1448·L1830) 정확 검출, ch06·ch09 오탐 0. ch01·ch11의 Main 각 1건은 Phase C 수정 대상.
- CLAUDE.md 셀프체크에 scaffold-lint 항목 추가. **day_by_spring 공개는 보류**(사용자 결정) — 시크릿 스캔 결과(실유출 0, Supabase 호스트 1건 플레이스홀더 교체 필요)는 계획 페이지에 기록, 공개 시 커밋 1개+URL 1줄이면 전환 가능.
- 다음: Phase C 배치 1 (ch02·ch04·ch09).

## [2026-07-03] plan | 실습 스캐폴드 계획 신설 (예제마다 경로·패키지·실행명령)
- 사용자 피드백: "실제로 따라 해보니 클래스명부터 고민 — 어느 프로젝트 어느 경로에 어떤 파일, 패키지 구분, 실행 명령까지 딱 제공해야 실습하기 좋다."
- 에이전트 2병렬 진단(ch01~05/ch06~11): 완결 실습 예제 약 76개 중 **경로·package·실행명령 3요소를 모두 갖춘 것 3~4개(ch05 소켓·JDBC)뿐**. ch02는 드라이버 19개 전부 `Main`(충돌)+한 블록 다중 public(컴파일 불가), ch05는 따라 하면 컴파일 실패하는 버그(파일명↔클래스명·package 불일치), ch06은 6.1 demo↔day_by_spring 프로젝트 가정 단절, ch07은 넣을 프로젝트 자체 불명. 모범: ch11 §11.23·ch09 §9.2.
- 사용자 결정 4건: ① Spring 실습 자족형(6.1 demo 승격, day_by_spring은 private라 참고 격하 — 공개 시 URL 한 줄 추가로 전환 가능) ② ch07 실습 가능화(Querydsl 환경 절 신설) ③ ch03 전면 실행형화 ④ Core는 ch01 1.2 프로젝트 승계+`com.example.chNN`.
- [[plan-practice-scaffold]] 신설: §7-7 표준안(스니펫/실습 예제 구분, 4요소, 프로젝트 매핑, Main 금지→`<주제>Demo`) + scripts/scaffold-lint.sh 설계 + 프롬프트 A~D(구축/챕터 루프/컴파일 스모크/적대적 검수) + 배치 계획. nav·index 등록. 메모리(wiki-editing-preferences)에도 기록.

## [2026-07-02] feat | §7 문체 표준 개정 — guide-*/concept-*/entity-* 58개 파일 합니다체 통일 + 배포
- 사용자 지적: `guide-java-learning-path` 등 guide-* 페이지가 §7 기준(한다체)대로 쓰였는데도 "군대식"으로 딱딱하게 읽힘. 짧게 끊어지는 문장("다진다. 끝낸다.")과 지시조 표현("건너뛰지 말고 따라간다")이 브리핑체처럼 느껴진다는 지적이 정확했음.
- **§7-1 개정**: guide-*뿐 아니라 concept-*·entity-*(독자가 읽는 콘텐츠 페이지 전체)도 합니다체로 통일(기존엔 챕터만 합니다체, 나머지는 한다체). `backlog.md`·`plan-tone-consistency.md` 같은 저자 전용 운영 메모(type: synthesis)는 예외로 명시. 표준 문서 자체(guide-wiki-authoring-standards.md)도 전면 정합.
- `scripts/style-lint.sh`의 평어체 검사 대상을 `guide-*`/`concept-*`/`entity-*`로 확장.
- **58개 파일 병렬 배치 전환**(guide 15+concept 17+entity 15+표준문서 1, 8개씩 배치): 한다체·명사형 종결("~함.", "~음.")을 합니다체 완결 문장으로. 비유·설명용 blockquote도 예외 없이 전환(lecture-*만 개조식 예외 유지), 실제 외부 원문 인용은 원문 언어 그대로 보존. 코드블록·표·체크리스트·frontmatter는 불변.
- 후속 보완: "폴더"→"디렉터리" 잔여 3건, guide-loop-engineering-demo의 비-코드 하라체 지시문 1건, guide-java-book-study-lab 체크리스트 서술형→의문형 통일.
- **최종 검증**: 챕터 6개 + guide/concept/entity 58개, 총 64개 파일 style-lint 위반 0건(표준 문서 자체의 자기참조 3건 제외 — 금지어를 규칙표에서 예시로 인용하는 의도된 표기). 커밋 4개(§7 개정+게이트 확장, guide 15, concept 17, entity 15).
- 빌드·push·Firebase 배포 완료(`wiki.wonslab.dev`), 라이브 반영 확인.

## [2026-07-02] feat | 톤앤매너 정합 Phase 5(후속) — 범위 밖 REJECT 3건 + ch07 잔여 17건 마감
- 적대적 검수(Phase 4)에서 편집 범위 밖으로 판명된 4월 구본문 문체 섬 3건을 프롬프트 B 패턴으로 이어서 처리: ch01 `[참고 1] Java와 OS의 관계 및 C/C++과의 비교`(개조식→합니다체), ch05 `5.8 파일 처리 실전문제 1`(개조식+구어체 "하시오~!"→합니다체), ch07 잔여 style-lint 위반 17건(Querydsl 7.5~7.9의 예상 결과 펜스 직후 단독 평어체 4건·서비스 계층 나열 문체 섬 2건·곡선따옴표 4건·용어 등).
- **원노트 파편 처리 사용자 결정**: ch07 L507-520("게시판.", "블로그." 등 명사형 단편)을 "완결 문장 목록으로 정리" 선택 → "### 추가로 설계해볼 수 있는 시나리오 아이디어" 불릿 목록(합니다체)으로 재작성, "도스 커맨드"→"도스 명령" 용어도 함께 정리.
- 3파일 병렬 에이전트 실행(ch07은 5사이클 여유, 나머지는 3사이클) → 전부 1사이클 내 style-lint 통과. 커밋 3개(ch01·ch05·ch07 개별).
- **결과: java-study-ch01·05·06·07·08·09 6개 파일 전체 style-lint 위반 0건.** [[plan-tone-consistency]] Phase 1~5 전 단계 완료, 배포만 남음(사용자 결정 대기).

## [2026-07-02] feat | 톤앤매너 정합 Phase 3+4 — ch01·05·06·07·08·09 정합 + 적대적 검수
- [[plan-tone-consistency]] 프롬프트 B×6 + C 실행. 배치1(ch01/05/06)·배치2(ch07/08/09) 각 3파일 병렬 에이전트로 §7 문체 표준 정합 — 경어 산문 속 평어체 섬 제거, 라벨형 성공 문구(성공 판정:/성공:/성공 출력:)를 예상 결과 펜스·완결 문장으로 교체, 금칙 용어(커맨드→명령·폴더/디렉토리→디렉터리) 정리.
- **ch07**: 표 구조 4건 정정(표6 헤더 대소문자·제약조건 열에 값 예시 혼입·표18~20 인덱스 행을 표 아래 부기로 이동). 원노트 파편(L507-520)은 지시대로 보존.
- **ch08**: 8.0/8.3 실습 섹션 평어→합니다체, "성공 판정:" 라벨 제거.
- **ch09**: 9.1/9.2/9.3 문체 정합 + Maven/Gradle 예시 순서를 ch08 관례에 맞춰 Maven 우선으로 통일 + `/api/admin/**` 코드스팬과 충돌해 문장 끝까지 깨지던 볼드 마커 렌더 결함 수정.
- 각 배치 후 공유 자원 충돌 방지를 위해 build-site.sh·git commit은 오케스트레이터가 일괄 실행(에이전트는 style-lint.sh만 사용). 파일별 개별 커밋 6개.
- **적대적 검수(프롬프트 C)**: REJECT 4건 중 편집 범위(이번 최근 변경분) 내 2건 확인 후 즉시 수정 — ch05 5.6 classpath 구분자 OS분기(중복 코드블록 2개→트레일링 주석 1블록 병합), ch09 9.1 OS분기 형식 통일 + ✏️ 직접 해보기의 "초록불" 금칙 은유·"돌리다" 금칙어 제거. 범위 밖 REJECT 2건(ch01 [참고 1], ch05 5.8, ch07 Querydsl 7.5~7.9 — 전부 4월 ingest 구본문)은 backlog로 이관.
- 커밋 총 9개(§7+게이트 1 + 정합 6 + 검수반영 1 + 이 기록). 매 단계 style-lint·build-site.sh 통과 확인. **배포는 미실행** — 사용자 결정 대기.

## [2026-07-02] feat | 톤앤매너 정합 Phase 1+2 — §7 문체 표준 명문화 + style-lint.sh 게이트
- [[plan-tone-consistency]] 프롬프트 A 실행. guide-wiki-authoring-standards.md에 **§7 문체 표준** 신설(구 §7 표준 적용 점검은 §8로 이동): 문서군별 종결어미 매트릭스(챕터=합니다체/가이드=한다체/강의노트=개조식), 독자 지시 표준, 성공확인 문구 표준(라벨형 금지), OS 분기 3형식 용도 규정, 용어 표준, 표 규칙.
- `scripts/style-lint.sh` 신작 — 토큰 0 무료 게이트: 금칙 용어(커맨드/폴더·디렉토리)·라벨형 성공 문구·곡선따옴표·(챕터 한정) 산문 평어 종결을 grep으로 검출, 위반 시 exit 1.
- **캘리브레이션**: ch02(모범)에 돌려 오탐 0 확인(디렉토리·곡선따옴표 2건은 실제 존재하는 사소한 기존 위반, 스캐폴드·코드펜스 오탐 없음), ch08(기지 위반)에 돌려 "성공 판정:" 라벨 + 8.0/8.3 평어 섬 5건 정확 검출 확인. 라인번호 이중 계산 버그·곡선따옴표 정규식(글리프가 도구 경유 시 직선따옴표로 뭉개지는 문제, 유니코드 이스케이프로 해결) 2건 수정.
- CLAUDE.md 셀프 체크에 style-lint 통과 항목 추가. 빌드 통과.
- 다음: Phase 3 — 프롬프트 B로 ch01·05·06·07·08·09 파일 정합 루프 실행.

## [2026-07-02] plan | 톤앤매너 정합 계획 신설 (문체 표준 + 검증 루프)
- 에이전트 3병렬 진단: 최근 보강분(ch01·05·06·07·08·09)의 신설 실습 섹션이 전부 평어체(~한다)인데 기존 본문은 경어체(~합니다) — 한 소절 안에서 문체가 꺾이는 최고 심각도 불일치. 그 외 성공 확인 라벨 4종 혼재, OS 분기 표기 3형식, Maven/Gradle 1차 도구 반대(ch08↔09), 용어 흔들림(커맨드/명령·폴더/디렉터리/디렉토리), ch09 볼드 미종결 렌더 결함, ch07 표 6·18~20 구조 이탈.
- 근본 원인: 실질 문체 규칙(종결어미·지시형·성공확인·OS분기)이 authoring-standards에 명문화 안 됨 — 개별 문서(ch02·module1·object-ch6)에 사실상 표준으로만 존재.
- [[plan-tone-consistency]] 신설: 문체 정책(문서군별 표준 유지 — 챕터 산문 합니다체, 스캐폴드 슬롯 평어) + 3층 실행 구조(§7 명문화 → scripts/style-lint.sh 무료 게이트 → 파일 단위 정합 루프) + 업무지시 프롬프트 A(시스템 구축)/B(파일 루프, 종료조건 3종)/C(적대적 검수).
- nav(위키·지식관리>환경설정)·index 등록.

## [2026-07-02] fix | ch07 빈 스키마 표 복구 (Notion 표 블록 변환 손실) + 중복 제거
- ch07 7.0-1 "추가시나리오 예제"의 DB 스키마 표 20개가 4월 ingest 때 Notion 표 블록 변환 실패로 `<!-- table -->` 플레이스홀더로 비어 있던 것을 복구.
- 라이브 published-site API로 재수집(loadPageChunk 2청크) → **표 대응 렌더러(render_tbl) 신작**(table/table_row 블록 → 마크다운 표, 첫 행=헤더, `plain text`→`text` 보정) → 20표 렌더.
- cluster A 20 placeholder에 순서대로 채움 + **시나리오 1 중복판(cluster B) 제거**(4월 ingest 중복 버그). 시나리오 2~5 설계 프롬프트는 유지.
- 검증: 위키 전체 빈 표 0, 7.0-1 마크다운 표 20개, 중복 1→해소, 펜스 짝맞음, 빌드 통과.


## [2026-07-02] feat | ch01 "첫 프로젝트 만들기" 신설 (빈약한 프로젝트 셋업 보강)
- 사용자 지적: 최초 프로젝트 생성·설정 내용이 빈약(단일 파일 Hello World에서 곧장 2장으로). 실제 프로젝트 스캐폴딩·빌드·구조·git이 없었음.
- **1.2 첫 프로젝트 만들기 (Maven·Gradle)** 신설: 왜 빌드도구 → 생성(둘 다 병기) → 표준 구조 → 빌드·실행 사이클 → 의존성(pom.xml/build.gradle) → git init+.gitignore. IDE 최소화·커맨드 중심.
- **Mac/Windows 감안**: OS 분기 3가지(래퍼 `./gradlew`↔`gradlew`, 줄바꿈 `\`는 Unix 전용→한 줄, `.gitignore` heredoc→편집기 생성) 표로 명시. 생성 명령 한 줄화로 양쪽 호환. `.gitignore` 값 옆 주석 제거(gitignore는 줄 전체 # 만 인식).
- 반영: ch01 목표·따라하는법, [[guide-java-track1-basics]] 1단계 표, src 챕터 표. 빌드·펜스 통과.


## [2026-07-02] style | 위키 콘텐츠에서 Notion(소스 도구) 언급 제거
- 사용자 지적 "Notion 자체는 언급할 필요 없다" — 소스 도구는 독자 콘텐츠에 등장할 이유 없음.
- **A 일괄(12챕터)**: `원본: Notion 데이터베이스 "..."` 구분 블록 12개 제거, frontmatter `tags`의 `notion` 12개 제거, `<!-- 라이브 Notion 수집/갱신 -->` HTML 주석 48건 제거.
- **B 판단(사용자 선택: 0.1 삭제 + ch01 유지)**: ch00 문서 `0.1 출판용 Notion 뷰 운영 가이드`(저자 운영 메모, Java 학습 무관) 147줄 삭제. ch01 "Notion 계정 준비"(학습자 노트 도구 안내)는 유지.
- **콘텐츠 페이지**: index("Notion DB"·"Notion 북마크"→제거, 91→97 정정), src-java-study(개요 "Notion 데이터베이스 기반"→제거·갱신노트 정리·0.1 참조 삭제), src-my-links(개요 "Notion 데이터베이스" 제거).
- **유지**: log/backlog(내부 작업기록), raw catalog/README(source-of-record), frontmatter `sources:` 경로. dangling(→0.1) 0, 빌드 통과.

## [2026-07-01] fix | bash 명령 정확성·복붙 안정성 점검 (에이전트 5병렬) + 수정
- 복붙 실행용 가이드 11편 + java-study 6챕터 전수 검증(대화형 혼합/포그라운드 장기실행/heredoc 따옴표/변수·cwd 의존/명령 정확성). heredoc 따옴표·exit code 등은 /tmp 실측까지.
- **🔴 module5 Step3-2 펜스 깨짐**: 바깥 ` ```bash `가 heredoc 본문 중첩 ` ``` `를 못 감싸 렌더·복사버튼 truncation → 4-backtick(Step2와 동일)으로 수정.
- **🟡 수정 7건**: ① ch10 `-Xlog:gc*`→`-Xlog:'gc*'`(zsh `no matches` 실패, 3곳) ② deploy 가이드 하드코딩 경로 `/Users/jungwonpark/...`→플레이스홀더(2곳) ③ deploy Step7 `firebase login`/`init` 대화형 3블록 분리 ④ project-docs-setup `claude` REPL 블록 ` ```bash `→` ```text `(>가 리다이렉션 오해) ⑤ prerequisites A-3 `npm create vite`를 `npm install`과 분리(1a/1b) ⑥ module3 Step1·module4 Step2/3 `cd ~/harness-playground` 추가 ⑦ module5 `find -maxdepth 2`→3(hooks 깊이3 누락).
- 검증: 편집 7파일 펜스 짝맞음, 빌드 통과. (loop-demo·module1~2·java-book-lab은 이상 없음 — heredoc 리터럴·유한 루프·cwd 견고 확인.)

## [2026-07-01] style | 코드·표 표시 통일 — "글머리에서 빼낸다(top-level)" 명문화
- 전수 스캔: 위키 코드펜스 3166개 중 **글머리 종속(들여쓴) 6개뿐**(concept-spring-core 4·guide-harness-module5 2), 표·bash 블록은 들여쓴 것 0. 이미 99.8% top-level.
- 사용자 결정 "전부 top-level". 규칙 [[guide-wiki-authoring-standards]] §2-5 명문화: 코드·표는 항상 좌측정렬, 리스트 항목에 코드 딸리면 **`**1) …**` 굵은 리드인으로 바꿔** 빼냄(번호 안 깨짐)·표는 예외 없음.
- 어긋난 6개 정규화: concept-spring-core 해결책 3가지를 번호목록→굵은 리드인+top-level 코드, module5 guard.sh 로그 스니펫 de-dent. bash 블록 160개 전부 top-level 확인. 빌드·펜스 짝 통과.

## [2026-07-01] fix | Java 챕터 내부 문서번호 학습순 통일 (Notion 원번호 폐기)
- 다른 PC의 챕터 회전(입출력 ch10→05 등) 후 **챕터 파일번호 ↔ 내부 문서번호 불일치**(ch05인데 docs 10.x). 사용자 결정 "Notion 원번호 안 맞춰도 됨" → 내부 번호를 챕터(학습순)에 맞춰 통일.
- 회전 매핑(cycle) **10→5,5→6,6→7,7→8,8→9,9→10** 단일패스 동시치환. 적용: h2 문서헤딩(`## X.Y`)·`(→ X.Y)` 참조·레슨 "따라하는법"·트랙표/cross-ref. **제외**: 코드펜스 안, h3+ 헤딩(`##### 7.1` 등 doc 내부 지역 소제목), ch00 "책 순번 예시". 총 119토큰.
- 검증: 12챕터 전부 파일번호=내부prefix 일치, h5 지역번호·ch00 예시 보존, `(→ N.N)` 고아참조 0, 코드펜스 짝맞음, 빌드 통과.
- **raw 챕터 본문도 동일 적용**(사용자 요청 "맞춰줘", 42토큰) — raw는 (→)·레슨 없어 전부 헤딩. 파일번호=내부번호 일치, h5·ch00 보존. (raw는 미게시라 빌드 무관. 카탈로그·README는 Notion 원번호 문서라 유지.)

## [2026-06-30] refactor | Java·Spring nav — 학습 vs 레퍼런스 역할 분리
- **배경**: 외부 AI 지적 잔여 항목 — "개념·도구·생태계 메뉴가 챕터(3단계)와 역할 중첩". 실제 원인은 학습(경로·3단계·트랙)과 레퍼런스(개념·도구·소스)가 nav 같은 레벨에 평면 나열돼 역할이 안 드러난 것.
- **정리**: 레퍼런스 3종(개념·도구·생태계·원본 소스)을 **「📚 레퍼런스 (필요할 때 찾아보기)」 그룹**으로 묶어 학습 섹션과 분리. "개념 → 개념 — 심화 주제", "소스 → 원본 소스"로 라벨 명확화.
- **learning-path**: "챕터(학습 흐름) vs 레퍼런스(심화 자료)는 겹치는 게 아니라 배우기→깊이 파기로 이어진다" 콜아웃 추가(콘텐츠 차원 역할 구분).
- 빌드 통과.

## [2026-06-30] refactor | Java 스터디 챕터 번호 학습순 재부여 (raw + wiki)
- **배경**: 3단계 재편 후에도 파일 번호(chNN)가 원본 교재 순이라 "입출력=ch10이 Core 1단계"처럼 번호와 학습순서가 어긋남. 사용자가 raw도 손볼 것을 지시("불변 아님").
- **회전 재부여**: 입출력 ch10→ch05, Spring 5→6, SQL 6→7, 인증 7→8, 테스트 8→9, JVM 9→10 (ch00~04·ch11 유지). 결과 **번호=학습순서**, "다음 장" 체인이 ch00→01→…→11 자연 순서.
- **범위**: raw 6편 + wiki 6편 **파일명 git mv**(회전, 임시 경유) + 19개 파일 내용 회전 치환(`java-study-chNN` 링크·sources·tags·mkdocs nav). zsh 단어분리 함정으로 `while read`·명시 치환 사용.
- **자연어 장번호**: 본문 "원본 교재 N장 본문" → "원본 교재 본문"(주제로 식별). **Notion 원본 장번호는 `raw/java-study/README.md` 매핑표로 보존**(ch05=원본10장 등).
- **검증**: 깨진 [[chNN]] 링크 0, chTMP/임시파일 잔재 0, 12개 페이지 빌드 통과.

## [2026-06-30] refactor | Java 스터디 — 3단계 로드맵 재편 (Core→Spring→고급)
- **배경**: 사용자 지적(+외부 AI 분석) — Java·Spring nav가 "일관성 없고 유기적이지 않다". 검증 결과 진짜 원인은 **챕터 번호순 나열 vs 학습경로 T1~T5가 서로 다른 두 순서를 주장**(외부 AI는 nav만 보고 절반만 진단). 입출력(ch10)이 9 뒤에 와서 비유기적인 것도 트랙은 이미 T3로 Spring 앞에 뒀으나 본문 nav가 안 보여줌.
- **결정**: 3단계(Core/Spring/고급) 재편 (사용자 선택). 절대번호 1~11 의존 제거, 파일명 chNN은 내부 유지(리넘버링 안 함 = 링크 안정).
- **3단계 매핑**: 1단계 Java Core(ch00·01·02·03·04 + **ch10 입출력 전진**) / 2단계 Spring & 웹(ch05·06·07) / 3단계 고급·품질(ch08·09·11).
- **nav 재편** (mkdocs.yml): 챕터 본문을 3단계 그룹으로, 트랙 T1~T5는 "학습 코스(미니프로젝트 동선)"로 역할 분리(중첩 해소). nav 라벨에서 절대번호 제거.
- **챕터 11편** (에이전트 3병렬): title·H1 절대번호 제거+띄어쓰기 교정, 상단 메타를 `**단계** · **앞 장** · **다음 장**`으로 교체. **"다음 장" 체인을 학습 순서로 재배선**: ch00→01→02→03→04→**10**→**05**→06→07→**08**→09→11. (raw 원본 장번호 언급은 유지.)
- **학습경로 허브** (guide-java-learning-path): 5트랙 표 → **3단계 로드맵**으로 재작성 + 트랙↔단계 매핑 매트릭스(T2·T4가 두 단계 걸치는 이유 명시).
- 빌드 통과, 체인 무결성(앞/다음 양방향 일치) 확인, `**트랙**` 잔재 0.

## [2026-06-29] fix | 변환 아티팩트 정리 + 한글 URL 정책 위반 교정
- **변환 아티팩트(사용자 지적 "내용 깨짐")**: Notion "Plain Text" 코드블록이 `` ```plain text ``(공백 든 무효 info string)로 변환돼 렌더 깨짐 — 4월 ingest 본문에도 다수. 전 챕터 일괄 정상화 **134건**: `` ```plain text ``→`` ```text ``, `c++`→`cpp`, `docker`→`dockerfile`. (산문이 코드박스에 든 건 Notion 원저작 선택이라 펜스만 정상화.)
- **한글 URL 정책 위반**: 챕터 페이지 파일명이 한글(`java-study-ch11-부록.md` → URL `/java-study-ch11-부록/`)이라 정책 위반. **12개 파일명에서 한글 제거**(`java-study-chNN.md`) + 모든 `[[wikilink]]`·mkdocs nav 경로 갱신(`git mv`). frontmatter `sources:`의 raw 경로는 raw 파일명이 한글이라 유지(raw는 URL 아님). nav 표시 라벨은 한글 유지(URL만 영문).
- 빌드 통과, 영문 URL 12개 생성, 한글 URL 디렉터리 0, 깨진 링크 0. (페이지 내 앵커는 한글 헤딩 자동 생성이라 한글 — 본문이 한국어라 불가피.)
- **추가 전수 점검(다른 챕터 깨짐)**: notion.so 내부 링크 **65건**(독자에겐 비공개 Notion 빠짐) → blockid→seq 매핑으로 `텍스트 (→ N.N)` 변환(62 일반 + 중첩 깨진 링크 3건). 그 외 점검: 본문 끼어든 `##`은 ` ```markdown ` 코드블록 안 예시(정상), 빈 코드펜스 0, `**` 불균형은 전부 코드 내(`/**`·URL 패턴)라 오탐, 표 깨짐 없음. → java-study 변환 아티팩트 정리 완료.

## [2026-06-29] feat | Java 챕터 본문 갱신후보 38개 라이브 최신본으로 교체
- 전수 감사(라이브 97개 수집 → 위키 본문 글자수 대조): 4월 ingest가 **다수 문서를 축약본(stub)으로만** 가져왔음이 드러남(예: 10.8-2 위키 159자 vs 라이브 8144자, 11.x 다수 100~200자 → 1500자+). 라이브가 30%+·300자+ 큰 **38개 문서**를 증보후보로 식별.
- 38개 본문을 라이브 Notion 최신본(render.py로 코드블록·헤더 보존 렌더)으로 교체. **🎯목표·✏️직접해보기 스캐폴드는 보존**(heading+목표 유지, 본문만 교체, 직접해보기 재부착). 갱신 마커 주석 삽입.
- 전 챕터 코드펜스 짝맞음, 빌드 통과. 6.1(24→92줄)·10.8-2 등 stub이 전체 내용으로 채워짐.
- 비고: 라이브와 거의 같던 문서(2.0·9.0 등)는 4월본 유지(불필요 교체 회피). raw 챕터 파일은 4월 스냅샷 유지(위키가 게시 제품).

## [2026-06-29] feat | Java 챕터 레슨 형식 전체 통일 (96문서)
- ch02 모델 확정 후 나머지 11개 챕터로 확장. **96개 문서 전체에 🎯 목표** 추가(제목·주제 맞춤 한 줄), 개념·가이드 문서 **50개에 ✏️ 직접 해보기**(작은 실습 과제) 추가. 문제/실습/풀이/PJ 문서는 목표만.
- 형식: `## N.N` → 🎯 목표 → 개요 → 본문(개념·코드) → ✏️ 직접 해보기 → 정리. 본인 산문은 그대로, 스캐폴드만 보강.
- 스펙 커버리지 누락 0, 전 챕터 코드펜스 짝맞음, 빌드 통과. 학습자가 각 문서를 "목표 보고 → 따라 하고 → 직접 해보는" 일관된 흐름으로 학습 가능.

## [2026-06-29] fix | Java 챕터 본문 — 문서 순번 정렬
- 챕터 내 문서가 순번과 무관하게 배치돼 있던 것(원본 4월 배치 + 신규 10개가 끝에 append)을 **책 순번(N.N) 오름차순으로 정렬**. 7개 챕터 재정렬(ch01·02·05·06·08·10·11), 5개는 이미 정렬.
- 안전장치: 문서 경계는 "seq(N.N)로 매핑되는 `## ` 헤딩"만으로 판정(본문 내부 `## 기능개요` 등 렌더 소제목·`## [참고 1]`은 카탈로그 title→seq 매핑). **12개 파일 라인 수 before=after 검증(내용 보존, 순서만 변경)**, 코드펜스 짝맞음, 빌드 통과.

## [2026-06-29] fix | Java 학습 경로 — 독자(학습자) 맞춤 재정비 (챕터=레슨, 트랙=코스안내)
- **문제 인지**(사용자 지적): 트랙 페이지가 얇은 지도(요약+팁)에 그치고, 본문을 게시 안 되는 `raw/...` 경로로만 가리켜(트랙→챕터 링크 0건) 학습자가 따라 할 수 없었음. 독자 재정의: "따라 하며 배우는 초중급 학습자".
- **결정**(A안): **챕터 본문=레슨(따라 하는 본체), 트랙=코스 안내**.
- **챕터 12개에 레슨 헤더 삽입**: H1 직후에 `🎯 이 장에서 배우는 것`(목표 3~4) + 트랙·다음 장 링크 + `따라 하는 법`. 각 챕터가 목표→본문(개념·코드)→실습으로 읽히도록.
- **트랙 5개 코스 안내로 전환**: 모든 `raw/...` 참조(11곳) 제거 → 게시된 챕터 레슨 위키 링크([[java-study-chNN]])로 교체. "이 페이지는 코스 안내, 실제 학습은 챕터 레슨에서" framing 추가. 트랙→챕터 링크 0→11.
- 빌드 통과(깨진 링크 0). 이제 학습자 동선: 트랙(흐름·미니프로젝트·이론팁) → 챕터 레슨(목표·코드·실습) 연결.

## [2026-06-29] feat | Java 스터디 챕터 본문 12개 위키 게시
- 그동안 raw에만 있던 챕터 본문(12개, ~13k줄)을 위키 페이지로 게시 — frontmatter(type:source, sources:java-study/<file>) + 원본/학습경로 백링크 prepend. 파일명은 raw와 동일(`java-study-chNN-*.md`).
- mkdocs nav `Java·Spring → Java 스터디 — 챕터 본문` 12항목 추가. src-java-study에 챕터 본문 직접 링크([[java-study-ch00~11]]) 안내 추가.
- 빌드 통과(12개 챕터 HTML, 3.8초). 이제 구독자가 트랙 가이드(흐름)→챕터 본문(전문) 양쪽 열람 가능.

## [2026-06-29] feat | Java 학습 경로 T2~T5 + 전체 지도 허브 완성
- T1 톤 확정 후 동일 템플릿으로 나머지 트랙 일괄 작성(구독자 흐름: 개요→학습순서→핵심개념→💡이론·방법론 팁+상세링크→🛠미니프로젝트→정리):
  - **T2 객체지향 설계로 응용**(ch4 패턴8종+ch9 JVM, 🛠전략패턴 리팩터링) — [[guide-java-track2-design]]
  - **T3 입출력과 네트워크**(ch10 예외/파일/네트워크, 🛠파일처리 시스템) — [[guide-java-track3-io-network]]
  - **T4 Spring 웹 애플리케이션**(ch5~8, 🛠도서 주문·대여 시스템) — [[guide-java-track4-spring-web]]
  - **T5 심화·워크북·종합**(ch11 부록+9 워크북, 🛠종합 토이프로젝트) — [[guide-java-track5-deep-dive]]
  - **전체 지도 허브** — [[guide-java-learning-path]] (5트랙 표·흐름도·특징)
- 각 트랙 💡팁이 5권 강의(오브젝트·EJ·리팩터링·CleanCode·TDD)·concept 페이지로 "자세히 →" 연결, 미니프로젝트 풀이는 raw 경로 명시. mkdocs nav "학습 경로" 6항목, index.md Guides 등재. 빌드 통과(트랙 간 링크 전부 해결).

## [2026-06-29] feat | Java 스터디 재구성 0단계(raw 최신화) + T1 트랙 시범 + 브랜드 통일
- **Notion DB 직접 수집**: `[2024-2025] java 스터디 자료`(`goodjwon.notion.site`)를 published-site API(loadPageChunk+queryCollection, curl)로 접근 — MCP 없이 97개 문서 추출. (기존 본문 12챕터는 4월 ingest로 이미 raw 보유, 위키 src 1장으로 등록돼 있었음.)
- **0단계 raw 최신화**: 4월 이후 추가된 **신규 10개**(전략패턴 실전문제·메모앱 토이프로젝트·JVM 워크북·도서주문/대여 시나리오·레거시 실습 등)를 Notion→md 렌더러(코드펜스·헤더·링크 보존)로 변환해 해당 챕터 raw에 반영. 신규 산출물: `java-study-notion-db-catalog.md`(97행 목차), `java-study-refresh-checklist.md`(보유87/수집10/갱신후보 6.1·8.0). 위키 `src-java-study-2024-2025` 91→**97** 갱신.
- **T1 트랙 시범**(B안): `guide-java-track1-basics.md` 신설 — 구독자 학습 흐름(개요→학습순서→핵심개념→💡이론·방법론 팁+상세링크→🛠미니프로젝트→정리). 5권 강의/concept 페이지 재활용 연결. mkdocs nav "학습 경로" 섹션 신설. T2~T5는 톤 합의 후 동일 템플릿 확장 예정.
- **브랜드 통일**: 사이트 실명 노출 제거 — `mkdocs.yml` site_author/description `JungWon Park`·`박정원`→**`wonslab`**, wiki 4편(src/concept-loop·deploy 가이드 예시·clean-code 예시주석)도 일반표현/placeholder로. raw 원본은 출처보존상 유지(미게시).

## [2026-06-29] verify | Loop 실습 후속 3종 종결 (실행검증·1차출처·토큰심화)
- **① 실행 검증** (Node v26, scratchpad에서 가이드와 동일 파일로 실측): 후보 (A)·(B) 실패·(C)만 통과(결정적 확인), Step 2 메아리방 20회 중 13회(≈2/3) 깨진 채 "완료" 종료, Step 4 검증 루프 통과 시 정상 종료, "드물게 약 4%"=이론 (2/3)⁸=3.9% 정확. → [[guide-loop-engineering-demo]] 상단에 "✅ 실행 검증됨(2026-06-29, Node v26)" 노트 추가. Step 6(claude -p)은 토큰 소요로 미실행, 구문은 공식 헤드리스 docs 기준.
- **② 1차 출처 검증·보존** (리서치 에이전트 WebSearch/WebFetch): `raw/loop-engineering/primary-sources.md` 신설(원본 2차 정리본은 보존). 교정 — Steinberger "650만 조회·06-08"은 **2차 매체 주장(X 원본 402 미검증)**, 소속 **OpenAI**(Anthropic 아님), Cherny 자구("write loops"/"write the loop")·날짜(게시 06-02/에피소드 미확정) 매체별 편차, **Osmani(✅직접확인)·Sonar(✅) verbatim 확보**, arXiv 3편 제목·저자·연도 일치. → [[src-loop-engineering]] 발화표(출처 검증 열 추가)·신중론(검증 인용)·외부 1차 출처 표 반영, frontmatter sources/external 갱신.
- **③ 토큰 비용 심화**: demo에 "Step 6.5 토큰 비용 심화" 신설 — 봉투뒷면 비용모델(컨텍스트·사이클·서브에이전트), "무료 결정적 게이트를 모델 앞에 두기"(거부 신호=토큰 절약 장치) 코드 패턴, 종료조건 3종(goal·resource·**budget**). Osmani "Verification is still on you"·Sonar "fails quietly" 검증 인용.
- 메모리 `loop-engineering-demo-progress` 후속 종결로 갱신. 빌드 통과.

## [2026-06-29] fix | Module 4 AGENTS.md 개념 정정 + harness 경미건 일괄
- **Module 4 사실성 (3순위)**: "AGENTS.md를 (Claude Code가) 공통 자동 로드 / 충돌 시 우선순위"가 엔진 동작인 듯한 서술 → 공식 사양("Claude Code는 CLAUDE.md만 자동 로드, AGENTS.md는 아님")에 맞춰 정정. Step 1 도입에 ⚠️ 박스 추가(자동 로드 안 됨 → 프롬프트 명시 읽기로 동작 / `@AGENTS.md` import·심링크·`/init` 워크어라운드 3종), heredoc 자기소개 문구도 "자동 로드 안 함" 명시로 수정. FAQ에 `/clear` 경량 초기화 + 네이티브 서브에이전트(`.claude/agents/`+`/agents`) 대안 항목 신설.
- **경미건 일괄**:
  - **시작 경로 `cd ~/harness-playground`**: M2 Step 1(+"본인 프로젝트 루트"→"실습 프로젝트(`~/harness-playground`)" 명확화)·M4 Step 1·M5 Step 1 bash 블록 첫 줄에 추가 — 새 터미널서 엉뚱한 위치 파일 생성 방지.
  - **M5 Step 2 README 중첩 펜스**: 바깥 ` ```bash `를 4-backtick(` ````bash `)으로 바꿔 heredoc 본문의 ` ``` `(온보딩 코드블록)가 마크다운 펜스를 조기 종료하던 문제 해소(펜스 88/120 균형 확인).
  - **M1 산출물 표 커밋명**: 영문 가상 `harness: add module1 baseline` → 실제 `harness(M1): 베이스라인 측정 결과 저장` + `baseline(M1-A/B/C)`.
- **검증**: 빌드 통과, 4-backtick 1쌍, M2/4/5 cd 각 1건. frontmatter `updated` 2026-06-29(M1·M4 포함).
- **harness 검증 후속 종결**: 🔴/🟡 전부 반영 완료(Module 3 hooks·M1↔M5 비교·M4 AGENTS.md·경미건). 남은 건 없음.

## [2026-06-29] fix | M1↔M5 Before/After 비교 정합 (Module 2·5 태스크 A)
- **배경**: 검증에서 M2·M5의 태스크 A 재실행 프롬프트가 M1 원문과 달라("표현 그대로"라 단언하나 web/ 누락, api만) Before/After가 apples-to-apples가 아니었음. 측정표엔 in-memory playground에 없는 "마이그레이션 처리" 행이 유입되고 M1의 "화면 작동 확인"·Zod 항목은 누락.
- **수정**:
  - **M2 Step 5-3 / M5 Step 5-1 프롬프트**: M1 태스크 A 본문(`이 모노레포에 User에…` api/+web/ 모노레포)을 **표현 그대로** 복원. 유일한 의도적 차이는 M2의 CLAUDE.md 섹션 확인 지시 한 줄.
  - **측정 항목·비교표(M2·M5)**: M1 태스크 A의 7개 항목과 일치 — `내부 모델(in-memory) 노출`·`Zod 스키마 검증`·`api 테스트`·`불필요한 코드`·`메시지 횟수`·`가정 명시`·`화면 작동 확인`. 존재하지 않는 `마이그레이션 처리` 행 제거, `DB 모델 노출`→`내부 모델(in-memory)`.
  - **M5 Step 5-1 문구**: "태스크 A·B·C 재실행"이나 실제 A만 제공 → "A 하나로 확인 가능(B·C 선택)"으로 정정.
- **검증**: M1/M2/M5 3곳 프롬프트 grep 일치, 잔재(옛 프롬프트·마이그레이션 행) 0, 빌드 통과. frontmatter `updated` 2026-06-29.
- **남은 후속**: Module 4 AGENTS.md 자동로드 개념 정정(🟡), 복붙 경미건(M2·4·5 `cd` 추가·M5 중첩 펜스·M1 커밋명).

## [2026-06-29] fix | Module 3 hooks 사양 3건 교정 (wiki + raw 동시)
- **배경**: 직전 검증에서 guard.sh/lint-fix.sh가 현재 Claude Code hooks 사양과 어긋나 실습이 실제로 안 돈다고 확인. CLAUDE.md 규칙 #1 "raw 불변"이 "오류 시 수정 가능"으로 갱신돼 raw도 함께 교정.
- **3대 교정 (wiki Node판 + raw Java/Gradle판 동일 적용)**:
  - ① **차단 exit code**: `block()`/checkstyle·eslint 실패 `exit 1` → **`exit 2`** (exit 2만 Claude Code가 도구 차단; exit 1은 비차단이라 명령 그대로 실행됨).
  - ② **입력 전달**: `COMMAND="$1"`/`read` (argv 가정) → **stdin JSON을 `jq -r '.tool_input.command'`** 로 파싱. jq 없거나 평문 테스트 시 입력 전체를 명령으로 보는 fallback 추가.
  - ③ **PostToolUse 파일경로**: 존재하지 않는 `CLAUDE_TOOL_OUTPUT_FILE` 환경변수 → **`jq -r '.tool_input.file_path'`** (기존엔 항상 빈 값이라 prettier/eslint 전부 미실행이었음).
- **부수 갱신**: Step 1에 `jq` 설치 안내 추가, Step 5 차단 검증을 stdin JSON 방식(`echo '{"tool_input":...}' | bash guard.sh`)·기대 exit 2로 교체 + 검증표 갱신, FAQ 2건(eslint 멈춤·파일경로) 갱신, raw `hooks-config.json` `_docs` URL을 `code.claude.com/docs/en/hooks`로.
- **검증**: wiki 추출본·raw 양쪽 `bash -n` 통과, 차단 6건 exit 2 / 허용 3건 exit 0 / lint-fix 빈·없는 파일 exit 0 실측 확인.
- **남은 후속**(미진행): M1↔M5 비교 정합(M2·M5 태스크 A web/ 복원·마이그레이션 행 제거), Module 4 AGENTS.md 개념 설명 정정, 복붙 경미건.

## [2026-06-29] infra | sitemap.xml 자동화 확인 + robots.txt 추가
- **요청**: 콘텐츠가 늘면 빌드→Firebase 배포 시 sitemap.xml이 자동 생성되어야 함.
- **확인**: MkDocs가 빌드마다 `site/sitemap.xml`(+`.gz`)을 **이미 자동 생성** → firebase.json `public: site` 라 자동 배포. 별도 작업 불필요. 단 직전 빌드본이 옛 도메인 `wons-wiki.web.app`이었는데, `site_url`이 `wiki.wonslab.dev`로 갱신돼 있어 재빌드 시 자동 교정 확인(166 URL, `lastmod` 파일날짜 자동).
- **추가**: `wiki/robots.txt` 신설 — `Sitemap: https://wiki.wonslab.dev/sitemap.xml` 명시(크롤러 발견용). build-site.sh rsync가 wiki/→docs/→site/ 복사하므로 빌드마다 자동 배포됨. 재빌드로 `site/robots.txt` 생성 확인.

## [2026-06-29] verify | harness-module 1~5 정밀 검증 (에이전트 5병렬)
- **요청**: `wiki/guide-harness-module*` 내용 검증.
- **🔴 Module 3 hooks 사양 3건 오류(실습 미작동, raw 원본도 동일)**: ① guard.sh 차단 `exit 1`→`exit 2` ② 입력 `$1`/`read`→stdin JSON `jq -r '.tool_input.command'` ③ lint-fix.sh `CLAUDE_TOOL_OUTPUT_FILE`(없는 변수)→`jq -r '.tool_input.file_path'`. jq 설치 전제·Step5 테스트 명령도 stdin 방식으로 수정 필요.
- **🔴/🟡 M1↔M5 비교 무효화(M2·M5)**: 태스크 A 재실행 프롬프트가 M1 원문(api+web 모노레포)과 달리 web/ 누락("표현 그대로"라 단언하나 불일치). in-memory playground에 없는 "마이그레이션 처리" 측정행 유입, M1 "화면 작동 확인" 행 누락. M5는 "A·B·C 재실행"이라며 A만 제공.
- **🟡 Module 4 사실성**: AGENTS.md 자동 로드·CLAUDE.md 우선순위 주장 거짓(공식: CLAUDE.md만 자동 로드). 단 워크플로는 "AGENTS.md 읽어줘" 명시라 실동작 OK — 개념 설명만 수정 대상. `@AGENTS.md` import/심링크/`/init` 워크어라운드. 네이티브 서브에이전트(`.claude/agents/`)·`/clear` 미언급.
- **🟡 복붙/렌더**: M5 Step2 README heredoc 내 중첩 ` ``` ` 펜스로 조기 종료(4-backtick 필요), M2·4·5 시작 `cd ~/harness-playground` 누락, M1 산출물 표 커밋명 불일치.
- **✅ 견고**: 과거 $WEEK·heredoc 함정 수정 확인, 모든 wikilink·앵커·sources·nav·index 실존.
- **결론**: 수정은 미진행(검증만). 1순위 Module 3 hooks 3건(wiki+raw 동시), 2순위 M1↔M5 비교 정합.

## [2026-06-27] style | 글쓰기 스타일 일괄 점검 13편 + 도메인·카피라이트 갱신
- **글쓰기 스타일 일괄 (에이전트 13병렬)**: 백로그 1차 대상 13편의 비유 산문에서 괄호 개념 매핑 + 마침표 없는 명사구 단편을 "장면 묘사 한 문단 + 개념 매핑 한 문단" 분리 구조의 능동 완결 문장으로 재작성 (메모리 `feedback-wiki-writing-style` 규칙, ch6 "회의 vs 사람" 모범 톤).
  - lecture-object: ch4(도구 vs 사람)·ch5(공연 무대)·ch7(공장 라인 vs 자율 작업장)·ch9(콘센트 표준)·ch12(전화 한 통)·ch13(혈연 vs 자격증)·ch15(조리법→요리책→식당)·appendixA(매매 계약)·appendixC(건축)
  - lecture-clean-code: ch4(사과문, 명사구 1건)·ch6(객체 vs 자료 구조)
  - lecture-tdd: ch4(주방)·ch11(주방 통합)
  - 각 편 1건씩, 표·코드·체크리스트·퀴즈·용어 풀이 괄호는 규칙대로 보존. frontmatter `updated` 2026-06-27 갱신.
- **도메인 최신화**: 커스텀 도메인 `wiki.wonslab.dev` 연결됨(Firebase 콘솔 확인) → `mkdocs.yml` `site_url` 을 정식 도메인으로 변경, `guide-code-authoring-and-review` 참조 URL 12곳·`guide-wiki-authoring-standards` 배포 주석 1곳 `wons-wiki.web.app` → `wiki.wonslab.dev` 치환, backlog 운영환경 표 갱신(기본 도메인 web.app·firebaseapp.com 병기).
- **카피라이트 통일**: `wonslab-hub.web.app` 푸터와 동일하게 `mkdocs.yml` copyright 를 `© 2026 wonslab · blog · wiki · club`(링크 포함)으로 변경.

## [2026-06-27] style | 글쓰기 스타일 피드백 메모리화 + ch6 시연 1건
- 사용자 지적: `lecture-object-ch6.md:41` "회의 (메시지) 가 본질, 회의에 참여하는 사람 (객체) 은 그 자리에 맞으면 누구든 OK. 자리 (역할) 가 먼저 정해지고 사람 (객체) 이 캐스팅." — 괄호 매핑·단편 명사구로 읽기 불편
- 메모리 저장: `feedback-wiki-writing-style` (괄호 매핑·명사구 종결 금지, 비유 한 문단 + 매핑 한 문단 분리)
- 시연: `lecture-object-ch6.md` "회의 vs 사람" 비유를 책 풍 자연어 완결 문장으로 재작성 (1건)
- 백로그: 1차 대상 14개 페이지 식별 (lecture-object 9 + lecture-clean-code 2 + lecture-tdd 2 + ch6 완료) — 다음 세션에 일괄 진행
- UI: `scripts/css/extra.css` 에 `.md-sidebar--secondary { display: none }` — 우측 TOC 숨김

## [2026-06-26] feat | Loop 엔지니어링 실습 신설 (외부 자료 조사 반영)
- **요청**: harness 실습과 비슷한 컨셉으로 Loop 엔지니어링 **실습** + 외부 자료 조사.
- **외부 조사 (에이전트 3병렬, WebSearch/WebFetch)**:
  - 이론: ReAct([arXiv 2210.03629]) · Reflexion(2303.11366) · Self-Refine(2303.17651) · Sonar "검증 없는 루프 = 단순 자동화"("A failing build is a fact").
  - 2026 발화: Cherny(6/2 Acquired "write loops") → Steinberger(6/7) → Osmani(6/7 블로그, 토큰 신중론) — X 링크는 직접 검증 불가(402)라 venue 표기.
  - 구현: `claude -p` 헤드리스(1회 실행 후 종료=루프 적합), `cat test.log | claude -p` stdin 피드백 공식 패턴.
- **신설** [[guide-loop-engineering-demo]] (synthesis, ~270줄): Node mock 에이전트로 **메아리방(거부 신호 없는 루프) vs 검증 루프(거부 신호 있는 루프)** 8분 체험 → 실제 `claude -p` 연결(stdin 피드백) → 4 설계 질문 체크리스트 → 이론·1차 출처. **복붙 안정성 원칙 적용**(절대경로 `cd ~/loop-demo`, 따옴표 heredoc으로 JS `${}` 보존, 장기실행 없음).
- **교차참조**: mkdocs nav 실습 섹션, index Guides, [[concept-loop-engineering]] 양방향(본문 🧪 실습 박스 + 관련 페이지).

## [2026-06-26] fix | index.md 점검 — 카테고리 구조·중복 정리
- **깨진 링크 0**, lecture-* 93개 미등재는 교재 인덱스(src-*-lecture)로 대표하는 의도된 설계 → 유지.
- **수정**: ① `## Synthesis` 중복(빈 placeholder + guide 목록) → guide 목록을 `## Guides`로, 빈 것 제거 ② `src-clean-code-lecture`·`src-tdd-lecture`·`src-object-lecture`가 Sources·Entities **양쪽 중복 등재** → Entities에서 제거(src는 Source 분류) ③ harness module4 설명에 "컨텍스트 관리" 보강 ④ `guide-code-authoring-and-review` 설명 "5권" 강조 톤다운 ⑤ frontmatter updated 갱신.

## [2026-06-26] fix | harness 사전준비 Step A-3 — 복붙 실패(대화형 npm create) 분리
- **증상**: 사용자 보고 — `guide-harness-00-prerequisites` Step A-3(React 프론트)를 한 번에 붙여넣으면 실행 실패.
- **원인**: `npm create vite@latest`(대화형 프롬프트: 패키지 설치 확인·Vite 버전 선택)와 `cat ... << EOF` heredoc·`npm install` 이 **한 코드블록**에 묶여, 프롬프트 대기 중 뒷줄이 응답으로 먹혀 스캐폴딩이 깨짐.
- **수정**: Step A-3을 **두 블록으로 분리** — ① 스캐폴딩+설치(대화형, 먼저 실행) ② App.jsx 작성+커밋. 각 블록을 절대경로(`cd ~/harness-playground[/web]`)로 시작해 직전 Step 상태와 무관하게 견고. 상단에 ⚠️ 경고 박스 추가.
- **후속 — 전체 Step 동일 관점 점검**:
  - **A-4**: `npm run dev:web`(포그라운드 장기 실행 서버)이 한 블록에 묶여 통째 붙여넣으면 멈춰 뒤 `kill`이 안 돌던 함정 → **3블록 분리**(API 검증 / 프론트=다른 터미널 / 정리), `sleep 1`→`2`, 시작 `cd` 추가, ⚠️ 박스.
  - **A-5**: `git log` 예시가 **영문 메시지 + "4개"** 인데 실제 커밋은 **한글 3개** 불일치 → 실제와 일치(한글 3개)로 수정.
  - **A-2**: 시작 상대경로(`cd api`) → `cd ~/harness-playground` 선행 추가.
  - 결과: A-1~A-5 모든 블록이 절대경로 시작으로 통일, 대화형·장기실행 명령은 독립 블록으로 분리.
- **module1~5 동일 관점 점검 (에이전트 5병렬)**: 치명적 복붙 깨짐은 없음(대화형/장기실행 명령이 bash 블록에 거의 없고 heredoc은 대부분 `<< 'EOF'`로 안전). 실제 수정 3건:
  - **module5 Step 3-2**: 따옴표 heredoc(`<< 'EOF'`) 본문의 `$WEEK`가 전개 안 돼 파일명은 날짜인데 내용엔 리터럴 `$WEEK`. 본문엔 보호해야 할 `$COMMAND` 예시도 공존 → 따옴표 유지하고 본문 `$WEEK`를 플레이스홀더로 교체(날짜는 파일명에 자동).
  - **module5 Step 3-3**: 커밋 메시지가 이전 블록 변수 `$WEEK`에 의존 → 블록 첫 줄에 `WEEK=$(date …)` 재선언(단독 붙여넣기 안전).
  - **module3 Step 3 노트**: `npx eslint --init`(대화형 마법사)을 `npm install`과 같은 블록에서 분리 + "질문에 직접 답" 안내.
  - module1·2·4: 복붙 깨짐 없음. 디렉터리 의존은 "본인 프로젝트 루트" 전제라 절대경로 불가 → 보류.
- **demo 페이지 점검**: 복붙 깨짐 없음(`claude` 단독 실행 2곳 모두 독립 블록, heredoc 전부 `<< 'EOF'` 안전). demo는 `~/harness-demo` 고정 경로가 있어 Step 3(Hook 설치)에 `cd ~/harness-demo` 추가로 견고화. "5분 요약"은 prerequisites 내 산문 섹션(bash 없음)이라 점검 대상 없음. → harness 가이드 전체(prerequisites·module1~5·demo) 복붙 점검 완료.

## [2026-06-23] refactor | 코드 가이드 — "5권 강조" 톤다운 + 슬래시 명령 전체 코드 게재
- **배경**: 사용자 피드백 — `guide-code-authoring-and-review` 가 "책 5권을 분석했다"를 제목에서 과하게 강조. 1.2 "6원칙 — 5권을 관통하는 공통 골격" 같은 제목이 부적절.
- **제목 톤다운**:
  - title/H1 "코드 작성·점검 가이드 (5권 도서 종합)" → "코드 작성·점검 가이드"
  - 1장 "5권 원칙 한 페이지 종합" → "1. 6가지 핵심 설계 원칙" (기존 1.2 승격, "5권 관통" 제거)
  - 2.1~2.7·3.1~3.4 섹션 제목의 괄호 책 출처를 제거 → 제목 아래 `*근거: ...*` 이탤릭 캡션으로 격하 (근거 표시는 유지)
  - 1.1 "5권 오각형" 표를 페이지 상단 → 하단 "8. 참고 — 근거가 된 도서" 로 이동
- **슬래시 명령 portable 재작성 (7장)**: 사용자 요청 — "복붙 좋게 스킬 전체 코드를 표시"
  - 방법 A: `code-guide.md`·`code-check.md` **전체 코드를 4백틱 펜스로 게재** (복붙 한 번으로 다른 프로젝트 설치, 오프라인 OK)
  - 방법 B: GitHub raw `curl` (원본·최신), 방법 C: 프롬프트/본문 (Cursor·ChatGPT)
  - 깨진 경로 수정: `.claude/commands/{code-guide,code-check}.md` 의 `cp /Users/jungwonpark/...` (다른 PC 절대경로) 제거 → curl + 복붙 안내로 교체
  - 명령 내부 참조 `1.2 6원칙` → `1. 6가지 핵심 설계 원칙` 동기화
- **검증**: wikilink 변환 103파일 정상, 4백틱 펜스 2/2 짝. `mkdocs build` 는 이 PC mkdocs 미설치로 미실행 (콘텐츠 무관).
- **후속 보강**: 3.1 코드 악취 표가 15행(9개 누락)·처방 번호만(`6.1·6.11`) 부실 → **24행 완전판**으로 교체. 묶음 열 추가, 영문 악취명 병기, 처방을 정식 기법명(번호)으로 통일. 출처 [[lecture-refactoring-ch3]] 대조. mkdocs(.venv) 신설 후 빌드 워닝 0건 확인 + Firebase 재배포.
- **3.2·3.3 표 점검·보강**: 3.2 휴리스틱에 PR 단골 4개(G9 죽은 코드·G14 기능 욕심·G15 boolean 플래그·G36 디미터) 추가(10→14행), [[lecture-clean-code-ch17]] 링크. 3.3 EJ 20에 **장(章) 그룹 열** 추가 + 항목 설명 다듬기, [[entity-effective-java]] 링크. 두 표 모두 강의자료 대조.
- **3.4 GRASP 표 점검·보강**: 6패턴 → **9패턴 완전판** (순수 가공물·간접화·컨트롤러 추가), 영문명 병기, 질문 문구 정련.
- **전체 재점검 (오늘 맥락 반영)**: ① 7장 삭제 흔적인 **이중 `---`** 제거 ② 2.1~2.7 캡션 뒤 빈 줄 2개 → 1개 정돈 ③ 3장 도입 "5권 표준 코드" → "표준 코드" ④ 6장 "5권 모두에 누적된" → "여러 책에 공통으로 누적된" ⑤ 7장 참고 리드 문장 중복 표현 완화. 남은 "5권"은 명령 코드블록 내부·참고/관련 링크 레이블뿐(정당). 사용자 편집 선호를 메모리 [[wiki-editing-preferences]] 로 저장.
- **4장·7장 통합 (중복 제거)**: 4.1(AI 프롬프트)이 7장 방법 C와, 4.2(슬래시)가 7장 방법 A·B와 겹치던 구조 → **4. 사용 방법** 한 섹션으로 통합. 4.1 이 프로젝트(슬래시)·4.2 다른 CC 프로젝트(전체 복붙 A·curl B)·4.3 다른 AI(프롬프트·본문)·4.4 환경별 비교·4.5 PR 어휘·4.6 교육. 기존 7장 삭제, 참고·관련 페이지 8·9 → 7·8 번호 조정.
- **3.3 표 재구성**: "적용 시점" 헤더가 부정확(시점 아닌 규칙)·Item 번호만 있어 애매 → **항목(공식 제목) + 실무 포인트** 2열로 분리. 부제 "메서드·필드 단위" → "Effective Java 핵심 20" (범위 정정).
- **강의자료 [[lecture-object-ch5]] 컨트롤러 패턴 보강**: "GRASP 9개"라면서 컨트롤러 설명이 빠진 8개만 다루던 불일치 해소. 창조자 다음 **2.4 컨트롤러 (Controller)** 절 신설(Spring `@Controller` 연결 + "받아서 위임만" 주의), 이후 절번호 2.5~2.10으로 정렬. 개요·핵심 정리의 패턴 나열 2곳도 9개로 통일. → 가이드 3.4 표와 강의자료가 9패턴으로 일치.

## [2026-06-21] cleanup | Effective Java 외부 블로그 요약 raw 삭제 반영
- 사용자가 `raw/effective_java/개발서적 이펙티브 자바...핵심 요약.md` 를 제거한 상태 확인
- raw 원본이 사라진 `src-effective-java-summary.md` 를 위키에서 제거하고, 관련 참조를 `src-effective-java-lecture.md` 중심으로 정리
- 목적: raw 출처 추적 규칙 유지 + nav 미등록 페이지 경고 제거

## [2026-06-21] enrich | Java 도서 5권 강의 교재 — 초보자 실습 흐름·환경 가이드 보강
- 대상: `raw/object/`, `raw/effective_java/`, `raw/refactoring/`, `raw/clean-code/`, `raw/tdd/` 기반 5권 강의 교재 전체
- 신규 가이드:
  - `guide-java-book-study-lab.md` — Java 17 + JUnit 5 + Maven, Python 3, Node.js 기반 공통 실습 환경과 장별 루틴
  - `guide-code-authoring-and-review.md` — 5권 도서 원칙을 코드 작성·점검 체크리스트로 종합한 페이지를 nav/index에 연결
- 인덱스 보강:
  - `src-object-lecture.md` / `src-effective-java-lecture.md` / `src-refactoring-lecture.md` / `src-clean-code-lecture.md` / `src-tdd-lecture.md` 에 공통 실습 루틴 추가
  - 각 장을 "문제 확인 → 작은 변경 → 실행/테스트 → 인사이트 기록" 흐름으로 읽도록 안내
- 내용 보강:
  - `lecture-tdd-ch21.md` — TestResult 도입을 RED/GREEN/REFACTOR 흐름으로 확장
  - `lecture-tdd-ch24.md` — xUnit 2부 회고에 최종 코드 구조·복습 순서·체크리스트 추가
  - `lecture-tdd-ch29.md` — Assertion/Fixture/예외 테스트/JUnit 5 예제로 따라하기 보강
- 정정:
  - Clean Code 17장 휴리스틱 수를 80여 개 → 66개로 수정
  - `src-refactoring-lecture.md` frontmatter source 경로를 `refactoring/`으로 수정

## [2026-06-21] lint | 전체 점검 — 5권 entity 비교표 통일 후 일관성 검증
- 영역 1 인덱스 일관성: ✅ 165 페이지 모두 등록 (lecture-* 93편은 src-*-lecture 인덱스 hub 역할). 깨진 링크 0건.
- 영역 2 고아 페이지: ✅ entity·concept·src·guide 모두 인바운드 1+
- 영역 3 교차참조·sources: ✅ 모든 source/entity/concept 에 frontmatter `sources:` 존재
- 영역 4 모순·오래된 정보: ⚠️ 발견 + 자동 수정 (sed)
  - 5권 entity `updated: 2026-06-20` → `2026-06-21` (오늘 비교표 갱신 반영)
  - backlog.md "마지막 업데이트" 본문 2026-06-07 → 2026-06-21
  - backlog "오브젝트 entity 만" → "강의 18편 완성" 수정
  - backlog 위키 규모 "~50개" → "165개" 수정
  - backlog 최근 완료 작업에 6/13·20·21 5건 추가 기록
- 영역 5 raw 추적 마킹: ✅ 모든 페이지 통과
- 영역 6 새 제안: 백로그에 신규 concept 페이지 후보 11건 등록 상태 유지 (오브젝트 4·EJ 4·Clean Code 3) — 사용자 노트 입력 대기

## [2026-06-21] ingest | 📚 오브젝트 강의 교재 18편 — 5권 도서 모두 강의 교재 완성
- 사용자 입력: 1·2·3장 강의 교재 (raw/object/)
- 본 세션 작성: 4~15장 + 부록 A·B·C (15편, 약 3,500줄)
- wiki 신규 (19개): lecture-object-ch1~15 (15편) + appendixA·B·C (3편) + src-object-lecture 인덱스
- entity-object 보강 (강의 교재 18편 링크 추가)
- mkdocs.yml nav 18편 모두 등록 (📚 도서 > 오브젝트 하위)
- **5권 도서 모두 강의 교재 완성**: 오브젝트 18편 + EJ 11편 + 리팩터링 12편 + Clean Code 17편 + TDD 35편 = **91편**

## [2026-06-20] ingest | 📚 테스트 주도 개발 (Kent Beck, 2002) 전체 ingest — 5권 도서 오각형 완성
- 사용자 입력: `raw/tdd/toc.md` + 강의 교재 1·2장
- 본 세션 작성: 3~32장 + 부록 A·B + 마치는 글 (Fowler) = **33편 신규** (raw)
- wiki 신규 (37개):
  - `lecture-tdd-ch1~32.md` (32편)
  - `lecture-tdd-appendixA.md` / `appendixB.md` / `afterword.md` (3편)
  - `entity-tdd.md` 책 카드
  - `src-tdd-lecture.md` 인덱스
- mkdocs.yml nav 35편 모두 등록 (📚 도서 > TDD 하위 1·2·3부)
- 5권 도서 ingest 완료:
  - 오브젝트 (entity 만)
  - Effective Java (entity + 강의 11편)
  - 리팩터링 (entity + 강의 12편)
  - Clean Code (entity + 강의 17편)
  - **TDD (entity + 강의 35편)** ← 마지막
- 5권 오각형 비교표 (관점·단위·시점·언어) `entity-tdd` 안에 정리

## [2026-06-20] expand | 📚 Clean Code 실전 강의 교재 17장 + Q/A 토글 일괄 정리
- Clean Code 강의 교재:
  - 사용자 입력: 1·2장 raw
  - 본 세션 작성: 3~17장 (약 4,500줄). 1·2장 형식 그대로 (0.도입·절별 비유→Before/After→체크리스트·Q/A 분리 퀴즈)
- wiki 신규 (18개): `lecture-clean-code-ch1~17.md` 17편 + `src-clean-code-lecture.md` 인덱스
- mkdocs.yml nav 17장 모두 등록 (📚 도서 > Clean Code 하위)
- **토글 → Q/A 분리 일괄 변환** (47편): `scripts/convert_quiz.py` 작성, EJ·리팩터링·Clean Code 강의 교재의 `<details><summary>` 패턴을 `**Q.**`+`**A.**` 형식으로 일괄 변환. raw 22편 + wiki 23편 + 신규 Clean Code raw 1편. 어떤 뷰어에서도 깨지지 않음.
- 인덱스 (src-*-lecture) 형식 설명도 갱신 (`<details>` 펼침형 → Q/A 분리)
- 4권 도서 사각형 완전 ingest (목차 + entity + 강의 교재 + wiki 본문 노출): *Effective Java*·*리팩터링*·*Clean Code* — 강의 교재까지. *오브젝트* — 책 카드만 (강의 교재 미입력)

## [2026-06-20] ingest | 📚 Clean Code (Robert C. Martin, 2008) 책 entity
- 원본: `raw/clean-code/toc.md` — 사용자 입력 목차 (책 본문 미보유)
- 생성된 페이지 (1개):
  - `entity-clean-code.md` — 책 카드 + 11개 핵심 메시지 + 3부 구조 + **17장 휴리스틱(C·E·F·G·J·N·T 7 카테고리, ⭐ 11개)** + 위키 매핑 + "사람이 읽기 위한 코드" 패턴 비교(7행) + **4권 도서 사각형 비교표** (오브젝트·EJ·리팩터링·Clean Code)
- 기존 페이지 보강 (4개):
  - `concept-oop.md` / `concept-design-patterns.md` — Clean Code 인용
  - `entity-object.md` / `entity-effective-java.md` / `entity-refactoring.md` — 4권 양방향 링크
- 신규 concept 후보 3개 (백로그): `concept-naming-conventions`, `concept-tdd-laws-and-first`, `concept-simple-design-rules`
- 4권 도서 ingest 4/4 완료 (목차 기반 entity). 마지막 책 *테스트 주도 개발* 미입력

## [2026-06-20] expand | 강의 교재 본문 23편을 wiki로 노출 — 사이트에서 실습 본문 검색 가능
- 문제: src-*-lecture.md 인덱스 페이지가 있어도 raw 파일 링크라 사이트(wons-wiki.web.app)에서 본문 접근 불가
- 해결: raw 강의 교재 23편(EJ 11편 + 리팩터링 12편) 을 wiki/로 복사, mkdocs nav에 모두 등록
- raw 디렉터리 정리: `raw/clean-code/리팩터링*` 12편 → `raw/refactoring/` 이동, 빈 clean-code 제거
- 신규 wiki 페이지:
  - `lecture-refactoring-ch1.md` ~ `ch12.md` (12개)
  - `lecture-effective-java-ch2.md` ~ `ch12.md` (11개)
- 인덱스 갱신:
  - `src-refactoring-lecture.md` — raw 경로 → `[[lecture-refactoring-chN]]` 위키링크
  - `src-effective-java-lecture.md` — raw 경로 → `[[lecture-effective-java-chN]]` 위키링크
- mkdocs.yml nav 23개 항목 추가 (📚 도서 > 각 책 하위)
- 효과: 사이트 nav에서 각 장 클릭 → 본문(학습 목표·비유·Before/After·Spring 현업·체크리스트·퀴즈) 바로 진입

## [2026-06-20] expand | 📚 리팩터링 2판 실전 강의 교재 12장 작성·인덱스
- 원본 입력: `raw/clean-code/리팩터링 실전 강의 교재 1·2장.md` (사용자 직접 작성)
- 본 세션 추가 작성: 3~12장 10편 (약 4,200줄). 1·2장 형식 그대로 (0.도입·기법별 비유→Before/After→절차→Spring 현업·종합 정리·퀴즈).
- 위키 신규 페이지 (1개):
  - `src-refactoring-lecture.md` — 12편 강의 교재 통합 인덱스 (각 장 raw 링크·시그니처 비유 모음·★ 핵심 9개·6원칙·활용 가이드)
- 기존 페이지 보강:
  - `entity-refactoring.md` — 원본 출처·관련 페이지에 강의 교재 12편 링크 추가
- raw 디렉터리: 사용자가 `raw/clean-code/` 에 입력해 현 위치 유지 (디렉터리명 정리는 사용자 결정 사항으로 미룸)

## [2026-06-20] ingest | 📚 리팩터링 2판 (Martin Fowler, 2018) 책 entity
- 원본: `raw/refactoring/toc.md` — 사용자 입력 목차 (책 본문 미보유)
- 생성된 페이지 (1개):
  - `entity-refactoring.md` — 책 카드 + 8개 핵심 메시지 + 3부 구조 + **24개 코드 악취 표(악취 ↔ 리팩터링 기법 매핑)** + 6~12장 카탈로그 요약(약 66개 리팩터링) + 위키 기존 페이지 매핑 + "이름 있는 메커니즘이 즉흥보다 안전" 패턴 비교 + 세 책 삼각형 관계(*오브젝트*·*Effective Java*·*리팩터링*)
- 기존 페이지 보강 (4개):
  - `concept-oop.md` — 4원칙 위배 = 악취
  - `concept-design-patterns.md` — 10.4 → Strategy, 11.8 → Factory Method
  - `entity-object.md` — 책임 주도 설계가 도달점, 리팩터링이 거기까지 가는 카탈로그
  - `entity-effective-java.md` — 매일의 권고 vs 이미 짠 코드의 카탈로그
- 4권 도서 ingest 계획 중 3권 완료 (실제로는 책 진행 흐름 변경: 오브젝트·Effective Java·리팩터링). 남은: Clean Code, 테스트 주도 개발

## [2026-06-20] ingest | 📚 Effective Java (Joshua Bloch, 3판 2018) 전체
- 원본 입력:
  - `raw/effective_java/이펙티브 자바 실전 강의 교재 2~6장.md` (사용자 제공, 약 2,900줄)
  - `raw/effective_java/개발서적 이펙티브 자바...핵심 요약.md` (모찌모찝 블로그 12장 요약, 출처 명시)
- 본 세션 추가 작성 (raw):
  - `이펙티브 자바 실전 강의 교재 7~12장.md` 6편 (Item 42~90, 약 3,500줄)
  - 형식: 학습 목표·큰 그림·아이템별 비유→문제→해법→Spring/JPA·함정·체크리스트·종합 정리·퀴즈·다음 장 예고. 12장 끝에 책 전체 6원칙 요약.
- 위키 신규 페이지 (3개):
  - `entity-effective-java.md` — 책 카드 + 90 아이템 인덱스 + ⭐현업 최핵심 20개 + 위키 매핑 + "공개 API는 영원하다" 패턴 비교 + *오브젝트*와의 관계
  - `src-effective-java-summary.md` — 블로그 12장 한 페이지 요약 source
  - `src-effective-java-lecture.md` — 강의 교재 11장 통합 인덱스 source (각 장 raw 링크·시그니처 비유 모음·Spring/JPA 연결 표)
- 기존 페이지 보강 (5개, "관련 페이지" + 인용):
  - `concept-oop.md` — Item 17·18·20 인용
  - `concept-design-patterns.md` — Item 1·2·17·18 (정적 팩터리·빌더·불변·컴포지션)
  - `concept-spring-core.md` — Item 5(DI 이론)·3(싱글턴)·39(애너테이션)
  - `concept-transactional-rollback-policy.md` — Item 70(checked vs runtime 철학)·71
  - `concept-db-connection-pool.md` — Item 9 (try-with-resources 정석 사례)
- 신규 concept 후보 4개 (사용자 노트 입력 대기, 백로그 등록): `concept-jpa-enum-mapping`, `concept-functional-interfaces`, `concept-generics-pecs`, `concept-java-serialization-risk`
- 4권 도서 ingest 계획 중 2권 완료. 남은: Clean Code, TDD

## [2026-06-20] ingest | 📚 오브젝트 (조영호, 위키북스 2019) 책 entity
- 원본: `raw/object/toc.md` — 사용자 입력 목차 (책 본문 미보유)
- 생성된 페이지 (1개):
  - `entity-object.md` — 책 카드 + 9개 핵심 메시지 + 4부 구조 + 시그니처 예제(영화 예매·핸드폰 과금) + 위키 기존 페이지 매핑 + "데이터부터 그리면 망한다" 패턴 비교표
- 기존 페이지 보강 (2개):
  - `concept-oop.md` — 책 출처 인용 추가 (메시지가 객체를 결정한다)
  - `concept-design-patterns.md` — 책 15장·11장 인용
- 신규 concept 후보 4개 (사용자 노트 입력 대기): SOLID, GRASP, 계약에 의한 설계(DbC), DDD 모델 종류
- 4권 도서 ingest 계획 중 1권 완료. 남은: Clean Code, TDD, Effective Java

## [2026-06-13] ingest | Loop 엔지니어링 (2026-06 커뮤니티 발화)
- 원본: `raw/loop-engineering/loop-engineering-notes.md` (외부 AI 어시스턴트 정리본, 원전 URL 미확보)
- 계기: 2026-06-08 Peter Steinberger X 게시물(650만 조회) + Boris Cherny / Addy Osmani 발언
- 생성된 페이지 (2개):
  - `src-loop-engineering.md` — 발화·인용·맥락 정리
  - `concept-loop-engineering.md` — 정의·ReAct 골격·4가지 설계 질문·"거부 신호 없는 자동화는 폭주한다" 패턴 비교표 (AI 루프 ↔ Hooks ↔ Critic ↔ 크론잡 Forbid ↔ Keep-Alive race)
- 기존 페이지 보강 (3개):
  - `concept-harness-engineering.md` — 시대 진화표를 4단(2026중 Loop)으로 확장, "인간 노력의 단위" 컬럼 추가
  - `concept-claude-hooks.md` — back-pressure가 "거부할 수 있는 무언가"의 구현임을 명시 + 양방향 링크
  - `concept-multi-agent-pattern.md` — Critic의 REJECT가 거부 신호 구현임을 명시 + 양방향 링크
- index.md / mkdocs.yml nav 갱신 완료

## [2026-04-18] init | 위키 초기화
- 폴더 구조 생성: `raw/`, `raw/assets/`, `wiki/`
- 스키마 파일 생성: `CLAUDE.md`
- 인덱스·로그 파일 생성: `wiki/index.md`, `wiki/log.md`

## [2026-04-18] ingest | LLM Wiki Pattern
- 원본: `raw/llm-wiki-pattern.md`
- 생성된 페이지 (8개):
  - `src-llm-wiki-pattern.md` — 소스 요약
  - `concept-compounding-knowledge.md` — 복리 지식
  - `concept-memex.md` — Memex
  - `concept-ingest.md` — Ingest 워크플로
  - `concept-query.md` — Query 워크플로
  - `concept-lint.md` — Lint 워크플로
  - `entity-vannevar-bush.md` — Vannevar Bush
  - `entity-obsidian.md` — Obsidian
  - `entity-qmd.md` — qmd 검색 엔진
- index.md 업데이트 완료

## [2026-04-18] lint | 첫 번째 위키 정비
- 깨진 링크 3건 수정: entity-dataview, entity-marp, entity-obsidian-web-clipper 페이지 생성
- 이스케이프 오류 수정: src-llm-wiki-pattern.md의 `\|` → `|`
- index.md에 신규 entity 3건 추가

## [2026-04-18] ingest | Spring Boot 공식 소개 페이지
- 원본: `raw/Spring Boot.md`
- 생성된 페이지 (3개):
  - `src-spring-boot.md` — 소스 요약
  - `entity-spring-boot.md` — Spring Boot 엔티티
  - `entity-spring-initializr.md` — Spring Initializr 엔티티
- index.md 업데이트 완료

## [2026-04-18] ingest | Claude Design 리뷰 영상
- 원본: `raw/클로드 디자인! 디자인 스타트업 폐업시켜 버리기~.ko-orig.srt` (YouTube 자막)
- 생성된 페이지 (2개):
  - `src-claude-design-review.md` — 영상 소스 요약
  - `entity-claude-design.md` — Claude Design 엔티티
- index.md 업데이트 완료

## [2026-04-18] ingest | Spring Framework 7.0 릴리스 노트
- 원본: `raw/Spring Framework Versions.md`
- 생성된 페이지 (4개):
  - `src-spring-framework-7.md` — 소스 요약
  - `entity-spring-framework.md` — Spring Framework 엔티티
  - `concept-api-versioning.md` — API Versioning 개념
  - `concept-jspecify-null-safety.md` — JSpecify Null Safety 개념
- 기존 페이지 업데이트: `entity-spring-boot.md` (Spring Framework 링크 추가)
- index.md 업데이트 완료

## [2026-04-18] ingest | [2024-2025] Java 스터디 자료 (Notion DB)
- 원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료" (91페이지, 12챕터)
- Notion MCP 연결을 통해 74/91 페이지 fetch → raw/ 에 챕터별 마크다운 저장
- 생성된 raw 파일 (12개):
  - `java-study-ch00-안내.md` ~ `java-study-ch11-부록.md`
- 생성된 위키 페이지 (6개):
  - `src-java-study-2024-2025.md` — 소스 요약
  - `concept-oop.md` — 객체지향 프로그래밍
  - `concept-design-patterns.md` — 디자인 패턴 8가지
  - `concept-spring-core.md` — Spring 핵심 개념 (IoC, DI, Bean, MVC)
  - `entity-jvm.md` — JVM
  - `entity-querydsl.md` — Querydsl
- 기존 페이지 연결: entity-spring-boot, entity-spring-framework
- index.md 업데이트 완료

## [2026-04-18] ingest-update | Java 스터디 추가 페이지 수집
- 추가 수집: Ch10 (10.8-2, 10.9), Ch11 (11.1~11.4, 11.9, 11.11~11.13) 등 10페이지
- raw/ 전체 커버리지: 84/91 (92%)
- 누락 7페이지: Ch11 보충 자료 (면접, Git, 스레드, 포트폴리오, 프로젝트)

## [2026-04-19] ingest-complete | Java 스터디 나머지 7페이지 수집 완료
- 추가: 11.14 Java 면접, 11.15 Git, 11.16 스레드, 11.17 포트폴리오, 11.19 온라인게임, 11.21 JSP, 11.26 메모앱
- raw/ 전체 커버리지: 91/91 (100%) — 완료

## [2026-04-19] ingest | 나의 링크 (Notion 북마크 DB)
- 원본: Notion 데이터베이스 "나의 링크" (35개 북마크)
- 생성된 raw 파일: `my-links.md`
- 생성된 위키 페이지: `src-my-links.md` — 주제별 분류 포함
- index.md 업데이트 완료

## [2026-04-19] ingest | Spring Guide (cheese10yun) + 북마크 본문 보충
- 신규 raw: `spring-guide.md` (GitHub 6개 가이드, 1,697줄)
- 신규 wiki: `src-spring-guide.md` — 실무 가이드 요약
- 북마크 본문 보충: WebFetch로 5건 웹 콘텐츠 수집
- 본문 없는 11건 삭제 → 24개 유지 (모두 본문 포함)
- index.md 업데이트

## [2026-04-19] ingest | 카카오페이 DDD 구축기
- 원본: https://tech.kakaopay.com/post/backend-domain-driven-design/
- raw/kakaopay-ddd.md: 전문 저장 (DDD 개념, 설계, 구현, 코드 예시)
- wiki/src-kakaopay-ddd.md: 소스 요약 + 관련 페이지 교차참조
- index.md 업데이트

## [2026-04-19] ingest | Spring Framework Data Access Reference
- 원본: https://docs.spring.io/spring-framework/reference/data-access.html
- 수집 범위: Transaction, @Transactional, JDBC, JPA, DAO Support (5개 섹션)
- raw/spring-data-access-ref.md, wiki/src-spring-data-access-ref.md 생성
- index.md 업데이트

## [2026-04-19] ingest | Spring Web MVC + Testing 레퍼런스
- raw/spring-web-mvc-ref.md: Controller, @RequestBody, ResponseEntity, 예외 처리
- raw/spring-testing-ref.md: 테스트 어노테이션, Mock, MockMvc, 테스트 피라미드
- wiki/src-spring-web-mvc-ref.md, wiki/src-spring-testing-ref.md 생성
- CLAUDE.md에 콘텐츠 보강 정책 추가
- index.md 업데이트

## [2026-04-25] synthesis | 프로젝트 문서 시스템 셋업 가이드
- wiki/guide-project-docs-setup.md 생성
- CLAUDE.md 템플릿, 디렉터리 구조, 문서 유형별 템플릿 (ADR, API, 트러블슈팅)
- Step 1~4 셋업 절차, 일상 운영 명령, 체크리스트 포함

## [2026-05-30] ingest | 하네스 엔지니어링 실습 키트
- 원본 4종 → raw/harness-engineering/ 복사 (이후 reorg로 디렉터리 이동):
  - `harness-kit/` (module1~5 디렉터리 구조 보존)
  - `harness-engineering-tutor-prompt.md` (튜터 프롬프트)
  - `harness_engineering.pdf` (10페이지 슬라이드 덱)
  - `하네스엔지니어링_슬라이드해설_강의교안.docx`
- 생성된 위키 페이지 (5개):
  - `src-harness-engineering.md` — 통합 소스 (5모듈 커리큘럼 + 키트 구조 + Quick Start)
  - `concept-harness-engineering.md` — 마구 비유, 시대 진화, 4원칙, Rippable
  - `concept-claude-md.md` — Karpathy 4원칙 + STOP 트리거 + DDD 통합
  - `concept-claude-hooks.md` — Lifecycle 이벤트 + guard.sh + Back-pressure
  - `concept-multi-agent-pattern.md` — Planner/Coder/Critic + AGENTS.md + 세션 인계
- 교차참조: guide-project-docs-setup, src-kakaopay-ddd, concept-spring-core, concept-compounding-knowledge
- index.md 업데이트 완료

## [2026-05-31] rewrite | 하네스 guide 6개를 Node 친화 step-by-step으로 재작성
- **배경**: 초보자 점검 결과 — Spring DDD 톤이 강하고 사전조건/용어/실패대응 부재. 학습자 스택은 Node + 추후 GCP/Functions.
- **변경 사항**:
  - `guide-harness-00-prerequisites.md` (신규, 263줄) — 대상 학습자, Node 도구 사전조건, Node 친화 용어사전, Spring→Node 명령어 치환표, GCP 추후 안내, 7개 FAQ
  - `guide-harness-module1.md` (354줄) — Step 1~5 step-by-step, User/phone 필드 예시, Node 미니 프로젝트 생성 스크립트, 측정 체크리스트, Module1 FAQ
  - `guide-harness-module2.md` (재작성) — CLAUDE.md 12섹션 Node 친화 템플릿, STOP 트리거 Node 패턴 (env/시크릿/silent catch 등), Before/After
  - `guide-harness-module3.md` (재작성) — guard.sh Node 규칙 8종 (.env 커밋, 시크릿 echo, force push 등), lint-fix.sh = Prettier+ESLint, 차단 검증 표, 자기검증 루프 (npm test 기반)
  - `guide-harness-module4.md` (재작성) — AGENTS.md Node 친화 (route→controller→service 구조), Auth 기능 예시, Planner/Coder/Critic 사이클 step-by-step
  - `guide-harness-module5.md` (재작성) — 저장소 구조 + .gitignore 정책, 주간 리뷰 4스텝 (Claude에게 위임), Rippable 점검, M1↔M5 비교 표
- **공통 패턴**: 각 페이지 상단 "이 가이드 보기 전에" 박스 + "얻을 것" + 시간 + Step 번호 + 막힐 때 FAQ + 산출물 정리 + 다음 단계
- **GCP 처리**: 모듈 실습 본문에서 제외. prerequisites에만 "추후 배포 시 STOP 트리거에 추가할 것" 가이드.
- index.md에 prerequisites 항목 추가

## [2026-06-07] meta | 위키 작성 표준 + 백로그 신설 (다른 PC 인계용)
- `wiki/guide-wiki-authoring-standards.md` 신규 — 다이어그램 작성 기준(mermaid 한계·HTML+flexbox·3톤 색·2채널 가독성), 타입별 분량 기준, 페이지 표준 구조, 패턴 누적, 셀프 체크리스트, ingest 워크플로, 빌드·배포 워크플로
- `wiki/backlog.md` 신규 — 현재 상태, 진행 중·다음 단계 후보, 결정 사항(GCP 배포·다이어그램 표준·raw 구조), 운영 환경, 새 세션 시작 가이드
- CLAUDE.md 업데이트 — "위키 작성 표준" 섹션 추가 (다이어그램 + 분량 + 셀프 체크), backlog 참조 안내
- mkdocs.yml nav 추가 — 위키·지식관리 > 환경설정에 표준·백로그 추가
- index.md Synthesis에 2개 페이지 추가

## [2026-06-06] ingest | 2분코딩 — HTTP 진화와 HOL 블로킹 (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=RZTsrCjpoZc
- raw: `raw/2bun-coding/http-evolution-quic.md`
- 생성한 위키 페이지 (1개):
  - `concept-http-hol-blocking.md` — 3세대 비교표(HTTP 1.0/1.1/2/3), HTTP 1.1 Keep-Alive HOL 메커니즘, HTTP/2 멀티플렉싱과 TCP HOL 재발, HTTP/3 QUIC over UDP 설계 결정, 실무 한계(방화벽 UDP 차단·CPU 비용·운영 도구 미성숙), Spring Boot HTTP/2·3 설정, 빠른 진단(DevTools·curl --http3)
- **새 인사이트 패턴**: "한 계층의 해결이 다음 계층 문제를 드러낸다" — HTTP/2 → TCP HOL, ORM 풀 → 좀비 커넥션, Keep-Alive → 타임아웃 race
- mkdocs.yml nav: DB·운영·인프라 > 개념에 추가
- 교차참조: concept-keepalive-timeout-race, concept-db-connection-pool, src-java-study-2024-2025(Ch10), src-spring-web-mvc-ref

## [2026-06-06] ingest | 2분코딩 — API 하위 호환성 / Tolerant Reader (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=LBWefG5zjxk
- raw: `raw/2bun-coding/api-breaking-change-json.md`
- 생성한 위키 페이지 (1개):
  - `concept-api-backward-compatibility.md` — 사고 시나리오(웹/Gson/kotlinx.serialization 차이), 주요 JSON 라이브러리 8종 기본 동작표, Tolerant Reader 패턴(Martin Fowler), 안전한 변경 vs Breaking Change, 4가지 방어선(명세 명시·클라이언트 권장 설정·계약 테스트·v1/v2), 빠른 진단 grep
- **패턴 누적**: "기본값과 가정의 함정" 비교표에 추가 (총 6개 페이지로 확장)
- mkdocs.yml nav: Java·Spring·DDD > 개념에 추가 (concept-api-versioning 다음 위치)
- 교차참조: concept-api-versioning, src-spring-web-mvc-ref, src-spring-data-access-ref, concept-transactional-rollback-policy, concept-cronjob-concurrency-trap, concept-claude-md

## [2026-06-06] ingest | 2분코딩 — @Transactional 롤백 정책 (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=L3IFezsV5VI
- raw: `raw/2bun-coding/transactional-rollback-exception.md`
- 생성한 위키 페이지 (1개):
  - `concept-transactional-rollback-policy.md` — 함정 케이스, Java 예외 2분류 철학(Checked/Unchecked/Error), 실무 괴리, rollbackFor 패턴(3가지: 메서드별/메타 어노테이션 @Tx/AOP), noRollbackFor, 현대 트렌드(Kotlin 폐지/모던 Java wrap), CLAUDE.md STOP 트리거 후보, 빠른 진단 grep
- **패턴 누적**: "프레임워크 기본값은 절대값이 아니다" 비교표 추가 (이 페이지/크론잡/Keep-Alive/풀/VARCHAR 5개)
- mkdocs.yml nav: Java·Spring·DDD > 개념에 추가 (Spring Core 다음 위치)
- 교차참조: src-spring-data-access-ref, concept-spring-core, src-java-study-2024-2025(Ch02·Ch06), src-kakaopay-ddd, concept-cronjob-concurrency-trap, concept-keepalive-timeout-race, concept-claude-md

## [2026-06-06] ingest | 2분코딩 — 크론잡 중복 실행 + Forbid 함정 (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=JhBiSdXpvk4
- raw: `raw/2bun-coding/cronjob-concurrency-trap.md`
- 생성한 위키 페이지 (1개):
  - `concept-cronjob-concurrency-trap.md` — 월말 정산 2배 사고, 환경별 동시 실행 기본값(Linux cron, K8s Allow, Spring @Scheduled), 1차 방어(flock/Forbid), 2차 방어(activeDeadlineSeconds)와 Hang 함정, 권장 K8s 매니페스트 전체 예시, 모니터링(JobAlreadyActive·Prometheus 메트릭), 진단 체크리스트
- **패턴 누적**: 4개 인프라 사고 페이지의 공통 인사이트 "단일 방어선의 함정 — 모든 자동화·차단·관습은 부작용을 동반" 비교표 추가 (크론잡/풀/LB/VARCHAR)
- mkdocs.yml nav: DB·운영·인프라 > 개념에 추가
- 교차참조: concept-db-connection-pool, concept-keepalive-timeout-race, concept-varchar-length-prefix, src-spring-data-access-ref, concept-harness-engineering

## [2026-06-06] ingest | 2분코딩 — VARCHAR(255)의 진짜 이유 (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=EbeSOshOgX4
- raw: `raw/2bun-coding/varchar-255-prefix.md`
- 생성한 위키 페이지 (1개):
  - `concept-varchar-length-prefix.md` — InnoDB 1/2 byte length prefix, 문자셋별 경계표(Latin1 255 / utf8 85 / utf8mb4 63), 성능 영향(저장공간+인덱스 페이지 스플릿), DBMS 비교(MySQL vs PostgreSQL varlena vs SQL Server vs Oracle), 실무 결정 가이드(이메일 RFC 5321 등), 진단 SQL
- 교차참조: concept-db-connection-pool, concept-keepalive-timeout-race(같은 "관습대로 두면 사고" 패턴), src-spring-data-access-ref(@Column length), src-java-study-2024-2025(Ch06), src-kakaopay-ddd(VO 길이 제약 정합)

## [2026-06-06] ingest | 2분코딩 — 새벽 502 / LB Keep-Alive race (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=a-KFzdW_Ybw
- raw: `raw/2bun-coding/502-keepalive-timeout-race.md`
- 생성한 위키 페이지 (1개):
  - `concept-keepalive-timeout-race.md` — 현상·메커니즘·기본값 비교표(ALB 60s, NLB 350s, Gunicorn 2s, Node 5s, Tomcat 20s)·해결 규칙(서버 > LB)·언어별 설정 예시·ALB→NLB 함정·진단 체크리스트
- 패턴 인식: `concept-db-connection-pool`과 같은 "두 타이머 불일치 → race" 패턴 → 두 페이지 양방향 교차참조
- 교차참조: concept-db-connection-pool, src-java-study-2024-2025(Ch10), src-spring-data-access-ref, concept-harness-engineering

## [2026-06-06] ingest | 2분코딩 — Copilot 토큰 종량제 전환 (YouTube Shorts)
- 원본: https://www.youtube.com/watch?v=Ujuy6cSYa6g
- raw: `raw/2bun-coding/copilot-token-pricing.md` (영상 요약 + 사례 + 타임스탬프)
- 생성한 위키 페이지 (1개):
  - `src-copilot-token-pricing.md` — 사건 정리(2026-06-01 종량제 전환), 비용 폭증 사례 표, 에이전트 모드 재귀 토큰 소비, 안전장치 제거, 예산 상한 설정 안내, 하네스 적용 후보 (CLAUDE.md STOP 트리거·주간 리뷰 지표)
- 교차참조: concept-harness-engineering, concept-claude-md, guide-harness-module2, guide-harness-module5, src-claude-design-review
- index.md "Sources" 카테고리에 추가

## [2026-06-06] ingest | 2분코딩 — getConnection()이 빠른 이유 (YouTube Shorts)
- 원본: https://www.youtube.com/shorts/El5lOXM1r5E
- raw: `raw/2bun-coding/getconnection-pool.md` (영상 요약 + 타임스탬프 보존, 신규 채널 디렉터리)
- 생성한 위키 페이지 (1개):
  - `concept-db-connection-pool.md` — JDBC `getConnection()` 빠른 이유, 3단계 흐름(빌리고·쓰고·돌려주기), HikariCP 3타이머(maxLifetime/idleTimeout/keepaliveTime), `maxLifetime < db.wait_timeout` 규칙, leakDetectionThreshold, Spring Boot 설정 예시
- 교차참조: src-spring-data-access-ref, src-java-study-2024-2025, concept-spring-core, src-kakaopay-ddd
- index.md "Concepts" 카테고리에 추가

## [2026-05-31] guide | 하네스 5개 모듈 실습 가이드 페이지 생성 (1차)
- **배경**: 기존 concept 4개는 module2~4의 핵심 개념만 다뤘음. module1(Failure Audit·베이스라인), module5(주간 리뷰·Rippable), 각 module의 prompt/스크립트는 wiki에 정리 안 됨.
- **생성한 페이지 (synthesis 타입, 5개)**:
  - `guide-harness-module1.md` — 실패 패턴 감사 프롬프트, 베이스라인 측정 태스크 A·B·C, 기록 시트
  - `guide-harness-module2.md` — CLAUDE.md 12개 섹션 요약, 초안 작성 프롬프트, Before/After 비교 절차
  - `guide-harness-module3.md` — guard.sh 7개 규칙, lint-fix.sh 분기, hooks-config.json, 자기검증 루프 4단계
  - `guide-harness-module4.md` — AGENTS.md 3역할, task-list/progress 템플릿, 워크플로우 프롬프트 (Planner/Coder/Critic)
  - `guide-harness-module5.md` — 저장소 구조 + .gitignore 정책, 주간 리뷰 4스텝, Rippable 점검 기준
- **마킹**: 각 페이지 `> 원본: raw/harness-engineering/harness-kit/moduleN/...` 인용 명시. frontmatter `sources:`에 raw 파일 5~12개 등록.
- **교차참조**: module1→2→3→4→5 순방향 + 역방향 의존, concept 4개 ↔ guide 5개 양방향
- **수정**: index.md "Synthesis" 카테고리에 guide 5개 추가, src-harness-engineering.md에 "모듈별 실습 가이드" 섹션 추가

## [2026-05-31] enrich | 빈약 8개 페이지 외부 공식 자료로 보강
- **대상**: 30줄 미만 페이지 8개 (이전 분량 → 보강 후 분량)
  - entity-vannevar-bush (16 → 64줄): 생애 표, As We May Think 인용, Memex 구상, 후세 영향
  - entity-spring-initializr (19 → 66줄): 선택 옵션, 산출물, 사용 경로, 셀프 호스팅·확장
  - entity-marp (21 → 84줄): 4개 구성요소, 출력 포맷, frontmatter 디렉티브 예제, 기본 테마
  - entity-obsidian-web-clipper (21 → 64줄): 8개 브라우저, 템플릿/하이라이트/Defuddle 기능표
  - entity-qmd (21 → 82줄): 3계층 retrieval (BM25/Vector/Re-rank), CLI 예제, MCP 모드
  - entity-dataview (24 → 86줄): DQL 쿼리 유형/문법, 인라인 필드, JS API, 실용 예시
  - concept-query (27 → 72줄): RAG 차이, 출력 형식, 표준 플로우 다이어그램, 규모별 검색
  - entity-obsidian (28 → 83줄): 플랫폼, 가격, 핵심 기능표, 위키 운영용 팁
- **외부 자료**: WebFetch로 공식 사이트 7건 수집 (Wikipedia, start.spring.io, github/initializr, marp.app, obsidian.md/clipper, blacksmithgu/dataview, obsidian.md, github/tobi-qmd)
- **마킹**: 각 페이지에 `## 원본 출처` 섹션 추가 (raw 경로 + 외부 URL 명시). frontmatter `external:` 키 추가
- **양방향 교차참조 보강**: entity-obsidian ↔ 플러그인 4개, vannevar-bush ↔ concept-memex/concept-compounding-knowledge, entity-qmd ↔ concept-query, entity-marp ↔ concept-query 등

## [2026-05-30] refactor | raw/ 주제별 디렉터리로 재편 + PDF/DOCX 변환 + 마킹 정비
- **목적**: raw/ 구조 일관성 + 원본 추적 마킹 시스템 구축
- **raw/ 재편 (7개 주제 디렉터리)**:
  - `raw/java-study/` ← java-study-ch00~ch11.md (12개)
  - `raw/spring/` ← Spring Boot.md, Spring Framework Versions.md, spring-guide.md, spring-data-access-ref.md, spring-web-mvc-ref.md, spring-testing-ref.md, Accessing Relational Data using JDBC with Spring.md (7개)
  - `raw/harness-engineering/` ← harness-kit/, pdf, docx, tutor-prompt (4종)
  - `raw/llm-wiki-pattern/`, `raw/kakaopay-ddd/`, `raw/my-links/`, `raw/claude-design/`
- **PDF/DOCX → MD 변환** (textutil 사용):
  - `raw/harness-engineering/harness_engineering.md` (PDF 10페이지 압축본)
  - `raw/harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md` (DOCX 강의 해설, 부록 A~C 포함)
- **마킹 시스템**:
  - `raw/harness-engineering/README.md` 생성 — 자료 구성, 추천 읽기 순서, 위키 페이지 매핑
  - `src-harness-engineering.md`에 "원본 파일 위치" 섹션 추가
  - `CLAUDE.md` 스키마에 "raw/ 구조 규칙" + "원본 추적 마킹 규칙" 절 추가
- **frontmatter sources 업데이트**: 모든 src-*.md (11개) + concept 하네스 4개의 sources 경로를 새 디렉터리로 재지정
- **본문 경로 보정**: src-harness-engineering, concept-claude-md, concept-claude-hooks의 본문 raw/ 경로를 새 경로로 일괄 치환
- **README.md (루트) 업데이트**: 디렉터리 구조 + 빠른 시작 명령 예시 업데이트

## [2026-05-31] guide | 위키 외부 배포 가이드 (MkDocs Material + Firebase Hosting)
- **배경**: 위키를 외부에 깔끔하게 공개하고 싶다는 요청. GitHub 종속 회피, 무료 또는 저렴 우선.
- **결정**:
  - SSG: MkDocs Material (10년차 안정성, 검색·정보전달력 최강, 한국어 자료 풍부)
  - 호스팅: Firebase Hosting (무료 티어, CDN·SSL 자동, `firebase deploy` 한 줄, GitHub 종속 없음)
  - raw/ 는 비공개 — `wiki/` 만 `docs/` 로 복사해 빌드
- **생성된 페이지**: `guide-deploy-mkdocs-firebase.md` (Step 1~10 + 트러블슈팅 + 비용 예상)
  - 빌드 흐름 Mermaid 다이어그램, 유지보수 흐름 다이어그램
  - `mkdocs.yml` 전체 예시 (한국어 검색, 다크모드, navigation, pymdownx 확장)
  - `scripts/build-site.sh`, `scripts/deploy.sh` 스크립트
  - `firebase.json` 캐시 헤더 설정 포함
- **부수 작업**: `.claude/commands/ingest.md`, `query.md`, `lint.md` 슬래시 명령어 신규 작성
- index.md Synthesis 카테고리에 추가
