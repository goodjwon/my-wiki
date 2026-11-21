# 동네기후 — 기술 노트

> 원본: 앱 저장소 `~/VsCodeProjects/wonrae` — `CLAUDE.md`, `docs/00-design-summary.md`, `docs/03-architecture.md`,
> `docs/domain.md`, `docs/07-color-and-message.md`, `docs/08-open-decisions.md`, 커밋 본문. 조회 2026-11-19.
> 비밀값·인프라 식별자(프로젝트 ID, 서명 팀 ID, 서비스 키)는 옮기지 않았다.

## 1. 구성

| 구성 요소 | 기술 | 역할 |
|---|---|---|
| 배치 | Spring Boot 3.5, Java 21, Gradle(Kotlin DSL) | 실행 후 종료하는 jar. 수집·판정·집계·JSON 생성·배포 |
| 실행기 | batch-hub(맥 로컬 launchd, 개인 공용 배치 실행기) | 매일 05:00 morning, 11:00 confirm |
| 원장 | Firestore default DB | observations(실측), forecasts(예보), climate(관측소별 일값 맵), meta |
| 배포본 | Firebase Hosting | 관측소별 정적 JSON + CDN, Cache-Control max-age=3600 |
| 앱 | Flutter 3, Dart, Riverpod | iOS·Android. 정적 JSON만 읽는다 |
| 웹 | web/index.html + app.js | 같은 정적 JSON을 읽는 실데이터 화면 |
| 데이터 | 기상청 ASOS 일자료, 단기예보(공공데이터포털) | 과거·어제 실측, 오늘 예보 |

- 앱은 Firestore 관측 컬렉션을 읽지 않는다. 보안 규칙상 관측·예보 컬렉션은 클라이언트 접근 금지.
- Cloud Run·Scheduler·Cloud CDN·Terraform·Secret Manager는 2026-11-16에 뺐다. Cloud CDN은 외부 부하 분산기 고정비(월 약 $18) 때문(docs/03).

## 2. 배치 작업

| 작업 | 시각 | 단계 | 내용 |
|---|---|---|---|
| local-climate-morning | 05:00 | forecast, seed, history, publish | 오늘 단기예보 → 최초 1회 시드 → 재시도 키 → 오늘 월·일의 과거 10년 → 배포 |
| local-climate-confirm | 11:00 | forecast-missing, confirm, publish | 05:00에 못 받은 예보 → 어제 ASOS 확정값 → 배포 |
| (수동) backfill | 필요 시 | backfill | 관측소×연도(2016~올해) 1년치를 한 번에 받아 climate 문서에만 |

- 전일 확정값은 당일 10시 이후 게시 → 05:00엔 받을 수 없어 오늘 값은 예보로 먼저 보여 주고 다음 날 11:00에 실측으로 보정.
- batch-hub 계약: 성공 0·실패 ≠ 0, `date=yyyy-MM-dd`, `force=true`, 같은 기준일 재실행은 덮어쓰기(멱등), 로그에 키 금지.
- 종료 코드 3 = 확정값 아직 게시 전(E-B03), batch-hub가 1시간 간격 2번 재시도.
- 문서 키 `{stationId}_{yyyyMMdd}` upsert. 이미 저장된 과거 키는 force가 아니면 건너뛴다.
- 재시도: 실패 키는 meta/retry, 5번째 실패면 결측 확정(E-B05).

## 3. 도메인 규칙 (docs/domain.md)

| 대상 | 규칙 |
|---|---|
| SkyJudge | 눈(신적설 ddMefs > 0) > 비(강수 ≥ 1.0mm) > 강풍(최대풍속 ≥ 14m/s) > 흐림(운량 ≥ 8) > 구름조금(운량 ≥ 5) > 맑음. 근거 없고 운량 결측이면 UNKNOWN |
| BaselinePeriod | 평년 기간을 값 하나로. 직전 10년과 고정 기간을 같은 계산기로 |
| NormalCalculator | 기간 안 연도만, 결측 제외, 2/29는 2/28 값, 표본 5년 미만이면 bandHidden |
| Deviation | 오늘 − 평년, 둘 중 하나라도 없으면 없음 |
| DeviationBand | \|편차\| 1·3·5 경계 7구간. 해석 문구와 색 토큰이 같은 구간 |
| YearStats | 더운 날(평균 ≥ 평년 + 3), 열대야(최저 ≥ 25), 영하일(최저 < 0), 평균기온 |
| DayValue | 실측 > 예보 > 없음 |
| 계층 | domain 패키지에 Spring·GCP import 없음(ArchUnit) |

