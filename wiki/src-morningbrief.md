---
title: 모닝 브리핑 개발기 (2026-10-05 ~ 2026-11-14)
type: source
tags: [morningbrief, spring-batch, kotlin, firestore, fcm, flutter, loop-engineering, graph-engineering, app-release, on-pocket-news, incident]
sources:
  - morningbrief/
external:
  - https://wonslab.dev/morningbrief/
  - https://blog.wonslab.dev/2026-10-18-morningbrief-intro/
  - https://blog.wonslab.dev/2026-11-19-morningbrief-update/
created: 2026-10-24
updated: 2026-11-19
---

# 모닝 브리핑 개발기 — 배치 + Firestore, 상한 있는 요약 루프

## 출처

- 이 페이지는 블로그 글 [모닝 브리핑 — 출근 전 3분 뉴스 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-10-18-morningbrief-intro/)과 1:1로 대응하는 지식 원본입니다.
- 사실 원본은 **비공개 앱 저장소** morningbrief입니다(CLAUDE.md, docs/progress.md, docs/BACKLOG-done.md, docs/architecture.md, docs/samples/, 백엔드 코드, git 이력). 소개 글의 주장은 2026-10-24 기준 저장소와 한 문장씩 대조했습니다.
- 2026-11-19에 git 이력 기반 원본 노트 `raw/morningbrief/TIMELINE.md`를 만들고, 10-24 이후 변경을 아래 「10-24 이후 변경」 절에 더했습니다. 대응 블로그 글은 [모닝 브리핑 한 달](https://blog.wonslab.dev/2026-11-19-morningbrief-update/)입니다.

## 앱 한 줄

내가 고른 토픽의 어제~오늘 소식을 사건 단위로 묶고 한두 문장으로 요약해, 아침 7시에 한 화면으로 보내 주는 1인 개발 뉴스 앱입니다. 앱 문구는 "출근 전 3분, 시장에 영향을 주는 소식부터"입니다.

| 축 | 내용 |
|----|------|
| 토픽 8개 | 경제·시장, 시사, 세상 이야기, 기업 공시(OpenDART 주요사항보고), IT·AI, 과학기술, 건강, 복지·정책([[src-on-pocket-news|On Pocket News]] 피드) |
| 수집원 | 언론사 RSS 직접 구독. 포털 검색 API와 Google News RSS는 제외 |
| 한 항목 | 원래 제목 + 120자 이내 요약 1~2문장 + 출처·시각·원문 링크 |
| 받는 요일 | 매일·평일만·주말만 |
| 표시 원칙 | ▲▼·빨강/파랑 방향 표시 없음(투자 판단처럼 읽히기 때문), 요약의 숫자만 굵게 |

## 아키텍처 — 서버 없이 배치와 Firestore

| 단계 | 기술 | 역할 |
|------|------|------|
| 요약 배치 | Kotlin + Spring Boot + Spring Batch | 매일 06:00 토픽별 Digest 그래프 실행 → Firestore `briefs/{date}` 게시 |
| 알림 배치 | 같은 jar의 notifyJob | 매일 07:00 사용자별 FCM 푸시("경제·시장 5 · 시사 4 — 오늘의 브리핑") |
| 저장소 | Firestore | 날짜별 브리핑, 사용자 관심사·기기 토큰·피드백·스크랩 |
| 앱 | Flutter(iOS·Android) | Firestore 직접 읽기·쓰기, 권한은 보안 규칙 |

API 서버를 걷어 낸 이유는 세 가지입니다. 클라우드 RDB의 고정비, 노트북 서버에는 집 밖 휴대폰이 접속할 수 없다는 점, FCM 데이터 한도(4KB)에 브리핑 전체를 실을 수 없다는 점입니다. 비싼 호출(LLM)은 content 컨텍스트의 Digest 그래프에서만 일어나고, 사용자 단위 처리에서는 LLM을 부르지 않습니다. 그래서 사용자 수가 늘어도 LLM 비용은 토픽 수에만 비례합니다.

## 루프·그래프 설계

토픽 하나의 Digest 그래프는 `collect → cluster → (expandCoverage → collect)* → rank → fetchBodies → summarize → verify → (summarize → verify)* → (fallback) → store` 순서입니다.

| 장치 | 구현 | 상한 |
|------|------|------|
| 커버리지 루프 | 사건 수 < 토픽 최소치이면 수집 창을 24 → 36 → 48시간으로 넓혀 다시 수집 | `MAX_COVERAGE_ATTEMPTS = 2` |
| 사건 묶기 | URL 정규화 중복 제거 후 제목 문자 바이그램 Jaccard ≥ 0.6 | — |
| 순위 | 최신성 0.4 + 묶음 크기 0.3 + 시장 키워드 0.3, 상위 15개 | `TOP_N = 15` |
| 품질 루프 | 코드 검사(JSON·개수·120자·cluster id 존재) 통과 시 검수 LLM 채점, 불합격이면 지적 사항을 넣어 재요약 | `MAX_QUALITY_ATTEMPTS = 2`(재요약 최대 2회) |
| 폴백 | 품질 루프 소진·LLM 오류·토큰 예산 초과 시 대표 기사 제목 + 설명을 그대로 게시(FALLBACK) | — |
| 스텝 상한 | GraphRunner가 실행당 노드 실행 수를 강제, 초과 시 FAILED | `maxSteps = 20` |
| 토큰 예산 | 실행당 입력 + 출력 토큰 합계 | 기본 300,000 |

검수 기준은 grounding(입력에 없는 수치·인과 금지), neutrality(감정·편향 표현 금지), topic_rule(경제·공시의 투자 판단, 건강의 치료 권고 금지), selection(낚시·가십 사건 금지) 네 가지입니다. 2026-10-07 dry-run의 경제·시장 토픽은 기사 397건 → 사건 336개 → 상위 15개 요약 → 5줄 게시, 검수 재시도 0회, 7스텝으로 끝났습니다.

기사 본문은 요약을 만드는 순간에만 메모리에서 쓰고 DB·로그·graph_steps 어디에도 남기지 않습니다. 저장은 제목, 200자 이하 설명, 출처, URL, 발행 시각뿐이고, 원문 수집은 robots.txt를 따릅니다.

## 타임라인

| 날짜 | 사건 | 근거 |
|------|------|------|
| 2026-10-05 | 작업 명세·개발 규칙·도메인 모델, GraphRunner(스텝 상한 20) | `c064706` |
| 2026-10-06 | 백엔드 Java → Kotlin 결정(커밋은 10-07) | progress.md, `58f859b` |
| 2026-10-07 | 언론사 RSS 전환, 품질 루프·폴백, 앱 Android 네이티브 → Flutter | `58f859b` `9bb08c7` |
| 2026-10-08 | API 서버 → 배치 + Firestore(A안) | `7dd2797` |
| 2026-10-12 | Spring Batch Job 전환, 배치 허브 등록(10-13부터 매일 06:00 성공) | `e0d0be1` `6f715b0` |
| 2026-10-16 | 복지·정책 토픽, 푸시 notifyJob, 지난 브리핑, TestFlight IPA, 앱 아이콘 | `2a2c1f3` `806896a` `11185ef` |
| 2026-10-17~18 | 요약 읽음·스크랩, Sign in with Apple, 스토어 등록 자료 | `54c09f4` `990e78e` |
| 2026-10-21 | App Store 출시(0.1.0 빌드 5), 이후 0.1.1 업데이트 준비 | progress.md, `0963c54` |
| 2026-10-23 | Android 패키지 `dev.wonslab.morningbrief`, Play 비공개 테스트 제출 | `34cca40` `7530224` |

## 10-24 이후 변경 (2026-10-25 ~ 11-14)

날짜별 사실은 `raw/morningbrief/TIMELINE.md`에 있습니다. 여기서는 구조가 바뀐 지점만 정리합니다.

| 축 | 변경 | 근거 |
|----|------|------|
| 온포켓 연동 ① 맞춤 정보 | notifyJob = picks → notify. 온포켓 partner/matches로 동의 회원의 추천을 받아 `users/{uid}/picks`에 동기화(firstSeenAt), 알림에 "새 맞춤 정보 N건". 매칭 키는 소셜 로그인 sub, 이메일·이메일 해시 미사용 | `0449dd3` |
| 온포켓 연동 ② 앱 안 화면 | morningBriefJob = digest → publish → onpocket → claims. 전날 06:00 이후 공개분을 `onpocket/{date}`(제목·200자 설명·링크·분류, 본문 없음, 30일)에 저장, 앱은 BriefScreen을 재사용해 같은 읽음·스크랩·맨 위로 | `dd1c29c` `dd691ef` |
| 온포켓 연동 ③ 분류·설정 | 대표 주제는 앱이 정하지 않고 온포켓이 준 category를 따름. 맞춤 설정(관심 주제·지역·내 상황·동의)은 앱에서 온포켓 프로필 API로 저장, 온포켓 토큰은 기기 메모리만 | `2d6d259` `29d1e40` |
| 알림 | notifyJob `slot`(06:30·07:00·07:30·08:00), 배치 허브에 시각별 작업 4개. 계기: 06:30 선택 사용자에게 07:00 도착 | `dc00436` |
| 토픽 | 보안 신설(9개), IT·AI 하루 최대 5 → 7건 | `9fc8cd4` |
| 앱 운영 | 업데이트 안내(Android 인앱 업데이트·iOS lookup 비교) | `58eac93` |
| 테스트 | Testcontainers → H2, 회원 upsert를 공통 SQL로, `./gradlew check` 58개 전부 통과 | `652b2c3` |
| 스토어 | 스크린샷 6장 재촬영(가상 샘플 데이터), 업로드 자동화 스크립트(키 미발급으로 미사용) | `778569e` |

### 함정과 해결

| 함정 | 해결 | 근거 |
|------|------|------|
| YAML에 끼어든 블록이 `brief.sources.rss`를 끊어 뉴스 토픽 7개가 0건(10-27) | 빈 피드면 실패, 운영 설정 바인딩 테스트 → [[concept-empty-result-vs-failure]] | `6b50db9` `403935a` |
| 재게시한 오늘 브리핑이 이미 받은 기기에 안 보임 | 오늘 날짜만 항상 서버 읽기 | `9af12b0` |
| iOS 푸시 10-22~10-28 `THIRD_PARTY_AUTH_ERROR` | Firebase에 APNs 인증 키 등록(10-28) | `4224aa6` |
| App Store가 승인된 버전 트레인에 새 빌드를 받지 않음(0.1.1·0.1.2·1.0.0) | 빌드마다 버전도 올림 | `507bc30` `7ac6590` `797757a` |
| `Navigator.canPop()`이 위에 쌓인 화면 때문에 첫 화면에서도 참 → 뒤로 버튼 노출 | `ModalRoute.isFirst` | progress.md |
| 날짜만 있는 `pubDate`를 0시로 해석하면 전날 공지가 24시간 창에서 빠짐 | KST 정오로 해석 | `9fc8cd4` |
| Mockito `eq/any`가 null을 돌려 Kotlin non-null 인자에서 NPE(Docker가 없어 한 번도 안 돈 테스트) | `?: 대체값` | `652b2c3` |

### 배포 상태 (기록 기준)

| 스토어 | 상태 | 근거 |
|--------|------|------|
| App Store | 11-03 lookup 기준 공개 버전 1.0.4, 1.0.5는 "배포 준비됨"(11-14 백로그) | progress.md, BACKLOG.md |
| Google Play | 10-23 비공개 테스트 제출, 11-14에 빌드 27(1.0.5) 출시를 콘솔 화면으로 확인(트랙 미기재) | `7530224` `2d0b191` |

## 블로그 글과의 1:1 대응

| 블로그 절 | 위키 절 | 대조 메모 |
|-----------|---------|-----------|
| 왜 만들었나 | 앱 한 줄 | 10-24 블로그 갱신: App Store 출시(10-21)·Play 비공개 테스트(10-23) 반영 |
| 무엇을 하는 앱인가 | 앱 한 줄 | 토픽 8개·요일·표시 원칙 일치 |
| 구조 — 서버 없이 | 아키텍처 | 06:00/07:00·4KB·LLM 토픽 단위 일치 |
| 하루치 브리핑 과정 | 루프·그래프 설계 | 397→336→15→5줄·7스텝 일치(dry-run 기록) |
| 지킨 원칙 네 가지 | 루프·그래프 설계 | 상한 2·20스텝·토큰 예산·검수 4기준 일치 |
| 2주 동안 바뀐 결정들 | 타임라인 | 10-24 블로그 갱신: Kotlin 전환 날짜 10-06~07(결정·커밋), 칸 내용을 진행 방식으로 표현. 전환 동기는 기록에 없음 |
| AI와 함께 만든다는 것 | 같은 인사이트 패턴 | 5회 중단·테스트 약화 금지·게이트, iOS 콘텐츠 차단 규칙의 정규식 OR 미지원 원인 일치 |
| 앞으로 | 타임라인 | 출시 경과는 타임라인 절에 반영, 수신 시각 선택은 BACKLOG 미결 |

## 같은 인사이트 패턴 — "끝내는 조건을 먼저 설계한다"

| 페이지 | 반복 장치 | 상한·거부 신호 | 대안 경로 |
|--------|-----------|----------------|-----------|
| [[concept-loop-engineering]] | 계획 → 실행 → 검증 사이클 | "아니오라고 말할 무언가", 반복 상한 | 사람에게 보고 |
| [[concept-graph-engineering]] | 노드·조건부 엣지 | 하드 규칙은 코드, 소프트 판단은 LLM | 분기 노드 |
| 모닝 브리핑 요약 배치 | 커버리지·품질 루프 | 각 2회, 스텝 20, 토큰 300,000, 코드 검사 후 LLM 검수 | FALLBACK 게시 |
| 모닝 브리핑 개발 루프 | Plan → Implement → Verify → Reflect | 같은 작업 5회 실패 시 중단·보고, Phase 게이트 | 원인 한 줄 기록 |
| [[src-workout-history-launch]] | 에이전트 6역할 게이트 | 리뷰 → 테스트 게이트 생략 금지 | 문서 먼저 수정 |

앱 안의 요약 파이프라인과 앱을 만드는 개발 과정이 같은 구조라는 점이 핵심입니다. 두 곳 모두 결과를 거부할 장치와 끝낼 조건을 먼저 정했고, 실패의 원인은 기록으로 남겼습니다.

## 빠른 진단

- [ ] 모든 루프가 State에 시도 횟수와 상한을 가지고 있습니까?
- [ ] 코드로 확인할 수 있는 검사를 LLM 호출보다 먼저 수행합니까?
- [ ] 상한에 도달했을 때 사용자에게 무엇이 보이는지(폴백)가 정해져 있습니까?
- [ ] LLM 호출 횟수가 사용자 수가 아닌 토픽·작업 수에 묶여 있습니까?

## 원본 출처

- raw: `raw/morningbrief/README.md`, `raw/morningbrief/TIMELINE.md` (2026-11-19 조회, HEAD `b394843`)
- 비공개 저장소 morningbrief — CLAUDE.md 1~4장, docs/progress.md, docs/BACKLOG-done.md, docs/architecture.md, docs/samples/dryrun-2026-10-07.md
- 백엔드 코드 — `DigestGraph.kt`, `DigestSummarizer.kt`, `RunOptions.kt`, `EventClusterer.kt`, `NotifyService.kt`
- 지원 페이지 https://wonslab.dev/morningbrief/

## 관련 페이지

- [[concept-loop-engineering]] — 품질 루프·개발 루프의 영속 개념
- [[concept-graph-engineering]] — Digest 그래프(조건부 엣지·스텝 상한)의 영속 개념
- [[src-workout-history-launch]] — 같은 계정·번들 ID 규칙으로 출시한 앞선 1인 앱
- [[src-on-pocket-news]] — 복지·정책 토픽의 피드, 맞춤 정보(picks), 대표 주제를 주는 자매 서비스
- [[concept-empty-result-vs-failure]] — 10-27 0건 장애에서 나온 "빈 결과와 실패를 구분한다" 원칙
- [[src-dongne-climate]] — 같은 batch-hub, 서버 없는 구조를 쓴 다음 앱(앱은 정적 JSON을 읽음)

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [모닝 브리핑 — 출근 전 3분 뉴스 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-10-18-morningbrief-intro/)
- [모닝 브리핑 한 달 — 소개 글 이후 바뀐 것과 그 이유](https://blog.wonslab.dev/2026-11-19-morningbrief-update/)
