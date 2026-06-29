---
title: Wons Wiki 로그
---

# Wiki Log

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
