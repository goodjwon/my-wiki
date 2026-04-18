---
title: "Spring Framework 7.0 릴리스 노트"
type: source
tags: [Spring, Java, 프레임워크, 릴리스노트]
sources: [Spring Framework Versions.md]
created: 2026-04-18
updated: 2026-04-18
---

# Spring Framework 7.0 릴리스 노트

- **출처**: GitHub Wiki — Spring Framework 7.0 Release Notes
- **URL**: https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-7.0-Release-Notes

## 베이스라인 업그레이드

| 항목 | 요구사항 |
|------|----------|
| JDK | 17 최소, **25 LTS** 권장 |
| Jakarta EE | 11 |
| Servlet | 6.1 (Tomcat 11.0, Jetty 12.1) |
| JPA | 3.2 (Hibernate ORM 7.1/7.2) |
| Bean Validation | 3.1 (Hibernate Validator 9.0/9.1) |
| GraalVM | 25 (새 reachability metadata 형식) |
| Netty | 4.2 |
| Kotlin | 2.2 |
| JUnit | 6 |

## 제거된 API

- **spring-jcl 모듈 제거** → Apache Commons Logging 1.3.0으로 대체
- **javax.annotation / javax.inject 지원 제거** → `jakarta.annotation`, `jakarta.inject`로 마이그레이션 필요
- **경로 매핑 옵션 제거** — suffixPatternMatch, trailingSlashMatch 등 6.0부터 deprecated 되었던 것들 완전 제거
- **Undertow 지원 제거** — Servlet 6.1 미지원으로 인해 드롭
- **ListenableFuture 제거** → `CompletableFuture`로 대체
- **OkHttp3 지원 제거**

## 주요 Breaking Changes

### HttpHeaders 변경
- `MultiValueMap` 계약 상속 제거 — 헤더는 대소문자 무관이라 map 연산이 부적합
- `HttpHeaders#asMultiValueMap`으로 폴백 제공 (즉시 deprecated)

### SpringExtension 스코프 변경
- JUnit Jupiter에서 test-method 스코프 `ExtensionContext` 사용
- `@Nested` 테스트 클래스 계층에서 일관된 DI 제공
- 기존 `TestExecutionListener` 구현에 영향 가능

## 주요 Deprecation

| 대상 | 대체 |
|------|------|
| **RestTemplate** | `RestClient` (7.1에서 공식 `@Deprecated`) |
| `<mvc:*>` XML 설정 | Java 설정 |
| JUnit 4 지원 | JUnit Jupiter `SpringExtension` |
| Jackson 2.x | Jackson 3.x |
| `AntPathMatcher` | `PathPattern` |
| `HandlerMappingIntrospector` | — |
| JSR 305 null 어노테이션 | [[concept-jspecify-null-safety|JSpecify]] |

## 주요 신규 기능

### Null Safety — JSpecify 채택
- JSR 305 기반 어노테이션을 **JSpecify** 어노테이션으로 전면 마이그레이션
- 제네릭 타입, 배열, vararg 요소의 nullness 명시 가능
- Kotlin 통합 개선

### Programmatic Bean Registration
- `BeanRegistrar` 계약 도입
- `@Bean` 메서드의 한계(단일 빈, 구체 타입 반환) 극복
- 유연한 조건부·다중 빈 등록 가능

### Resilience 기능
- `RetryTemplate`, `RetryPolicy` — spring-retry 프로젝트에서 spring-core로 통합
- `@Retryable` — 선언적 재시도 (리액티브 메서드 자동 적응)
- `@ConcurrencyLimit` — 동시성 제한
- `@EnableResilientMethods`로 활성화

### [[concept-api-versioning|API Versioning]]
- Spring MVC / WebFlux 1급 지원
- 서버: 요청 API 버전 기반 컨트롤러 매핑
- 클라이언트: `RestClient`, `WebClient`, HTTP 인터페이스 클라이언트에서 버전 설정
- 버전 deprecated 알림 지원

### JmsClient
- `JdbcClient`, `RestClient`에 이은 일관된 클라이언트 API 패턴
- `JmsMessagingTemplate`의 대안
- 재사용 가능한 operation handle + QoS 설정

### HTTP Interface Client 설정 간소화
- `@ImportHttpServices`로 그룹별 HTTP 인터페이스 선언
- `AbstractHttpServiceRegistrar`로 클라이언트 프록시 자동 빈 등록

### RestTestClient
- `WebTestClient`의 비리액티브 버전
- 라이브 서버, MVC 컨트롤러, ApplicationContext에 바인딩 가능

### 기타
- **Class-File API** (JEP 484) — Java 24+에서 ASM 대신 표준 API 사용
- **PathPattern 개선** — `/**/pages/index.html` 패턴 지원
- **JPA 3.2** — `PersistenceConfiguration`으로 persistence.xml 없이 부트스트랩
- **Hibernate StatelessSession** 지원
- **Kotlin Coroutines 컨텍스트 전파** — 트레이싱 정보 자동 전파
- **테스트 컨텍스트 일시정지** — 미사용 ApplicationContext 백그라운드 프로세스 중지

## 관련 페이지

- [[entity-spring-framework]]
- [[entity-spring-boot]]
- [[concept-api-versioning]]
- [[concept-jspecify-null-safety]]
