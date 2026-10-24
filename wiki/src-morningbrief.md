---
title: 모닝 브리핑 개발기 (2026-10-05 ~ 2026-10-23)
type: source
tags: [morningbrief, spring-batch, kotlin, firestore, fcm, flutter, loop-engineering, graph-engineering, app-release]
sources: []
external:
  - https://wonslab.dev/morningbrief/
  - https://blog.wonslab.dev/2026-10-18-morningbrief-intro/
created: 2026-10-24
updated: 2026-10-24
---

# 모닝 브리핑 개발기 — 배치 + Firestore, 상한 있는 요약 루프

## 출처

- 이 페이지는 블로그 글 [모닝 브리핑 — 출근 전 3분 뉴스 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-10-18-morningbrief-intro/)과 1:1로 대응하는 지식 원본입니다.
- 사실 원본은 **비공개 앱 저장소** morningbrief입니다(CLAUDE.md, docs/progress.md, docs/BACKLOG-done.md, docs/architecture.md, docs/samples/, 백엔드 코드, git 이력). raw/ 사본은 두지 않았고, 블로그 글의 주장은 2026-10-24 기준 저장소와 한 문장씩 대조했습니다.

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

- 비공개 저장소 morningbrief — CLAUDE.md 1~4장, docs/progress.md, docs/BACKLOG-done.md, docs/architecture.md, docs/samples/dryrun-2026-10-07.md
- 백엔드 코드 — `DigestGraph.kt`, `DigestSummarizer.kt`, `RunOptions.kt`, `EventClusterer.kt`, `NotifyService.kt`
- 지원 페이지 https://wonslab.dev/morningbrief/

## 관련 페이지

- [[concept-loop-engineering]] — 품질 루프·개발 루프의 영속 개념
- [[concept-graph-engineering]] — Digest 그래프(조건부 엣지·스텝 상한)의 영속 개념
- [[src-workout-history-launch]] — 같은 계정·번들 ID 규칙으로 출시한 앞선 1인 앱
- [[src-on-pocket-news]] — 복지·정책 토픽의 피드를 주는 자매 서비스

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [모닝 브리핑 — 출근 전 3분 뉴스 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-10-18-morningbrief-intro/)
