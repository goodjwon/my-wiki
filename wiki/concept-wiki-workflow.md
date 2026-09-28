---
title: LLM 위키 워크플로 — Ingest·Query·Lint
type: concept
tags: [워크플로, 위키운영, 질의응답, LLM-Wiki]
sources: [ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md]
created: 2026-09-28
updated: 2026-09-28
---

# LLM 위키 워크플로 — Ingest·Query·Lint

LLM이 유지·관리하는 위키는 세 가지 반복 작업으로 굴러갑니다. 원본을 들여와 페이지로 만드는 **Ingest**, 쌓인 페이지로 질문에 답하는 **Query**, 위키의 건강을 점검하는 **Lint**입니다. 세 작업 모두 결과를 `wiki/`에 되돌려 쓰기 때문에, 작업할수록 위키가 두꺼워지는 [[concept-compounding-knowledge|복리 지식]] 구조가 만들어집니다.

> 원본 인용 (`raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md`):
> "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."

사람은 소스를 고르고 질문을 던지고 방향을 정합니다. 요약·교차참조·정리 같은 반복 노동은 LLM이 맡습니다.

## 세 워크플로 비교

| 구분 | Ingest | Query | Lint |
|------|--------|-------|------|
| 입력 | `raw/<주제>/`에 추가된 원본 | 사용자 질문 | 위키 전체 (또는 지정 섹션) |
| 산출물 | `src-*` 요약 + entity·concept 신설·갱신 | 답변 (가치 있으면 `synthesis`·`comparison` 페이지) | 모순 교정, 링크 보강, 신규 질문·소스 제안 |
| 갱신 파일 | `wiki/*`, `index.md`, `log.md` | (저장 시) 새 페이지, `index.md`, `log.md` | 수정 페이지, `log.md` (페이지 증감 시 `index.md`) |
| 빈도 | 새 소스가 생길 때마다 | 필요할 때마다 | 주기적 또는 대규모 변경 후 |
| 사람의 역할 | 핵심 내용 논의·강조점 지정 | 질문·보존 여부 판단 | 결정 사항 승인 |
| 이 위키의 스킬 | `/ingest` | `/query` | `/lint` |

세 작업은 순환합니다. Ingest가 Query의 재료를 만들고, Query 결과가 다시 페이지로 쌓이며, Lint가 둘이 남긴 흔적의 모순과 빈틈을 메웁니다.

## Ingest

새 원본 소스를 위키에 통합하는 핵심 작업입니다.

### 플로우

1. 사용자가 `raw/<주제>/`에 소스를 추가합니다. PDF·DOCX는 같은 디렉터리에 `.md` 변환본을 함께 둡니다.
2. LLM이 소스를 읽고 사용자와 핵심 내용을 논의합니다.
3. `wiki/`에 source 요약 페이지(`src-간결한제목.md`)를 생성합니다.
4. 관련 entity·concept 페이지를 생성하거나 갱신하고, 기존 페이지와 양방향으로 연결합니다.
5. `wiki/index.md`를 업데이트합니다.
6. `wiki/log.md`에 `## [YYYY-MM-DD] ingest | 제목` 형식으로 기록합니다.

### 특성

- 단일 소스 ingest가 **10~15개 위키 페이지**에 영향을 줄 수 있습니다.
- 사용자가 참여하는 개별 ingest와 LLM이 자율로 처리하는 배치 ingest 중에서 고를 수 있습니다.
- 웹 기사는 [[entity-obsidian|Obsidian Web Clipper]]로 `raw/`에 빠르게 넣을 수 있습니다.

### 이 위키의 실제 규칙

