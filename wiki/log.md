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
