---
title: Ingest (소스 수집)
type: concept
tags: [워크플로, 위키운영]
sources: [ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-09-28
---

# Ingest (소스 수집)

새 원본 소스를 위키에 통합하는 핵심 작업입니다.

## 플로우

1. 사용자가 `raw/`에 소스를 추가합니다.
2. LLM이 소스를 읽고 사용자와 핵심 내용을 논의합니다.
3. `wiki/`에 source 요약 페이지(`src-*.md`)를 생성합니다.
4. 관련 entity·concept 페이지를 생성하거나 갱신합니다.
5. `wiki/index.md`를 업데이트합니다.
6. `wiki/log.md`에 기록을 추가합니다.

## 특성

- 단일 소스 ingest가 **10~15개 위키 페이지**에 영향을 줄 수 있습니다.
- 사용자가 참여하는 개별 ingest와 LLM이 자율로 처리하는 배치 ingest 중에서 고를 수 있습니다.
- 이 과정이 [[concept-compounding-knowledge|복리 지식]]을 실현하는 구체적 메커니즘입니다.

## 관련

- [[concept-query|Query]] — 위키에 질의
- [[concept-lint|Lint]] — 위키 정비
