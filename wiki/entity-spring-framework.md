---
title: Spring Framework
type: entity
tags: [Spring, Java, 프레임워크, 백엔드]
sources: [Spring Framework Versions.md]
created: 2026-04-18
updated: 2026-04-18
---

# Spring Framework

Java/Kotlin 기반의 엔터프라이즈 애플리케이션 프레임워크. [[entity-spring-boot]]의 기반이 되는 핵심 프레임워크.

## 최신 메이저 버전: 7.0

7.0은 Jakarta EE 11 베이스라인을 채택하며 다수의 레거시 API를 정리한 대규모 릴리스.

### 핵심 변화
- **javax → jakarta 완전 전환** — `javax.annotation`, `javax.inject` 지원 제거
- **Null Safety 재설계** — JSR 305에서 [[concept-jspecify-null-safety|JSpecify]]로 전면 마이그레이션
- **RestTemplate deprecated** → `RestClient`가 권장 HTTP 클라이언트
- **Jackson 3.x 기본 지원** — 2.x는 deprecated
- **Undertow 지원 제거** — Servlet 6.1 미호환
- **Resilience 내장** — `@Retryable`, `@ConcurrencyLimit` 등 spring-core에 통합
- **[[concept-api-versioning|API Versioning]]** 1급 지원

### 클라이언트 API 패턴 통일
| 버전 | 클라이언트 |
|------|-----------|
| 6.1 | `JdbcClient`, `RestClient` |
| 7.0 | `JmsClient` |

공통적으로 fluent API + 재사용 가능한 operation handle 설계.

## 관련 페이지

- [[entity-spring-boot]] — Spring Boot (독립 실행형 프레임워크)
- [[src-spring-framework-7]] — 7.0 릴리스 노트 소스
- [[concept-api-versioning]]
- [[concept-jspecify-null-safety]]
- [[src-java-study-2024-2025|Java 스터디 자료]] — Spring 핵심 개념(IoC, DI, MVC, AOP)을 다루는 교재
- [[concept-spring-core]] — IoC, DI, Bean, MVC 핵심 정리
