---
title: Local-first + Append-only — 기록이 진실, 나머지는 파생
type: concept
tags: [local-first, append-only, event-sourcing, derived-state, tombstone, timezone, clock-injection]
sources:
  - workout-history/TECH_NOTES.md
created: 2026-09-03
updated: 2026-09-03
---

# Local-first + Append-only — 기록이 진실, 나머지는 파생

## 정의

세 가지 원칙이 한 묶음으로 움직입니다.

| 원칙 | 규칙 | 한 줄 이유 |
|------|------|-----------|
| **Local-first** | 모든 읽기·쓰기는 로컬 DB에서 즉시 끝나고, 네트워크·동기화·외부 조회는 전부 백그라운드 | "3초 기록"은 네트워크 왕복 하나로 깨집니다 |
| **Append-only** | 기록은 추가만 하고 수정은 없으며, 삭제는 tombstone(삭제 시각)으로 남김 | 기록이 진실이면 언제든 재현 가능합니다 |
| **파생값은 계산** | 스트릭·목표 진행률·뱃지·통계는 저장하지 않고 기록에서 매번 계산 | 저장하는 순간 "언제 다시 계산하나"가 버그의 온상이 됩니다 |

여기에 [[src-workout-history-launch]]의 원칙 6 "기록은 행위의 산물"이 붙습니다. 기록을 만드는 것은 탭 카운트·타이머·센서·헬스 가져오기뿐이고, 숫자를 타이핑하는 UI는 두지 않습니다. 스트릭의 가치는 정직성에서 오므로 수동 입력이 있으면 스트릭은 자기기만 도구가 됩니다.

## Local-first의 부수 효과와 비용

| 항목 | 내용 |
|------|------|
| 사라지는 것 | 계정·로그인·서버 비용, 그리고 스토어 개인정보 설문의 "수집 없음"이 사실이 됩니다 |
| 미뤄지는 것 | 기기 간 동기화·백업은 별도 마일스톤으로 분리해야 합니다 |
| 사용자에게 명시할 것 | 앱 삭제 = 데이터 삭제 |

## Append-only 구현 골격

```dart
class WorkoutRecord {
  final String id;          // UUIDv7 — 생성 시각 순서 보존
  final int occurredAtMs;   // epoch ms UTC (저장은 항상 UTC)
  final int count;
  final int? deletedAtMs;   // null이면 살아 있음, 값이 있으면 tombstone
}

// 수정 API는 없습니다. "되돌리기"도 새 사실(tombstone)을 추가하는 일입니다.
Future<void> undo(String id) => db.markDeleted(id, now: clock.now());
```

저장 스낵바의 5초 실행취소는 tombstone 처리로 끝납니다. 이미 받은 뱃지는 회수하지 않습니다. 한 번 일어난 사실은 취소해도 "일어났었다"는 기록이 남는 것이 append-only 철학과 일치합니다.

## 파생값이 무거워질 때 — 캐시보다 윈도우 캡

성능이 문제 되면 저장(캐시)이 아니라 **조회 범위 상한**을 먼저 둡니다.

| 대안 | 효과 | 부작용 |
|------|------|--------|
| 파생값 저장(캐시) | 조회는 빠름 | 무효화 시점 관리가 새 버그 표면이 됩니다 |
| **윈도우 캡** (예: 스트릭 조회 400일) | 계산량 상한 고정 | 표시 수치만 캡되고 뱃지 판정은 무손실 |
| 성능 테스트로 상한 잠금 (예: 50ms) | 회귀를 리뷰에서 차단 | 없음 |

실시간성은 두 스트림으로 해결합니다. DB 테이블 변경 틱과 자정 틱을 파생값 Provider가 함께 watch하면 기록이 바뀌어도, 날짜가 바뀌어도 홈 화면이 스스로 갱신됩니다. 전면 스트림 개서 대신 기존 Future 구조를 유지한 것은 범위 절제입니다.

## 함정 1 · "하루"의 경계

저장 타임스탬프는 UTC이지만 **"하루" 판정은 기기 로컬 자정 기준**입니다. 스트릭 버그 1순위 지점입니다.

```dart
// 시계 seam은 하나(appClock)로 통일합니다. 여러 개면 계통이 갈라집니다.
final appClock = Clock();

DateTime localDay(int epochMs) =>
    DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();

// 테스트는 시계와 존을 주입해 자정·타임존을 고정합니다.
test('자정 직전 기록과 직후 기록은 다른 날', () {
  withClock(Clock.fixed(DateTime(2026, 9, 3, 23, 59, 59)), () {
    expect(streak.of(records).days, 1);
  });
});
```

