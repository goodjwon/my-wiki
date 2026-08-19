# 아키텍처 설계서 (Workout History)

작성일: 2026-07-19 · 상태: 리팩터링 목표 v0.2 · 기준 문서: PLANNING.md v0.3, CODING.md v1.0

---

## 1. 전체 시스템 구성도

```
                        ┌─────────────────────────────┐
                        │        Supabase (M4)        │
                        │  Postgres · Auth · Realtime │
                        └──────────────▲──────────────┘
                                       │ 백그라운드 비동기 동기화 (push/pull)
                                       │ ※ 앱 동작에 필수 아님 (Local-first)
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                             폰 앱 (Flutter, 1벌)                             │
│                                                                             │
│  Presentation   홈 / 루틴 / 통계 / 설정 · 기록 시트 · 세트 모드 · 런 타이머     │
│       │         (Riverpod 상태관리)                                          │
│  Domain         RecordService · TimerEngine · GoalEngine · BadgeEngine       │
│       │         CueService(TTS·햅틱)                                         │
│  Data           Drift(SQLite) · Repositories · SyncQueue · HealthBridge      │
│                                                                             │
│  Platform Channels: 워치 브리지 · 헬스 · 위젯 · 알림                          │
└───────┬──────────────────────────────────────────────────────┬──────────────┘
        │ WatchConnectivity (iOS)                              │ HealthKit /
        │ Wearable Data Layer (Android)                        │ Health Connect
┌───────▼───────────────┐  ┌───────────────▼───────┐  ┌────────▼─────────────┐
│ Apple Watch (SwiftUI) │  │ Wear OS (Compose)     │  │ 외부 러닝앱·워치 운동앱 │
│ 링·기록·세트·런·루틴   │  │ 동일 구조 경량 앱      │  │ (나이키런·스트라바 등)  │
└───────────────────────┘  └───────────────────────┘  └──────────────────────┘
```

## 2. 설계 원칙

1. **Local-first가 1순위 (R1)** — 모든 읽기/쓰기는 로컬 SQLite에서 즉시 완료. 네트워크·동기화·헬스 연동은 전부 백그라운드. 클라우드가 죽어도 앱은 완전 동작.
2. **Append-only 이벤트 + 파생 상태** — `WorkoutRecord`는 수정하지 않고 쌓기만 한다(삭제는 tombstone). 목표 진행률·스트릭·뱃지·통계는 모두 기록에서 **계산되는 파생값** — 동기화 충돌과 정합성 문제를 원천 차단.
3. **단일 타이머 엔진** — 세트 모드 휴식(R8), 루틴 인터벌(R7), 런 타이머(R10)는 하나의 `TimerEngine` 상태기계를 공유한다. 음성·햅틱 안내(`CueService`)도 공용.
4. **워치는 얇은 클라이언트** — 워치 로컬엔 "최근 종목 캐시 + 미전송 기록 큐"만 둔다. 진실의 원천(source of truth)은 항상 폰의 DB.
5. **플랫폼 코드 최소화** — 네이티브(Swift/Kotlin)는 워치 앱, 헬스, 위젯, 워치 브리지 등 플랫폼이 강제하는 부분에만 사용.
6. **기록은 행위의 산물 (2026-08-02 확정 · 08-05 강화)** — 기록은 수행 행위(카운트·타이머·센서·헬스 가져오기)가 만든다. **임의 수동 입력은 반칙**(사용자: "운동앱이 연결 안 될 때만 쓰는 건데 입력을 임의로 하는 것은 반칙") — 수동은 연동·센서가 불가능한 상황의 보정 fallback으로만. 행위가 만든 값은 읽기 전용. 상세: PLANNING 5장.

## 3. 폰 앱 (Flutter) — 레이어드 아키텍처

### 3.1 레이어 구성

| 레이어 | 역할 | 의존 방향 |
|--------|------|-----------|
| Presentation | View(Widget), Riverpod ViewModel, 라우팅(go_router) | ↓ Domain 계약만 참조 |
| Domain | 유스케이스·엔진·Repository 포트(순수 Dart, Flutter 비의존) | ↓ 추상 계약만 참조 |
| Data | Drift DB, Repository 구현, 외부 Service/Bridge | 외부 세계와 통신 |

