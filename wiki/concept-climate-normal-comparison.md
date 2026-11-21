---
title: 기후 평년 비교 — 이동 기준선과 고정 기준선, 예보와 실측의 분리
type: concept
tags: [climate-normal, baseline, deviation, forecast, observation, domain-model, dongne-climate]
sources: [dongne-climate/TECH_NOTES.md]
created: 2026-11-19
updated: 2026-11-19
---

# 기후 평년 비교 — 이동 기준선과 고정 기준선, 예보와 실측의 분리

## 정의

"오늘 날씨가 평소와 다른가"와 "우리 동네 기후가 변했는가"는 비슷해 보이지만 다른 질문입니다. [[src-dongne-climate]]는 두 질문에 **서로 다른 기준선**을 쓰고, 두 기준선을 **하나의 계산기**로 처리합니다. 그리고 아직 확정되지 않은 오늘 값(예보)이 기준선 계산에 섞이지 않도록 **타입으로** 막습니다.

> 체감은 최근 기후로, 변화는 움직이지 않는 기준선으로. (앱 저장소 docs/00 "핵심 결정")

| 질문 | 화면 | 기준선 | 성질 |
|------|------|--------|------|
| 오늘, 원래 이랬나? | 오늘 카드, 주간 그래프 | 직전 10년 같은 월·일 | 해마다 함께 이동 |
| 10년 사이 동네가 변했나? | 기후 섹션(더운 날 수, 줄무늬) | 고정 기간 2016~2025 | 움직이지 않음 |

## 왜 기준선이 두 개인가

| 기준선 | 장점 | 한 가지만 쓰면 생기는 문제 |
|--------|------|--------------------------|
| 이동(직전 10년) | 요즘 사람이 기억하는 "보통 이맘때"와 가까움 | 기후 섹션에 쓰면 기준선이 더위를 따라 올라가 "더운 날"이 늘어도 덜 보임 |
| 고정(2016~2025) | 연도별 숫자를 같은 자로 잴 수 있음 | 오늘 카드에 쓰면 해가 갈수록 오래된 기억과 비교하게 됨 |

2026년에는 직전 10년이 2016~2025라 두 기준선이 우연히 같습니다. 2027년부터 이동 기준선은 2017~2026으로 옮겨 가고, 고정 기준선은 그대로 남습니다. 둘을 처음부터 다른 값으로 넘기도록 설계했기 때문에 그때 코드를 고칠 필요가 없습니다.

## 계산기 하나, 기간은 값으로

기간을 계산기의 내부 상수로 두지 않고 값 객체로 넘깁니다. 어느 기간을 넘길지는 호출하는 배치(PublishJob)가 정합니다.

```java
/** 평년 계산 기간(양 끝 포함). 직전 10년과 고정 기간을 같은 값으로 다룬다. */
public record BaselinePeriod(int fromYear, int toYear) {
    public static BaselinePeriod precedingTenYears(int year) {
        return new BaselinePeriod(year - 10, year - 1);   // 2026 → 2016~2025
    }
    public boolean contains(int year) { return year >= fromYear && year <= toYear; }
}

// 호출 쪽(PublishJob) — 화면마다 기간이 다르다
static final BaselinePeriod CLIMATE_BASELINE = new BaselinePeriod(2016, 2025);
normal(md, BaselinePeriod.precedingTenYears(d.getYear()));   // 오늘 카드·주간
```

| 규칙 | 내용 | 이유 |
|------|------|------|
| 기간 안 연도만 | `period.contains(year)` | 기준선이 섞이지 않게 |
| 결측 제외 | 평균기온이 비어 있는 해는 표본에서 뺌 | 0으로 채우면 평년이 내려감 |
| 2/29 | 평년 계산에서는 2/28 값으로 봄 | 4년에 한 번 표본 1~3개가 되는 문제 회피 |
| 표본 부족 | 5년 미만이면 `bandHidden=true`, 범위 밴드를 숨김 | 짧은 기록으로 "보통 범위"를 그리지 않음 |

