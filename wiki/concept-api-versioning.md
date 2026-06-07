---
title: API Versioning (Spring 7.0)
type: concept
tags: [Spring, API, versioning, REST, web]
sources: [spring/Spring Framework Versions.md]
external:
  - https://spring.io/blog/2025/09/16/api-versioning-in-spring
  - https://docs.spring.io/spring-framework/reference/web/webmvc-versioning.html
created: 2026-04-18
updated: 2026-06-07
---

# API Versioning (Spring 7.0)

## 정의

Spring Framework 7.0에서 도입된 **API 버전 관리 1급 지원**. 이전엔 직접 분기·라우팅을 구현해야 했지만, 7.0부터 어노테이션 한 줄 또는 컨트롤러 설정으로 가능.

> 참고: [[concept-api-backward-compatibility]]에서 본 것처럼, **버전 분리는 마지막 카드**. 그 전에 Tolerant Reader 계약으로 해결할 수 있는 변경이 더 많다.

## 왜 필요한가

### 버전 분리가 필수인 경우 (Breaking Change)

- 응답 **구조 자체 변경** (`{...}` → `{ "data": {...} }`)
- 기존 필드 **제거** 또는 **타입 변경**
- 기존 필드 **의미 변경** (단위 KRW → USD 등 silent change)
- 인증 방식 변경 (쿠키 → JWT 등)

→ 새 필드 추가만 한다면 버전 분리는 과한 대응. 자세히는 [[concept-api-backward-compatibility|Tolerant Reader]].

## 4가지 버전 전달 방식

| 방식 | 예시 | 장점 | 단점 |
|------|------|------|------|
| **URL 경로** | `/v1/users`, `/v2/users` | 가장 직관적, 캐싱·라우팅 쉬움 | "URL이 안정적이지 않다" 비판 |
| **요청 헤더** | `API-Version: 2` | URL 깔끔 | 디버깅 어려움, curl 부담 |
| **미디어 타입** | `Accept: application/vnd.app.v2+json` | RESTful 원리주의 | 매우 깐깐, 학습 비용 |
| **쿼리 파라미터** | `?version=2` | 쉬움 | 권장 안 함 (캐싱 깨짐) |

→ 실무는 **URL 경로 (`/v1/`, `/v2/`)** 가 압도적으로 많다.

## Spring 7.0의 1급 지원

### 서버 측

```java
@RestController
@RequestMapping(path = "/users", version = "1")
public class UserControllerV1 {
    @GetMapping("/{id}")
    public UserV1 get(@PathVariable Long id) { ... }
}

@RestController
@RequestMapping(path = "/users", version = "2")
public class UserControllerV2 {
    @GetMapping("/{id}")
    public UserV2 get(@PathVariable Long id) { ... }
}
```

7.0 이전엔 직접 URL 분리(`/v1/users`)나 `@RequestMapping` 헤더 매칭으로 처리.

### 버전 해석 (Resolution) 설정

```java
@Configuration
public class ApiVersionConfig implements WebMvcConfigurer {
    @Override
    public void configureApiVersioning(ApiVersionConfigurer configurer) {
        configurer.useRequestHeader("API-Version")
                  .setDefaultVersion("1")
                  .addSupportedVersions("1", "2", "3");
    }
}
```

지원 옵션:
- `useRequestHeader("API-Version")` — 헤더 기반
- `useMediaTypeParameter("application/json", "v")` — 미디어 타입 파라미터
- `usePathSegment(0)` — URL 첫 세그먼트
- `useQueryParameter("v")` — 쿼리 파라미터 (가능하지만 권장 X)

### 함수형 엔드포인트

```java
@Bean
public RouterFunction<ServerResponse> routes() {
    return route()
        .GET("/users/{id}", RequestPredicates.version("1"), handler::getV1)
        .GET("/users/{id}", RequestPredicates.version("2"), handler::getV2)
        .build();
}
```

### Deprecation 알림

```java
@RestController
@RequestMapping(path = "/users", version = "1", deprecated = true)
public class UserControllerV1 { ... }
```

응답 헤더에 자동으로 `Deprecation`, `Sunset` 헤더 추가 → 클라이언트가 인식.

