---
title: Dataview
type: entity
tags: [도구, Obsidian, 플러그인, 쿼리]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://blacksmithgu.github.io/obsidian-dataview/]
created: 2026-04-18
updated: 2026-05-31
---

# Dataview

[[entity-obsidian|Obsidian]] 노트를 **라이브 인덱스 + 쿼리 엔진**으로 다루는 플러그인. YAML frontmatter와 인라인 필드에 메타데이터를 달아두면, 페이지 내에서 동적으로 갱신되는 테이블/리스트/태스크 뷰를 만들 수 있다.

- **공식 문서**: https://blacksmithgu.github.io/obsidian-dataview/
- **GitHub**: https://github.com/blacksmithgu/obsidian-dataview

## 쿼리 유형 (DQL)

| 유형 | 출력 |
|------|------|
| **TABLE** | 지정한 컬럼의 표 |
| **LIST** | 매칭 파일의 글머리표 리스트 |
| **TASK** | 메타데이터 포함 태스크 항목 |
| **CALENDAR** | 날짜 기반 시각화 |

## DQL 문법

```dataview
TABLE author, year, rating
FROM #book
WHERE rating >= 4
SORT year DESC
LIMIT 10
```

구조: `<쿼리 유형>` + `FROM` (선택) + `WHERE` / `SORT` / `GROUP BY` / `LIMIT` (선택)

예시:
```dataview
LIST FROM #poems WHERE author = "Edgar Allan Poe"
```

## 데이터 입력 방식

| 방식 | 예시 |
|------|------|
| **Frontmatter** (YAML) | `---\ntags: [book]\nrating: 5\n---` |
| **인라인 필드** | 본문에 `[author:: Tolkien]` 또는 `rating:: 5` |
| **암묵 필드** | 태그·링크·태스크는 자동 인덱싱 |

## 3가지 사용 모드

1. **DQL (Dataview Query Language)** — 선언적 쿼리 (기본·권장)
2. **인라인 DQL** — 본문 내 단일 값 표현식. `` `= file.size` ``
3. **Dataview JS** — JavaScript API. `dv.pages("#book").table(...)` — 고급 커스터마이징

## 실용 예시

- 책 컬렉션을 평점순으로 정렬
- 진행 중인 프로젝트 대시보드 (`WHERE status = "in-progress"`)
- 수면 추적 트렌드
- 자동 태그 기반 MOC(Map of Content)

## LLM Wiki에서의 활용

[[src-llm-wiki-pattern|LLM Wiki 패턴]]은 LLM이 위키 페이지에 일관된 frontmatter를 다는 점을 활용해 Dataview로 **동적 뷰**를 만들 것을 제안:

- 특정 태그를 가진 페이지 목록
- 최근 업데이트된 페이지 (`updated` 필드 기반)
- 소스별 관련 페이지

이 위키의 frontmatter 컨벤션(`type`, `tags`, `sources`, `created`, `updated`)도 Dataview 친화적으로 설계됨.

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "Dataview is an Obsidian plugin that runs queries over page frontmatter. If your LLM adds YAML frontmatter to wiki pages (tags, dates, source counts), Dataview can generate dynamic tables and lists."

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (Tips and tricks 섹션)
- 외부: [blacksmithgu.github.io/obsidian-dataview](https://blacksmithgu.github.io/obsidian-dataview/)

## 관련

- [[entity-obsidian]] — 호스트 앱
- [[src-llm-wiki-pattern]] — Dataview 활용을 제안한 원본
