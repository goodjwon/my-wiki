---
title: 위키 백로그 (작업·아이디어·보류)
type: synthesis
tags: [meta, backlog, project-status]
sources: []
created: 2026-06-07
updated: 2026-06-27
---

# 위키 백로그

**다른 PC·다른 세션에서 위키 작업을 이어가기 위한 상태 인계 파일.**

새 세션 시작 시 가장 먼저 읽어야 함:
1. 이 페이지
2. [[guide-wiki-authoring-standards]]
3. `wiki/log.md` (최근 작업 시간순)
4. `wiki/index.md` (전체 페이지 카탈로그)

---

## 📅 마지막 업데이트

2026-07-01

## 🎯 현재 위키의 큰 줄기 (Strategy)

이 위키는 4개 카테고리로 누적 중:

1. **위키·지식관리** — Obsidian·Memex·LLM Wiki 패턴 (메타·인프라)
2. **하네스·AI 에이전트** — Claude Code 하네스 5모듈 실습 + AI 도구 비용 관리
3. **Java·Spring·DDD** — Spring 7.0, JVM, OOP, 디자인 패턴, DDD 모델링
4. **DB·운영·인프라** — DB 운영 함정, 네트워크, K8s, "기본값 사고" 패턴 누적

핵심 인사이트가 두 가지로 자라는 중:
- **"복리 지식"** (Karpathy/Hashimoto) — 위키가 누적될수록 페이지 간 교차참조 가치 ↑
- **"기본값과 가정의 함정"** — 인프라/프레임워크 기본값이 그대로 사고로 이어진다는 패턴 (6+ 페이지에 비교표)

## ✅ 최근 완료 작업 (2026-06~07 누적)

### 2026-07-01
- ✅ **Java 스터디 변환 아티팩트·URL·번호 대정비** — Notion published-site API(loadPageChunk/queryCollection)로 본문 직접 수집한 자료의 후처리: ` ```plain text ` 깨진 펜스 134건→`text`, notion.so 내부 깨진 링크 65건→`(→ N.N)`, 헤딩 `**`·본문 `****` 굵게 아티팩트, 챕터 파일명 **URL 영문화**(`java-study-chNN.md`).
- ✅ **챕터 내부 문서번호 학습순 통일 (wiki+raw)** — 다른 PC의 챕터 회전(입출력 ch10→05) 후 파일번호↔내부 문서번호 불일치를, **Notion 원번호 폐기**하고 학습순으로. 회전 매핑(cycle) 동시치환, `#####` 지역 소제목·코드펜스·ch00 예시 제외. 고아참조 0.
- ✅ **코드·표 표시 통일** — "글머리에서 빼낸다(top-level)" 규칙 [[guide-wiki-authoring-standards]] §2-5 명문화(리스트엔 굵은 리드인). 위키 전체 99.8% 이미 top-level, 어긋난 6개 정규화. bash 블록 160개 전부 top-level 확인.
- ✅ **bash 명령 정확성·복붙 안정성 전수 점검 (에이전트 5병렬)** — 🔴 module5 Step3-2 펜스 4-backtick + 🟡 7건: ch10 `-Xlog:'gc*'`(zsh nomatch), deploy 하드코딩 경로→플레이스홀더·firebase 대화형 분리, project-docs REPL 블록 `text` 재라벨, prerequisites A-3 분리, module3/4 `cd` 추가, module5 maxdepth 3.

### 2026-06-30
- ✅ **Java 스터디 3단계 로드맵 재편** — 외부 AI 지적(nav 비유기성) 검증 후 "언어→프레임워크→고급" 3단계로. nav 그룹화 + 챕터 11편 절대번호 제거·"다음 장" 체인 학습순 재배선 + [[guide-java-learning-path]] 3단계 재작성. (에이전트 3병렬)
- ✅ **챕터 번호 학습순 재부여 (raw+wiki)** — 입출력 ch10→05 회전(번호=학습순서). raw 6 + wiki 6 `git mv` + 링크·sources·tags·nav 회전 치환. Notion 원본 장번호는 `raw/java-study/README.md` 매핑표로 보존. (zsh 단어분리 함정으로 `while read`·명시 치환 사용)
- ✅ **Java·Spring nav 학습/레퍼런스 분리** — 개념·도구·소스를 「📚 레퍼런스 (찾아보기)」 그룹으로 묶어 학습(3단계·트랙)과 역할 분리. → 외부 AI 지적 3건(주객전도·순서·메뉴중첩) 모두 종결.
- ✅ **GSC 사이트 인증** — `overrides/main.html`(google-site-verification) + mkdocs `custom_dir: overrides`. (원격 sitemap/robots 작업과 짝)
- ✅ **멀티-PC 동기화** — 원격 14커밋(다른 PC Java 스터디 트랙/챕터, 변환 아티팩트 정리, sitemap/robots) fast-forward pull. **작업 전 `git pull --ff-only` 습관**을 메모리 [[project_overview]]에 기록.
- ✅ 라이브 확인(`wiki.wonslab.dev`) — 3단계·체인·카피라이트 정상.

