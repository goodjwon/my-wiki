---
title: Workout History 출시 여정 (2026-07 ~ 2026-11)
type: source
tags: [workout-history, flutter, watchos, wear-os, app-release, retrospective, local-first]
sources:
  - workout-history/TIMELINE.md
  - workout-history/TECH_NOTES.md
  - workout-history/README.md
external:
  - https://wonslab.dev/workout-history
created: 2026-09-03
updated: 2026-11-19
---

# Workout History 출시 여정 — 회고와 설계 원칙 6개

## 출처

- `raw/workout-history/TIMELINE.md` — 출시 여정 회고(2026-08-19 심사 제출 스냅샷 + 2026-09-03 출시 후 표 + 2026-11-19 추가 기록)
- `raw/workout-history/TECH_NOTES.md` — 설계 원칙 6개와 그 이유·함정(2026-09-03 공개 요약)
- 상세 설계 문서(PLANNING·CONCEPTS·ARCHITECTURE·DATABASE)는 **비공개 앱 저장소**가 유일한 원본입니다. 이 위키에는 공유 기준선(2026-08-19) 결정대로 회고와 개념 요약만 둡니다.

## 앱 한 줄

"3초 안에 기록하는" 맨손운동 중심 운동 기록 앱입니다. 요구사항 1번(R1)이 "3초 기록"이고, 이후 모든 설계 결정은 R1을 해치는지로 심판했습니다.

| 축 | 선택 | 이유 |
|----|------|------|
| 폰 | Flutter/Dart 3 · Riverpod · Drift(SQLite) · go_router · freezed | iOS·Android 한 벌 |
| 워치 | Apple Watch = SwiftUI + WatchConnectivity · Wear OS = Jetpack Compose | Flutter는 워치 미지원, 화면 3개짜리 얇은 클라이언트라 네이티브가 더 쌉니다 |
| 구조 | feature-first + 각 feature 안 presentation/domain/data 3분할 | 횡단 엔진(타이머·목표 계산·헬스 가져오기)은 별도 domain 층 |
| 잠금 | Domain은 순수 Dart(Flutter import 금지) | 아키텍처 테스트로 강제 |

## 주요 이정표

| 날짜 | 사건 |
|---|---|
| 2026-07-20 | 백로그 시작, M1 폰 MVP 착수 |
| 2026-07-23 | 로드맵 결정: 코칭(루틴·TTS·햅틱)을 헬스 연동보다 선행 |
| 2026-07-31 | 헬스 연동을 워치보다 선행(달리기 가져오기 기본) |
| 2026-08-02/05 | 설계 원칙 6 확정: "기록은 행위의 산물, 임의 수동 입력은 반칙" |
| 2026-08-14~16 | 워치 실기기 검증 라운드, 피드백 6건 즉시 수정 |
| 2026-08-17 | 개념 모델 v1.2 + 스키마 v9 · 애플 개발자 등록 승인 · 번들 ID 전면 교체 |
| 2026-08-19 | 19:54 iOS 1.0 심사 제출(첫 배포) |
| 2026-08-21 | iOS 1.0 승인(1차 심사는 Guideline 2.1 정보 요청, 스크린 레코딩 + 영문 회신 후 통과) |
| 2026-08-22 | Google Play 개발자 계정 개통 · 내부 테스트 게시 |
| 2026-08-24 ~ 08-30 | 1.0.1(헬스 앵커·줄바꿈) → 1.0.2(시간형 수량 표시) → 1.0.4(화면 재정합·홈 개편) |
| 2026-09-03 | 1.0.6 심사 제출(세트 이어하기·부분 저장·화면 잠금 방지) · 소개 페이지 wonslab.dev 이관 |

## 설계 원칙 6개 — 어디로 승격했나

| # | 원칙 | 한 줄 | 승격된 위키 개념 |
|---|------|-------|-----------------|
| 1 | Local-first | 모든 읽기·쓰기는 로컬 DB에서 즉시, 네트워크는 전부 백그라운드 | [[concept-local-first-append-only]] |
| 2 | Append-only + 파생값 | 기록은 추가만, 삭제는 tombstone, 스트릭·통계는 저장 않고 계산 | [[concept-local-first-append-only]] |
| 3 | 단일 타이머 상태기계 | 세트 휴식·루틴 인터벌·달리기가 한 엔진, 벽시계 앵커 | [[concept-wall-clock-state-machine]] |
| 4 | 워치는 얇은 클라이언트 | 진실은 폰 DB, 워치는 스냅샷 캐시 + 미전송 큐 | [[concept-thin-client-idempotent-sync]] |
| 5 | 성능 예산 | 콜드 스타트 <1.5s, 저장 탭→햅틱 <100ms, 위반은 리뷰 블로커 | (이 페이지 아래) |
| 6 | 기록은 행위의 산물 | 탭·타이머·센서·헬스 가져오기만 기록을 만들고 타이핑 UI는 없음 | [[concept-local-first-append-only]] |