주의할 점이 하나 있습니다. 평년 계산의 2/29 규칙과 **연도 비교 화면**의 2/29 규칙은 다릅니다. 2026-11-16 예외처리 점검(E-B07)에서 2/29가 없는 해는 연도 비교에서 빈칸으로 두기로 바꿨습니다. 전에는 2/28 값을 넣어서, 없는 날짜에 값이 있는 것처럼 보였습니다.

## 편차와 구간 — 문구와 색이 같은 경계를 쓴다

편차는 `오늘 − 평년`이고 관측 정밀도(0.1℃)로 반올림합니다. 둘 중 하나라도 없으면 편차도 없습니다(`Optional.empty()`).

| 구간 | 경계 | 색 토큰 |
|------|------|---------|
| COLD_3 | ≤ −5 | #08519c |
| COLD_2 | −5 < d ≤ −3 | #4292c6 |
| COLD_1 | −3 < d ≤ −1 | #9ecae1 |
| NORMAL | −1 < d < 1 | #e6e3d9 |
| WARM_1 | 1 ≤ d < 3 | #fc9272 |
| WARM_2 | 3 ≤ d < 5 | #ef3b2c |
| WARM_3 | ≥ 5 | #a50f15 |

헤드라인 문구("이맘때치고 정말 추워요" 등)와 점·칩의 색이 같은 `DeviationBand`를 씁니다. 경계를 화면마다 따로 적으면 문구는 "보통"인데 색은 "따뜻함"인 어긋남이 생기기 때문입니다. 색은 기후 줄무늬(ColorBrewer Blues·Reds) 팔레트이고, 빨강·파랑은 기온 의미에만 씁니다.

## 연간 지표는 고정 기준선만 받는다

```java
// 더운 날 = 편차 ≥ +3℃, 열대야 = 최저 ≥ 25℃, 영하일 = 최저 < 0℃
public static YearStats of(int year, List<DailyObservation> observations,
                           Function<MonthDay, Normal> normalOf) { ... }
```

`normalOf`를 함수로 받아 YearStats는 기간을 모릅니다. 기후 섹션은 고정 기간 평년을 넘깁니다. 서울 관측소 실데이터(2026-11-17 backfill)에서 2016 → 2025 더운 날은 45 → 74일, 열대야 32 → 45일, 영하일 94 → 81일이었습니다(커밋 `e3f2c43`).

## 예보와 실측의 분리

오늘 값은 아침 05:00엔 확정값이 없습니다. 기상청 전일 자료는 당일 10시 이후에 게시되기 때문입니다. 그래서 오늘은 단기예보로 "오늘 예상"을 보여 주고, 다음 날 11:00에 실측으로 바꿉니다.

| 저장 | 컬렉션 | 덮어쓰기 | 기준선 계산에 쓰나 |
|------|--------|---------|------------------|
| 실측 | observations | 실측만 upsert | 예 |
| 예보 | forecasts | 실측이 들어와도 지우지 않음(나중에 예보 오차 비교용) | 아니오 |

섞이지 않게 하는 장치는 문서 규칙이 아니라 타입입니다.

| 타입 | 받는 것 | 효과 |
|------|---------|------|
| NormalCalculator, YearStats | `DailyObservation`만 | 예보를 넘기면 컴파일 오류 |
| DayValue | `resolve(observed, forecast)` → 실측 > 예보 > 없음 | 화면용 값에만 예보가 섞이고 `forecast=true` 표시가 붙음 |

```java
public static Optional<DayValue> resolve(DailyObservation observed, DailyForecast forecast) {
    if (observed != null) return Optional.of(/* ... */ false);   // 실측
    if (forecast != null) return Optional.of(/* ... */ true);    // 예상
    return Optional.empty();
}
```

화면은 `forecast=true`인 값에 "(예상)", 점선 테두리, 표의 `*`를 붙입니다.