자정을 넘기면 홈 화면이 스스로 갱신되어야 하므로 "자정+1초"에 발화하는 체인 틱을 둡니다.

## 함정 2 · 행위의 산물 원칙이 만드는 우회 통로

사후 입력이 불가하면 정상 흐름에서 놓친 기록을 건질 통로를 따로 설계해야 합니다.

| 상황 | 통로 |
|------|------|
| 하다가 나감 | 부분 저장(한 만큼) |
| 화면을 켜두고 방치 | "했나요?" 확인, 단 탭 0회일 때만 |
| 잘못 저장 | 실행취소 5초 |
| 오늘 이어하기 | 누적을 링의 시작값으로 시드하고 저장은 증가분만 |
| 시간형(플랭크) 이어하기 | 시드 대신 "남은 시간"을 타깃으로. 타이머 경과 자체가 증가분이라 시드까지 넣으면 이중 차감됩니다 |
| 연동·센서가 불가한 값 | "보정" 입력만 허용(예: 달리기 거리), 행위가 만든 값은 읽기 전용 |

## 같은 인사이트 패턴 — "편한 기본값은 규모에서 함정이 된다"

| 페이지 | 편한 기본값 | 규모에서의 함정 | 실무 권장 |
|--------|------------|----------------|----------|
| **이 페이지** | "하루 = UTC 날짜" 또는 "서버 시각" | 자정·타임존 경계에서 스트릭 오판 | 저장은 UTC, 판정은 로컬 자정, 시계는 단일 seam으로 주입 |
| [[concept-id-reference-vs-object-reference]] | JPA 객체 참조 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |
| [[concept-cronjob-concurrency-trap]] | `concurrencyPolicy` 기본 `Allow` | 중복 실행 | `Forbid` + `activeDeadlineSeconds` |
| [[concept-db-connection-pool]] | 무한 수명 커넥션 | DB `wait_timeout`과 충돌 | `maxLifetime` < `wait_timeout` |

## 같은 인사이트 패턴 — "진실은 하나, 나머지는 파생"

| 영역 | 진실 | 파생 | 참조 |
|------|------|------|------|
| **기록 앱** | append-only 기록 | 스트릭·통계·뱃지 | (이 페이지) |
| 타이머 | 세그먼트 인덱스 + 시작 앵커 | 남은 시간 | [[concept-wall-clock-state-machine]] |
| 폰↔워치 | 폰 DB | 워치 스냅샷 캐시 | [[concept-thin-client-idempotent-sync]] |
| 도메인 이벤트 | 원본 트랜잭션 | 구독자의 반영 | [[concept-domain-event-eventual-consistency]] |

→ 공통 원리: **파생값을 저장하면 두 개의 진실이 생기고, 둘이 어긋나는 순간이 반드시 옵니다.** 진실을 하나로 두고 나머지는 계산하거나, 계산이 무거우면 저장 대신 범위를 자릅니다.

## 빠른 진단

- "스트릭이 어제 끊겼다는데 어제 분명히 했다" → 자정·타임존 경계 판정을 확인합니다.
- "통계 숫자와 기록 목록이 안 맞는다" → 파생값을 어딘가 저장하고 있습니다.
- "삭제했더니 뱃지가 사라졌다 / 안 사라졌다"가 팀 안에서 논쟁이 된다 → tombstone 정책을 문서로 못 박습니다.
- "테스트가 새벽에만 실패한다" → 시계 seam이 둘 이상이거나 `DateTime.now()`를 직접 부르고 있습니다.

## 원본 출처

- raw: `raw/workout-history/TECH_NOTES.md` §2·§3·§7 (2026-09-03 공개 요약)

## 관련 페이지

- [[src-workout-history-launch]] — 이 원칙이 나온 앱의 출시 여정
- [[concept-wall-clock-state-machine]] — 같은 앱의 시계 주입 원칙을 타이머에 적용
- [[concept-thin-client-idempotent-sync]] — 진실(폰 DB)과 캐시(워치)의 분리
- [[concept-domain-event-eventual-consistency]] — 원본 트랜잭션이 진실, 구독자는 파생
- [[concept-id-reference-vs-object-reference]] — "편한 기본값" 패턴표의 본가