### 2026-06-29
- ✅ **harness module 1~5 정밀 검증 + 후속 전부 종결** (에이전트 5병렬 검증 → 수정):
  - **Module 3 hooks 사양 3건 교정 (wiki+raw 동시)** — 실습이 실제로 안 돌던 결함: ① 차단 `exit 1`→`exit 2` ② 입력 argv→**stdin JSON `jq -r '.tool_input.command'`** ③ PostToolUse 파일경로 `CLAUDE_TOOL_OUTPUT_FILE`(없는 변수)→`jq -r '.tool_input.file_path'`. jq 설치 안내·Step5 검증을 stdin 방식으로. 실측 검증 완료.
  - **M1↔M5 Before/After 비교 정합** — M2·M5 태스크 A 재실행 프롬프트가 M1 원문과 달라(web/ 누락) 비교 무효였던 것 → api/+web/ 모노레포 원문 복원, 측정 7항목 일치, in-memory에 없는 "마이그레이션 처리" 행 제거.
  - **Module 4 AGENTS.md 개념 정정** — "Claude Code가 AGENTS.md 자동 로드/우선순위"는 거짓(공식: CLAUDE.md만 자동) → 정정 + `@AGENTS.md` import·심링크·`/init` 워크어라운드 + `/clear`·네이티브 서브에이전트(`.claude/agents/`) FAQ.
  - **경미**: M2/4/5 시작 `cd ~/harness-playground` 추가, M5 README 중첩 펜스 4-backtick, M1 산출물 표 커밋명 실제화.
- ✅ **sitemap.xml 자동화 확인 + robots.txt 신설** — sitemap은 MkDocs가 빌드마다 자동 생성(166 URL, `wiki.wonslab.dev` 자동 교정) → firebase `site/` 자동 배포. `wiki/robots.txt` 추가로 크롤러에 sitemap 위치 명시.
- ✅ **CLAUDE.md 규칙 #1 갱신**(사용자) — "raw 불변" → "단 내용에 **오류가 있을 경우 수정 가능**" (위 Module 3 raw 교정의 근거).
- ✅ **Loop 실습 후속 3종 종결** ([[guide-loop-engineering-demo]]):
  - ① **실행 검증**(Node v26 실측) — 후보 (A)(B)실패·(C)통과, 메아리방 13/20≈⅔, 검증 루프 정상 종료, "약4%"=이론 (2/3)⁸=3.9% 정확. demo에 "✅실행 검증됨" 노트.
  - ② **1차 출처 검증·보존** — `raw/loop-engineering/primary-sources.md` 신설. Osmani(✅)·Sonar(✅)·arXiv 3편 verbatim, Steinberger "650만 조회"는 2차 주장·OpenAI 소속 교정. src 페이지 반영.
  - ③ **토큰 비용 심화** — demo "Step 6.5" 신설(비용모델·무료 게이트 우선·종료조건 3종 goal/resource/budget).
- ✅ **커밋·배포 완료** — `ea49634`·`b98b6cc` (Firebase `wiki.wonslab.dev` 라이브). *(Loop 후속분은 별도 커밋 예정)*

### 2026-06-28
- ✅ **harness module1 Step 2 실습 흐름 정비** — "반복 문제 분석" 프롬프트가 신규 실습 프로젝트엔 빈 표가 정상임을 프롬프트 앞 맥락 박스로 명시 + `claude` 실행 블록 분리. (사용자가 따라하다 "갑자기 나온다" 지적)
- ✅ **harness 가이드 7편 톤앤매너·흐름 통일** (에이전트 7병렬) — H2 Step 시간표기 대시형(`— N분`), 커밋 코드블록만(`→ git commit` 화살표 제거), 단계 간 연결문 보강, module3 설명-코드 불일치(신규=새로 만들기/기존=머지) 수정, demo 정리→Step6 편입. (※ 별개로 다른 PC가 2026-06-29 module1~5 hooks 사양 검증 수행 — 영역 다름)

