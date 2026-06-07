---
title: Spring Framework
type: entity
tags: [Spring, Java, Kotlin, 프레임워크, 백엔드]
sources: [spring/Spring Framework Versions.md]
external:
  - https://spring.io/projects/spring-framework
  - https://docs.spring.io/spring-framework/reference/
created: 2026-04-18
updated: 2026-06-07
---

# Spring Framework

Java/Kotlin 기반 엔터프라이즈 애플리케이션의 사실상 표준 프레임워크. **IoC/DI 컨테이너 + AOP + 데이터 접근 + 웹**을 통합 제공. [[entity-spring-boot|Spring Boot]]의 기반.

- **공식**: https://spring.io/projects/spring-framework
- **레퍼런스**: https://docs.spring.io/spring-framework/reference/
- **GitHub**: https://github.com/spring-projects/spring-framework
- **개발 주체**: VMware Tanzu (구 Pivotal)
- **라이선스**: Apache 2.0
- **첫 릴리스**: 2003년 (Rod Johnson, _Expert One-on-One J2EE Design and Development_)

## 모듈 구조

Spring Framework는 단일 거대 라이브러리가 아니라 **모듈 묶음**:

| 모듈 | 역할 |
|------|------|
| `spring-core` | 의존성 주입(DI), IoC 컨테이너, 유틸리티 |
| `spring-beans` | Bean 정의, 생명주기, BeanFactory |
| `spring-context` | ApplicationContext, 이벤트, i18n |
| `spring-aop` | AOP (`@Aspect`, 프록시) |
| `spring-aspects` | AspectJ 통합 |
| `spring-jdbc` | JdbcTemplate, JdbcClient |
| `spring-orm` | JPA/Hibernate 통합 |
| `spring-tx` | 트랜잭션 관리 (`@Transactional`) |
| `spring-web` | 공통 웹 기능 |
| `spring-webmvc` | Servlet 기반 MVC (전통) |
| `spring-webflux` | 리액티브 웹 (Netty 기반) |
| `spring-test` | 테스트 통합 (`@SpringBootTest` 등) |
| `spring-messaging` | JMS, AMQP, WebSocket |
| `spring-r2dbc` | 리액티브 RDB |

→ Spring Boot의 starter가 이들 중 필요한 것을 묶어준다.

## 최신 메이저: 7.0 (2025)

Spring Framework 7.0은 **Jakarta EE 11 베이스라인** + 대규모 레거시 정리.

### 7.0 주요 변화

#### 1) javax → jakarta 완전 전환
- `javax.annotation`, `javax.inject` 지원 제거
- 마이그레이션은 Spring 6.0(2022)에 시작 → 7.0에서 완료

#### 2) Null Safety 재설계
- JSR 305 → [[concept-jspecify-null-safety|JSpecify]] 로 전면 마이그레이션
- 코드베이스 전체가 JSpecify 어노테이션 사용
- Kotlin 통합 개선

#### 3) HTTP 클라이언트 정리
- **`RestTemplate` deprecated** → `RestClient` 권장
- `WebClient` (WebFlux) 계속 사용
- HTTP 인터페이스 클라이언트 (선언적 HTTP)

#### 4) Jackson 3.x 기본 지원
- Jackson 2.x deprecated

#### 5) Undertow 지원 제거
- Servlet 6.1 미호환
- Tomcat / Jetty / Netty만 지원

#### 6) Resilience 내장
- `@Retryable`, `@ConcurrencyLimit` 등 `spring-core`에 통합

#### 7) API Versioning 1급 지원
- [[concept-api-versioning|상세 페이지]]
- URL·헤더·미디어 타입 기반 라우팅

### 7.x의 fluent Client 패턴 통일

| 버전 | 신규 클라이언트 |
|------|---------------|
| 6.1 | `JdbcClient`, `RestClient` |
| **7.0** | `JmsClient` |

```java
// JdbcClient — JdbcTemplate 대체
List<User> users = jdbcClient
    .sql("SELECT * FROM users WHERE active = :active")
    .param("active", true)
    .query(User.class)
    .list();

// RestClient — RestTemplate 대체
User user = restClient
    .get()
    .uri("/users/{id}", 1)
    .retrieve()
    .body(User.class);
```