| 규칙 | 내용 |
|------|------|
| raw 불변 | `raw/`는 수정·삭제하지 않습니다. 사실 오류만 예외로 교정하고 근거를 주석으로 남깁니다 |
| 원본 불신 검증 | Notion·개인 정리·외부 AI 산출물도 틀릴 수 있으므로, 기술적 사실은 공식 문서·정평 있는 도서와 대조합니다 |
| 원본 추적 | frontmatter `sources:`에 `raw/`를 뺀 경로를 적고, 본문 인용은 `raw/<주제>/<파일>` 전체 경로로 씁니다 |
| 코드 예제 필수 | 설명만 있는 요약은 가치가 낮으므로 핵심 코드 예제를 반드시 옮깁니다 |
| 실행 검증 배너 | 실습 페이지는 실제로 돌려 본 뒤 `✅ 실행 검증됨 (날짜, 환경)` 배너로 재현 범위를 밝힙니다 |
| 문체·스캐폴드 게이트 | 저장 전에 `style-lint.sh`(합니다체·금칙 용어), 실습이 있으면 `scaffold-lint.sh`(파일 리드인↔package↔클래스명)를 통과시킵니다 |

실행 검증 배너의 실제 예시는 [[guide-advisor-worker-demo]]에 있습니다. 헤드리스 실행으로 관찰 포인트를 재현한 뒤, 재현하지 못한 부분은 원본 쪽을 교정합니다.

```bash
# 페이지 저장 후 게이트 (저장소 루트에서)
bash scripts/style-lint.sh wiki/src-새소스.md
bash scripts/scaffold-lint.sh wiki/guide-새실습.md   # 실습 예제가 있을 때만
bash scripts/build-site.sh
```

## Query

위키에 질문하고 LLM이 관련 페이지를 종합해 답하는 워크플로입니다. Ingest와 함께 LLM 위키의 두 축을 이룹니다.

### RAG와의 차이

전통 RAG는 매 질의마다 raw 문서에서 청크를 검색·재합성하므로 **누적되는 것이 없습니다.** Query는 이미 Ingest로 구조화·교차참조된 페이지 위에서 동작합니다.

1. `wiki/index.md`를 읽어 관련 페이지를 찾습니다.
2. 해당 페이지들을 읽고 답변을 합성합니다.
3. 출처(`[[페이지명]]`)와 함께 인용합니다.

따라서 합성이 빠르고, 같은 질문을 다시 받아도 추가 비용 없이 일관된 답이 나옵니다.

### 표준 플로우

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

### 답변을 다시 위키로

> 원본 인용 (`raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md`):
> "**good answers can be filed back into the wiki as new pages.** A comparison you asked for, an analysis, a connection you discovered — these are valuable and shouldn't disappear into chat history."

가치 있는 응답은 채팅 히스토리에서 사라지지 않게 **synthesis·comparison 페이지로 저장**합니다. 이 위키에서는 [[guide-project-docs-setup]]이 Query 결과를 페이지로 보존한 예입니다.

### 답변 출력 형식

| 형식 | 쓰임 |
|------|------|
| 마크다운 페이지 | 가장 일반적인 형식입니다 |
| 비교표 | entity 대 entity, 버전 대 버전 비교에 씁니다 |
| 슬라이드 덱 | Marp([[entity-obsidian]] 참조)로 위키 내용을 그대로 발표 자료로 만듭니다 |
| 차트·캔버스 | matplotlib, Obsidian Canvas로 시각화합니다 |
| 다이어그램 | 단순 흐름은 Mermaid, 그룹 구조는 HTML + flexbox로 그립니다 |

### 위키 규모와 검색

| 규모 | 탐색 방식 |
|------|----------|
| ~100 페이지 | `index.md` 통독으로 충분합니다. 인덱스를 먼저 보고 필요한 페이지로 내려갑니다 |
| 그 이상 | qmd([[entity-obsidian]] 참조) 같은 로컬 하이브리드 검색 엔진 도입을 검토합니다 |

## Lint

위키의 건강 상태를 점검하고 개선하는 주기적 작업입니다. 위키가 커질수록 유지보수 부담이 커지는데, LLM이 이를 맡으므로 위키가 방치되지 않습니다.

### 점검 항목