- 평년·YearStats는 DailyObservation만 받는다 → 예보가 기후 계산에 섞이지 않는 것을 타입으로 막는다.
- 기준선 두 개: 오늘 카드·주간 그래프는 직전 10년 같은 월·일, 기후 섹션의 더운 날은 고정 기간 2016~2025.
- E-B07(2026-11-16): 2/29가 없는 해는 연도 비교에서 빈칸(전에는 2/28 값을 넣음). 평년 계산의 2/29 → 2/28 규칙과 별개.

## 4. 읽기 비용을 줄인 저장 구조

| 단계 | 방식 | 읽기 |
|---|---|---|
| 처음 계획 | yearSummary를 연도마다 재계산 | 실행당 약 42만 |
| P4 구현 | `climate/{stationId}` 문서 하나에 날짜별 일값 맵, 배포 때 계산 | 실행당 약 315(관측소당 climate 1 + 예보 2) |

- climate 문서는 해마다 약 30KB 증가, 1MiB까지 약 30년. 넘으면 연도별 문서로 분할 예정.
- climate.days는 색인 제외(문서당 색인 한도).
- 배포는 무상태: 매번 최근 1년 week(53주)·year·summary·index를 다시 만들고, Hosting이 없는 해시만 업로드. 실패한 관측소는 이전 릴리스 해시를 그대로 등록(E-B10).

## 5. 앱 데이터 계층

- 캐시 먼저 보여 주고 갱신(stale-while-revalidate). 결과는 sealed(Fresh·Cached·Missing·NeedsUpdate·Broken).
- 같은 경로 중복 요청 합치기, 미리 받은 주는 요청 0회.
- 결함 기록: whenComplete가 자기 자신을 기다리는 교착(`4f575b8`), 메모리 캐시 때문에 다음 날에도 어제 화면(`669159e`) → 앱 복귀·당겨서·버튼에서 비우고 재요청.

## 6. 함정과 해결 (커밋 본문)

| 함정 | 해결 | 커밋 |
|---|---|---|
| ASOS numOfRows=1000이 오류 99로 거부 | 999 | `690a8f6` |
| ddMes(일 최심적설)는 며칠 전 눈도 잡음 | ddMefs(일 최심신적설) | `3609a2b` |
| 단기예보 401의 실제 원인이 활용기간 만료인데 로그엔 "활용신청 승인 확인" | 응답 본문의 errMsg·returnAuthMsg만 메시지에 | `dc41c13` |
| batch-hub jar 작업이 .env를 환경변수로 넘기지 않음 | jar가 cwd의 .env를 직접 import | `ee0bfcb` |
| 사용자 ADC의 quota 프로젝트가 다른 프로젝트 | setQuotaProjectId로 고정 | `2e09b51` |
| Hosting 380파일 순차 업로드 8분 | 16개 동시 | `2e09b51` |
| geolocator가 always API 참조 → App Store 처리 90683 | Always 키 추가(실제 요청은 WhenInUse) | `7d31206` |
| 11:00 전 예보 실패 시 summary 비어 "오늘 기록이 비어 있어요" | 지난 7일 안 마지막 값 + 기준일 강조 | `e10a1dc` |

## 7. 화면·메시지 원칙 (CLAUDE.md, docs/07)

- 문구는 질문 → 답 → 근거. 전문 용어 대신 "보통 이맘때".
- 환경 문구는 사실 → 체감 → 오늘의 한 가지, 훈계 없이 숫자로, 효과 수치는 출처 있는 것만.
- 기온 색은 기후 줄무늬(ColorBrewer Blues·Reds) 7단계, 화면은 숲·흙 중간색. 빨강·파랑은 기온 의미에만. 무지개 금지(IPCC 시각 스타일 가이드).