## 버전 이력 요약

| 버전 | 출시 | 주요 변화 |
|------|------|---------|
| 1.0 | 2003 | XML 기반 DI 컨테이너 |
| 2.5 | 2007 | 어노테이션 기반 설정 (`@Autowired`) |
| 3.0 | 2009 | Java 5 baseline, REST 지원 |
| 4.0 | 2013 | Java 8 baseline, WebSocket |
| 5.0 | 2017 | **WebFlux** (리액티브), Kotlin 지원 |
| 6.0 | 2022 | **Jakarta EE 9+ 전환**, Java 17 baseline, AOT/Native Image |
| **7.0** | 2025 | Jakarta EE 11, JSpecify, RestTemplate deprecated, API Versioning |

## Spring Framework vs Spring Boot

| | Spring Framework | Spring Boot |
|---|----------------|-------------|
| 정체성 | **기반 프레임워크** | **응용 도구** (Framework 위에) |
| 설정 | 직접 (XML/JavaConfig) | 자동 설정 |
| 서버 | 외부 (Tomcat 별도) | 내장 (실행 가능 jar) |
| 시작 시간 | 길다 | 짧다 |
| 운영 도구 | 직접 추가 | Actuator 기본 |

→ **Spring Boot = Spring Framework + 자동 설정 + 내장 서버 + 운영 도구.** 새 프로젝트는 거의 100% Spring Boot.

## Spring 생태계 (Boot 외 주요 프로젝트)

| 프로젝트 | 역할 |
|---------|------|
| **Spring Data** | 데이터 접근 추상화 (Spring Data JPA, MongoDB, Redis...) |
| **Spring Security** | 인증·인가 |
| **Spring Cloud** | 마이크로서비스 (Config, Gateway, Sleuth) |
| **Spring Batch** | 대용량 배치 처리 |
| **Spring Integration** | 메시징·EAI 패턴 |
| **Spring Session** | 분산 세션 관리 |
| **Spring AI** (2024+) | LLM 통합 |

## 학습 경로

| 순서 | 자료 |
|------|------|
| 1. 기본 | [[concept-spring-core]] — IoC·DI·Bean·AOP·MVC |
| 2. 실무 | [[src-spring-guide]] — cheese10yun 6편 가이드 |
| 3. Data Access | [[src-spring-data-access-ref]] — Transaction·JPA·QueryDSL |
| 4. Web | [[src-spring-web-mvc-ref]] — Controller·예외처리 |
| 5. Test | [[src-spring-testing-ref]] — MockMvc·테스트 피라미드 |
| 6. 최신 | [[src-spring-framework-7]] — 7.0 릴리스 노트 |

## 같은 도메인 다른 프레임워크

| 프레임워크 | 특징 |
|----------|------|
| **Spring** | 가장 보편적, 가장 큰 생태계 |
| **Quarkus** | 빠른 기동, Native Image 친화, K8s 친화 |
| **Micronaut** | 컴파일 시 DI, 빠른 기동, GraalVM 통합 |
| **Helidon** | Oracle, MicroProfile 기반 |
| **Ktor** (Kotlin) | Kotlin 친화 경량 웹 프레임워크 |

## 원본 출처

- raw: `raw/spring/Spring Framework Versions.md`
- 공식: [Spring Framework 프로젝트](https://spring.io/projects/spring-framework)
- 레퍼런스: [docs.spring.io/spring-framework/reference/](https://docs.spring.io/spring-framework/reference/)

## 관련 페이지

- [[entity-spring-boot]] — Spring Boot
- [[entity-spring-initializr]] — 프로젝트 부트스트랩
- [[concept-spring-core]] — IoC·DI·Bean·AOP·MVC 깊이
- [[concept-api-versioning]] — Spring 7.0 신규
- [[concept-jspecify-null-safety]] — Spring 7.0 null safety
- [[concept-transactional-rollback-policy]] — `@Transactional` 함정
- [[src-spring-framework-7]] — 7.0 릴리스 노트
- [[src-java-study-2024-2025]] — Spring 핵심 학습 교재