- **ViewModel = Riverpod Provider** — `Notifier`/`AsyncNotifier`와 화면 전용 Provider가 ViewModel 역할을 맡는다. Widget은 상태를 렌더링하고 사용자 이벤트를 전달하며, 저장·조회·오류 상태 전이는 ViewModel이 조정한다. 타이머처럼 화면 수명주기와 강하게 결합된 경우에만 명시적 Controller를 사용한다.
- **상태관리: Riverpod** — Drift의 반응형 쿼리(`Stream`)를 `StreamProvider`로 노출하면 "기록 저장 → 홈 카드·링·통계 자동 갱신"이 코드 몇 줄로 끝난다. 컴파일 타임 안전성과 테스트 용이성(Provider override)도 이유.
- **파생값은 전부 Provider로** — `todayProgressProvider`, `streakProvider`, `badgeProgressProvider` 등. 저장된 캐시가 아니라 쿼리+계산 결과이므로 항상 정합.
  - **실시간성 메커니즘(2026-07-28 확정, B-05·B-06)**: 파생값 FutureProvider들은 두 개의 틱을 watch한다 — `recordsChangeTickProvider`(Drift `tableUpdates(workout_records)` — 데이터 축: 기록 insert·tombstone 시 자동 재계산)와 `midnightTickProvider`(로컬 자정 체인 타이머 — 시간 축: 날이 바뀌면 "오늘" 재판정). 쿼리 전면 스트림 개서 대신 틱 watch로 실시간성을 얻는다(계산 로직·테스트 구조 보존). 저장/삭제 경로의 명시적 invalidate는 즉시성 보장용으로 병존.
- **엔티티는 Domain이 소유** (2026-07-20 advisor 확정) — `Exercise`·`WorkoutRecord` 등 엔티티 클래스는 각 feature의 domain에 정의하고, Drift 테이블은 `@UseRowClass`로 이를 행 타입으로 사용한다. Drift 생성 행 타입·DAO를 domain 포트 시그니처에 노출하는 것 금지 (별도 수동 매퍼 계층도 두지 않는다 — 매핑은 Drift 생성 코드가 담당).
- 엔티티를 워치 메시지·동기화 페이로드로 직접 직렬화하지 않는다 — 경계 스키마는 7장(워치)·6장(동기화)이 각각 정의.

#### 데이터 경계와 조립

- 로컬 Drift DB가 영속 데이터의 source of truth다. Repository는 source of truth가 아니라 Domain 포트의 구현체다.
- Presentation은 `AppDatabase`, DAO, Repository 구현체, 파일·플랫폼 플러그인을 직접 참조하지 않는다. 읽기 모델도 Repository 또는 Query Service를 통해 제공한다.
- 구현체 조립은 `app/` 또는 feature별 DI Provider에만 둔다. ViewModel·Domain Service·Repository 내부에서 구현체를 생성하지 않는다.
- Health, Watch, Supabase의 메시지·응답은 경계 DTO/스키마로 분리한다. 반면 Drift 로컬 경로는 `@UseRowClass`를 유지하며 수동 DTO/Mapper를 추가하지 않는다.

#### 리팩터링 전환 규칙

이 문서는 목표 구조다. 기존 Presentation의 직접 DAO 접근과 Widget의 직접 저장 호출은 새로 추가하지 않으며, 기능 수정 시 아래 순서로 이전한다.

1. DAO 호출을 Repository 또는 읽기 전용 Query Service로 이동한다.
2. UI 명령·loading/error 상태를 Riverpod ViewModel로 이동한다.
3. Widget은 상태 렌더링, 입력 수집, 라우팅과 일회성 UI 효과만 담당하게 한다.
4. 이전 전후에 해당 ViewModel/Service의 단위 테스트와 기존 Widget 테스트를 유지한다.

### 3.2 폴더 구조 (feature-first)

