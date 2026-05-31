---
title: qmd
type: entity
tags: [도구, 검색, CLI, MCP, 온디바이스]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://github.com/tobi/qmd]
created: 2026-04-18
updated: 2026-05-31
---

# qmd

마크다운 파일용 **로컬 하이브리드 검색 엔진**. BM25 + 벡터 + LLM 리랭킹의 3계층 retrieval을 전부 온디바이스로 수행. CLI + MCP 서버 모두 제공.

- **GitHub**: https://github.com/tobi/qmd

## 3계층 Retrieval

| 계층 | 엔진 | 역할 |
|------|------|------|
| **BM25 Full-Text** | SQLite **FTS5** | 키워드 정확 매칭, 연산 부담 거의 없음 |
| **Vector Semantic** | 로컬 embedding 모델 | 의미 기반 검색 (키워드와 다른 표현도 매칭) |
| **LLM Re-ranking** | 파인튜닝된 reranker | 후보 결과를 관련도 기준 재정렬 |

세 결과를 **Reciprocal Rank Fusion (RRF)** 으로 결합. 고확신 매치는 우선순위 유지하면서 의미 검색을 보강.

## 온디바이스 동작

- `node-llama-cpp` + **GGUF** 모델
- 모델 캐시: `~/.cache/qmd/models/` (3개 모델 약 2GB, 최초 실행 시 자동 다운로드)
- **외부 API 호출 0건** — 모든 인덱싱·검색이 로컬

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

Claude 등 AI 시스템과 통합되는 Model Context Protocol 서버 제공:

| 모드 | 명령 | 용도 |
|------|------|------|
| **stdio (기본)** | `qmd mcp` | 서브프로세스 트랜스포트 |
| **HTTP** | `qmd mcp --http` | 장기 실행 서버. 모델 반복 로드 회피 |

MCP 노출 도구: `query`, `get`, `multi_get`, `status`

## LLM Wiki에서의 위치

[[src-llm-wiki-pattern|LLM Wiki 패턴]]은 위키가 커져 `index.md` 기반 탐색이 한계에 다다랐을 때의 **선택지**로 qmd를 추천. CLI(LLM이 shell out)와 MCP(LLM의 네이티브 도구로) 양쪽 진입점을 가져 LLM 친화적.

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "[qmd](https://github.com/tobi/qmd) is a good option: it's a local search engine for markdown files with hybrid BM25/vector search and LLM re-ranking, all on-device. It has both a CLI (so the LLM can shell out to it) and an MCP server (so the LLM can use it as a native tool)."

## 적용 시점

- 위키 페이지 ~100개까지는 index.md만으로 충분 (LLM이 index 먼저 읽고 드릴다운)
- 그 이상 또는 페이지 본문 검색이 필요할 때 qmd 도입 검토

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (Optional: CLI tools 섹션)
- 외부: [github.com/tobi/qmd](https://github.com/tobi/qmd)

## 관련

- [[entity-obsidian]] — 위키 뷰어 (qmd는 보조 검색)
- [[concept-query]] — 위키 질의 워크플로 (대규모에서 qmd 활용)
- [[src-llm-wiki-pattern]] — 출처 패턴
