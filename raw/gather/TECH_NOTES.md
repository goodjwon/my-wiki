# 언제볼래 — 기술 노트

> 원본: gather-project docs/requirements.md 3·5·7절, functions/src, clients/, 커밋 메시지(2026-11-19 조회).
> 공개용 요약. GCP 프로젝트 ID·서비스 계정·키 경로는 뺐다.

## 1. 구성

| 경로 | 기술 | 역할 |
|---|---|---|
| `functions/` | Cloud Functions 2세대, TypeScript, Node 22, asia-northeast3, 최대 1대 | 도메인 규칙 전부(후보 칸·날짜 점수·중간 지점·추천·상태 전이), 공유 미리보기 HTML |
| `apps/web/` | React + Vite + TS | 참여자 응답·결과 요약·확정 카드, 소개·약관 |
| `apps/app/` | Flutter(fvm 3.47.7) | 주최자·참여자 앱: 내 모임·만들기·결과·확정·응답 |
| `clients/` | `openapi.json` + 생성 클라이언트(TS·Dart) | API 계약 |

- Firebase Hosting이 `/api/**`·`/g/**`를 함수로 rewrite. 화면과 API가 같은 도메인이라 CORS가 없다(requirements 7.5).
- `main` push → GitHub Actions가 서버·웹·앱 테스트 후 함수와 Hosting을 함께 배포(공유 링크 HTML이 웹과 같은 빌드). 인증은 Workload Identity.

## 2. 도메인 모델(requirements 3절)

| 구분 | 이름 | 규칙 |
|---|---|---|
| 애그리거트 | Gathering | 후보 규칙을 펼쳐 응답 칸(Slot = 날짜 + 시간대)을 만든다. 확정 후 응답 불가 |
| 애그리거트 | Response | 모임당 기기 1개 1응답. Gathering과 분리해 동시 응답에 락 경합이 없게 |
| 값 객체 | CandidateRule | 날짜·시간·장소를 항목별 FIXED/OPEN. 장소 기본은 "내가 정하기"(2026-11-07 결정) |
| 값 객체 | Origin | 좌표는 소수 둘째 자리로 반올림 저장, 남에게는 동네 이름만 |
| 상태 | 모집 중 → 날짜 확정 → 확정, 취소 | 날짜·시간 고정이면 DATE_FIXED, 전부 고정이면 CONFIRMED에서 시작 |

## 3. 날짜 점수(requirements 5.1, functions/src/domain.ts)

```text
score(slot) = 2·가능 + 1·애매 − 100·필수참석자불참
정렬: 전원 가능 여부 → score → 날짜 빠른 순(안정 정렬)
```

- 결과 화면은 상위 3개와 날짜별 "못 오는 사람" 이름을 보여 준다.
- 장소 추천: 중간 지점(기하 중심 → 가까운 역) → 반경 카테고리 검색(카카오 로컬) → 못 먹는 음식 제외 → 취향 일치·거리 정렬. 평점은 카카오 API가 주지 않아 쓰지 않는다.

## 4. 저장(Firestore)

| 컬렉션 | 문서 ID | 의도 |
|---|---|---|
| gatherings | slug(10자 base62) | 추측 방지, 목록 API 없음 |
| responses | `{slug}_{sha256(기기토큰) 22자}` | 유일성 제약이 없는 Firestore에서 "기기 1개 1응답"을 ID로 보장. 2026-11-09 토큰 원문 → 해시로 변경 |
| place_cache | 캐시 키(좌표 100m 격자 + 반경 + 카테고리 + 키워드) | 24시간 TTL |

자동 파기: 약속일 + 30일 뒤 TTL(requirements NFR-PR3).

## 5. API 계약과 서버 교체

- 2026-11-07: Spring Boot 서버에서 OpenAPI 스펙을 내보내고 `clients/generate.sh`로 TS(openapi-typescript)·Dart(openapi-generator) 클라이언트 생성.
- 2026-11-11: 서버를 TypeScript Cloud Functions로 옮기며 `clients/openapi.json`을 **손으로 고치는 계약**으로 바꿨다. 이전 커밋 `ed81fea`의 변경 파일에 `apps/web`·`apps/app`이 없다(클라이언트 무변경). 저장 문서·응답 JSON이 Java와 같은지 에뮬레이터에서 같은 흐름을 돌려 비교했다(커밋 메시지).
- generate.sh는 openapi-generator dart 7.x의 버그 두 가지(날짜 목록, enum 값 맵 역직렬화)를 perl 치환으로 고친다.
- 심사 중 원칙(NEXT.md): 제출한 빌드는 바꾸지 않고, 서버·웹을 따로 배포해도 API 모양은 바꾸지 않는다(필드 추가는 허용).

## 6. 콜드 스타트 시도 기록

| 날짜 | 시도 | 결과 |
|---|---|---|
| 11-07 | Cloud Run JVM + CDS·지연 초기화 | 첫 요청 7~11초(requirements 7.4) |
| 11-07 | GraalVM 네이티브 이미지 | 로컬 기동 0.09초, 빌드에 8GB 이상 → 큰 빌드 머신 비용으로 철회 |
| 11-11 | Node(Cloud Functions)로 이전 | 채택. 더 필요하면 최소 인스턴스 1대(유료) 검토 |

## 7. 심사 기록

- App Store 1.0.0(6): 2026-11-11 첫 제출 → 2026-11-14 "Guideline 2.1 - Information Needed"(정보 요청, 빌드 문제 아님). 실기기 화면 녹화 + 영문 메모(목적·사용법·외부 서비스·지역·규제 업종)를 메모와 회신에 넣고 재제출 → 심사 대기 중.
- 2026-11-19(작업 트리 기록): 중국 판매 때문에 배포가 막혀 판매 국가를 한국만으로 → 출시 확인.
- 로그인·계정이 없다(기기 익명 식별자). 그래서 계정 삭제 기능 대상이 아니다(심사 메모).
