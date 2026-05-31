---
description: 위키 기반으로 질문에 답변 (가치 있으면 synthesis 페이지로 보존)
argument-hint: <질문>
---

# /query — 위키 질의 워크플로

질문: `$ARGUMENTS`

`$ARGUMENTS` 가 비어 있으면 사용자에게 질문을 받는다.

## 절차 (CLAUDE.md "워크플로 > 2. Query" 준수)

1. **인덱스 탐색**
   - `wiki/index.md` 를 먼저 읽어 질문과 관련된 페이지를 식별.
   - 필요하면 `wiki/` 디렉터리를 `grep` 으로 보조 검색.

2. **관련 페이지 읽기**
   - 후보 페이지 본문을 읽고 frontmatter `sources:` 로 raw 원본까지 추적.
   - 페이지 간 모순이 있으면 사용자에게 보고하고 어느 쪽을 신뢰할지 확인.

3. **답변 합성**
   - 한국어로 답변.
   - 본문에서 위키 페이지 인용 시 `[[파일명]]` Obsidian 링크 사용.
   - raw 원본 인용 시 `raw/<주제>/<파일>` 전체 경로 사용.
   - 추측·LLM 일반지식과 위키 근거를 명확히 구분 표시.

4. **synthesis 가치 판단**
   - 답변이 여러 source를 종합했거나 새로운 관점을 만들었으면 보존 가치가 있다.
   - 사용자에게 "이 답변을 `wiki/synth-<제목>.md` 로 저장할까요?" 확인.
   - 저장한다면 frontmatter:
     ```yaml
     ---
     title: ...
     type: synthesis     # 또는 comparison
     tags: [...]
     sources: [<참조한 raw들>]
     created: <오늘>
     updated: <오늘>
     ---
     ```

5. **인덱스/로그 갱신** (synthesis 생성한 경우만)
   - `wiki/index.md` 에 등록.
   - `wiki/log.md` 에 `## [YYYY-MM-DD] query→synthesis | <제목>` 기록.

## 사용자 메모리에 저장된 작업 피드백 준수

`feedback_preferences.md` 의 규칙(본문 필수, Mermaid 차트, 정책 기재) 적용.
