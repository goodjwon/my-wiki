---
title: Spring Boot
type: entity
tags: [Java, Spring, 프레임워크, 백엔드, autoconfiguration]
sources: [spring/Spring Boot.md]
external:
  - https://spring.io/projects/spring-boot
  - https://docs.spring.io/spring-boot/reference/
created: 2026-04-18
updated: 2026-06-07
---

# Spring Boot

[[entity-spring-framework|Spring Framework]] 기반 독립 실행형 프로덕션급 애플리케이션을 **최소 설정으로** 만들 수 있는 자바 프레임워크. 새 Spring 프로젝트의 사실상 100%.

- **공식**: https://spring.io/projects/spring-boot
- **레퍼런스**: https://docs.spring.io/spring-boot/reference/
- **GitHub**: https://github.com/spring-projects/spring-boot
- **최신 버전**: 4.0.x (2026 기준)
- **라이선스**: Apache 2.0

## 핵심 가치 — Boot의 4가지 약속

| | 의미 |
|---|------|
| **독립 실행** | `java -jar app.jar` 한 줄로 실행. 내장 서버 포함 (Tomcat/Jetty/Netty) |
| **자동 설정** | 클래스패스에 라이브러리 있으면 합리적 디폴트로 자동 구성 |
| **Opinionated 의존성** | "그냥 시작하면 동작하게" — starter로 의존성 묶음 제공 |
| **운영 기능** | Actuator로 메트릭·헬스체크·환경변수 노출 기본 제공 |

## Starter 의존성

`spring-boot-starter-*` 형태로 검증된 의존성 묶음:

| Starter | 포함 |
|---------|------|
| `spring-boot-starter-web` | Spring MVC + Tomcat + Jackson + Validation |
| `spring-boot-starter-data-jpa` | Spring Data JPA + Hibernate + JDBC |
| `spring-boot-starter-security` | Spring Security |
| `spring-boot-starter-test` | JUnit 5 + Mockito + AssertJ + Spring Test |
| `spring-boot-starter-actuator` | 운영 엔드포인트 |
| `spring-boot-starter-webflux` | 리액티브 웹 (Netty) |
| `spring-boot-starter-validation` | Bean Validation (Hibernate Validator) |
| `spring-boot-starter-cache` | Caffeine, Redis 등 추상화 |
| `spring-boot-starter-batch` | Spring Batch |
| `spring-boot-starter-thymeleaf` | Thymeleaf 템플릿 |

## 자동 설정 (`@EnableAutoConfiguration`)

```java
@SpringBootApplication  // = @Configuration + @ComponentScan + @EnableAutoConfiguration
public class App {
    public static void main(String[] args) { SpringApplication.run(App.class, args); }
}
```

**작동 원리**:
1. 클래스패스 스캔 → 어떤 라이브러리가 있나?
2. `META-INF/spring.factories` (또는 `AutoConfiguration.imports`)에 등록된 `@AutoConfiguration` 클래스들 평가
3. 각 자동 설정은 `@ConditionalOn*`으로 조건부 적용
   - `@ConditionalOnClass(DataSource.class)` — DataSource가 클래스패스에 있으면
   - `@ConditionalOnMissingBean` — 사용자가 직접 등록 안 했으면
   - `@ConditionalOnProperty` — 특정 프로퍼티가 켜져 있으면
4. 사용자 Bean이 항상 우선

→ "왜 내가 한 줄도 안 짰는데 H2가 동작하지?"의 답.

## 외부 설정

우선순위 (높을수록 우선):
1. 커맨드라인 인자 (`--server.port=8081`)
2. 환경 변수 (`SERVER_PORT=8081`)
3. `application-{profile}.yml`
4. `application.yml`
5. `@PropertySource` 명시
6. 내장 디폴트

```yaml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: app
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
```

### `@ConfigurationProperties` — 타입 안전 설정

```java
@ConfigurationProperties(prefix = "app.payment")
public record PaymentConfig(
    String apiKey,
    Duration timeout,
    int maxRetries
) {}
```

```yaml
app:
  payment:
    api-key: ${PAYMENT_KEY}
    timeout: 30s
    max-retries: 3
```

## Actuator — 운영 도구

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,heapdump,loggers
  endpoint:
    health:
      show-details: when-authorized
