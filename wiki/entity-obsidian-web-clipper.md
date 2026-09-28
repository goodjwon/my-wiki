---
title: Obsidian Web Clipper
type: entity
tags: [도구, Obsidian, 브라우저확장, 클리핑]
sources: [ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://obsidian.md/clipper]
created: 2026-04-18
updated: 2026-09-28
---

# Obsidian Web Clipper

웹 페이지를 마크다운으로 변환하여 [[entity-obsidian|Obsidian]] vault에 한 번의 클릭으로 저장하는 **공식 브라우저 확장**입니다.

- **공식**: https://obsidian.md/clipper
- 모든 데이터는 로컬 vault에 저장됩니다 ("file over app" 철학).

## 지원 브라우저

Chrome · Safari · Firefox · Edge · Brave · Arc · Orion · Vivaldi를 지원합니다.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **템플릿 시스템** | 콘텐츠 유형별(기사, 레시피, 논문, 영화 등)로 다른 템플릿을 적용합니다. 변수: `{{title}}`, `{{date}}`, `{{published}}`, `{{author}}` 등 |
| **하이라이트** | 텍스트·이미지·콘텐츠 블록을 하이라이트합니다. 저장 후에도 유지되어 재방문 시 보입니다 |
| **속성 매핑** | 페이지 메타 태그·Schema.org 정보를 Obsidian frontmatter로 자동 매핑합니다 |
| **콘텐츠 필터링** | Defuddle 라이브러리로 광고·내비게이션을 걷어내고 본문만 추출합니다 |
| **자동화** | 핫키와 URL 규칙으로 템플릿을 자동 적용하고 데이터를 변환합니다 |
| **데이터 매니퓰레이션** | 고급 템플릿에서 저장 전에 데이터를 가공합니다 (정규식·필터 등) |

## 산출물

- **클립 본문**: vault 안 지정 디렉터리에 Markdown 파일로 저장됩니다.
- **하이라이트·설정**: JSON으로 내보낼 수 있습니다.

## LLM Wiki에서의 역할

[[src-llm-wiki-pattern|LLM Wiki 패턴]]에서 `raw/`에 소스를 빠르게 추가하는 **주요 입력 채널**입니다. 워크플로는 다음과 같습니다.

```
웹 기사 발견 → Web Clipper 한 클릭 → raw/<주제>/ 에 .md 저장
  → 이미지 첨부는 raw/assets/ 로 일괄 다운로드 (Obsidian 핫키)
  → LLM에게 "ingest 해줘" → wiki/ 페이지 생성
```

> 원본 인용 (`raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md`):
> "Obsidian Web Clipper is a browser extension that converts web articles to markdown. Very useful for quickly getting sources into your raw collection."

## 비공식 vs 공식

기존 비공식 Clipper들이 있었지만, 이 확장은 **Obsidian 팀이 직접 만든 공식 도구**라 vault와 직접 통합되고 템플릿/속성 시스템이 풍부합니다.

## 원본 출처

- raw: `raw/ai-engineering/llm-wiki-pattern/llm-wiki-pattern.md` (Tips and tricks 섹션)
- 외부: [obsidian.md/clipper](https://obsidian.md/clipper)

## 관련

- [[entity-obsidian]] — 호스트 앱
- [[concept-ingest]] — 클리핑 후 실행하는 워크플로
- [[src-llm-wiki-pattern]] — 출처 패턴
