---
title: Query (질의)
type: concept
tags: [워크플로, 위키운영]
sources: [llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-04-18
---

# Query (질의)

위키에 질문하고 답변을 합성하는 작업.

## 플로우

1. `wiki/index.md`를 읽어 관련 페이지 파악
2. 관련 페이지를 읽고 답변 합성 (마크다운, 비교표, 슬라이드 등)
3. 가치 있는 답변은 위키에 synthesis/comparison 페이지로 재편입

## 핵심 인사이트

**좋은 답변은 위키에 다시 들어간다.** 비교 분석, 발견한 연결, 새로운 통찰 — 이것들이 채팅 히스토리에서 사라지지 않고 위키에 축적된다. 탐구 자체가 [[concept-compounding-knowledge|복리 지식]]에 기여.

## 관련

- [[concept-ingest|Ingest]] — 소스 수집
- [[concept-lint|Lint]] — 위키 정비