```
lib/
├── main.dart
├── app/                    # 라우팅, 테마(다크 고정 팔레트), 부트스트랩
├── core/                   # 공용 유틸, 상수, 확장함수, Result 타입
├── features/
│   ├── home/               # 홈: 카드 그리드, 오늘 링, Undo 스낵바
│   ├── record/             # 기록 시트(단발/세트), 세트 모드, 런 타이머 화면
│   ├── exercise/           # 종목 CRUD, 프리셋
│   ├── goal/               # 목표 설정·진행률
│   ├── routine/            # 루틴 빌더·실행
│   ├── stats/              # 히트맵, 그래프, 뱃지 컬렉션
│   └── settings/           # 설정, 헬스 연동 on/off, 계정
│   └── (각 feature 내부: presentation/ domain/ data/ 3분할)
├── domain/                 # feature 횡단 엔진: timer_engine, badge_engine, cue_service
└── data/
    ├── db/                 # Drift 테이블·DAO·마이그레이션
    ├── sync/               # SyncQueue, SupabaseClient (M4)
    └── bridges/            # watch_bridge, health_bridge, widget_bridge (MethodChannel)
```

## 4. 로컬 데이터베이스 (Drift / SQLite)

PLANNING.md 6장의 모델을 그대로 테이블화한다. 요점만:

```sql
exercises        (id TEXT PK, name, emoji, color, unit_type, default_amount,
                  increment_step, default_rest_sec, is_pinned, sort_order,
                  updated_at, deleted_at)          -- 목표·종목: LWW 대상
workout_records  (id TEXT PK, exercise_id, amount, weight, duration_sec, distance_m,
                  set_group_id, set_index, rest_sec_before,
                  recorded_at, source, external_source, external_id,
                  routine_session_id, created_at, deleted_at)  -- append-only
goals            (id TEXT PK, exercise_id, target_amount, period, active_days,
                  start_date, end_date, updated_at, deleted_at)
routines / routine_sessions / earned_badges       -- 기획서 6장과 동일
sync_queue       (seq INTEGER PK AUTOINCREMENT, table_name, row_id, op, queued_at)
```

- **PK는 전부 UUIDv7** (시간순 정렬 가능) — 폰·워치·서버 어디서 생성해도 충돌 없음.
- 인덱스: `workout_records(exercise_id, recorded_at)`, `(set_group_id)`, `(external_source, external_id)` UNIQUE — 헬스 중복 가져오기 방지.
- `GoalProgress`는 테이블이 아니라 **쿼리**다. **B-01 확정(2026-07-23)**: 스트릭 조회는 최근 400일 윈도우로 캡(`AppConstants.streakLookbackDays`) — 5만 행 실측 212~229ms가 예산(50ms) 초과해 도입. 뱃지 임계(최대 365일) 판정은 무손실, 스트릭 수치만 400 캡. daily rollup 캐시는 **M4 재평가**(헬스 대량 가져오기·위젯과 함께 무효화 인프라가 생기는 시점).
- 마이그레이션: Drift `schemaVersion` + 단계별 migration, CI에서 구버전 스키마 업그레이드 테스트.

## 5. 도메인 엔진

### 5.1 TimerEngine — 세트·루틴·런 공용 상태기계

```
상태:  idle → running(segment) → paused → completed
세그먼트 타입:
  work(count 기반)  : 사용자 탭으로 완료      (루틴 운동 구간, 세트 수행)
  rest(시간 기반)    : 자동 진행, ±30초, skip  (세트 간 텀, 루틴 휴식)
  openEnded(스톱워치): 종료 탭까지 무한        (런 타이머)
```