```

| 엔드포인트 | 용도 |
|----------|------|
| `/actuator/health` | K8s liveness/readiness probe |
| `/actuator/metrics` | JVM·HTTP·커스텀 메트릭 |
| `/actuator/prometheus` | Prometheus 스크래핑 (Micrometer) |
| `/actuator/loggers` | 로그 레벨 동적 변경 |
| `/actuator/heapdump` | 힙 덤프 다운로드 |
| `/actuator/threaddump` | 스레드 덤프 |
| `/actuator/env` | 환경 변수 (보안 주의) |
| `/actuator/beans` | 등록된 Bean 목록 |

> 운영에서 `/env`·`/configprops`는 시크릿 노출 위험 — Security로 보호.

## 프로젝트 구조 (관용)

```
src/main/java/com/example/myapp/
├── MyAppApplication.java       # @SpringBootApplication
├── config/                     # @Configuration 클래스
├── controller/ 또는 web/        # @RestController
├── service/                    # @Service (비즈니스)
├── repository/                 # @Repository
├── domain/ 또는 model/          # JPA Entity, DTO
└── exception/                  # 커스텀 예외, @ControllerAdvice

src/main/resources/
├── application.yml
├── application-dev.yml
├── application-prod.yml
├── static/                     # 정적 파일
├── templates/                  # Thymeleaf
└── db/migration/               # Flyway SQL
```

DDD 적용 시 ([[src-kakaopay-ddd]]):
```
domain/ application/ infrastructure/ interfaces/
```

## 시작 방법

### 1. Spring Initializr ([[entity-spring-initializr]])
- https://start.spring.io 접속, GUI로 선택 → ZIP 다운로드

### 2. CLI
```bash
spring init --dependencies=web,data-jpa,security --build=gradle demo
cd demo && ./gradlew bootRun
```

### 3. IDE 통합
- IntelliJ IDEA: New → Project → Spring Initializr
- VS Code: Spring Boot Extension Pack

## 버전 정책

- **Major (3.x → 4.x)** : 2~3년 주기. Jakarta EE 베이스라인 변경 시
- **Minor (4.0 → 4.1)** : 6개월 주기, 새 기능 추가
- **Patch (4.0.5)** : 매월, 버그 수정·보안 패치

## Spring Boot vs 다른 Spring

```
Spring Framework      ── (가장 아래, IoC/DI/AOP/MVC 기본기)
   ↓ 위에 쌓임
Spring Boot           ── 자동 설정 + 내장 서버 + Starter (실무 표준)
   ↓ 위에 쌓임
Spring Cloud (선택)    ── 마이크로서비스
```

## 흔한 함정

| 함정 | 해결 |
|------|------|
| **`@ComponentScan` 범위 잘못** | 메인 클래스가 최상위 패키지에 있어야 자동 |
| **자동 설정이 안 됨** | `@SpringBootApplication`이 있고 클래스패스에 starter가 있나? |
| **포트 이미 사용 중** | `server.port=0` (랜덤) 또는 다른 포트 |
| **2.x→3.x 마이그레이션** | `javax → jakarta`, Java 17 baseline |

## 학습 리소스

| 자료 | 특징 |
|------|------|
| [공식 레퍼런스](https://docs.spring.io/spring-boot/reference/) | 가장 정확 |
| [Spring Guides](https://spring.io/guides) | 짧은 튜토리얼 모음 |
| [Spring Academy](https://spring.academy) | 공식 교육·인증 |
| [[src-spring-guide]] | cheese10yun 실무 가이드 6편 |
| [[src-java-study-2024-2025]] | Ch5~Ch8에서 Spring Boot 실습 |

## 원본 출처

- raw: `raw/spring/Spring Boot.md`
- 공식: [Spring Boot 프로젝트](https://spring.io/projects/spring-boot)
- 레퍼런스: [docs.spring.io/spring-boot/reference/](https://docs.spring.io/spring-boot/reference/)

## 관련 페이지

- [[entity-spring-framework]] — 기반 프레임워크
- [[entity-spring-initializr]] — 프로젝트 부트스트랩
- [[concept-spring-core]] — Spring 핵심 개념
- [[concept-transactional-rollback-policy]] — `@Transactional` 함정
- [[concept-api-versioning]] — Spring 7.0 신규
- [[src-spring-boot]] — 공식 소개 페이지 요약
- [[src-spring-guide]] — 실무 가이드
- [[entity-jvm]] — Spring Boot도 JVM 위에서 동작
