---
title: qmd
type: entity
tags: [도구, 검색, CLI, MCP, 온디바이스]
sources: [ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://github.com/tobi/qmd]
created: 2026-04-18
updated: 2026-09-28
---

# qmd

마크다운 파일용 **로컬 하이브리드 검색 엔진**입니다. BM25 + 벡터 + LLM 리랭킹의 3계층 retrieval을 전부 온디바이스로 수행하며, CLI와 MCP 서버를 모두 제공합니다.

- **GitHub**: https://github.com/tobi/qmd

## 3계층 Retrieval

| 계층 | 엔진 | 역할 |
|------|------|------|
| **BM25 Full-Text** | SQLite **FTS5** | 키워드를 정확히 매칭하며 연산 부담이 거의 없습니다 |
| **Vector Semantic** | 로컬 embedding 모델 | 의미로 검색해 키워드와 다른 표현도 찾습니다 |
| **LLM Re-ranking** | 파인튜닝된 reranker | 후보 결과를 관련도 기준으로 재정렬합니다 |

세 결과를 **Reciprocal Rank Fusion (RRF)** 으로 결합합니다. 확신도가 높은 매치는 우선순위를 유지하면서 의미 검색으로 보강합니다.

## 온디바이스 동작

- `node-llama-cpp`와 **GGUF** 모델로 동작합니다.
- 모델 캐시는 `~/.cache/qmd/models/`입니다. 모델 3개(약 2GB)를 최초 실행 시 자동으로 내려받습니다.
- **외부 API 호출이 없습니다.** 모든 인덱싱·검색을 로컬에서 처리합니다.

## CLI 사용

```bash
# 컬렉션 등록 후 임베딩 생성
qmd collection add ~/notes --name notes
qmd embed

# 검색 모드
qmd search "authentication"      # BM25만
qmd vsearch "how to login"       # 벡터만
qmd query "user authentication"  # 하이브리드 + 리랭킹 (권장)

# 문서 가져오기
qmd get "notes/meeting.md"
qmd multi-get "docs/*.md" --json
```

## MCP 서버

Claude 등 AI 시스템과 통합되는 Model Context Protocol 서버를 제공합니다.

| 모드 | 명령 | 용도 |
|------|------|------|
| **stdio (기본)** | `qmd mcp` | 서브프로세스로 통신합니다 |
| **HTTP** | `qmd mcp --http` | 장기 실행 서버로 모델을 반복 로드하지 않습니다 |

MCP로 노출하는 도구는 `query`, `get`, `multi_get`, `status`입니다.

## LLM Wiki에서의 위치

[[src-llm-wiki-pattern|LLM Wiki 패턴]]은 위키가 커져 `index.md` 기반 탐색이 한계에 다다랐을 때의 **선택지**로 qmd를 추천합니다. CLI(LLM이 셸로 호출)와 MCP(LLM의 네이티브 도구) 두 진입점을 모두 갖춰 LLM이 쓰기 좋습니다.

> 원본 인용 (`raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md`):
> "[qmd](https://github.com/tobi/qmd) is a good option: it's a local search engine for markdown files with hybrid BM25/vector search and LLM re-ranking, all on-device. It has both a CLI (so the LLM can shell out to it) and an MCP server (so the LLM can use it as a native tool)."

## 적용 시점

- 위키 페이지 ~100개까지는 index.md만으로 충분합니다. LLM이 index를 먼저 읽고 필요한 페이지로 내려갑니다.
- 그 이상이거나 페이지 본문 검색이 필요할 때 qmd 도입을 검토합니다.

## 원본 출처

- raw: `raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md` (Optional: CLI tools 섹션)
- 외부: [github.com/tobi/qmd](https://github.com/tobi/qmd)

## 관련

- [[entity-obsidian]] — 위키 뷰어 (qmd는 보조 검색)
- [[concept-query]] — 위키 질의 워크플로 (대규모에서 qmd 활용)
- [[src-llm-wiki-pattern]] — 출처 패턴
