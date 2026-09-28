---
title: Obsidian
type: entity
tags: [도구, PKM, 에디터, 마크다운, 플러그인, 클리핑, 쿼리, 검색, MCP, 프레젠테이션]
sources: [ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://obsidian.md, https://obsidian.md/clipper, https://blacksmithgu.github.io/obsidian-dataview/, https://github.com/tobi/qmd, https://marp.app]
created: 2026-04-18
updated: 2026-09-28
---

# Obsidian

로컬 마크다운 파일 기반의 개인 지식 관리(PKM) 앱입니다. "Your thoughts are yours" — 모든 데이터를 사용자 디스크에 평문 .md로 저장합니다.

- **공식**: https://obsidian.md
- **개발**: Dynalist 팀

## 플랫폼

Windows · macOS · Linux · iOS · Android를 지원합니다. Sync를 사용하면 모든 플랫폼에서 같은 vault를 쓸 수 있습니다.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **로컬 평문 저장** | vault는 로컬 디렉터리이고 모든 노트는 `.md` 파일입니다. 앱이 없어도 다른 에디터에서 열립니다 |
| **Wikilinks** `[[]]` | 페이지명만으로 연결합니다. 페이지를 옮기거나 이름을 바꾸면 링크가 자동 갱신됩니다 |
| **Backlinks** | 어떤 페이지가 현재 페이지를 가리키는지 자동으로 추적합니다 |
| **Graph View** | 위키 전체 연결 구조를 시각화해 허브·고아 페이지를 찾게 해 줍니다 |
| **Canvas** | 무한 화이트보드 (브레인스토밍, 다이어그램) |
| **플러그인 생태계** | 커뮤니티 플러그인 수천 개 — Dataview, Marp 등 (아래 플러그인·주변 도구 참조) |
| **테마** | 커뮤니티 테마 다수 |

## 가격 모델

- **개인용 무료** (상업적 사용 시 commercial license)
- **유료 부가 서비스**:
  - **Obsidian Sync** — 종단간 암호화 동기화
  - **Obsidian Publish** — 노트를 웹사이트로 게시

## LLM Wiki에서의 역할

[[src-llm-wiki-pattern|LLM Wiki 패턴]]에서 Obsidian은 **위키 뷰어** 역할을 합니다.

> "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."
> — `raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md`

LLM이 vault의 마크다운을 직접 편집하고, 사용자는 Obsidian에서 실시간으로 결과를 봅니다. 링크를 따라가고, 그래프 뷰를 확인하고, 페이지를 읽습니다.

## 위키 운영에 유용한 기능

- **그래프 뷰** — 페이지 추가·삭제 후 연결 상태를 점검합니다 ([[concept-wiki-workflow|Lint]] 워크플로의 시각화 도구)
- **Hotkeys** — "Download attachments for current file" 같은 기능에 단축키를 지정합니다
- **플러그인·주변 도구** — Web Clipper(입력), Dataview(동적 뷰), qmd(대규모 검색), Marp(슬라이드 출력)는 아래 절에서 다룹니다

## 설정 팁

- **첨부파일 경로 고정**: Settings → Files and links → "Attachment folder path" = `raw/assets/`
- **이미지 일괄 다운로드 핫키**: Settings → Hotkeys → "Download" 검색 → 핫키 바인딩 (예: `Ctrl+Shift+D`). 클리핑 후 핫키 한 번으로 이미지가 로컬에 저장되어 LLM이 직접 참조할 수 있습니다.
- **파일 명령 제약**: 한글 파일명·공백 포함 파일명은 OS·도구별 호환성에 주의합니다.

## 철학

- **Privacy** — 데이터가 본인 디스크에만 있습니다.
- **Longevity** — 평문 마크다운은 앱이 사라져도 읽을 수 있습니다 ("file over app").
- **Flexibility** — 코어는 최소한으로 두고 플러그인으로 확장합니다.

## 플러그인·주변 도구

[[src-llm-wiki-pattern|LLM Wiki 패턴]]이 추천하는 도구 네 가지를 위키 운영 단계별로 정리합니다.

| 도구 | 종류 | 위키 운영 단계 | 한 줄 요약 |
|------|------|--------------|-----------|
| Obsidian Web Clipper | 공식 브라우저 확장 | Ingest 입력 | 웹 기사를 마크다운으로 `raw/`에 저장합니다 |
| Dataview | 커뮤니티 플러그인 | 탐색·대시보드 | frontmatter를 쿼리해 동적 표·목록을 만듭니다 |
| qmd | 외부 CLI·MCP 서버 | 대규모 Query | 온디바이스 하이브리드 검색 엔진입니다 |
| Marp | 커뮤니티 플러그인·CLI | Query 출력 | 마크다운을 슬라이드 덱으로 변환합니다 |

### Obsidian Web Clipper

웹 페이지를 마크다운으로 변환해 vault에 한 번의 클릭으로 저장하는 **Obsidian 팀의 공식 브라우저 확장**입니다 ([obsidian.md/clipper](https://obsidian.md/clipper)). Chrome · Safari · Firefox · Edge · Brave · Arc · Orion · Vivaldi를 지원합니다. 비공식 클리퍼와 달리 vault와 직접 통합되고 템플릿·속성 시스템이 풍부합니다.

| 기능 | 설명 |
|------|------|
| **템플릿 시스템** | 콘텐츠 유형(기사, 레시피, 논문 등)별로 템플릿을 적용합니다. 변수: `{{title}}`, `{{date}}`, `{{published}}`, `{{author}}` 등 |
| **하이라이트** | 텍스트·이미지·블록을 하이라이트하며, 저장 후 재방문 시에도 유지됩니다 |
| **속성 매핑** | 페이지 메타 태그·Schema.org 정보를 frontmatter로 자동 매핑합니다 |
| **콘텐츠 필터링** | Defuddle 라이브러리로 광고·내비게이션을 걷어내고 본문만 추출합니다 |
| **자동화** | 핫키와 URL 규칙으로 템플릿을 자동 적용하고, 정규식·필터로 저장 전 데이터를 가공합니다 |

LLM 위키에서는 `raw/`에 소스를 넣는 **주요 입력 채널**입니다.

```
웹 기사 발견 → Web Clipper 한 클릭 → raw/<주제>/ 에 .md 저장
  → 이미지 첨부는 raw/assets/ 로 일괄 다운로드 (Obsidian 핫키)
  → LLM에게 "ingest 해줘" → wiki/ 페이지 생성
```

### Dataview

노트를 **라이브 인덱스 + 쿼리 엔진**으로 다루는 플러그인입니다 ([공식 문서](https://blacksmithgu.github.io/obsidian-dataview/), [GitHub](https://github.com/blacksmithgu/obsidian-dataview)). frontmatter와 인라인 필드에 메타데이터를 달아두면 페이지 안에서 동적으로 갱신되는 표·목록을 만들 수 있습니다.

| 쿼리 유형 | 출력 |
|----------|------|
| **TABLE** | 지정한 열의 표 |
| **LIST** | 매칭 파일의 글머리표 목록 |
| **TASK** | 메타데이터를 포함한 태스크 항목 |
| **CALENDAR** | 날짜 기반 시각화 |

구조는 `<쿼리 유형>` + `FROM`(선택) + `WHERE` / `SORT` / `GROUP BY` / `LIMIT`(선택)입니다. 이 위키의 frontmatter 컨벤션(`type`, `tags`, `sources`, `created`, `updated`)은 Dataview 친화적이라, 다음과 같은 뷰를 바로 만들 수 있습니다.

```dataview
TABLE type, updated
FROM "wiki"
WHERE contains(tags, "워크플로")
SORT updated DESC
LIMIT 10
```

| 데이터 입력 방식 | 예시 |
|----------------|------|
| **Frontmatter** (YAML) | `tags: [book]`, `rating: 5` |
| **인라인 필드** | 본문에 `[author:: Tolkien]` 또는 `rating:: 5` |
| **암묵 필드** | 태그·링크·태스크는 자동으로 인덱싱됩니다 |

사용 모드는 세 가지입니다. 선언적 **DQL**(기본·권장), 본문에서 단일 값을 계산하는 **인라인 DQL**(`` `= file.size` ``), JavaScript API로 고급 커스터마이징을 하는 **Dataview JS**(`dv.pages("#book").table(...)`)입니다.

### qmd

마크다운 파일용 **로컬 하이브리드 검색 엔진**입니다 ([github.com/tobi/qmd](https://github.com/tobi/qmd)). 세 계층의 retrieval을 전부 온디바이스로 수행하고, CLI와 MCP 서버를 모두 제공합니다.

| 계층 | 엔진 | 역할 |
|------|------|------|
| **BM25 Full-Text** | SQLite FTS5 | 키워드를 정확히 매칭하며 연산 부담이 거의 없습니다 |
| **Vector Semantic** | 로컬 embedding 모델 | 키워드와 다른 표현도 의미로 찾습니다 |
| **LLM Re-ranking** | 파인튜닝된 reranker | 후보를 관련도 기준으로 재정렬합니다 |

세 결과는 **Reciprocal Rank Fusion(RRF)** 으로 결합합니다. `node-llama-cpp`와 GGUF 모델로 동작하며, 모델 3개(약 2GB)를 최초 실행 시 `~/.cache/qmd/models/`에 내려받습니다. 외부 API 호출은 없습니다.

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

# MCP 서버 (stdio 기본, --http는 모델을 반복 로드하지 않는 장기 실행 서버)
qmd mcp
qmd mcp --http
```

MCP로 노출하는 도구는 `query`, `get`, `multi_get`, `status`입니다. LLM이 셸로 호출할 수도(CLI), 네이티브 도구로 쓸 수도(MCP) 있습니다. 위키 페이지가 ~100개까지는 `index.md`만으로 충분하고, 그 이상이거나 본문 검색이 필요해질 때 도입을 검토합니다.

### Marp

마크다운으로 슬라이드 덱을 만드는 오픈소스(MIT) 생태계입니다 ([marp.app](https://marp.app), [GitHub](https://github.com/marp-team)). Obsidian 플러그인이 있어 위키 내용을 그대로 발표 자료로 출력할 수 있으며, Query 결과의 출력 형식 중 하나입니다.

| 컴포넌트 | 역할 |
|---------|------|
| **Marp Core** | 모든 공식 도구의 변환 엔진입니다 |
| **Marpit Framework** | Markdown + CSS 테마를 HTML/CSS 슬라이드로 변환하는 기반입니다 |
| **Marp CLI** | 명령줄 도구입니다 (`marp slides.md -o slides.pdf`) |
| **Marp for VS Code** | 실시간 미리보기와 내보내기를 지원합니다 |

출력 포맷은 HTML, PDF, PPTX, PNG/JPEG이며, PDF·PPTX 렌더링에는 Chrome/Chromium을 씁니다. 기본 테마는 default(흰 배경)·gaia(컬러 액센트)·uncover(미니멀)이고 커스텀 CSS로 자체 테마를 만들 수 있습니다.

```markdown
---
marp: true
theme: gaia
paginate: true
---

# 첫 슬라이드

내용...

---

# 두 번째 슬라이드

![bg right:40%](image.png)

- 글머리표
- $E = mc^2$  ← 수식 지원
```

`---`(수평선)이 슬라이드 구분자이고, 테마는 frontmatter의 `theme:`으로 지정합니다.

## 원본 출처

- raw: `raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md` (전반 + Tips and tricks + Optional: CLI tools)
- 외부: [obsidian.md](https://obsidian.md) · [Web Clipper](https://obsidian.md/clipper) · [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) · [qmd](https://github.com/tobi/qmd) · [Marp](https://marp.app)

## 관련

- [[src-llm-wiki-pattern]] — Obsidian을 위키 뷰어로 채택한 원본 패턴
- [[concept-wiki-workflow]] — Ingest·Query·Lint 위키 운영 워크플로
- [[concept-compounding-knowledge]] — 위키가 지식을 누적시키는 원리
- [[entity-claude-design]] — 다른 접근의 AI 도구 (디자인 → 코드)
