---
title: 빈 결과와 실패를 구분한다 — 조용한 0건을 막는 경계
type: concept
tags: [fail-loud, batch, configuration, partial-failure, cache, morningbrief, spring-boot, kotlin, flutter]
sources:
  - morningbrief/
created: 2026-11-19
updated: 2026-11-19
---

# 빈 결과와 실패를 구분한다 — 조용한 0건을 막는 경계

## 정의

배치·동기화·화면 어디서든 "0건"은 두 가지 뜻을 가집니다. 정말 소식이 없었다는 **정상 빈 결과**와, 무언가 깨져서 아무것도 못 가져왔다는 **실패**입니다. 둘을 같은 값(빈 리스트)으로 흘려보내면 시스템은 실패를 정상처럼 게시하고, 아무 알림도 울리지 않습니다.

이 페이지의 원칙은 한 줄입니다. **빈 값이 정상일 수 없는 자리에서는 빈 값을 실패로 바꾸고, 실패가 빈 값으로 둔갑해 기존 데이터를 지우거나 덮지 못하게 합니다.**

사례는 모두 [[src-morningbrief]] 저장소의 2026-10-25 ~ 11-04 기록입니다(`raw/morningbrief/TIMELINE.md`).

## 원형 사고 — 2026-10-27 뉴스 토픽 0건

아래 표는 그날 아침에 일어난 일을 순서대로 정리한 것입니다.

| 단계 | 일어난 일 |
|------|----------|
| 원인 | `application.yml`의 `brief.sources` 블록 한가운데에 `brief.picks` 블록이 끼어들었습니다 |
| 증상 | 뒤따르던 `rss:`가 `picks` 아래로 붙어 `brief.sources.rss`가 빈 맵으로 바인딩됐습니다 |
| 결과 | 06:00 배치는 성공으로 끝났고, 뉴스 토픽 7개가 0건, 복지·정책만 게시됐습니다 |
| 2차 증상 | 07:59 재게시 뒤에도 이미 오늘 브리핑을 받은 기기는 캐시의 빈 브리핑을 계속 보여 줬습니다 |

YAML 구조는 다음과 같았습니다. 들여쓰기 두 칸짜리 `picks:`가 들어온 순간, 네 칸짜리 `rss:`의 부모가 바뀝니다.

```yaml
brief:
  sources:
    onpocket:
      base-url: ...
  picks:                 # ← 10-25에 끼어든 블록 (들여쓰기 2칸)
    partner-key: ${ONPOCKET_PARTNER_KEY:}
    rss:                 # ← 원래 sources.rss. 이제 brief.picks.rss가 됨
      feeds:
        economy: [...]
```

컴파일·기동·테스트 어디에서도 오류가 나지 않았습니다. RSS 토픽의 피드 목록을 `orEmpty()`로 받고 있었기 때문입니다.

## 고친 방법 — 세 겹

| 겹 | 변경 | 커밋 |
|----|------|------|
| 1. 설정 복구 | `picks` 블록을 `sources` 밖으로 옮김 | `6b50db9` |
| 2. 바인딩 테스트 | 실제 `application.yml`을 `Binder`로 읽어 뉴스 토픽 피드가 비어 있지 않은지 검사 | `6b50db9` |
| 3. 런타임 실패 | RSS 토픽인데 피드가 비면 `error(...)` → 배치 실패 → 배치 허브 알림 | `403935a` |
| 4. 클라이언트 | 오늘 브리핑은 캐시 대신 항상 서버에서 읽음(지난 날짜만 캐시 우선) | `9af12b0` |

3번이 핵심입니다. RSS 토픽에 피드가 0개인 상태는 어떤 날에도 정상이 아니므로, 빈 값을 실패로 바꿔도 잃는 것이 없습니다.

```kotlin
private fun initialQueries(topic: Topic): List<String> = when (topic.source) {
    // 설정이 깨져 피드가 비면 조용히 0건이 된다(2026-10-27) → 실패시켜 배치 알림이 가게 한다
    Topic.SourceType.RSS -> feeds.feeds[topic.key].orEmpty().map { it.url }
        .ifEmpty { error("RSS 피드 설정 없음: ${topic.key}") }
    else -> listOf(topic.sourceParam)
}
```

