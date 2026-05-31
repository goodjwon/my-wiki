---
title: Obsidian Web Clipper
type: entity
tags: [도구, Obsidian, 브라우저확장, 클리핑]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://obsidian.md/clipper]
created: 2026-04-18
updated: 2026-05-31
---

# Obsidian Web Clipper

웹 페이지를 마크다운으로 변환하여 [[entity-obsidian|Obsidian]] vault에 한 번의 클릭으로 저장하는 **공식 브라우저 확장**.

- **공식**: https://obsidian.md/clipper
- 모든 데이터는 로컬 vault에 저장 ("file over app" 철학)

## 지원 브라우저

Chrome · Safari · Firefox · Edge · Brave · Arc · Orion · Vivaldi

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **템플릿 시스템** | 콘텐츠 유형별(기사, 레시피, 논문, 영화 등)로 다른 템플릿 적용. 변수: `{{title}}`, `{{date}}`, `{{published}}`, `{{author}}` 등 |
| **하이라이트** | 텍스트·이미지·콘텐츠 블록 하이라이트. 저장 후에도 유지되어 재방문 시 보임 |
| **속성 매핑** | 페이지 메타 태그·Schema.org → Obsidian frontmatter로 자동 매핑 |
| **콘텐츠 필터링** | Defuddle 라이브러리로 광고·내비 제거, 본문만 추출 |
| **자동화** | 핫키, URL 규칙 기반 자동 템플릿 적용, 데이터 변환 |
| **데이터 매니퓰레이션** | 고급 템플릿에서 저장 전 데이터 가공 (정규식·필터 등) |

## 산출물

- **클립 본문**: Markdown 파일 (vault 내 지정 폴더)
- **하이라이트·설정**: JSON 익스포트 가능

## LLM Wiki에서의 역할

[[src-llm-wiki-pattern|LLM Wiki 패턴]]에서 `raw/`에 소스를 빠르게 추가하는 **주요 입력 채널**. 워크플로:

```
웹 기사 발견 → Web Clipper 한 클릭 → raw/<주제>/ 에 .md 저장
  → 이미지 첨부는 raw/assets/ 로 일괄 다운로드 (Obsidian 핫키)
  → LLM에게 "ingest 해줘" → wiki/ 페이지 생성
```

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "Obsidian Web Clipper is a browser extension that converts web articles to markdown. Very useful for quickly getting sources into your raw collection."

## 비공식 vs 공식

기존 비공식 Clipper들이 있었지만, 이 확장은 **Obsidian 팀이 직접 만든 공식 도구**라 vault와 직접 통합되고 템플릿/속성 시스템이 풍부함.

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (Tips and tricks 섹션)
- 외부: [obsidian.md/clipper](https://obsidian.md/clipper)

## 관련

- [[entity-obsidian]] — 호스트 앱
- [[concept-ingest]] — 클리핑 후 실행하는 워크플로
- [[src-llm-wiki-pattern]] — 출처 패턴
