---
description: 위키 정비 (모순 검사, 고아 페이지, 누락 교차참조, 오래된 정보)
argument-hint: [영역] (생략 시 전체 점검)
---

# /lint — 위키 정비 워크플로

영역: `$ARGUMENTS` (예: `orphans`, `cross-refs`, `stale`, `index`, 생략 시 전체)

## 절차 (CLAUDE.md "워크플로 > 3. Lint" 준수)

### 1. 인덱스 일관성
- `wiki/index.md` 에 등록된 페이지 ↔ `wiki/` 실제 파일 비교.
- 누락된 페이지를 index에 추가, 삭제된 페이지를 index에서 제거.

### 2. 고아 페이지 탐지 (`orphans`)
- `wiki/` 의 각 페이지에 대해 인바운드 `[[파일명]]` 링크가 있는지 검사.
- 인바운드 0인 페이지 목록 보고 → 사용자에게 (a) 교차참조 추가 (b) 통합 (c) 삭제 중 선택받기.

### 3. 누락 교차참조 (`cross-refs`)
- source 페이지의 frontmatter `sources:` ↔ 본문에서 raw 인용 일치 확인.
- entity/concept 페이지에서 같은 주제를 다루는 다른 페이지 식별 → 양방향 링크 보강.

### 4. 모순·오래된 정보 (`stale`)
- 같은 entity/concept을 다루는 페이지들 간 모순(버전, 사실, 정책) 검사.
- `updated:` 가 오래된 페이지 중 raw 원본이 갱신된 것 식별 (`git log raw/<주제>/<파일>` 활용).
- 발견 시 사용자에게 보고하고 갱신 여부 확인.

### 5. raw 추적 마킹 (CLAUDE.md "원본 추적 마킹 규칙")
- 모든 source/concept/entity 페이지 frontmatter에 `sources:` 가 있는지.
- 본문 raw 인용이 `raw/<주제>/<파일>` 전체 경로인지.
- PDF/DOCX는 `.md` 변환본 우선 링크인지.

### 6. 새 질문·소스 제안
- 위키를 통독한 후 탐구할 만한 빈틈을 사용자에게 제안.
- "이 주제에 대해 source가 1개뿐인데 추가로 ingest할 만한 것은?" 같은 형태.

## 보고 형식

각 영역별로 발견 사항을 분리해 보고. 자동 수정 가능한 것(예: index 갱신)은 적용 후 보고, 판단이 필요한 것(고아 삭제, 모순 해결)은 사용자 확인 후 적용.

## 로그 기록

수정이 발생했으면 `wiki/log.md` 에 `## [YYYY-MM-DD] lint | <요약>` 추가.

## 사용자 메모리에 저장된 작업 피드백 준수

`feedback_preferences.md` 의 규칙(push 확인 등) 적용.
