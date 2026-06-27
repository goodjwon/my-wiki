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

2026-06-27

## 🎯 현재 위키의 큰 줄기 (Strategy)

이 위키는 4개 카테고리로 누적 중:

1. **위키·지식관리** — Obsidian·Memex·LLM Wiki 패턴 (메타·인프라)
2. **하네스·AI 에이전트** — Claude Code 하네스 5모듈 실습 + AI 도구 비용 관리
3. **Java·Spring·DDD** — Spring 7.0, JVM, OOP, 디자인 패턴, DDD 모델링
4. **DB·운영·인프라** — DB 운영 함정, 네트워크, K8s, "기본값 사고" 패턴 누적

핵심 인사이트가 두 가지로 자라는 중:
- **"복리 지식"** (Karpathy/Hashimoto) — 위키가 누적될수록 페이지 간 교차참조 가치 ↑
- **"기본값과 가정의 함정"** — 인프라/프레임워크 기본값이 그대로 사고로 이어진다는 패턴 (6+ 페이지에 비교표)

## ✅ 최근 완료 작업 (2026-06 누적)

### 2026-06-26
- ✅ **Loop 엔지니어링 실습 신설** — [[guide-loop-engineering-demo]] (Node mock 메아리방 vs 거부 신호 루프 + `claude -p` 헤드리스 + 외부 1차 출처). 진행 상태: 메모리 `loop-engineering-demo-progress`.
- ✅ **harness 가이드 전체 복붙 안정성 점검** — prerequisites(A-3 분리·A-4 3블록·A-5 git log 정정), module3(eslint --init 분리)·module5(`$WEEK` 전개 2건), demo(경로 견고화).
- ✅ **코드 가이드 대정비** — `guide-code-authoring-and-review` 5권 강조 톤다운 + 표 3.1~3.4 완전화 + 4·7장 통합 + lecture-object-ch5 GRASP 9패턴 동기화.
- ✅ **index.md 점검** — 카테고리 구조(Synthesis 중복→Guides)·src-*-lecture 중복 제거.
- ⏭️ **후속 (Loop 실습)**: ① `~/loop-demo` 실제 실행 검증([[verify]]) ② 외부 1차 출처 raw 저장 검토(2026 X 발화 재확인) ③ 토큰 비용·심화편.

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

- [ ] **위키 본문 글쓰기 스타일 일괄 점검·개선** — 비유에 괄호 매핑 박은 단편 명사구 ("회의 (메시지) 가 본질, …캐스팅" 류) 를 자연어 완결 문장 + 매핑 분리 문단으로 재작성. **규칙은 메모리 `feedback-wiki-writing-style` 참조** (괄호 매핑·명사구 종결 금지, 책 풍 "관람객은 스스로 표를 사고…" 처럼).
  - **시연 완료**: `wiki/lecture-object-ch6.md:41` ("회의 vs 사람" 비유) 1건 모범 답안 반영. 같은 톤으로 일괄 진행.
  - **1차 대상 14개 페이지** (괄호 매핑 `(메시지)·(객체)·(역할)` 등이 grep 으로 식별됨):
    - lecture-object: ch4·ch5·ch6 (완료)·ch7·ch9·ch12·ch13·ch15·appendixA·appendixC
    - lecture-clean-code: ch4·ch6
    - lecture-tdd: ch4·ch11
  - **2차 확장 후보**: 5권 entity·concept-oop·concept-design-patterns·guide-code-authoring-and-review 의 도입·비유 산문 부분.
  - **진행 방식 미정**: Agent fleet 으로 페이지별 병렬 처리 (~19 agent) vs 사용자 직접 우선순위 지정. 다음 세션 시작 시 결정.
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
| 호스팅 | Firebase Hosting → `wons-wiki.web.app` |
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
