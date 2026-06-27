---
title: 위키 작성 표준 (다이어그램·분량·마킹)
type: synthesis
tags: [wiki, standards, authoring, diagram, mermaid, html]
sources: []
created: 2026-06-07
updated: 2026-06-07
---

# 위키 작성 표준

이 위키를 어느 PC·어느 세션에서 이어가도 **일관된 결과**가 나오게 하는 표준. CLAUDE.md의 짧은 규칙을 풀어서 설명.

## 1. 다이어그램 작성 기준

### 1-1. Mermaid를 쓸 수 있는 경우

다음 조건 **모두** 만족하면 mermaid 사용:

- `subgraph` **없는** 단순 흐름 (단일 노드 + 화살표만)
- 노드 6개 이하의 트리·그래프
- 분기(`{...}`)·합류만 있는 결정 다이어그램

예: README의 "지식 구조" `graph TD`, "Java 챕터 맵" `graph LR`.

### 1-2. Mermaid를 쓰면 안 되는 경우 — HTML+flexbox 사용

**subgraph 안의 노드가 subgraph 바깥과 화살표로 연결**되면 mermaid는 `direction LR`을 **무시**하고 부모 그래프 방향(`TB`)을 따라간다. ([mermaid 알려진 버그](https://github.com/mermaid-js/mermaid/issues/6438))

ELK 렌더러(`defaultRenderer: 'elk'`)도 mkdocs-material 환경에서 안 먹는 경우가 있음.

**해결: HTML + 인라인 스타일 + flexbox로 직접 작성.**

#### 표준 템플릿 (행 구조 4-1-2 예시)

```html
<div style="display:flex;flex-direction:column;gap:14px;align-items:center;font-family:sans-serif;margin:24px 0;">

  <!-- 행 1: 4개 노드 가로 -->
  <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px;padding:16px;width:100%;box-sizing:border-box;">
    <div style="font-weight:600;margin-bottom:12px;color:#1e40af;font-size:15px;">💻 그룹 제목</div>
    <div style="display:flex;align-items:stretch;gap:10px;">
      <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#1e3a8a;font-weight:500;">노드 1</div>
      <div style="display:flex;align-items:center;font-size:24px;color:#2563eb;font-weight:bold;">→</div>
      <div style="background:#dbeafe;border:2px solid #2563eb;border-radius:8px;padding:14px 10px;flex:1;text-align:center;color:#1e3a8a;font-weight:500;">노드 2</div>
      <!-- ... -->
    </div>
  </div>

  <div style="font-size:28px;color:#999;line-height:1;">↓</div>

  <!-- 행 2: 1개 노드 (다리) -->
  <!-- 행 3: 2개 노드 -->

</div>
```

#### 색 톤 표준 (3톤 통일)

| 의미 | 그룹 배경 | 노드 배경 | 노드 테두리 | 텍스트 |
|------|----------|----------|-----------|--------|
| 🔵 로컬·시작 | `#eff6ff` | `#dbeafe` | `#2563eb` | `#1e3a8a` |
| 🟠 다리·전환 | `#fff7ed` | `#fed7aa` | `#ea580c` | `#7c2d12` |
| 🟢 결과·목적지 | `#f0fdf4` | `#bbf7d0` | `#16a34a` | `#14532d` |

> **6톤 이상 쓰지 말 것.** 의미 그룹별로 같은 톤. 마지막 목적지는 `border-width:3px`로 강조.

### 1-3. 모든 다이어그램 아래 글 풀이 추가 (2채널)

다이어그램만 두지 말고 **단계별 글 풀이**를 본문 섹션으로 추가. 시각 + 텍스트로 가독성 2채널 확보.

```markdown
### 단계별 자세히

**1단계 — 그룹 A**

1. **노드 1** — 이 단계에서 무엇이 일어나는지 설명
2. **노드 2** — ...

**2단계 — 그룹 B**

...
```

### 1-4. 다이어그램 점검 체크리스트

- [ ] subgraph 안의 노드가 외부와 연결되는가? → HTML 사용
- [ ] 색이 4톤 이상인가? → 3톤으로 통일
- [ ] 노드 모양이 섞여 있는가? (사각형 + 원 등) → 같은 모양으로
- [ ] 다이어그램 아래 글 풀이가 있는가?
- [ ] 페이지 폭에 맞춰 노드가 작아지지 않는가? (`flex:1` 사용)

---

## 2. 콘텐츠 분량·구조 기준

### 2-1. 타입별 권장 분량

| 타입 | 권장 줄 수 | 권장 글자 수 | 비고 |
|------|----------|------------|------|
| **source** (`src-*`) | 50~120줄 | 1.5K~4K | 원본 1개의 요약 |
| **concept** (`concept-*`) | 100~250줄 | 4K~10K | 정의 + 함정 + 패턴 연결 |
| **entity** (`entity-*`) | 100~250줄 | 3K~9K | 도구·인물·기술 — 공식 정보 + 활용 |
| **synthesis/guide** (`guide-*`) | 150~400줄 | 6K~15K | 실습 step-by-step 또는 종합 |
| **comparison** | 100~250줄 | 4K~10K | 비교 대상 ≥ 2개 |

### 2-2. 부실 판정 기준

다음 중 하나면 **보강 대상**:

- **줄 수 50줄 미만** (concept/entity 기준)
- 정의·관련 페이지 외 본문이 거의 없음
- 표·코드 예시 없음
- 공식 자료 인용·외부 URL 없음

### 2-3. 페이지 표준 섹션 구조

```markdown
---
title: ...
type: source | concept | entity | synthesis | comparison
tags: [...]
sources: [<주제>/원본파일.md]
external:
  - https://공식문서
  - https://기타URL
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# 제목

## 정의 (또는 개요·핵심)
한두 문단으로 본질을 잡고, 인용 박스(`> "..."`)로 핵심 한 줄.

## 핵심 본문 (섹션 N개)
- 표 중심으로 정리 (불릿 나열보다 표가 비교·인지 쉬움)
- 코드 예시는 Before/After 또는 안 좋은 예/좋은 예

## 같은 인사이트 패턴 (위키 내 연결)
| 페이지 | 위험 | 해결 |
|--------|------|------|
| **이 페이지** | ... | ... |
| [[다른 페이지]] | ... | ... |

## 빠른 진단 / 체크리스트
명령어·grep·체크리스트 형태로 즉시 활용 가능한 정보.

## 원본 출처
- raw: `raw/<주제>/<파일>.md`
- 공식: [링크 텍스트](URL)

## 관련 페이지
- [[다른 위키 페이지]] — 관계 한 줄 설명
```

### 2-4. 외부 자료로 보강할 때

- **공식 문서 우선** — 블로그·SO 답변은 부차
- **WebSearch로 최신성 확인** — 버전·API 변경 잦은 주제
- **3~5개 외부 출처를 종합** — 단일 출처 위험
- **frontmatter `external:`에 모든 출처 명시**

---

## 3. 마킹·교차참조 패턴

### 3-1. frontmatter 필수 키

```yaml
---
title: 페이지 제목                    # 필수
type: concept                        # 필수: source/concept/entity/synthesis/comparison
tags: [tag1, tag2]                   # 필수
sources: [<주제>/원본.md]             # source/concept/entity는 필수 (raw 경로)
external:                            # 외부 자료로 보강 시 필수
  - https://공식
created: YYYY-MM-DD                  # 필수
updated: YYYY-MM-DD                  # 필수 (수정 시 갱신)
---
```

### 3-2. raw 인용 방식

본문에서 raw 원본을 직접 인용할 때:

```markdown
> 원본 인용 (`raw/<주제>/<파일>.md`):
> "원본의 핵심 문장."
```

### 3-3. 패턴 누적 — "같은 인사이트 패턴" 비교표

이 위키의 가장 큰 가치 → 비슷한 구조의 함정·해결이 여러 페이지에 흩어진 것을 **한 비교표로 묶어** 양방향 연결.

예시:
```markdown
## 같은 인사이트 패턴 — "기본값과 가정의 함정"

| 페이지 | 위험한 기본값 | 실무 권장 |
|--------|-------------|----------|
| **이 페이지** | ... | ... |
| [[concept-cronjob-concurrency-trap]] | K8s Allow | Forbid + activeDeadlineSeconds |
| [[concept-keepalive-timeout-race]] | 서버 < LB | 서버 > LB |
| [[concept-db-connection-pool]] | 무한 수명 | maxLifetime < wait_timeout |
```

새 페이지 작성 시 **기존 페이지에서 같은 패턴 찾아 양방향 추가**.

### 3-4. 관련 페이지 섹션

마지막에 항상 `## 관련 페이지` 두기. 각 링크에 한 줄 설명:

```markdown
## 관련 페이지

- [[concept-spring-core]] — Spring DI의 기반
- [[entity-spring-boot]] — 실무 적용 환경
```

---

## 4. mkdocs nav 분류 기준

### 4-1. 현재 카테고리 4개

| 카테고리 | 들어가는 주제 |
|----------|--------------|
| **위키·지식관리** | Obsidian·Marp·Dataview 같은 PKM 도구, Memex 등 개념 |
| **하네스·AI 에이전트** | Claude Code, CLAUDE.md, Hooks, 멀티 에이전트, AI 도구 비용 |
| **Java·Spring·DDD** | Spring 코어/Boot/Framework, JPA, DDD, 디자인 패턴, 자바 |
| **DB·운영·인프라** | DB 운영, 네트워크, K8s, 인프라 함정 |

### 4-2. 새 카테고리 추가 기준

기존 4개에 자연스럽게 안 들어가고, 향후 **같은 주제 페이지가 3개 이상** 누적될 가능성 있을 때만 신규 추가.

예: "DB·운영·인프라"는 처음 1개 추가 후 나중에 누적 보고 신설.

### 4-3. 하위 그룹

각 카테고리 안: `개념` / `도구` / `인물` / `소스` / `실습` / `환경설정` 중 적합한 것.

---

## 5. ingest 워크플로 (사용자가 영상·자료 제공 시)

1. **raw 저장** — `raw/<채널>/<주제>.md` 형식. 타임스탬프 보존.
2. **wiki 페이지 작성** — type 결정 (source vs concept). 분량 기준 준수.
3. **같은 패턴 찾기** — 이미 위키에 있는 비슷한 페이지와 비교표 작성.
4. **mkdocs.yml 메뉴 추가** — 적합한 카테고리·하위.
5. **index.md 추가** — 해당 type 카테고리에 한 줄.
6. **log.md 추가** — 작업 기록.
7. **bash scripts/build-site.sh** — 빌드.

---

## 6. 빌드·배포 워크플로

```bash
# 1. 빌드 (wiki/ → docs/ → site/)
bash scripts/build-site.sh

# 2. 로컬 프리뷰
.venv/bin/mkdocs serve
# → http://127.0.0.1:8000

# 3. Firebase 배포
firebase deploy --only hosting
# → https://wiki.wonslab.dev
```

**중요**: `mkdocs serve`는 `docs/`만 watch. `wiki/` 수정 후엔 **반드시 build-site.sh** 재실행.

선택적 자동 빌드:
```bash
fswatch -o wiki/ | xargs -n1 -I{} bash scripts/build-site.sh
```

---

## 7. 표준 적용 점검 (페이지 작성 후 셀프 체크)

- [ ] frontmatter 필수 키 모두 있나? (`updated` 갱신?)
- [ ] 분량이 type별 권장 범위인가?
- [ ] 다이어그램이 필요하다면 mermaid 한계 점검했나?
- [ ] 같은 인사이트 패턴 비교표가 있나? (양방향 연결?)
- [ ] 원본 출처 / 관련 페이지 섹션이 있나?
- [ ] mkdocs.yml nav에 추가했나?
- [ ] index.md에 추가했나?
- [ ] log.md에 작업 기록했나?
- [ ] `bash scripts/build-site.sh` 통과하나?

## 관련 페이지

- [[guide-deploy-mkdocs-firebase]] — 배포 인프라 자체의 셋업
- [[concept-compounding-knowledge]] — 위키가 복리로 가치 쌓이는 원리
- [[concept-ingest]] — 새 소스를 위키에 통합하는 워크플로
- [[concept-lint]] — 위키 정비 워크플로
