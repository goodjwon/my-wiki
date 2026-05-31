---
title: Query (질의)
type: concept
tags: [워크플로, 위키운영, 질의응답]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-05-31
---

# Query (질의)

위키에 질문하고 LLM이 관련 페이지를 종합해 답하는 워크플로. [[concept-ingest|Ingest]]와 함께 LLM Wiki의 두 축.

## RAG와의 차이

전통 RAG는 매 질의마다 raw 문서에서 청크를 검색·재합성한다. **누적되는 것이 없다.**

Query는 다르다 — 이미 [[concept-ingest|Ingest]]를 통해 위키에 구조화·교차참조된 페이지가 존재한다. LLM은:

1. `wiki/index.md` 를 읽어 관련 페이지 식별
2. 해당 페이지들을 로드, 답변 합성
3. 출처(`[[페이지명]]`)와 함께 인용

→ 합성 자체가 빠르고, 같은 질문을 다시 받아도 추가 비용 없이 일관된 답이 나온다.

## 답변 출력 형식

질문 성격에 따라 다양:

- **마크다운 페이지** (가장 일반적)
- **비교표** (entity vs entity, version vs version 등)
- **슬라이드 덱** ([[entity-marp|Marp]])
- **차트·캔버스** (matplotlib, Obsidian Canvas)
- **다이어그램** (Mermaid)

## 핵심 인사이트: 답변을 다시 위키로

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "**good answers can be filed back into the wiki as new pages.** A comparison you asked for, an analysis, a connection you discovered — these are valuable and shouldn't disappear into chat history."

가치 있는 Query 응답은 채팅 히스토리에서 사라지지 않게 **synthesis / comparison 페이지로 다시 위키에 저장**한다. 이 과정에서 탐구 자체가 [[concept-compounding-knowledge|복리 지식]]에 기여한다.

이 위키의 예: [[guide-project-docs-setup]] (synthesis 페이지로 저장된 Query 결과)

## 표준 플로우

```
사용자 질문
   ↓
LLM이 index.md 읽음 → 관련 페이지 식별
   ↓
관련 페이지 로드 + 답변 합성 (출처 인용)
   ↓
답변이 보존 가치 있나?
   ├─ Yes → synthesis/comparison 페이지로 저장
   │         → index.md, log.md 업데이트
   └─ No → 답변만 반환
```

## 위키 규모와 검색

- **~100 페이지**: `index.md` 통독으로 충분 (LLM이 인덱스 먼저 보고 드릴다운)
- **그 이상**: [[entity-qmd|qmd]] 같은 하이브리드 검색 엔진 도입 검토

## 관련

- [[concept-ingest]] — 소스 수집 (Query의 입력 재료)
- [[concept-lint]] — 위키 정비 (Query 품질을 받쳐주는 정비 활동)
- [[concept-compounding-knowledge]] — Query 응답이 누적되는 원리
- [[entity-qmd]] — 대규모 위키의 보조 검색 엔진
- [[entity-marp]] — Query 출력 형식 중 하나
- [[src-llm-wiki-pattern]] — 원본 워크플로 정의
