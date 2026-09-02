---
title: Workout History 출시 여정 (2026-07 ~ 2026-09)
type: source
tags: [workout-history, flutter, watchos, wear-os, app-release, retrospective, local-first]
sources:
  - workout-history/TIMELINE.md
  - workout-history/TECH_NOTES.md
  - workout-history/README.md
external:
  - https://wonslab.dev/workout-history
created: 2026-09-03
updated: 2026-09-03
---

# Workout History 출시 여정 — 회고와 설계 원칙 6개

## 출처

- `raw/workout-history/TIMELINE.md` — 출시 여정 회고(2026-08-19 심사 제출 스냅샷 + 2026-09-03 출시 후 표)
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
- [[concept-advisor-worker]] — 6역할 프로세스의 원형
- [[guide-project-docs-setup]] — PLANNING·ARCHITECTURE·BACKLOG 문서 체계의 템플릿
