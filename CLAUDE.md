# Wons Wiki — Schema

이 저장소는 LLM이 유지·관리하는 개인 지식 위키(Second Brain)입니다.

## 디렉터리 구조

```
my-wiki/
├── CLAUDE.md          # 이 파일 — 위키 스키마·규칙
├── raw/               # 원본 소스 (불변, LLM이 수정하지 않음)
│   ├── assets/        # 이미지·첨부파일
│   └── *.md           # 클리핑·노트·원본 문서
├── wiki/              # LLM이 생성·유지하는 위키 페이지
│   ├── index.md       # 위키 전체 목록 (카테고리별)
│   └── log.md         # 작업 기록 (시간순, append-only)
└── .obsidian/         # Obsidian 설정
```

## 핵심 규칙

1. **raw/ 는 불변이다.** LLM은 raw/ 안의 파일을 절대 수정·삭제하지 않는다.
2. **wiki/ 는 LLM이 소유한다.** 모든 위키 페이지는 wiki/ 아래에 생성한다.
3. **index.md 는 항상 최신 상태를 유지한다.** 페이지를 추가·삭제할 때마다 업데이트한다.
4. **log.md 에 모든 작업을 기록한다.** 형식: `## [YYYY-MM-DD] 작업유형 | 제목`
5. **한국어를 기본 언어로 사용한다.** 고유명사·전문용어는 원문 병기 가능.

## 페이지 형식

모든 위키 페이지는 YAML frontmatter를 포함한다:

```yaml
---
title: 페이지 제목
type: entity | concept | source | synthesis | comparison
tags: [태그1, 태그2]
sources: [원본파일명]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### 페이지 유형

| type | 설명 | 예시 |
|------|------|------|
| `source` | 원본 소스 1개의 요약 | 논문 요약, 기사 요약 |
| `entity` | 인물·조직·도구·장소 등 | "OpenAI", "트랜스포머" |
| `concept` | 개념·원칙·프레임워크 | "RAG", "컴파운딩 지식" |
| `synthesis` | 여러 소스를 종합한 분석 | "LLM 지식관리 비교" |
| `comparison` | 비교·대조 | "Obsidian vs Notion" |

## 워크플로

### 1. Ingest (소스 수집)

사용자가 raw/ 에 소스를 추가하면:

1. 소스를 읽고 사용자와 핵심 내용을 논의한다.
2. `wiki/` 에 source 페이지를 생성한다 (파일명: `src-간결한제목.md`).
3. 관련 entity·concept 페이지를 생성하거나 업데이트한다.
4. `wiki/index.md` 를 업데이트한다.
5. `wiki/log.md` 에 기록을 추가한다.

### 2. Query (질의)

사용자가 질문하면:

1. `wiki/index.md` 를 읽어 관련 페이지를 파악한다.
2. 관련 페이지를 읽고 답변을 합성한다.
3. 답변이 위키에 보존할 가치가 있으면 synthesis/comparison 페이지로 저장한다.
4. 새 페이지를 만들었으면 index.md, log.md를 업데이트한다.

### 3. Lint (정비)

사용자가 요청하거나 주기적으로:

- 페이지 간 모순 검사
- 오래된 정보 갱신
- 고아 페이지(인바운드 링크 없음) 정리
- 누락된 교차 참조 추가
- 탐구할 만한 새 질문·소스 제안

## 교차 참조

위키 내부 링크는 Obsidian 호환 `[[파일명]]` 형식을 사용한다.
경로는 생략하고 파일명만 쓴다 (Obsidian이 자동 해석).

## 대화 규칙

- 모든 응답은 한국어로 한다.
- 위키 수정 시 변경 사항을 간결하게 보고한다.
- 사용자가 명시적으로 요청하지 않는 한, 위키 외부 파일을 생성하지 않는다.