- 루틴 = 세그먼트 리스트 × 반복, 세트 모드 = `[work, rest]` 무한 반복 후 "세트 종료", 런 타이머 = `openEnded` 하나. **세 기능이 같은 엔진의 설정값 차이**일 뿐이다.
- 전환 이벤트마다 `CueService`에 위임: TTS("시작!"/"쉬세요"), 햅틱 패턴, 휴식 종료 3초 전 카운트다운.
- 백그라운드 생존: 타이머는 벽시계 기준(`startedAt` + 경과 계산)으로 동작 — 앱이 죽어도 재실행 시 복원. iOS는 Live Activity(선택), Android는 Foreground Service로 표시.
- 스냅샷 영속화 (2026-07-20 확정): 타이머 스냅샷은 DB가 아닌 파일에 저장(path_provider, 기능·종목별 키 분리 — 예: `run_timer_snapshot_<exerciseId>.json`). 기기 로컬 전용·동기화 비대상. 파일 IO는 Data 레이어 인터페이스 뒤에 두어 엔진은 순수 Dart 유지. 완료된 세트 기록은 스냅샷과 별개로 즉시 DB 저장(내구성) — 실제 휴식은 다음 세트 행 `rest_sec_before`에 기록.

### 5.2 RecordService / GoalEngine / BadgeEngine

- `RecordService.save()` — 저장(<100ms) → Undo 5초 윈도우(실제 삭제는 tombstone) → `sync_queue` 적재 → 도메인 이벤트 `RecordSaved` 발행.
- `GoalEngine` — 기록 스트림에서 일/주 진행률·스트릭 계산(순수 함수). 100% 도달 이벤트 발행 → 알림·워치 축하.
- `BadgeEngine` — `RecordSaved`·`GoalAchieved`·날짜 변경 이벤트를 구독해 뱃지 정의(코드 내장 `BadgeDefinition` 목록)와 대조 → 신규 획득 시 `earned_badges` insert + 축하 오버레이. 판정은 전부 로컬·순수 함수라 테스트가 쉽다.

## 6. 동기화 (Supabase, M4)

- 서버 테이블은 로컬과 동일 스키마 + `user_id` + RLS(행 수준 보안).
- **Push**: `sync_queue`를 순서대로 배치 업로드(upsert). 성공 시 큐에서 제거. 실패·오프라인이면 그대로 대기 — 재시도는 지수 백오프.
- **Pull**: 테이블별 `last_pulled_at` 커서로 `updated_at > cursor` 증분 다운로드.
- **충돌 해결**: `workout_records`는 append-only + UUID라 충돌 자체가 없음. `exercises`·`goals`·`routines`는 `updated_at` 비교 last-write-wins.
- 인증: 익명 시작(로컬 전용) → 로그인 시 로컬 데이터에 `user_id` 부여 후 첫 push. 계정 전환 시 로컬 DB 분리.

## 7. 폰 ↔ 워치 통신

| 용도 | iOS (WatchConnectivity) | Android (Wearable Data Layer) |
|------|------------------------|-------------------------------|
| 상태 스냅샷 (오늘 링·최근 종목·프리필 값) | `updateApplicationContext` | `DataClient` (경로: `/state`) |
| 워치 → 폰 기록 전송 | `transferUserInfo` (큐잉·보장) | `MessageClient` + 자체 재시도 큐 |
| 실시간 (루틴 진행 미러링) | `sendMessage` (도달 시) | `MessageClient` |

- 메시지 페이로드는 **플랫폼 공통 JSON 스키마** (`schemaVersion` 필드 포함): `{type: "record", id: uuid, exerciseId, amount, recordedAt, source: "watch"}`.
- 워치는 오프라인이면 로컬 큐에 쌓고 연결 시 일괄 전송. 폰은 UUID로 멱등 처리(중복 insert 무시).
- 워치 앱 저장소: 최근 종목 2~3개 + 오늘 진행률 스냅샷 + 미전송 큐뿐 — DB 없음(UserDefaults/DataStore 수준).
- 워치 단독 루틴·세트 실행: 타이머 로직은 워치 네이티브로 각각 구현(경량 상태기계 포팅), 완료 기록만 폰으로 전송.

## 8. 헬스 연동 (HealthKit / Health Connect, M4)

