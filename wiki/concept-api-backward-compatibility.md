---
title: API 하위 호환성과 JSON Tolerant Reader 계약
type: concept
tags: [api, json, backward-compatibility, breaking-change, kotlinx-serialization, gson, jackson]
sources:
  - ai-engineering/2bun-coding/api-breaking-change-json.md
external:
  - https://www.youtube.com/watch?v=LBWefG5zjxk
  - https://martinfowler.com/bliki/TolerantReader.html
created: 2026-06-06
updated: 2026-09-29
---

# API 하위 호환성과 JSON Tolerant Reader 계약

## 정의

API 응답에 **새 필드를 추가**하는 것은 서버 개발자에겐 "안전한 변경"으로 느껴지지만, **클라이언트 JSON 라이브러리의 미지(unknown) 필드 처리 정책에 따라 Breaking Change**가 됩니다. 가장 엄격한 클라이언트가 기준이 됩니다.

> "응답에 정의되지 않은 필드가 와도 클라이언트는 무시한다"는 **Tolerant Reader 계약**을 명시적으로 약속해야 한다 (Martin Fowler).

## 사고 시나리오

```
서버: User 응답에 nickname 필드 추가 (기존 필드 유지)
       기존: { "id": 1, "name": "Alice" }
       신규: { "id": 1, "name": "Alice", "nickname": "AliceTheCat" }
                                          ^^^^^^^^^^^^^^ 추가됨

웹 (JavaScript JSON.parse):       ✅ 정상 (모르는 필드 자연 무시)
안드로이드 A (Gson):              ✅ 정상 (모르는 필드 무시)
안드로이드 B (kotlinx.serialization): ❌ SerializationException 폭발
                                       → API 호출 전부 실패
```

원인은 같은 안드로이드 안에서도 **JSON 라이브러리 기본 설정 차이**에 있습니다.

## 주요 JSON 라이브러리의 기본 동작

| 환경 | 라이브러리 | 미지 필드 기본 동작 | 엄격 모드로 바꿀 수 있나? |
|------|---------|----------------|--------------------|
| Browser/Node | `JSON.parse` | 무시 (DTO 개념 없음) | — |
| Java/Kotlin (Android A) | **Gson** | **무시** ✅ | 명시적 검증 코드 필요 |
| Java/Spring | **Jackson** | **무시** ✅ (`FAIL_ON_UNKNOWN_PROPERTIES = false`가 사실상 표준) | `true`로 켜면 엄격 |
| Kotlin (Android B) | **kotlinx.serialization** | **실패** ❌ (`ignoreUnknownKeys = false` 기본) | `ignoreUnknownKeys = true` |
| Java | Moshi | 무시 (기본) | `@JsonClass(generateAdapter = true)` 옵션 |
| Java | Yasson (JSON-B) | 무시 (기본) | — |
| Rust | `serde_json` | **실패** ❌ (`#[serde(deny_unknown_fields)]` 가능) | 옵션 |
| Go | `encoding/json` | 무시 (기본) | `DisallowUnknownFields()` |

→ **클라이언트 JSON 라이브러리의 기본값이 천차만별입니다**. 서버가 컨트롤할 수 없습니다.

## Tolerant Reader 패턴 (Martin Fowler, 2011)

> "Be conservative in what you send, be liberal in what you accept."

API 클라이언트는 **응답에서 본인이 필요한 필드만 꺼내 쓰고, 모르는 필드는 무시**해야 한다는 패턴입니다. 이게 지켜져야 서버는 안전하게 새 필드를 추가할 수 있습니다.

### 서버 측 추가가 안전한 변경 (Tolerant Reader 전제 하에)

- ✅ **선택적 필드 추가** (있어도 되고 없어도 되는 응답 필드)
- ✅ 필드 순서 변경
- ✅ 응답 값 범위 확장 (enum에 새 값 추가 — 단, 클라이언트가 알 수 없는 enum도 안전하게 처리해야 합니다)

### Breaking Change (계약상으로도 깨짐)