### 클라이언트 측 (`RestClient`, `WebClient`)

```java
RestClient client = RestClient.builder()
    .baseUrl("https://api.example.com")
    .defaultApiVersion("2")
    .build();

User user = client.get()
    .uri("/users/{id}", 1)
    .retrieve()
    .body(User.class);
```

### HTTP 인터페이스 클라이언트

```java
public interface UserApi {
    @HttpExchange(version = "2")
    @GetExchange("/users/{id}")
    User getUser(@PathVariable Long id);
}
```

## 테스트 지원

```java
// MockMvc
mockMvc.perform(get("/users/1").apiVersion("2"))
    .andExpect(status().isOk());

// WebTestClient
webTestClient.get()
    .uri("/users/1")
    .header("API-Version", "2")
    .exchange()
    .expectStatus().isOk();
```

## 지원 범위

| 환경 | 지원 |
|------|------|
| Spring MVC (Servlet) | ✅ |
| Spring WebFlux | ✅ |
| Spring HTTP Interface Client | ✅ |
| Spring Cloud Gateway | (Spring Cloud 별도 업데이트 필요) |

## 흔한 버전 운영 패턴

### 1) Sunset Policy 명시
```
v1 - deprecated since 2026-06-01
v1 - sunset on 2027-06-01 (12개월 유예)
v2 - current
```

### 2) 응답 헤더로 알림
```
HTTP/1.1 200 OK
Deprecation: @1717200000
Sunset: Mon, 01 Jun 2027 00:00:00 GMT
Link: </docs/api/v2>; rel="successor-version"
```

### 3) Adapter 패턴으로 같은 비즈니스 로직 공유

```java
@Service
public class UserService {
    // 공통 비즈니스 로직
    public User get(Long id) { ... }
}

@RestController("/v1/users")
class UserControllerV1 {
    public UserV1 get(Long id) {
        return UserV1Mapper.from(userService.get(id));
    }
}

@RestController("/v2/users")
class UserControllerV2 {
    public UserV2 get(Long id) {
        return UserV2Mapper.from(userService.get(id));
    }
}
```

→ **버전은 Controller·DTO에만**, Service·Domain은 단일 유지. 버전 폭증 방지.

## 함정 — 버전 분리의 영원한 부담

> "강제 업데이트 불가능한 환경(B2B 고객사 앱)에서는 v1 사용자가 앱을 업데이트하지 않는 한, 서버는 과거 버전 코드를 영원히 유지해야 한다."

— [[src-copilot-token-pricing|2분코딩 영상 인사이트]] 와 같은 패턴.

`v1`을 만들면:
- 비즈니스 로직 변경 시마다 **v1·v2 양쪽 반영 + 양쪽 테스트** (2배 비용)
- 결국 v3, v4... 누적 → 유지보수 지옥
- **deprecation 정책 + sunset 시점 합의가 함께** 가야 함

## 같은 인사이트 패턴

| 페이지 | "기본값과 가정의 함정" |
|--------|----------------------|
| **이 페이지** | 버전 만들면 영원히 유지 부담 |
| [[concept-api-backward-compatibility]] | Tolerant Reader 명세 없으면 silent 사고 |
| [[concept-transactional-rollback-policy]] | `@Transactional` 체크 예외 commit |

→ 공통: **"단순 변경의 부담을 미래의 누군가에게 전가하는 결정"** — 신중히.

## 원본 출처

- raw: `raw/spring/Spring Framework Versions.md`
- 블로그: [API Versioning in Spring](https://spring.io/blog/2025/09/16/api-versioning-in-spring)
- 공식: [Spring MVC — API Versioning](https://docs.spring.io/spring-framework/reference/web/webmvc-versioning.html)

## 관련 페이지

- [[concept-api-backward-compatibility]] — 버전 분리 전 시도할 Tolerant Reader
- [[entity-spring-framework]] — Spring Framework 7.0 전체 변화
- [[src-spring-framework-7]] — 7.0 릴리스 노트
- [[src-spring-web-mvc-ref]] — Spring MVC 깊이
- [[src-copilot-token-pricing]] — 같은 "유지보수 부담" 인사이트
- [[concept-claude-md]] — STOP 트리거 후보