### 2026-06-27
- ✅ **글쓰기 스타일 1차 일괄 13편** — 비유 괄호 매핑·명사구 단편 → 장면+매핑 2문단 완결 문장(에이전트 13병렬). 규칙: 메모리 `feedback-wiki-writing-style`, 모범: ch6 "회의 vs 사람".
- ✅ **커스텀 도메인 `wiki.wonslab.dev` 반영** — `site_url`·guide 참조 URL·backlog 운영표 갱신(기본 도메인 web.app 병기).
- ✅ **카피라이트 `wonslab-hub` 와 통일** — `© 2026 wonslab · blog · wiki · club`(링크 포함).

### 2026-06-26
- ✅ **Loop 엔지니어링 실습 신설** — [[guide-loop-engineering-demo]] (Node mock 메아리방 vs 거부 신호 루프 + `claude -p` 헤드리스 + 외부 1차 출처). 진행 상태: 메모리 `loop-engineering-demo-progress`.
- ✅ **harness 가이드 전체 복붙 안정성 점검** — prerequisites(A-3 분리·A-4 3블록·A-5 git log 정정), module3(eslint --init 분리)·module5(`$WEEK` 전개 2건), demo(경로 견고화).
- ✅ **코드 가이드 대정비** — `guide-code-authoring-and-review` 5권 강조 톤다운 + 표 3.1~3.4 완전화 + 4·7장 통합 + lecture-object-ch5 GRASP 9패턴 동기화.
- ✅ **index.md 점검** — 카테고리 구조(Synthesis 중복→Guides)·src-*-lecture 중복 제거.
- ✅ **후속 (Loop 실습) — 2026-06-29 종결**: ① 실행 검증 완료 ② 1차 출처 raw 저장(`primary-sources.md`) 완료 ③ 토큰 비용 심화(Step 6.5) 완료.

### 2026-06-21
- ✅ **📚 5권 도서 강의 교재 모두 완성** — 오브젝트 18편 + EJ 11편 + 리팩터링 12편 + Clean Code 17편 + TDD 35편 = **93편**
- ✅ **5권 entity 모두 동일 5권 오각형 비교표** + "이 책의 자리" 한 문장 통일
- ✅ **오브젝트 강의 교재 18편** 작성 (사용자 1·2·3장 + 본 세션 4~15장 + 부록 A·B·C)
- ✅ **TDD 1부 4~16장 풍성하게 재작성** (각 200~240줄급)
- ✅ Q/A 토글 → `**Q.**` + `**A.**` 일괄 변환 (47편) + `scripts/convert_quiz.py`

### 2026-06-20
- ✅ **TDD (Kent Beck) ingest** — entity + 강의 교재 35편 (1·2·3부 + 부록·마치는 글)
- ✅ **Clean Code ingest** — entity + 강의 교재 17편
- ✅ **리팩터링 2판 ingest** — entity + 강의 교재 12편
- ✅ **Effective Java 강의 교재 wiki 노출 11편**
- ✅ **오브젝트 entity** 책 카드

### 2026-06-13
- ✅ **Loop 엔지니어링 ingest** (2026-06 Steinberger 발화) — concept-loop-engineering + src + 하네스 4단 진화 확장
- ✅ **"거부 신호 없는 자동화는 폭주한다" 패턴 비교표** 6행 누적

### 2026-06-07
- ✅ **부실 페이지 9개 공식 문서 기반 대폭 보강** (concept-spring-core, entity-jvm, concept-oop, concept-design-patterns, entity-spring-framework, entity-spring-boot, entity-querydsl, concept-api-versioning, concept-jspecify-null-safety)
- ✅ **위키 작성 표준 가이드 신설** ([[guide-wiki-authoring-standards]])
- ✅ **이 백로그 페이지 신설**
- ✅ Firebase 배포 (`wons-wiki.web.app` 정상화)

### 2026-06-06
- ✅ **2분코딩 영상 8편 ingest** (`raw/2bun-coding/`)
  - getConnection / Copilot 토큰 / 502 Keep-Alive / VARCHAR / 크론잡 / @Transactional / API 호환성 / HTTP HOL
