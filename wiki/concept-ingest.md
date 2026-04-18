---
title: Ingest (소스 수집)
type: concept
tags: [워크플로, 위키운영]
sources: [llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-04-18
---

# Ingest (소스 수집)

새 원본 소스를 위키에 통합하는 핵심 작업.

## 플로우

1. 사용자가 `raw/`에 소스를 추가
2. LLM이 소스를 읽고 핵심 내용을 논의
3. `wiki/`에 source 요약 페이지 생성
4. 관련 entity·concept 페이지를 생성 또는 갱신
5. `wiki/index.md` 업데이트
6. `wiki/log.md`에 기록 추가

## 특성

- 단일 소스 ingest가 **10~15개 위키 페이지**에 영향을 줄 수 있음
- 개별 ingest(사용자 참여) vs 배치 ingest(자율적) 선택 가능
- 이 과정이 [[concept-compounding-knowledge|복리 지식]]을 실현하는 구체적 메커니즘

## 관련

- [[concept-query|Query]] — 위키에 질의
- [[concept-lint|Lint]] — 위키 정비
