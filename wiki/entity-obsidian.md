---
title: Obsidian
type: entity
tags: [도구, PKM, 에디터, 마크다운]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://obsidian.md]
created: 2026-04-18
updated: 2026-05-31
---

# Obsidian

로컬 마크다운 파일 기반의 개인 지식 관리(PKM) 앱. "Your thoughts are yours" — 모든 데이터를 사용자 디스크에 평문 .md로 저장.

- **공식**: https://obsidian.md
- **개발**: Dynalist 팀

## 플랫폼

Windows · macOS · Linux · iOS · Android (전 플랫폼 동일 vault 사용 가능, Sync 사용 시)

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **로컬 평문 저장** | vault = 로컬 폴더. 모든 노트는 `.md` 파일. 앱이 없어도 다른 에디터에서 열림 |
| **Wikilinks** `[[]]` | 페이지명만으로 연결. 페이지 이동/이름 변경 시 링크 자동 갱신 |
| **Backlinks** | 어떤 페이지가 현재 페이지를 가리키는지 자동 추적 |
| **Graph View** | 위키 전체 연결 구조 시각화. 허브·고아 페이지 식별 |
| **Canvas** | 무한 화이트보드 (브레인스토밍, 다이어그램) |
| **플러그인 생태계** | 커뮤니티 플러그인 수천 개 — [[entity-dataview]], [[entity-marp]] 등 |
| **테마** | 커뮤니티 테마 다수 |

## 가격 모델

- **개인용 무료** (상업적 사용 시 commercial license)
- **유료 부가 서비스**:
  - **Obsidian Sync** — 종단간 암호화 동기화
  - **Obsidian Publish** — 노트를 웹사이트로 게시

## LLM Wiki에서의 역할

[[src-llm-wiki-pattern|LLM Wiki 패턴]]에서 Obsidian은 **위키 뷰어**:

> "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."
> — `raw/llm-wiki-pattern/llm-wiki-pattern.md`

LLM이 vault의 마크다운을 직접 편집하고, 사용자는 Obsidian에서 실시간으로 결과를 본다 — 링크 따라가기, 그래프 뷰 확인, 페이지 읽기.

## 위키 운영에 유용한 기능

- **그래프 뷰** — 페이지 추가·삭제 후 연결 상태 점검 ([[concept-lint|Lint]] 워크플로의 시각화 도구)
- **[[entity-dataview|Dataview]]** — frontmatter 기반 동적 쿼리 (태그별 페이지 목록 등)
- **[[entity-marp|Marp]] 플러그인** — 위키 콘텐츠 → 슬라이드 덱
- **[[entity-obsidian-web-clipper|Web Clipper]]** — 웹 기사 → vault `.md`
- **Hotkeys** — "Download attachments for current file" 같은 기능 단축키 지정

## 설정 팁

- **첨부파일 경로 고정**: Settings → Files and links → "Attachment folder path" = `raw/assets/`
- **이미지 일괄 다운로드 핫키**: Settings → Hotkeys → "Download" 검색 → 핫키 바인딩 (예: `Ctrl+Shift+D`)
- → 클리핑 후 핫키 한 번으로 이미지가 로컬에 저장됨. LLM이 직접 이미지를 참조할 수 있음.
- **파일 명령 제약**: 한글 파일명/공백 포함 파일명은 OS·도구별 호환성에 주의

## 철학

- **Privacy** — 데이터가 본인 디스크에만 있음
- **Longevity** — 평문 마크다운은 앱이 사라져도 읽을 수 있음 ("file over app")
- **Flexibility** — 코어는 미니멀, 플러그인으로 확장

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (전반 + Tips and tricks)
- 외부: [obsidian.md](https://obsidian.md)

## 관련

- [[src-llm-wiki-pattern]] — Obsidian을 위키 뷰어로 채택한 원본 패턴
- [[entity-dataview]] — 가장 자주 쓰이는 메타데이터 쿼리 플러그인
- [[entity-marp]] — 마크다운 슬라이드 플러그인
- [[entity-obsidian-web-clipper]] — 공식 웹 클리퍼
- [[entity-qmd]] — 외부 검색 엔진 (대규모 vault 보조)
- [[concept-ingest]] / [[concept-query]] / [[concept-lint]] — 위키 운영 워크플로