2번 테스트는 테스트용 설정이 아니라 **운영 설정 파일 자체**를 읽는다는 점이 중요합니다.

```kotlin
@Test
fun applicationYmlBindsRssFeedsForNewsTopics() {
    val env = StandardEnvironment()
    YamlPropertySourceLoader().load("app", ClassPathResource("application.yml"))
        .forEach { env.propertySources.addLast(it) }
    val feeds = Binder.get(env).bind("brief.sources.rss", RssFeedProperties::class.java).get().feeds

    assertThat(feeds.keys).contains("economy", "current", "world", "it-ai", "tech", "health")
    assertThat(feeds.values).allSatisfy { assertThat(it).isNotEmpty() }
}
```

4번은 같은 사고의 다른 면입니다. "게시된 브리핑은 바뀌지 않는다"는 가정으로 캐시를 우선했는데, 장애 복구용 재게시가 그 가정을 깼습니다. 지난 날짜는 여전히 불변이므로 캐시를 유지하고, 오늘만 예외로 뒀습니다.

## 같은 저장소의 형제 사례

10-27 이후 같은 앱에서 같은 구분이 반복해서 필요했습니다. 표의 "판정"은 빈 값이 그 자리에서 정상일 수 있는지를 뜻합니다.

| 자리 | 빈 값이 정상일 수 있나 | 실패를 빈 값으로 두면 | 택한 처리 |
|------|----------------------|---------------------|-----------|
| RSS 토픽 피드 설정 | 아니오 | 0건 게시, 알림 없음 | 실패로 바꿈 |
| 온포켓 맞춤 정보(picks) 동기화 | 예(동의를 끈 회원은 응답에 없음 → 삭제가 정상) | 조회 실패가 "전원 동의 해제"로 읽혀 전원의 picks 삭제 | 조회 실패면 아무것도 지우지 않음 |
| 앱 안 온포켓 날짜별 목록 `onpocket/{date}` | 예(공개분이 없는 날) | 피드 실패가 그날 목록을 빈 목록으로 덮음 | 피드 실패면 기존 목록을 덮지 않음 |
| 온포켓 대표 주제 목록 `categories` | 부가 정보 | 부가 정보 실패가 본 목록 저장까지 막음 | 실패해도 목록은 저장(부분 실패 격리) |
| 앱 온포켓 오늘 화면(30일 묶음) | 예 | 날마다 실패를 삼켜 오프라인에서 "소식이 없어요" | 한 날도 못 읽고 오류가 있으면 오류·다시 시도 |
| 맞춤 정보 하루 1회 캐시 | — | 오프라인 응답을 "오늘 받음"으로 기록하면 하루 동안 갱신 안 됨 | 오프라인 응답은 받은 시각을 기록하지 않음 |
| KISA 보호나라 RSS `pubDate`(날짜만) | — | 0시로 해석하면 전날 공지가 24시간 창에서 조용히 빠짐 | 날짜만 있으면 KST 정오로 해석 |
| 파트너 키 없는 환경 | 예(개발 환경) | — | 의도된 건너뜀, 로그 한 줄 |

마지막 행은 대조군입니다. 키가 없는 개발 환경에서 picks를 건너뛰는 것은 설계상 정상이라 실패로 만들지 않았습니다. 같은 "빈 설정"이라도 RSS 피드와 파트너 키의 처리가 다른 이유는 오직 **그 빈 값이 정상일 수 있느냐**입니다.

## 판정 순서

빈 결과를 다루는 코드를 쓰거나 리뷰할 때 아래 순서로 묻습니다.

1. 이 자리에서 빈 값이 **정상일 수 있는가?** 아니면 빈 값을 예외·실패 결과로 바꿉니다.
2. 정상일 수 있다면, 이 빈 값이 **기존 데이터를 지우거나 덮는가?** 그렇다면 "조회 성공 + 빈 응답"일 때만 지우고, 조회 실패면 손대지 않습니다.
3. 부가 정보의 실패가 **본 정보의 저장을 막는가?** 막는다면 분리해 본 정보는 저장합니다.
4. 캐시·앵커·"받은 시각" 같은 **진행 표시를 실패 응답이 전진시키는가?** 실패 응답은 진행 표시를 건드리지 않습니다.
5. 사용자 화면에서 **오류와 빈 목록이 같은 문구로 보이는가?** 오류에는 다시 시도를 줍니다.