## 함정 · "오늘 값이 비었다"

11:00 전(어제 확정값 게시 전)에 오늘 예보까지 실패하면 오늘 카드가 비었습니다. 해결은 "지난 7일 안의 마지막 값"을 기준일로 내보내고, 화면에서 그 기준일을 강조하는 것입니다(E-A04, 커밋 `e10a1dc`). 빈 화면 대신 "언제 값인지 밝힌 마지막 값"을 보여 줍니다.

## 함정 · 눈 판정에 쓸 적설

일 최심적설(ddMes)은 며칠 전에 내린 눈이 쌓여 있어도 값이 잡혀 "그날 눈"을 과대 판정합니다. 그날 새로 쌓인 눈인 일 최심신적설(ddMefs)로 바꿨습니다(커밋 `3609a2b`). 하늘상태 판정은 눈 > 비 > 강풍 > 흐림 > 구름조금 > 맑음 순서이고, 근거가 없고 운량도 결측이면 맑음으로 추측하지 않고 "알수없음"입니다.

## 같은 인사이트 패턴 — "진실은 하나, 나머지는 파생"

| 영역 | 진실 | 파생 | 참조 |
|------|------|------|------|
| **기후 비교** | 실측 일값(observations, climate 문서) | 평년·편차·연간 지표(배포 때 계산, 저장 안 함) | 이 페이지 |
| 기록 앱 | append-only 기록 | 스트릭·통계 | [[concept-local-first-append-only]] |
| 타이머 | 세그먼트 인덱스 + 시작 앵커 | 남은 시간 | [[concept-wall-clock-state-machine]] |
| 폰↔워치 | 폰 DB | 워치 스냅샷 캐시 | [[concept-thin-client-idempotent-sync]] |

이 앱에서는 예보가 "진실 후보"로 한 겹 더 있습니다. 예보는 화면에만 파생되고, 진실(실측)이 도착하면 같은 날짜가 실측으로 바뀝니다. 진실 자리를 예보에 내주지 않는 것이 핵심입니다.

## 같은 인사이트 패턴 — "기준을 값으로 주입한다"

| 페이지 | 바뀔 수 있는 기준 | 주입 방식 |
|--------|------------------|-----------|
| **이 페이지** | 평년 기간 | `BaselinePeriod` 값, `Function<MonthDay, Normal>` |
| 이 페이지(하늘상태) | 비·강풍·운량 임계값 | `SkyThresholds` 레코드 |
| [[concept-wall-clock-state-machine]] | 현재 시각 | 시계 주입 seam |

## 빠른 진단

- [ ] "평소"와 "변화"를 같은 기준선으로 재고 있지 않습니까?
- [ ] 기준선 기간이 계산기 안에 상수로 박혀 있지 않습니까?
- [ ] 확정 전 값(예보·추정)이 평균 계산 입력에 들어갈 수 있는 타입입니까?
- [ ] 표본이 적은 날의 범위를 그대로 그리고 있지 않습니까?
- [ ] 화면 문구와 색이 같은 구간 경계를 공유합니까?

## 원본 출처

- raw: `raw/dongne-climate/TECH_NOTES.md` §2·§3·§6
- 앱 저장소 docs/domain.md, docs/00-design-summary.md "핵심 결정", 도메인 코드 `BaselinePeriod.java` `NormalCalculator.java` `DayValue.java` `YearStats.java`

## 관련 페이지

- [[src-dongne-climate]] — 이 개념이 나온 앱의 개발기
- [[concept-local-first-append-only]] — 파생값을 저장하지 않는 같은 원리
- [[concept-wall-clock-state-machine]] — 기준(시각)을 주입하는 같은 원리
- [[concept-domain-model-kinds]] — 값 객체·엔티티 구분

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [동네기후 — 오늘 날씨, 원래 이랬나?](https://blog.wonslab.dev/2026-11-19-dongne-climate-intro/)
