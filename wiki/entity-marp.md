---
title: Marp
type: entity
tags: [도구, 프레젠테이션, 마크다운, 슬라이드]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://marp.app]
created: 2026-04-18
updated: 2026-05-31
---

# Marp — Markdown Presentation Ecosystem

마크다운으로 슬라이드 덱을 만드는 오픈소스 생태계 (MIT 라이선스). 내용 작성에 집중하고 포맷팅은 Markdown + CSS 테마로 위임.

- **공식**: https://marp.app
- **GitHub**: https://github.com/marp-team

## 구성 요소

| 컴포넌트 | 역할 |
|---------|------|
| **Marp Core** | 모든 공식 도구의 변환 엔진 |
| **Marpit Framework** | Markdown + CSS 테마 → HTML/CSS 슬라이드 덱으로 변환하는 기반 프레임워크 |
| **Marp CLI** | 커맨드라인 도구. `marp slides.md -o slides.pdf` |
| **Marp for VS Code** | VS Code 확장. 실시간 미리보기 + 익스포트 |

## 출력 포맷

HTML, **PDF**, **PPTX**, PNG/JPEG 이미지. PDF/PPTX 렌더링에는 Chrome/Chromium 사용.

## 마크다운 문법 (요점)

```markdown
---
marp: true
theme: gaia
paginate: true
header: 'My Talk'
footer: '© 2026'
---

# 첫 슬라이드

내용...

---

# 두 번째 슬라이드

![bg right:40%](image.png)

- 글머리표
- $E = mc^2$  ← 수식 지원
```

- `---` (수평선) → 슬라이드 구분자
- CommonMark 기반 + 확장 디렉티브 (이미지 사이징, 수식 typesetting, auto-scaling)
- frontmatter에 `theme:` 지정

## 기본 테마

- **default** — 깔끔한 흰 배경
- **gaia** — 컬러 액센트
- **uncover** — 미니멀, 가운데 정렬

커스텀 CSS로 자체 테마 제작 가능.

## LLM Wiki에서의 활용

[[src-llm-wiki-pattern|LLM Wiki 패턴]]은 [[concept-query|Query]] 결과의 출력 형식 중 하나로 Marp 슬라이드를 제안한다. 위키 콘텐츠를 그대로 슬라이드로 출력 가능.

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "Marp is a markdown-based slide deck format. Obsidian has a plugin for it. Useful for generating presentations directly from wiki content."

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (Tips and tricks 섹션)
- 외부: [marp.app](https://marp.app)

## 관련

- [[entity-obsidian]] — Obsidian Marp 플러그인 호스트
- [[concept-query]] — Marp는 Query 출력 옵션
- [[src-llm-wiki-pattern]] — 출처 패턴
