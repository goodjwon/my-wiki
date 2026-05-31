---
description: raw/ 에 추가된 소스를 위키로 ingest (source 페이지 생성, 교차참조, index/log 갱신)
argument-hint: <raw 경로 또는 주제명> (생략 시 git status로 새 raw 파일 탐지)
---

# /ingest — 소스 ingest 워크플로

대상: `$ARGUMENTS`

`$ARGUMENTS` 가 비어 있으면 `git status` 로 `raw/` 아래 추가·수정된 파일을 찾아 대상 후보로 제시하고 사용자에게 확인을 받는다.

## 절차 (CLAUDE.md "워크플로 > 1. Ingest" 준수)

1. **소스 읽기**
   - 대상이 디렉터리면 그 안의 모든 파일을 훑는다.
   - PDF/DOCX 원본이 있으면 같은 디렉터리의 `.md` 변환본을 우선 읽는다. 변환본이 없으면 만들 필요가 있는지 사용자에게 확인.
   - 핵심 주제·등장하는 entity/concept을 파악하고 사용자에게 1~2문장으로 요약 보고.

2. **source 페이지 생성** — `wiki/src-<간결한제목>.md`
   - frontmatter 필수:
     ```yaml
     ---
     title: ...
     type: source
     tags: [...]
     sources: [<주제>/<파일>]   # raw/ 생략
     created: <오늘 YYYY-MM-DD>
     updated: <오늘 YYYY-MM-DD>
     ---
     ```
   - **콘텐츠 보강 정책 (CLAUDE.md) 엄수**:
     - 코드 예제 필수 (설명만 있는 요약은 금지)
     - 실무 관점 우선 (자주 쓰는 부분 선별)
     - 본문에서 raw 인용 시 `raw/<주제>/<파일>` 전체 경로 사용
     - PDF/DOCX는 `.md` 변환본을 본문에서 우선 링크
   - 빈 콘텐츠(링크만 있는 북마크 등)는 source 페이지를 만들지 않고 사용자에게 보고.

3. **관련 entity/concept 페이지 생성·업데이트**
   - 새 entity/concept이면 `wiki/<이름>.md` 신규 생성.
   - 기존 페이지가 있으면 새 source로의 인바운드 링크 추가.
   - 양방향 교차참조 필수 (`[[파일명]]` Obsidian 형식).

4. **`wiki/index.md` 업데이트**
   - 적절한 카테고리에 새 페이지 등록.
   - 카테고리가 없으면 신설.

5. **`wiki/log.md` 에 기록 추가**
   - 형식: `## [YYYY-MM-DD] ingest | <제목>`
   - 본문: 추가/수정된 페이지 목록, 새로 만든 교차참조 요약.

## 사용자 메모리에 저장된 작업 피드백 준수

`~/.claude/projects/-Users-jungwonpark-Documents-my-wiki/memory/feedback_preferences.md` 의 규칙(본문 필수, Mermaid 차트, push 확인, 정책 기재)을 반드시 적용한다.

## 마지막 보고

- 생성·수정된 파일 목록
- 추가된 교차참조
- 다음 단계 제안 (synthesis 가치가 있는지 등)
- commit/push 여부는 사용자에게 명시적으로 확인