### 원칙 5 · 성능 예산의 구현 단서

헬스·걸음수 조회는 첫 프레임 이후로 미루고, 저장은 in-flight 가드로 더블탭 중복을 막습니다. 가드는 첫 `await` 이전의 동기 구간에 두어야 두 번째 탭이 끼어들 틈이 없습니다.

```dart
bool _saving = false;

Future<void> onSaveTap() async {
  if (_saving) return;      // 첫 await 이전, 동기 구간에서 차단
  _saving = true;
  try {
    await repo.append(record);
    haptic.success();       // 탭 → 햅틱 < 100ms 예산
  } finally {
    _saving = false;
  }
}
```

## 삽질 로그 — 다음에 안 밟기 위한 기록

| 함정 | 증상 | 해법 |
|------|------|------|
| 시뮬레이터 워치 세션 | 폰↔워치 WCSession이 붙지 않음 | 워치 앱에 시뮬 전용 데모 스냅샷 내장(`STORE_DEMO` env) 후 스토어 스크린샷 촬영 |
| 워치 실기기 설치 굳음 | 폰 Watch 앱 설치와 CLI 설치가 서로 끊어먹음 | 워치 재부팅 직후 약 1분이 터널 골든타임 |
| 무료 팀 7일 서명 만료 | 매주 재서명 루프 | 유료 등록(1년 프로비저닝) |
| ASC 업로드 반려 ① | iPad 멀티태스킹 방향 요건 | iPhone 전용 지정 |
| ASC 업로드 반려 ② | health 플러그인이 쓰기 API를 참조 | 미사용이어도 `NSHealthUpdateUsageDescription` 필수 |
| ASC 필드 제약 | 프로모션 텍스트에 `→` 문자 거부 | 문자 교체 |
| 제출 게이트 | 개인정보 URL + "수집 없음" 설문 | 게시(Publish)까지 해야 심사 추가 가능 |
| 번들 ID 교체 | 새 컨테이너라 기존 실기록 유실 | 헬스 가져오기로 복구 |
| xcodebuild 산출물 | DerivedData에 떨어지는데 `build/ios/` 구 잔해를 설치 | 설치 경로 확인 |

## 출시 이후 변경 (2026-09-03 ~ 2026-11-19)

근거는 `raw/workout-history/TIMELINE.md` "2026-09-03 이후" 절입니다. 1.0.6에서 1.7.4까지 약 2.5개월, 321커밋(9월 3일 블로그 글 게시 이후)입니다.

### 스토어 상태 (조회 기준 2026-11-19)

| 플랫폼 | 라이브·프로덕션 | 테스트 트랙 최신 | 비고 |
|--------|----------------|-----------------|------|
| iOS App Store | 1.7.1, 출시 시각 2026-11-11T01:33Z(UTC, App Store 공개 조회 2026-11-19) | 1.7.4(47) TestFlight | 1.7.2 이후는 스토어 미반영 |
| Google Play | 1.5.3(38) 프로덕션(2026-11-03 콘솔 확인, 2026-11-19 공개 페이지도 1.5.3) | 1.7.4(47) 비공개 트랙 | 프로덕션 액세스 승인 2026-10-12, 1.7.x는 비공개 테스트까지 |
| Wear OS | 스토어 미등록 | — | 가짜 데이터로 동작, 정식화 보류(B-176) |

### 기능 축별 변화

| 축 | 변화 | 스키마 |
|----|------|--------|
| 목표·계획 | 루틴 목표, 플랜 위저드, 목표 변경 이력, 60대+ 계획 개편, 월요일 주간 리뷰 목표 올리기 제안 | v10 · v11 |
| 헬스 연동 | Android Health Connect 가져오기, 걷기 하루 합산, 헬스 쓰기(앱 기록 → HealthKit·HC, 가져온 기록은 되쓰지 않음), 가져온 운동의 측정 kcal | v14 |
| 연속 기록 | 일시정지, 18~23시 지키기 알림(기본 on), 7일 연속 직후 인앱 리뷰 1회 | v13 |
| 수행 화면 | 세트 이어하기, 빠른 종목(세트마다 한 번 탭·좌우 안내), 동작 가이드(관절 좌표 → 3D 캐릭터 영상 → 근육 인체) | v15 |

### 새로 남긴 함정과 결정