- ✅ **mkdocs.yml에 "DB·운영·인프라" 카테고리 신규**
- ✅ **"기본값과 가정의 함정" 인사이트 패턴 비교표 누적** (6개 페이지에 양방향 연결)

### 2026-05-31 ~ 06-05
- ✅ MkDocs Material + Firebase Hosting 셋업
- ✅ 하네스 5모듈 가이드 Node 친화 step-by-step 재작성
- ✅ guide-harness-demo (5분 데모) 신설
- ✅ guide-deploy-mkdocs-firebase 다이어그램 HTML+텍스트 2채널 정착

### 2026-05-30
- ✅ 하네스 엔지니어링 자료 ingest + raw/ 주제별 디렉터리 재편
- ✅ Spring/Java 페이지들 첫 보강 (4월 작업 기반)

## 🔄 진행 중·다음 단계 후보

### 다음 세션 최우선 (Pending)

- [x] ~~**위키 본문 글쓰기 스타일 1차 일괄 점검·개선**~~ (2026-06-27 완료) — 비유 괄호 매핑·명사구 단편을 자연어 완결 문장 + 매핑 분리 문단으로 재작성. 규칙: 메모리 `feedback-wiki-writing-style`.
  - **1차 13편 완료** (에이전트 13병렬, ch6은 직전 세션 시연 완료): lecture-object ch4·ch5·ch7·ch9·ch12·ch13·ch15·appendixA·appendixC + lecture-clean-code ch4·ch6 + lecture-tdd ch4·ch11. 각 1건씩.
  - **2차 확장 후보 (남음)**: 5권 entity·concept-oop·concept-design-patterns·guide-code-authoring-and-review 의 도입·비유 산문 부분. 다음 세션에 같은 방식(에이전트 병렬)으로 진행 가능.
  - **유지 영역** (수정 X): 표·코드·체크리스트·`---` 절 헤더 옆 한 줄. 간결성이 본질인 곳은 그대로.

### 즉시 가능 (입력 대기 중)

- [x] ~~**📚 Java 도서 ingest 5권 entity + 강의 교재 모두 완성**~~ (2026-06-21)
  - *오브젝트* — entity + 강의 18편 (15장 + 부록 A·B·C)
  - *Effective Java* — entity + 강의 11편 (2~12장)
  - *리팩터링* — entity + 강의 12편 (1~12장)
  - *Clean Code* — entity + 강의 17편 (1~17장)
  - *TDD* — entity + 강의 35편 (1~32장 + 부록 A·B + 마치는 글)
  - **총 강의 교재 93편**
  - **5권 오각형 비교표** (관점·단위·시점·언어 + "이 책의 자리") 5권 entity 모두 동일 형식
- [ ] **Clean Code 책 기반 신규 concept 페이지 3개** — 사용자 노트·발췌 입력 대기
  - [ ] `concept-naming-conventions` — 2장 + 17장 N1~N7
  - [ ] `concept-tdd-laws-and-first` — 9장 TDD 3법칙 + F.I.R.S.T.
  - [ ] `concept-simple-design-rules` — 12장 Kent Beck 단순 설계 4규칙
- [x] ~~**raw 디렉터리 정리**~~ — 2026-06-20 완료. `raw/clean-code/리팩터링*` 12편 → `raw/refactoring/`
- [ ] **오브젝트 책 기반 신규 concept 페이지 4개** — 사용자 노트·발췌 입력 대기
  - [ ] `concept-solid` — SOLID 5원칙 (OCP·LSP·DIP 포함, 책 9·13장 기반)
  - [ ] `concept-grasp` — GRASP 책임 할당 9패턴 (책 5장 기반)
  - [ ] `concept-design-by-contract` — 계약에 의한 설계 (책 부록 A 기반)
  - [ ] `concept-domain-model-kinds` — 분석/설계/구현 모델 구분 (책 부록 C 기반)
- [ ] **Effective Java 책 기반 신규 concept 페이지 4개** — 강의 교재 본문 일부 발췌 ingest 대기
  - [ ] `concept-jpa-enum-mapping` — Item 34·35 + `@Enumerated(STRING)` 함정
  - [ ] `concept-functional-interfaces` — Item 44 표준 함수형 인터페이스 6개 + Spring 활용
  - [ ] `concept-generics-pecs` — Item 31 한정적 와일드카드 (Producer Extends Consumer Super)
  - [ ] `concept-java-serialization-risk` — Item 85·88·90 + Apache Commons Collections gadget chain 사례
