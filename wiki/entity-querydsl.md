---
title: Querydsl
type: entity
tags: [java, spring, jpa, querydsl, sql]
sources: [java-study-ch06-데이터접근과SQL.md]
created: 2026-04-18
updated: 2026-04-18
---

# Querydsl

## 정의

Java 코드로 타입 안전한 SQL/JPQL 쿼리를 작성할 수 있게 해주는 프레임워크. 동적 쿼리 조합에서 특히 강력하다.

## 핵심 기능

| 주제 | 설명 |
|------|------|
| 기본 문법 | `selectFrom`, `where`, `join`, `orderBy` |
| 프로젝션 | DTO 직접 조회, `@QueryProjection` |
| 동적 쿼리 | `BooleanBuilder` vs `BooleanExpression` 분리 |
| 페이징 | `offset/limit`, `fetchResults` |
| 리포지토리 설계 | 커스텀 리포지토리 + Spring Data JPA 통합 |

## 동적 쿼리 패턴

**권장: BooleanExpression 분리 방식** — 조건을 메서드 단위로 잘게 나누어 재사용성과 가독성을 높인다.

```java
.where(usernameEq(cond.getUsername()), ageGoe(cond.getAgeGoe()))
```

## 실무 기준

- 서비스 계층은 검색 조건 DTO를 넘긴다
- Querydsl 전용 `BooleanExpression` 조합은 조회 리포지토리 안에 둔다
- 조건이 적고 단순하면 JPA 메서드 쿼리로 충분

## 관련 페이지

- [[concept-spring-core]] — Spring Data JPA 통합
- [[src-java-study-2024-2025]] — Ch6 데이터 접근과 SQL
