---
title: 프로젝트 문서 시스템 셋업 가이드
type: synthesis
tags: [가이드, 문서화, CLAUDE.md, 템플릿]
sources: []
created: 2026-04-25
updated: 2026-04-25
---

# 프로젝트 문서 시스템 셋업 가이드

## 개요

my-wiki에서 검증된 LLM 기반 문서 관리 패턴을 다른 프로젝트에 적용하기 위한 가이드. 프로젝트 저장소에 `CLAUDE.md`와 `docs/` 구조를 넣으면 Claude Code가 문서를 자동 생성·유지한다.

## 구조 비교

```
my-wiki/ (개인 Second Brain)        project-x/ (프로젝트 문서)
├── CLAUDE.md                       ├── CLAUDE.md
├── raw/          ← 원본 불변         ├── docs/
├── wiki/         ← LLM 관리         │   ├── index.md
│   ├── index.md                    │   ├── decisions/    ← ADR
│   ├── log.md                      │   ├── api/          ← API 문서
│   ├── src-*.md                    │   ├── guides/       ← 개발 가이드
│   ├── concept-*.md                │   └── log.md
│   └── entity-*.md                 └── src/
└── .obsidian/                          └── (소스코드)
```

## Step 1: CLAUDE.md 템플릿

프로젝트 루트에 아래 내용으로 `CLAUDE.md`를 생성한다.

```markdown
# [프로젝트명] — 문서 스키마

## 프로젝트 개요
- 목적: [한 줄 설명]
- 기술 스택: [Spring Boot, JPA, PostgreSQL 등]
- 팀: [팀명 / 인원]

## 디렉터리 구조

\```
project-x/
├── CLAUDE.md
├── docs/
│   ├── index.md          # 문서 전체 목록
│   ├── log.md            # 작업 기록 (append-only)
│   ├── decisions/        # ADR (Architecture Decision Records)
│   │   └── adr-001-*.md
│   ├── api/              # API 문서
│   │   └── api-*.md
│   ├── guides/           # 개발 가이드
│   │   └── guide-*.md
│   └── troubleshooting/  # 트러블슈팅
│       └── ts-*.md
└── src/
\```

## 핵심 규칙

1. **docs/ 는 LLM이 관리한다.** 문서 생성·수정·삭제를 담당.
2. **index.md 는 항상 최신 상태를 유지한다.**
3. **log.md 에 모든 작업을 기록한다.**
4. **한국어를 기본 언어로 사용한다.**
5. **코드 변경 시 관련 문서도 함께 업데이트한다.**

## 문서 유형

| 접두사 | 유형 | 설명 | 예시 |
|--------|------|------|------|
| `adr-` | 의사결정 | 아키텍처/기술 결정과 근거 | adr-001-왜-jpa를-선택했나 |
| `api-` | API 문서 | 엔드포인트, 요청/응답, 에러 코드 | api-user, api-order |
| `guide-` | 가이드 | 개발 환경, 배포, 코딩 컨벤션 | guide-local-setup |
| `ts-` | 트러블슈팅 | 장애 대응, 버그 원인/해결 | ts-oom-2026-04 |

## 문서 형식

모든 문서는 YAML frontmatter를 포함한다:

\```yaml
---
title: 문서 제목
type: adr | api | guide | troubleshooting
tags: [태그1, 태그2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
\```

## 워크플로

### 코드 변경 시
1. 관련 API 문서가 있으면 함께 업데이트.
2. 새로운 아키텍처 결정이 있으면 ADR 생성.
3. index.md, log.md 업데이트.

### 장애/이슈 발생 시
1. 트러블슈팅 문서 생성 (원인, 해결, 재발 방지).
2. 관련 가이드가 있으면 보완.

### 질의 시
1. index.md에서 관련 문서 파악.
2. 문서를 읽고 답변 합성.
3. 보존 가치가 있으면 새 문서로 저장.

## 교차 참조
문서 내부 링크는 `[[파일명]]` 형식 (Obsidian 호환).

## 콘텐츠 보강 정책
1. 코드 예제 필수.
2. 실무 관점 우선.
3. 원본 URL/출처 보존.
```