- [ ] **5권 코드 가이드 — 다른 언어 분기 페이지** — 필요 시 신설 (현재 Java/Spring 가정, 다른 언어 학습자 등장 시)
  - 우선순위 순: Kotlin (Java 친화 99%) → TypeScript (리팩터링 책이 JS) → Python (OO·TDD·리팩터링 적용) → Go·Rust (OO 패러다임 다름)
  - 각 언어 매핑: record → data class/dataclass/struct, Optional → null safety, Stream → 언어별 함수형, try-with-resources → use/with/defer
  - EJ 동시성·직렬화 (11·12장) 만 언어별 다름. 나머지 원칙은 거의 모두 통용
  - 옵션: `guide-code-authoring-kotlin.md`·`guide-code-authoring-python.md` 등 분기 페이지. 단, 위키 비대화 위험 — 필요 증명 후 진행
  - 또는 현 `guide-code-authoring-and-review.md` 에 "언어별 매핑" 섹션 추가도 가능 (가성비 우위)
- [ ] **2분코딩 추가 영상** — 사용자가 새 영상 요약 보내면 같은 패턴으로 ingest
- [ ] **본인 프로젝트 GCP 배포 학습** — 하네스 5모듈 후 단계
  - playground (api/ + web/) → Cloud Run 또는 Cloud Functions
  - **결정 보류**: 현재 위키는 Firebase 그대로, GCP 다른 서비스 이전은 안 함 (2026-06-07 확정)
- [ ] **Notion DB "개발" ingest** — 보류 (2026-06-07)
  - 워크스페이스: `goodjwon`, DB ID: `3afaeb60-3963-4def-b97b-a3da70c4b843`
  - 막힌 원인: Notion 2025-09-03 API의 database → data_source 분리, MCP 도구가 새 data_source ID를 응답에 노출 안 함
  - 다음 시도: (a) Notion 통합 권한 "full content access" 재점검, (b) page URL 1개로 샘플 ingest 후 일괄 처리 패턴 마련, (c) MCP 버전 업데이트 대기

### 보강 후보 (낮은 우선순위)

여전히 부실한 페이지 — 외부 자료가 적거나 위키 운영용:

| 페이지 | 줄 수 | 보강 가치 |
|--------|------|---------|
| concept-lint | 30 | 낮음 (위키 운영 내부 개념) |
| concept-ingest | 32 | 낮음 (위키 운영 내부 개념) |
| concept-memex | 33 | 중간 (역사 자료 보강 가능) |
| concept-compounding-knowledge | 38 | 중간 |
| entity-claude-design | 43 | 중간 (Anthropic 도구) |

→ 우선순위 낮음. 외부 자료 부재 또는 위키 자체 메타 콘텐츠.

### 아이디어 (구체화 안 됨)

- 하네스 5모듈을 실제 playground에 적용한 후기 페이지 (synthesis)
- DDD 실전 적용 비교 페이지 (carrot/카카오페이/지방계약 비교)
- Spring Boot 4.x → 4.1 마이그레이션 노트 (출시 후)

## ⚠️ 주의사항·결정 사항

