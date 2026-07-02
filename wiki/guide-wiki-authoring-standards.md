---
title: 위키 작성 표준 (다이어그램·분량·마킹)
type: synthesis
tags: [wiki, standards, authoring, diagram, mermaid, html]
sources: []
created: 2026-06-07
updated: 2026-07-02
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

### 2-5. 코드·표 표시 — 글머리에서 빼낸다 (top-level)

**규칙: 코드블록과 표는 항상 좌측정렬(top-level)로 둔다. 글머리(리스트) 아래로 들여쓰지 않는다.**

| 이유 | |
|------|--|
| 가로폭 | 들여쓰면 코드 폭이 좁아짐 → 전체 폭 확보 |
| 표 안정성 | 마크다운 표를 리스트 안에 넣으면 python-markdown에서 깨짐 |
| 복붙 | 앞 공백이 따라오지 않아 깔끔 |
| 일관성 | "이건 종속?" 판단 불필요 — 규칙 1개 |

**리스트 항목에 코드가 딸릴 때**는 들여쓰지 말고, **항목을 굵은 리드인으로 바꿔** 코드를 빼낸다:

````text
❌ 나쁨 (글머리 종속 — 폭 좁고 번호 깨질 위험)
1. 별도 Bean으로 분리:
   ```java
   ...
   ```

✅ 좋음 (굵은 리드인 + top-level 코드)
**1) 별도 Bean으로 분리**

```java
...
```
````

- 단순 설명 뒤 코드: 앞 줄을 `:`로 끝맺어 연결감을 주고, 코드는 빈 줄 뒤 top-level.
- 번호가 중요한 절차: 리스트(`1.`) 대신 `**1) …**` 굵은 단락으로 → 코드 빼내도 번호 안 깨짐.
- 예외 없음. 표는 무조건 top-level.

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

## 7. 문체 표준

> 배경: 2026-07-02 진단에서 최근 보강분(신설 실습 섹션)이 기존 경어체 산문 한가운데 평어체로 끼어드는 "문체 섬" 현상이 반복 확인됨. 근본 원인은 이 규칙들이 명문화돼 있지 않아 세션·에이전트마다 달리 쓴 것 — 아래로 고정. 상세 진단·계획: [[plan-tone-consistency]].

### 7-1. 문서군별 종결어미 매트릭스

전역 통일(전부 한다체) 대신 **문서군별 표준을 유지**한다. 신설 산문은 소속 문서군 표준에 맞춘다.

| 문서군 | 산문 본문 | 예외 슬롯 (평어 유지) |
|--------|----------|---------------------|
| 챕터 `java-study-*` | **합니다체** | 🎯 목표 한 줄(~한다) · ✏️ 직접 해보기 명령(~하라) · "따라 하는 법" 콜아웃 · `예상 결과` 펜스 내부 서술 |
| 가이드 `guide-*` | **한다체** | 붙여넣기 프롬프트(~해줘) · 독자 안내 박스(~하세요) |
| 강의노트 `lecture-*` | **개조식** | 비유 인용박스만 경어 (장면 묘사 문단 + "~도 같은 순서입니다" 매핑 문단, 완결 문장) |

`concept-*`·`entity-*`·`synthesis`류(이 문서 포함)는 가이드와 동일하게 한다체.

### 7-2. 독자 지시 표준

- 챕터 실습 지시(✏️ 직접 해보기 본문): **~하라/~해 보라** (문어체 명령). "~하세요"·"~해요"는 쓰지 않는다.
- 가이드에서 Claude에 그대로 붙여넣는 프롬프트: **~해줘** (구어체, 실제 대화 프롬프트이므로).
- 가이드 독자 안내 박스(진행 순서 등): **~하세요**.

### 7-3. 성공 확인 문구 표준

- 기본형: ` ```text ` 펜스 + 첫 줄 `예상 결과` + 출력값. (챕터 표준, 기존 다수 섹션과 동일)
- 인라인이 불가피할 때: **완결 문장** `"…가 출력되면 정상입니다."`
- **금지**: 라벨형 문구 — `성공 판정:`, `성공:`, `성공 출력:` 등. "초록불" 같은 은유도 파일마다 쓰거나 안 쓰거나 갈리므로 도입하지 않는다.

### 7-4. OS(Mac/Windows) 분기 표기 — 용도별 3형식

| 상황 | 형식 |
|------|------|
| 명령 한 줄만 다름 | 코드 내 트레일링 주석 `# Windows: mvnw.cmd spring-boot:run` |
| 도구·동작 자체가 다름 (별도 설명 필요) | blockquote `> **Windows**: PowerShell의 curl은 별칭이라 …` |
| 비교 항목이 3개 이상 | 마크다운 표 |

한 파일 안에서 같은 상황에 다른 형식을 섞지 않는다.

### 7-5. 용어 표준

| 개념 | 표준 표기 | 금칙 |
|------|----------|------|
| 명령 실행 | 명령 | 커맨드 |
| 저장 위치 | 디렉터리 | 폴더, 디렉토리 |
| 실행 환경 | 터미널 | 콘솔 (단 "콘솔 출력"류 맥락은 허용) |
| 동작 수행 | 실행한다 | 돌리다 (단 blockquote 구어 콜아웃 안은 허용) |

### 7-6. 표 규칙 (엔티티-속성 표 한정)

- 행 = 컬럼. 인덱스·제약 조건은 표 아래 한 줄 부기로 두고, 별도 행으로 표 안에 섞지 않는다.
- 따옴표는 곧은따옴표(`"`)만 사용. 곡선따옴표(" ")는 렌더 시 원본 잔재로 보고 정정.

---

## 8. 표준 적용 점검 (페이지 작성 후 셀프 체크)

- [ ] frontmatter 필수 키 모두 있나? (`updated` 갱신?)
- [ ] 분량이 type별 권장 범위인가?
- [ ] 다이어그램이 필요하다면 mermaid 한계 점검했나?
- [ ] 같은 인사이트 패턴 비교표가 있나? (양방향 연결?)
- [ ] 원본 출처 / 관련 페이지 섹션이 있나?
- [ ] mkdocs.yml nav에 추가했나?
- [ ] index.md에 추가했나?
- [ ] log.md에 작업 기록했나?
- [ ] §7 문체 표준(종결어미·성공확인·OS분기·용어)을 지켰나?
- [ ] `bash scripts/style-lint.sh <파일>` 통과하나?
- [ ] `bash scripts/build-site.sh` 통과하나?

## 관련 페이지

- [[guide-deploy-mkdocs-firebase]] — 배포 인프라 자체의 셋업
- [[concept-compounding-knowledge]] — 위키가 복리로 가치 쌓이는 원리
- [[concept-ingest]] — 새 소스를 위키에 통합하는 워크플로
- [[concept-lint]] — 위키 정비 워크플로
- [[plan-tone-consistency]] — §7 문체 표준을 적용하는 정합 계획·실행 프롬프트