- ❌ **기존 필드 제거**
- ❌ **기존 필드 타입 변경** (string → object 등)
- ❌ **기존 필드 의미 변경** (가격 단위 KRW → USD 같은 silent change)
- ❌ **응답 구조 wrapping** (`{...}` → `{ "data": {...} }`)
- ❌ enum 값 의미 변경

## 해결책 — 4가지 방어 라인

### 1. API 명세에 Tolerant Reader 명시

OpenAPI 스펙이나 README의 클라이언트 가이드에:

```markdown
## 클라이언트 구현 규칙

- 서버는 응답에 **새 필드를 자유롭게 추가**할 수 있다.
- 클라이언트는 **자신이 모르는 필드를 반드시 무시**해야 한다.
- 미지 필드를 만났을 때 예외를 던지는 라이브러리를 쓴다면 **반드시 관용 모드로 설정**한다.
```

### 2. 클라이언트별 권장 설정 문서화

**Kotlin (kotlinx.serialization)**:
```kotlin
val json = Json {
    ignoreUnknownKeys = true       // 미지 필드 무시 (필수)
    coerceInputValues = true       // null → 기본값 변환
    explicitNulls = false
}
```

**Java (Jackson, Spring 기본)**:
```java
ObjectMapper mapper = new ObjectMapper()
    .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
```

Spring Boot에서는 `application.yml`:
```yaml
spring:
  jackson:
    deserialization:
      fail-on-unknown-properties: false   # 기본값, 명시적으로 보장
```

**Go**: 기본이 관용. 굳이 `DisallowUnknownFields()` 켜지 않기.

### 3. 계약 테스트 (Contract Test)

새 필드 추가 시 **각 주요 클라이언트의 mock 응답으로 회귀 테스트**:

```kotlin
@Test
fun `nickname 필드가 추가되어도 기존 클라이언트는 파싱 성공해야 한다`() {
    val newServerResponse = """{"id":1,"name":"A","nickname":"AC"}"""
    val parsed = Json { ignoreUnknownKeys = true }
        .decodeFromString<User>(newServerResponse)
    assertEquals(1, parsed.id)
}
```

CI에 자동으로 포함합니다.

### 4. 버전 관리 (`/v1`, `/v2`) — 마지막 카드

위 3가지로도 부족할 때 (구조 변경 등 진짜 breaking change)만:

| 패턴 | 부담 |
|------|------|
| URL 버전 (`/api/v1/users`) | 라우팅 단순, 가장 일반적 |
| 헤더 버전 (`API-Version: 2`) | 깔끔하지만 디버깅 어려움 |
| 미디어타입 (`Accept: application/vnd.app.v2+json`) | RESTful 원리주의 |

### 버전 분리의 함정

> "강제 업데이트가 불가능한 환경(B2B 고객사 앱)에서는 v1 사용자가 앱을 업데이트하지 않는 한, 서버는 과거 버전 코드를 영원히 유지해야 한다."

`v1`을 만들면:
- 비즈니스 로직 변경 시마다 **v1·v2 양쪽 반영 + 양쪽 테스트** (2배 비용)
- 결국 v3, v4... 누적 → 유지보수 지옥
- **deprecation 정책 + sunset 시점 합의가 함께** 가야 합니다

## 빠른 진단 — 우리 응답은 미지 필드 안전한가

```bash
# 클라이언트 코드에서 엄격 모드 사용 여부 점검
grep -rn "ignoreUnknownKeys\s*=\s*false\|FAIL_ON_UNKNOWN_PROPERTIES.*true\|deny_unknown_fields\|DisallowUnknownFields" \
  src/ android/ web/ 2>/dev/null
```

찾으면:
- 비즈니스 정당성 확인 (보안 검증 등 일부 케이스는 정당)
- 정당성 없으면 관용 모드로 변경 + 코드 리뷰 룰 추가

## 같은 인사이트 패턴 — "기본값과 가정의 함정"

