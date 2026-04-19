---
title: Spring Framework Data Access Reference
type: source
tags: [spring, jdbc, jpa, transaction, 공식문서]
sources: [spring-data-access-ref.md]
created: 2026-04-19
updated: 2026-04-19
---

# Spring Framework Data Access Reference

## 개요

Spring Framework 7.0.7 공식 문서의 Data Access 섹션. Transaction Management, JDBC, JPA, DAO Support 핵심 내용을 수집했다.

원본: https://docs.spring.io/spring-framework/reference/data-access.html

## 수집 범위

| 섹션 | 핵심 내용 |
|------|----------|
| **Transaction Management** | 선언적/프로그래밍 방식, 전파 수준, 이벤트 |
| **@Transactional** | 속성 테이블, 클래스/메서드 적용, 다중 매니저, self-invocation 주의 |
| **JDBC** | JdbcTemplate, JdbcClient, 책임 분리 매트릭스 |
| **JPA** | EntityManagerFactory 3가지 설정, @PersistenceContext DAO, JpaTransactionManager |
| **DAO Support** | @Repository 예외 변환, 기술 독립적 DAO 패턴 |

## 핵심 인사이트

> Spring Data Access의 핵심은 **기술(JDBC/JPA/Hibernate)에 독립적인 일관된 프로그래밍 모델**을 제공하는 것이다.

- `@Transactional` 하나로 선언적 트랜잭션 관리
- `DataAccessException` 계층으로 예외 통일
- `@Repository`로 DAO 자동 발견 + 예외 변환
- DomainEntity ↔ JpaEntity 분리는 카카오페이 DDD 사례에서 실무 적용 확인

## 관련 페이지

- [[concept-spring-core]] — IoC, DI, Bean, MVC, AOP 핵심
- [[entity-querydsl]] — JPA 위에서 동적 쿼리 조합
- [[src-spring-guide]] — cheese10yun 실무 가이드 (test-guide, service-guide)
- [[src-kakaopay-ddd]] — DDD에서 DomainRepository ↔ JpaEntity 분리 사례
- [[src-java-study-2024-2025]] — Ch6 데이터 접근과 SQL
- [[entity-spring-framework]] — Spring Framework 기반