| 함정·결정 | 내용 | 정리 위치 |
|-----------|------|----------|
| 목표를 바꾸면 과거가 재채점됨 | 제자리 UPDATE가 스트릭을 소급 붕괴, 한 달 뒤 주간 리뷰에서 재발 | [[concept-rule-as-of-judgment]] |
| 심사 대기 중 재제출 = 줄 다시 서기 | 열흘간 다섯 번 제출하며 매번 직전 제출을 취소, 1.2.0~1.4.0이 심사를 끝내지 못함 | 제출 뒤에는 결과까지 빌드를 건드리지 않음 |
| 이중 집계 | 아이폰+애플워치 걸음 2배 집계(B-131), 헬스 쓰기 시 가져온 기록 되쓰기 금지 | [[concept-thin-client-idempotent-sync]]와 같은 "진실은 한 곳" 원리 |
| Play 건강 권한 신고 | 소모 칼로리 선언이 "목적·기능·이점 불충분"으로 거절 → 데이터 유형마다 목적·앱 내 기능·사용자 이점 3요소로 재작성 | 앱 저장소 `STORE_ANDROID.md` 5.1 |
| 워치 버전 불일치 | TestFlight 업로드가 워치 타깃 버전 불일치로 거부 → ipa 내부 앱·워치 버전 검증 후 업로드 | 앱 저장소 `CHANGELOG.md` 3장 |
| 정책 반전 | "미달성 압박 알림 금지"를 사용자가 뒤집어 연속 기록 지키기 알림 도입(평가 1건·리뷰 요청 코드 0건 진단 직후) | 앱 저장소 `BACKLOG_DONE.md` B-185·B-190 |
| 추정값 표기 | 근육 활성도는 측정값이 아니므로 출시 노트에 효능·정확성 표현 금지 | 앱 저장소 `CHANGELOG.md` 2장 |

## 개발 프로세스 — 에이전트 6역할

Claude Code 에이전트를 advisor(판단·범위·문서 정합) · app-developer(도메인·엔진·DB·네이티브) · ui-developer(화면·토큰·접근성) · qa-reviewer(머지 게이트) · tester(회귀 시나리오) · release-manager(버전·제출) 6역할로 나눴습니다.

| 규칙 | 위키의 같은 원리 |
|------|-----------------|
| 판단/구현 분리 | [[concept-advisor-worker]] |
| 게이트(리뷰→테스트) 생략 금지 | [[concept-loop-engineering]] 거부 신호 |
| 문서가 진실(충돌 시 문서 수정부터) | [[concept-claude-md]] · [[guide-project-docs-setup]] |
| 용어 사전으로 동의어 금지(Exercise·Goal·WorkoutRecord·Streak·Badge·Routine·Segment, Workout·Log·Entry·Achievement·Program 금지) | [[concept-naming-conventions]] |
| 병렬 세션 재구현 충돌은 diff로 이식 | [[concept-multi-agent-pattern]] |

에이전트가 여섯이면 이름이 흔들리는 순간 코드가 갈라집니다. 용어 사전은 문체 규칙이 아니라 병합 충돌 예방책입니다.

## 관련 페이지

- [[concept-local-first-append-only]] — 원칙 1·2·6의 영속 개념
- [[concept-wall-clock-state-machine]] — 원칙 3의 영속 개념
- [[concept-thin-client-idempotent-sync]] — 원칙 4의 영속 개념 + 증분 가져오기 앵커 함정
- [[concept-rule-as-of-judgment]] — 출시 후 목표 변경 이력(B-117·B-180)에서 나온 판정 잣대 개념
- [[concept-advisor-worker]] — 6역할 프로세스의 원형
- [[guide-project-docs-setup]] — PLANNING·ARCHITECTURE·BACKLOG 문서 체계의 템플릿
- [[src-on-pocket-news]] — 같은 1인 개발 사례: 통과 신호보다 화면 증적을 완료 기준으로
- [[src-morningbrief]] — 다음 1인 앱: 같은 개발 루프 규칙(5회 실패 시 중단)과 배치 + Firestore 구조

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [운동 기록 앱을 45일 만에 App Store에 올리기까지 — 혼자, 그리고 여섯 에이전트와](https://blog.wonslab.dev/2026-09-03-workout-history-45-days-six-agents/)
- [출시 후 두 달 반, 운동기록 앱은 무엇이 왜 바뀌었나](https://blog.wonslab.dev/2026-11-19-workout-history-update/)
- [AI 네이티브 시대 개발자 생존 전략: 앱 세 개를 AI 에이전트와 만들며 바뀐 내 역할](https://blog.wonslab.dev/2026-04-04-ai-native-developer-survival/)