| 페이지 | 위험한 기본값·가정 | 결과 | 실무 권장 |
|--------|-------------------|------|----------|
| [[concept-transactional-rollback-policy|트랜잭션 롤백]] | `@Transactional`이 모든 예외를 롤백한다는 가정 (기본은 unchecked 예외·`Error`만 롤백) | 체크 예외에서 커밋되어 데이터 오염 | `rollbackFor = Exception.class` 또는 사내 합성 애너테이션 |
| **API 하위 호환 (이 페이지)** | 클라이언트 JSON 파서가 미지 필드에 관용적일 것이라는 가정 (라이브러리마다 기본값이 다름) | 응답 필드 하나 추가로 앱 전체 오류 | Tolerant Reader + 응답 구조 wrapping 변경 금지 |
| [[concept-api-versioning|API 버전 관리]] | 버전을 나누면 변경 부담이 끝난다는 가정 | 강제 업데이트가 불가한 환경에서 v1 코드 영구 유지 | 버전은 Controller·DTO에만 + deprecation·sunset 합의 |
| [[concept-jpa-enum-mapping|JPA enum 매핑]] | JPA `@Enumerated` 기본 `ORDINAL` | enum 순서 변경·중간 삽입 시 조용한 데이터 오염 | `EnumType.STRING` + `@Column(length)` 명시 |
| [[concept-cronjob-concurrency-trap|크론잡 동시 실행]] | K8s CronJob `concurrencyPolicy` 기본 `Allow` | 배치 중복 실행 → 정산 2배 | `Forbid` + `activeDeadlineSeconds` |
| [[concept-keepalive-timeout-race|Keep-Alive 타임아웃]] | 웹 서버 keep-alive 기본값이 LB idle 이하 (Gunicorn 2초·Node.js 5초·Tomcat 60초 vs ALB 60초) | 서버가 먼저 끊어 새벽 간헐 502 | 서버 keep-alive > LB idle (+5~15초) |
| [[concept-db-connection-pool|DB 커넥션 풀]] | 풀의 커넥션이 계속 유효하다는 가정 (`maxLifetime`이 DB `wait_timeout`·방화벽/LB idle 제한보다 김) | 이미 끊긴 커넥션 대여 → 산발적 `Connection is closed` | `maxLifetime`을 가장 짧은 인프라 제한보다 몇 초 짧게 + `keepaliveTime` |
| [[concept-varchar-length-prefix|VARCHAR 길이]] | 관습적 `VARCHAR(255)` (Latin1 시대의 1바이트 프리픽스 경계) | utf8mb4에서는 2바이트 프리픽스 → 의도와 다른 저장·인덱스 비용 | 도메인 상한 우선 + utf8mb4의 63 경계 인지 |
| [[concept-java-serialization-risk|자바 직렬화]] | `ObjectInputStream`이 데이터를 그냥 읽어 줄 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) | JSON·Protobuf로 대체, 불가피하면 `ObjectInputFilter` 화이트리스트 |
| [[concept-id-reference-vs-object-reference|애그리거트 참조]] | JPA 객체 참조로 애그리거트 경계 관통 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |

→ **"가장 엄격한 구현이 사실상의 표준이 됩니다"** — 서버 개발자가 자기 기준으로만 "안전한 변경"을 판단하면 안 됩니다.

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/api-breaking-change-json.md`
- 외부: [2분코딩 — 응답 필드 하나 추가했을 뿐인데, 앱이 전부 에러났어요](https://www.youtube.com/watch?v=LBWefG5zjxk)
- 이론: [Martin Fowler — Tolerant Reader](https://martinfowler.com/bliki/TolerantReader.html)

## 관련 페이지

- [[concept-api-versioning]] — Spring 7.0의 API 버전 1급 지원 (구조 변경 시 마지막 카드)
- [[src-spring-web-mvc-ref]] — Spring Web MVC + Jackson 기본 설정
- [[src-spring-data-access-ref]] — Spring Data 응답 매핑 맥락
- [[concept-transactional-rollback-policy]] / [[concept-cronjob-concurrency-trap]] — 같은 "기본값 함정" 패턴
- [[concept-claude-md]] — STOP 트리거 후보: "응답 구조 wrapping 변경 금지"
- [[guide-java-practice-library-book-search]] — 실습: 카카오 책 검색 응답을 필요한 필드만 읽는 Tolerant Reader record로 받기
