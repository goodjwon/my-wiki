---
title: 복리 지식 (Compounding Knowledge)
type: concept
tags: [지식관리, PKM, 세컨드브레인]
sources: [llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-04-18
---

# 복리 지식 (Compounding Knowledge)

지식이 단순히 쌓이는 것이 아니라, 새로운 정보가 기존 지식과 결합하면서 **복리적으로 가치가 증가**하는 현상.

## 핵심 아이디어

- 새 소스 하나가 기존 10개 페이지의 맥락을 풍부하게 만든다
- 교차참조가 늘어날수록 개별 페이지의 가치도 올라간다
- RAG는 매번 선형적으로 검색하지만, 위키는 이미 축적된 구조 위에서 동작한다

## LLM Wiki에서의 역할

[[src-llm-wiki-pattern|LLM Wiki 패턴]]의 핵심 전제. 위키가 "persistent, compounding artifact"인 이유:
- 교차참조가 이미 존재
- 모순이 이미 표시됨
- 종합이 이미 모든 소스를 반영

## 대비 개념

| 방식 | 지식 축적 | 한계 |
|------|-----------|------|
| RAG | 매 질문마다 재도출 | 축적 없음 |
| 수동 위키 | 복리 가능 | 유지보수 부담 → 포기 |
| LLM Wiki | 복리 + 자동 유지 | LLM 비용, 환각 가능성 |

## 관련 개념

- [[concept-memex|Memex]] — 연상적 연결을 통한 지식 축적의 원형
- [[concept-ingest|Ingest]] — 복리를 실현하는 구체적 작업
