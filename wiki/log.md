---
title: Wons Wiki 로그
---

# Wiki Log

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
