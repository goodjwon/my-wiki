---
title: 동네기후 개발기 (2026-11-15 ~ 2026-11-18)
type: source
tags: [dongne-climate, local-climate, kma-asos, spring-boot, firestore, firebase-hosting, flutter, batch-hub, static-json]
sources: [dongne-climate/]
external:
  - https://wonslab.dev/local-climate/
  - https://blog.wonslab.dev/2026-11-19-dongne-climate-intro/
created: 2026-11-19
updated: 2026-11-19
---

# 동네기후 개발기 — 배치가 계산하고, 앱은 정적 JSON만 읽는다

## 출처

- 이 페이지는 블로그 글 [동네기후 — 오늘 날씨, 원래 이랬나?](https://blog.wonslab.dev/2026-11-19-dongne-climate-intro/)와 짝을 이루는 지식 원본입니다.
- 사실 원본은 앱 저장소 local-climate(로컬 디렉터리 이름 wonrae)입니다. 공개 가능한 사실만 `raw/dongne-climate/README.md`, `raw/dongne-climate/TIMELINE.md`, `raw/dongne-climate/TECH_NOTES.md`로 옮겼고, 조회 기준은 2026-11-19, 커밋 `16dc1d1`입니다.

## 앱 한 줄

오늘 날씨를 같은 관측소의 최근 10년 같은 날짜와 비교해 "원래 이랬나?"에 한 문장으로 답하는 1인 개발 앱입니다. 앱 ID는 `dev.wonslab.local.climate`(iOS·Android 동일)입니다.

| 축 | 내용 |
|----|------|
| 동기 | (1) 체감과 사실 사이의 궁금증 해소 (2) 기후 변화를 내 동네 숫자로 실감하고 오늘 할 수 있는 한 가지로 잇기 |
| 탭 4개 | 오늘(편차·작년·재작년·오늘의 실천), 이번 주(3개년 그래프·요일별 표), 기후(줄무늬·10년 비교), 다른 동네(편차 순위) |
| 데이터 | 기상청 ASOS 일자료(실측), 단기예보(오늘 예상) |
| 관측소 | 7곳 운영 중, 목표 105곳 |
| 상태 | App Store 심사 제출(2026-11-19 기준 사용자 확인), 결과 대기. 저장소 기록은 TestFlight용 서명 빌드와 업로드 스크립트까지 |

## 아키텍처

| 계층 | 기술 | 역할 |
|------|------|------|
| 배치 | Spring Boot 3.5 jar, Java 21 | 실행 후 종료. 수집 → 판정 → 집계 → JSON 생성 → Hosting 배포 |
| 실행기 | batch-hub(맥 로컬 launchd) | 05:00 morning(오늘 예보·과거 10년·배포), 11:00 confirm(어제 확정값·배포) |
| 원장 | Firestore | 실측(observations)과 예보(forecasts)를 따로, 관측소별 일값 맵(climate) |
| 배포본 | Firebase Hosting | 관측소별 week·year·summary·index JSON, 1시간 캐시 |
| 앱·웹 | Flutter + Riverpod, 정적 웹 | 정적 JSON만 읽음. Firestore 관측 컬렉션은 클라이언트 접근 금지 |

[[src-morningbrief]]와 같은 "상시 서버 없이 배치 + 저장소" 구조지만, 앱이 읽는 곳이 Firestore가 아니라 CDN의 정적 파일이라는 점이 다릅니다. 관측 데이터는 사용자마다 다르지 않으므로 파일 하나를 모두가 읽습니다. 앱 요청 경로에 서버 인스턴스가 없어 콜드 스타트도 없습니다.

## 설계 결정 기록

| 날짜 | 결정 | 이유 | 근거 |
|------|------|------|------|
| 11-15 | 작업 큐 대신 "오늘 날짜의 과거 10년 + 어제 확정값" 매일 수집 | 날짜만으로 할 일이 정해져 멱등 | `6bcc52b` |
| 11-15 | 기준선 두 개: 오늘은 직전 10년, 기후 섹션은 고정 2016~2025 | 체감은 최근 기후로, 변화는 움직이지 않는 기준선으로 | `6bcc52b` |
| 11-16 | Cloud Scheduler·Cloud Run·Cloud CDN → batch-hub + Firebase Hosting | 부하 분산기 고정비(월 약 $18) 회피, 국내 IP | `246d5a0` |
| 11-16 | 오늘 값은 05:00 예보, 다음 날 11:00 실측으로 보정 | 전일 확정값은 10시 이후 게시 | `246d5a0` `c6c7f99` |
| 11-16 | 관측소당 climate 문서 하나 | 배포 읽기 약 42만 → 약 315 | `6b28fe6` |
| 11-17 | 과거 10년 일괄 수집(backfill) | 매일 수집만으론 기후 섹션이 1년 뒤에야 참 | `e3f2c43` |

기준선 분리와 예보/실측 분리의 상세는 [[concept-climate-normal-comparison]]에 정리했습니다.

## 함정과 해결

| 함정 | 해결 | 근거 |
|------|------|------|
| 단기예보 401이 "활용신청 승인 확인"으로만 보였는데 실제는 활용기간 만료 | 응답의 사유 필드만 오류 메시지에, 연장신청 | `dc41c13` `1dfbef3` |
| 일 최심적설은 며칠 전 눈도 잡아 "그날 눈" 과대 판정 | 일 최심신적설(ddMefs) | `3609a2b` |
| batch-hub jar 작업이 .env를 넘기지 않아 첫 실행 실패 | jar가 실행 디렉터리의 .env를 직접 import | `ee0bfcb` |
| 메모리 캐시 때문에 다음 날 열어도 어제 화면 | 앱 복귀·당겨서·버튼에서 캐시 비우고 재요청 | `669159e` |
| iOS 업로드 처리에서 위치 권한 Always 키 누락(90683) | 키 추가, 실제 요청은 사용 중에만 | `7d31206` |

## 같은 인사이트 패턴 — "읽는 쪽은 계산하지 않는다"

| 페이지 | 무거운 계산 | 읽는 쪽이 받는 것 | 상한·비용 고정 장치 |
|--------|------------|------------------|--------------------|
| **이 페이지** | 평년·편차·연간 지표(배치) | 관측소별 정적 JSON | 배포 읽기 실행당 약 315, Firestore 하루 쓰기 상한 10,000 |
| [[src-morningbrief]] | 토픽 요약(LLM 배치) | Firestore 날짜별 브리핑 | LLM 비용이 사용자 수가 아닌 토픽 수에 비례 |
| [[concept-local-first-append-only]] | 통계·스트릭(파생) | 계산값, 저장 안 함 | 윈도우 캡 |
| [[concept-thin-client-idempotent-sync]] | 폰 DB | 워치 스냅샷 캐시 | 디바운스 |

## 빠른 진단

- [ ] 앱이 읽는 데이터가 사용자마다 같다면, DB 질의 대신 정적 파일로 낼 수 있습니까?
- [ ] 배치 재실행이 같은 결과를 내도록 키가 날짜·대상으로만 정해져 있습니까?
- [ ] 외부 API 오류 메시지에 제공처가 준 실제 사유가 남습니까(키는 빼고)?

## 원본 출처

- raw: `raw/dongne-climate/TIMELINE.md`(날짜별 사실·출시 상태), `raw/dongne-climate/TECH_NOTES.md`(구조·규칙·함정)
- 앱 저장소 docs/00-design-summary.md, docs/03-architecture.md, docs/domain.md, docs/08-open-decisions.md

## 관련 페이지

- [[concept-climate-normal-comparison]] — 이 앱의 비교 기준선·예보 보정 개념
- [[src-morningbrief]] — 같은 배치 실행기와 서버 없는 구조를 쓴 앞선 앱
- [[src-on-pocket-news]] — batch-hub 작업을 함께 쓰는 서비스
- [[src-workout-history-launch]] — 같은 계정·앱 ID 규칙으로 출시한 1인 앱

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [동네기후 — 오늘 날씨, 원래 이랬나?](https://blog.wonslab.dev/2026-11-19-dongne-climate-intro/)