## 같은 인사이트 패턴 — "조용히 실패하는 것이 가장 비싸다"

다른 영역에서 같은 구조의 함정과 해결을 정리한 페이지들입니다.

| 영역 | 조용한 실패 | 시끄럽게 만든 방법 | 참조 |
|------|------------|------------------|------|
| **배치 설정 바인딩** | 깨진 YAML이 빈 맵 → 0건 게시 | 빈 피드면 실패 + 운영 설정 바인딩 테스트 | (이 페이지) |
| 헬스 증분 가져오기 | 전부 건너뛴 배치가 앵커를 전진 → 이후 영영 0건 | 가져온 것이 있을 때만 앵커 전진 | [[concept-thin-client-idempotent-sync]] |
| JPA Enum 매핑 | ORDINAL이 순서 변경 뒤 다른 값으로 조용히 오염 | STRING 매핑으로 즉시 예외 | [[concept-jpa-enum-mapping]] |
| AI 반복 루프 | 종료 조건 하나가 빠지면 루프가 조용히 실패 | 검증·반복 상한·토큰 예산 3중 종료 조건 | [[concept-loop-engineering]] |
| API 계약 | 기존 필드 의미를 바꾸는 silent change | 의미 변경 금지, 새 필드 추가 | [[concept-api-backward-compatibility]] |

→ 공통 원리: **실패는 발생한 자리에서 가장 싸게 드러납니다.** 빈 값으로 한 단계만 흘러가도 "성공한 배치"와 "정상 화면"의 모양을 하게 되고, 사람이 알아채는 시점은 사용자가 이상하다고 말할 때로 밀립니다.

## 빠른 진단

- [ ] `orEmpty()`·`?: emptyList()`·`catch { return [] }` 뒤에 그 빈 값이 정상인지 주석이나 테스트로 설명돼 있습니까?
- [ ] 운영 설정 파일(`application.yml` 등)을 직접 읽어 핵심 키가 비지 않았는지 보는 테스트가 있습니까?
- [ ] 동기화가 "응답에 없음 = 삭제"를 쓴다면, 조회 실패 때 삭제 단계로 넘어가지 않습니까?
- [ ] 실패 응답이 캐시 시각·앵커·커서를 전진시키지 않습니까?
- [ ] 게시물을 불변으로 보고 캐시한다면, 같은 날 재게시 경로가 클라이언트에 닿습니까?
- [ ] 화면에서 오류와 빈 목록이 다른 문구·다른 행동(다시 시도)을 가집니까?

## 원본 출처

- raw: `raw/morningbrief/TIMELINE.md` §2·§3·§5·§6 (2026-11-19 조회)
- 비공개 저장소 morningbrief — `DigestGraph.kt`(`403935a`), `RssFeedPropertiesBindingTest.kt`(`6b50db9`), `session.dart`(`9af12b0`), `docs/progress.md`(PickService·OnPocketService·오프라인 오류·보호나라 pubDate)

## 관련 페이지

- [[src-morningbrief]] — 이 원칙이 나온 앱의 개발·운영 기록
- [[concept-thin-client-idempotent-sync]] — 빈 배치가 앵커를 밀던 같은 구조의 함정
- [[concept-loop-engineering]] — "루프는 조용히 실패한다"는 종료 조건 설계
- [[concept-jpa-enum-mapping]] — 조용한 오염보다 즉시 예외가 안전한 실패 모드
- [[src-on-pocket-news]] — picks·피드·대표 주제를 제공하는 자매 서비스
- [[concept-run-once-batch-exit-contract]] — 헤드리스 감수가 API를 한 번도 못 불렀는데 exit 0이던 같은 뿌리의 사례

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [모닝 브리핑 한 달 — 소개 글 이후 바뀐 것과 그 이유](https://blog.wonslab.dev/2026-11-19-morningbrief-update/)