## Step 2: 초기 문서 생성

프로젝트에 Claude Code를 실행하고 아래 명령을 수행한다.

```bash
# 1. docs 구조 생성
claude
> docs/ 구조를 초기화해줘

# 2. 기존 코드에서 문서 추출
> src/ 코드를 분석해서 API 문서를 생성해줘
> 프로젝트 아키텍처를 분석해서 가이드 문서를 만들어줘

# 3. 외부 소스 ingest (필요 시)
> https://example.com/api-spec 을 ingest 해줘
```

## Step 3: 일상 운영

| 상황 | 명령 |
|------|------|
| API 변경 | `관련 API 문서 업데이트해줘` |
| 새 기능 추가 | `이 기능에 대한 가이드 만들어줘` |
| 기술 결정 | `왜 Redis를 선택했는지 ADR 작성해줘` |
| 장애 발생 | `이 장애에 대한 트러블슈팅 문서 만들어줘` |
| 정비 | `lint 해줘` |
| 질의 | `인증 흐름이 어떻게 되어있어?` |

## Step 4: 개인 위키와 연결

프로젝트에서 범용적인 지식이 나오면 개인 위키(my-wiki)로 옮긴다.

```
project-x/docs/guide-ddd-적용기.md
  ↓ 범용 지식 추출
my-wiki/wiki/src-project-x-ddd.md
  ↓ 교차참조
my-wiki/wiki/concept-oop.md
```

## 문서 유형별 템플릿

### ADR (Architecture Decision Record)

```markdown
---
title: "ADR-001: [결정 제목]"
type: adr
tags: [아키텍처]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# ADR-001: [결정 제목]

## 상태
[제안 | 승인 | 폐기 | 대체됨]

## 맥락
왜 이 결정이 필요했는가?

## 결정
무엇을 결정했는가?

## 근거
왜 이 선택을 했는가? 어떤 대안을 검토했는가?

## 결과
이 결정으로 인해 어떤 영향이 예상되는가?
```

### API 문서

```markdown
---
title: "API: [리소스명]"
type: api
tags: [api, rest]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# API: [리소스명]

## 엔드포인트

### POST /api/v1/[리소스]
설명: [기능]

**Request**
\```json
{
  "field": "value"
}
\```

**Response 201**
\```json
{
  "id": 1,
  "field": "value"
}
\```

**Error Codes**
| 코드 | 설명 |
|------|------|
| 400 | 유효하지 않은 요청 |
| 409 | 중복 리소스 |
```

### 트러블슈팅

```markdown
---
title: "TS: [이슈 제목]"
type: troubleshooting
tags: [장애, 인프라]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# TS: [이슈 제목]

## 현상
언제, 어디서, 무엇이 발생했는가?

## 원인
근본 원인은 무엇이었는가?

## 해결
어떻게 해결했는가? (코드/설정 변경 포함)

## 재발 방지
같은 문제가 다시 발생하지 않으려면?
```

## 체크리스트

프로젝트에 문서 시스템을 적용할 때:

- [ ] `CLAUDE.md` 생성 (위 템플릿 기반)
- [ ] `docs/` 디렉터리 구조 생성
- [ ] `docs/index.md`, `docs/log.md` 초기화
- [ ] 기존 코드에서 API 문서 추출
- [ ] 아키텍처 결정 ADR 작성 (최소 1개)
- [ ] 개발 환경 셋업 가이드 작성
- [ ] `.gitignore`에 불필요 파일 제외
- [ ] README.md에 docs/ 안내 추가

## 관련 페이지

- [[src-llm-wiki-pattern]] — LLM 위키 패턴 원본
- [[concept-ingest]] — Ingest 워크플로
- [[concept-query]] — Query 워크플로
- [[concept-lint]] — Lint 워크플로