- **쓰기**: 앱에서 저장한 세션(루틴·세트·런)을 워크아웃으로 기록.
- **읽기(R11)**: 러닝 워크아웃 구독 — iOS `HKObserverQuery` + 백그라운드 딜리버리, Android Health Connect 주기 폴링(WorkManager).
- 가져온 기록은 `source='health'`, `external_source`(예: `com.nike.nrc`) + `external_id`로 UNIQUE 제약 → 재가져오기 멱등. 자기 앱이 쓴 세션은 제외(루프 방지).
- 가져오기 후엔 일반 기록과 동일하게 `RecordSaved` 이벤트 → 목표·스트릭·뱃지 자동 반영.

## 9. 위젯 · 컴플리케이션 · 알림

- **홈 위젯**: iOS WidgetKit + App Intents(원탭 기록), Android Glance. 데이터는 공유 저장소(App Group / SharedPreferences)로 스냅샷 전달.
- **컴플리케이션**: 오늘 링 % 표시 + 탭 시 워치 앱 진입.
- **알림**: 전부 로컬 알림(목표 달성 축하, 뱃지 획득). 서버 푸시 없음 — 압박 알림을 만들지 않는 제품 원칙과 일치.

## 10. 성능 예산 (R1)

| 항목 | 목표 | 전략 |
|------|------|------|
| 콜드 스타트 → 홈 표시 | < 1.5s | 홈 첫 프레임에 필요한 쿼리 2개(종목+오늘 합산)만 동기 경로, 나머지 lazy |
| 기록 저장 (탭 → 햅틱) | < 100ms | 단일 insert + 트랜잭션, 동기화는 큐로 분리 |
| 카드 탭 → 시트 표시 | < 200ms | 프리필 값은 홈 로드 시 미리 메모리에 |
| 워치 기록 → 폰 반영 | < 5s (연결 시) | applicationContext 즉시 갱신 |
| DB 규모 | 10년치(~5만 행)에서 통계 < 50ms | 인덱스 + 월 단위 페이징 |

## 11. 기술 스택 확정 요약

| 영역 | 선택 | 비고 |
|------|------|------|
| 폰 UI | Flutter (Dart 3) | iOS·Android 1벌 |
| 상태관리 | Riverpod | Drift 스트림과 결합 |
| 라우팅 | go_router | 시트·모달 포함 |
| 로컬 DB | Drift (SQLite) | 반응형 쿼리, 타입 세이프 |
| 클라우드 | Supabase | Postgres + Auth + RLS (M4) |
| watchOS | SwiftUI + WatchConnectivity | 경량 네이티브 |
| Wear OS | Compose for Wear OS + Data Layer | 경량 네이티브 |
| 헬스 | HealthKit / Health Connect | 쓰기 M4, 러닝 읽기 M4 |
| TTS·햅틱 | flutter_tts · 플랫폼 햅틱 API | 워치는 네이티브 햅틱 |

## 12. 모듈 × 마일스톤

| 마일스톤 | 구현 범위 |
|----------|-----------|
| M1 | Flutter 앱 전체 레이어, Drift 스키마 v1, RecordService·TimerEngine(세트·런)·GoalEngine, CueService 최소 구현(햅틱·알림음 — TTS는 M3), 홈·기록·목표·통계·종목 CRUD, DB 내보내기 |
| M2 | 루틴 빌더·실행(TimerEngine 확장), CueService(TTS·햅틱 패턴), BadgeEngine + 컬렉션 화면 *(2026-07-23 워치와 순서 교체)* |
| M3 | 워치 2종(SwiftUI/Compose), 워치 브리지 + 공통 메시지 스키마, 멱등 수신 |
| M4 | SyncQueue + Supabase 동기화, 헬스 읽기/쓰기, 위젯·컴플리케이션, rollup 캐시(필요 시) |

---

### 열린 결정 (추후 확정)

1. iOS Live Activity(런 타이머·루틴 진행 잠금화면 표시) 도입 여부 — M3에서 판단
2. Supabase vs Firebase 최종 확정 — M4 착수 전 비용·RLS 편의성 비교
3. ~~통계 rollup 캐시 도입 시점~~ → **확정(2026-07-23)**: 스트릭 400일 윈도우로 대응, rollup은 M4 재평가 (4장 참고)
