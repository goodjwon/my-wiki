---
title: "LLM Wiki: LLM 기반 개인 지식베이스 구축 패턴"
type: source
tags: [LLM, 지식관리, 세컨드브레인, 위키, PKM]
sources: [llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-04-18
---

# LLM Wiki — 소스 요약

LLM을 활용해 개인 지식베이스(위키)를 점진적으로 구축·유지하는 패턴을 제안하는 아이디어 문서.

## 핵심 문제의식

기존 RAG 방식(NotebookLM, ChatGPT 파일 업로드 등)은 매 질문마다 원본에서 지식을 재발견한다. **축적이 없다.** 5개 문서를 종합해야 하는 질문을 할 때마다 LLM이 처음부터 조각을 맞춰야 한다.

## 제안하는 대안

LLM이 **영구적이고 복리로 성장하는 위키**를 점진적으로 구축·유지한다.

- 새 소스가 들어오면 → 읽고, 요약하고, 기존 위키에 통합 (교차참조 갱신, 모순 표시, 종합 보강)
- 지식이 한 번 컴파일되면 계속 유지됨 — 매번 재도출하지 않음

## 3계층 아키텍처

| 계층 | 역할 | 소유자 |
|------|------|--------|
| **Raw sources** | 원본 문서 (불변) | 사용자 |
| **Wiki** | 구조화된 마크다운 페이지 | LLM |
| **Schema** | 규칙·워크플로 정의 (CLAUDE.md 등) | 사용자 + LLM |

## 3가지 핵심 작업

- **[[concept-ingest|Ingest]]** — 소스 추가 시 요약 생성, entity/concept 페이지 갱신, index·log 업데이트
- **[[concept-query|Query]]** — index를 읽고 관련 페이지를 찾아 답변 합성. 좋은 답변은 위키에 재편입
- **[[concept-lint|Lint]]** — 모순 검사, 고아 페이지 정리, 누락 교차참조 보완, 새 탐구 방향 제안

## 인덱싱·로깅

- **index.md** — 콘텐츠 중심 카탈로그. 카테고리별 페이지 목록 + 한줄 요약
- **log.md** — 시간순 작업 기록 (append-only). `## [날짜] 작업유형 | 제목` 형식

## 도구 생태계

- [[entity-obsidian|Obsidian]] — 위키 뷰어·편집기 (그래프 뷰, Dataview, Marp 플러그인)
- [[entity-obsidian-web-clipper|Obsidian Web Clipper]] — 웹 기사를 마크다운으로 변환
- [[entity-qmd|qmd]] — 마크다운용 로컬 검색 엔진 (BM25 + 벡터 하이브리드)
- [[entity-marp|Marp]] — 마크다운 기반 슬라이드 생성
- [[entity-dataview|Dataview]] — frontmatter 기반 동적 쿼리

## 왜 작동하는가

위키 유지의 병목은 독서나 사고가 아니라 **잡무(bookkeeping)**이다 — 교차참조 갱신, 요약 최신화, 모순 감지. 사람은 이 부담 때문에 위키를 포기한다. LLM은 지루해하지 않고, 교차참조를 빠뜨리지 않으며, 한 번에 15개 파일을 건드릴 수 있다.

## 사상적 계보

[[entity-vannevar-bush|Vannevar Bush]]의 **[[concept-memex|Memex]]** (1945)와 정신적으로 연결됨. 개인이 큐레이팅하는 지식 저장소, 문서 간 연상적 연결이 문서 자체만큼 가치 있다는 비전. Bush가 풀지 못한 부분 — 유지보수의 주체 — 을 LLM이 해결.
