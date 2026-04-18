---
title: Memex
type: concept
tags: [지식관리, 역사, 비전]
sources: [llm-wiki-pattern.md]
created: 2026-04-18
updated: 2026-04-18
---

# Memex

[[entity-vannevar-bush|Vannevar Bush]]가 1945년 에세이 "As We May Think"에서 제안한 개인 지식 저장 장치.

## 핵심 비전

- 개인이 큐레이팅하는 지식 저장소
- 문서 간 **연상적 연결(associative trails)**이 문서 자체만큼 가치 있음
- 사적이고, 능동적으로 관리되며, 연결이 핵심

## 웹과의 차이

Bush의 비전은 실제 웹보다 LLM Wiki에 더 가깝다:
- 웹: 공개, 분산, 연결은 있지만 큐레이션은 약함
- Memex: 사적, 큐레이팅됨, 연결이 의도적

## 미해결 과제 → LLM의 역할

Bush가 풀지 못한 문제: **누가 유지보수를 하는가?** 연상적 연결을 만들고 업데이트하는 잡무는 결국 사람의 몫이었고, 사람은 이 부담 때문에 포기한다. [[src-llm-wiki-pattern|LLM Wiki 패턴]]은 이 유지보수 주체를 LLM으로 대체한다.

## 관련

- [[concept-compounding-knowledge|복리 지식]] — Memex가 추구한 축적의 현대적 구현
- [[src-llm-wiki-pattern|LLM Wiki]] — Memex 비전의 실용적 실현