- **메모리 동기화 안 함 (2026-06-30)**: Claude 메모리(`~/.claude/projects/.../memory/`)는 git 저장소 바깥 PC별 로컬 파일 → push 대상 아님. 멀티-PC 공유 인계는 **이 backlog가 전담**(메모리는 각 PC 보조 캐시). 다른 PC에서 "메모리도 push?"는 No.
- **GCP 배포 결정 (2026-06-07)**: Firebase Hosting 그대로 유지. Cloud Storage+CDN/Cloud Run 이전 안 함.
- **다이어그램 표준 (2026-06-06)**: subgraph + 외부 연결은 무조건 HTML+flexbox. mermaid 사용 X.
- **commit 메시지 (2026-05-31)**: 학생용 가이드 안의 git commit 예시는 한글. 위키 자체 commit 메시지는 한글+영어 prefix 자유.
- **raw 구조 (2026-05-30)**: 모든 원본은 `raw/<주제>/`. 단일 파일도 디렉터리화. PDF/DOCX는 같은 폴더에 `.md` 변환본 동봉.
- **wiki 구조 = flat 유지 (2026-06-23)**: wiki/는 raw처럼 디렉터리로 쪼개지 **않는다**. 모든 페이지는 `wiki/` 바로 아래 평평하게 둔다.
  - **이유**: raw는 분류 수단이 물리 디렉터리뿐(PDF·DOCX라 prefix·태그·검색 불가)이라 디렉터리화가 불가피. wiki는 전부 `.md`라 ① 파일명 prefix(`concept-`/`lecture-`...) ② frontmatter `type:`·`tags:` ③ mkdocs `nav` ④ `[[wikilink]]` 그래프 — **4개 분류 수단**을 이미 가짐. 디렉터리는 더 약한 분류(폴더 한 겹)이면서 링크만 깨뜨림.
  - **기술적 제약**: `scripts/wikilinks.py`가 `[[name]]`을 **같은 폴더** 상대링크(`name.md`)로 변환 → 디렉터리로 쪼개면 디렉터리 넘는 교차참조 전부 깨짐.
  - **이미지·첨부**: wiki/ 안에 두지 않고 `raw/assets/` 한 곳에 모은다(빌드가 raw/assets/만 docs로 복사, Obsidian 첨부 경로도 동일). 페이지 .md는 균질 `.md`로 유지.
  - **번복 조건**: 정말 디렉터리화가 필요하면 `wikilinks.py`를 파일명(stem) 전역 해석으로 개조(작업 ~30분)하면 가능. 단 실익(폴더 한 겹) < 무경로 링크 손실 → 현재는 안 함.

## 🛠️ 운영 환경

| 항목 | 현재 상태 |
|------|----------|
| 호스팅 | Firebase Hosting → 커스텀 도메인 `wiki.wonslab.dev` (연결됨, 정식) / 기본 도메인 `wons-wiki.web.app`·`wons-wiki.firebaseapp.com` |
| 빌드 | `bash scripts/build-site.sh` (wiki/→docs/→site/) |
| 로컬 프리뷰 | `.venv/bin/mkdocs serve` (docs/만 watch) |
| 배포 | `firebase deploy --only hosting` |
| Git 원격 | `git@github.com:goodjwon/my-wiki.git` |
| 로컬 path | `/Users/jungwonpark/Documents/my-wiki/` |

## 📊 위키 규모 (2026-06-21 기준)

```bash
# 빠른 통계 (다른 PC에서 확인)
wc -l wiki/*.md | tail -1
ls wiki/*.md | wc -l
find raw -type f | wc -l
git log --oneline | wc -l
```

| 구분 | 수 |
|------|---|
| wiki 페이지 | **165개** (entity·concept·src·guide·lecture·index·log·backlog 종합) |
| 5권 도서 강의 교재 | **93편** (lecture-*) |
| raw 원본 | 약 130 파일 (15개 주제 디렉터리) |
| nav 카테고리 | 5개 (위키관리·하네스·Java/Spring·DB운영·📚도서) |
| 커밋 | 50+ (5월 30일~) |

## 🗺️ 새 세션 시작 가이드

다른 PC에서 처음 열었을 때:

```bash
# 1. 클론 + 진입
git clone git@github.com:goodjwon/my-wiki.git
cd my-wiki

# 2. 최신 상태 확인
git log --oneline -10
cat wiki/log.md | tail -50

# 3. 백로그 (이 페이지)와 표준 가이드 확인
cat wiki/backlog.md
cat wiki/guide-wiki-authoring-standards.md

# 4. 로컬 환경 준비 (필요 시)
python3 -m venv .venv
source .venv/bin/activate
pip install mkdocs-material pymdown-extensions mkdocs-glightbox mkdocs-roamlinks-plugin

# 5. 빌드 + 프리뷰
bash scripts/build-site.sh
.venv/bin/mkdocs serve   # http://127.0.0.1:8000

# 6. Claude Code 실행
claude
# 첫 메시지로: "backlog 읽고 현재 상태 요약해줘"
```

## 관련 페이지

- [[guide-wiki-authoring-standards]] — 다이어그램·분량·마킹 표준
- [[concept-ingest]] / [[concept-query]] / [[concept-lint]] — 위키 운영 워크플로
- [[concept-compounding-knowledge]] — 위키가 복리로 자라는 원리
- [[src-llm-wiki-pattern]] — 이 위키의 출발 패턴