| 항목 | 확인 방법 |
|------|----------|
| 페이지 간 **모순** | 같은 주제를 다룬 페이지의 수치·주장을 대조합니다 |
| **오래된 주장** | 새 소스가 대체한 내용을 찾아 `updated`와 함께 갱신합니다 |
| **고아 페이지** | 인바운드 링크가 없는 페이지를 찾습니다 (Obsidian 그래프 뷰로 시각 확인) |
| **누락된 개념** | 여러 번 언급되지만 자체 페이지가 없는 개념을 찾습니다 |
| **교차참조** | 관련 페이지 간 빠진 링크를 양방향으로 추가합니다 |
| **데이터 공백** | 웹 검색으로 채울 수 있는 빈칸과 탐구할 새 질문·소스를 제안합니다 |
| **중복 페이지** | 같은 대상을 다룬 페이지를 하나로 통합하고 인바운드 링크를 다시 겁니다 |
| **문체·스캐폴드** | `style-lint.sh`, `scaffold-lint.sh`로 기계 검출 가능한 위반을 걸러냅니다 |

### 정본 표 원칙

같은 인사이트 패턴을 공유하는 페이지들은 **같은 행 집합·같은 열의 비교표를 한 벌씩** 갖고, 각 페이지는 자기 행만 `**주제 (이 페이지)**`로 표시합니다. Lint에서 멤버 페이지 하나가 바뀌면 나머지 멤버의 표도 함께 맞춥니다. 표가 어긋나면 어느 페이지에서 보더라도 같은 정본을 확인할 수 있다는 약속이 깨집니다. 상세 규칙은 [[guide-wiki-authoring-standards]]를 따릅니다.

## 같은 인사이트 패턴 — 생성 뒤에 검증 게이트를 둔다

| 페이지 | 생성 주체 | 검증 게이트 | 게이트가 없을 때 |
|------|----------|------------|----------------|
| **LLM 위키 워크플로 (이 페이지)** | LLM이 페이지 작성 | Lint·style-lint·실행 검증 배너 | 모순·고아 페이지가 누적되고 틀린 원본이 정본이 됩니다 |
| [[concept-harness-engineering]] | 에이전트가 코드 작성 | 테스트·hook·자기검증 루프 | 그럴듯하지만 동작하지 않는 코드가 통과합니다 |
| [[concept-advisor-worker]] | Worker가 구현 | Advisor가 diff·테스트를 직접 재실행 | Worker의 완료 보고를 그대로 믿게 됩니다 |
| [[concept-compounding-knowledge]] | 작업마다 지식 누적 | 누적물을 위키에 구조화해 저장 | 채팅 히스토리에 흩어져 재사용되지 않습니다 |

공통 구조는 "생성은 싸고 검증은 비싸다"는 점입니다. 검증을 사람의 기억에 맡기지 않고 스크립트·배너·재실행 같은 **기계적 게이트**로 고정해야 누적이 품질을 해치지 않습니다.

## 빠른 체크리스트

- [ ] Ingest: 원본을 `raw/<주제>/`에 두고 URL을 상단에 적었습니까?
- [ ] Ingest: 기술적 사실을 공식 문서와 대조했습니까?
- [ ] Ingest: 새 페이지가 기존 concept·entity와 양방향으로 연결됩니까?
- [ ] Query: 보존 가치가 있는 답변을 synthesis·comparison 페이지로 남겼습니까?
- [ ] 공통: frontmatter `sources:`·`updated`를 갱신했습니까?
- [ ] 공통: `index.md`·`log.md`를 갱신했습니까?
- [ ] 공통: `style-lint.sh`와 `build-site.sh`를 통과했습니까?
- [ ] Lint: 정본 표를 공유하는 멤버 페이지를 함께 맞췄습니까?

## 원본 출처

- raw: `raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md` (Operations 섹션 — Ingest·Query·Lint 정의)
- 이 위키의 운영 규칙: 저장소 루트 `CLAUDE.md` (워크플로·콘텐츠 보강 정책·원본 추적 마킹 규칙)

## 관련 페이지

- [[src-llm-wiki-pattern]] — 세 워크플로를 정의한 원본 패턴
- [[concept-compounding-knowledge]] — 워크플로가 지식을 누적시키는 원리
- [[entity-obsidian]] — 위키 뷰어와 주변 도구 (Web Clipper·Dataview·qmd·Marp)
- [[guide-wiki-authoring-standards]] — 문체·다이어그램·정본 표 작성 표준
- [[guide-project-docs-setup]] — Query 결과를 페이지로 보존한 예
- [[guide-advisor-worker-demo]] — 실행 검증 배너 예시
