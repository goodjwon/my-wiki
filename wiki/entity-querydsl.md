---
title: Querydsl
type: entity
tags: [java, spring, jpa, querydsl, sql, type-safe-query]
sources: [java-study/java-study-ch07-데이터접근과SQL.md]
external:
  - http://querydsl.com/
  - https://github.com/querydsl/querydsl
created: 2026-04-18
updated: 2026-06-07
---

# Querydsl

## 정의

Java 코드로 **타입 안전한 SQL/JPQL/MongoDB 쿼리**를 작성하게 해주는 프레임워크. JPA의 가장 약한 부분(동적 쿼리)을 강력하게 보강.

- **공식**: http://querydsl.com/
- **GitHub**: https://github.com/querydsl/querydsl
- **라이선스**: Apache 2.0

> "JPA + Querydsl = Spring 백엔드의 사실상 표준."

## 왜 Querydsl인가

### 기존 JPA의 동적 쿼리 한계

```java
// JPQL 문자열 조합 (오류 위험·가독성 최악)
public List<User> search(String name, Integer minAge, String city) {
    StringBuilder jpql = new StringBuilder("SELECT u FROM User u WHERE 1=1");
    Map<String, Object> params = new HashMap<>();

    if (name != null) {
        jpql.append(" AND u.name = :name");
        params.put("name", name);
    }
    if (minAge != null) {
        jpql.append(" AND u.age >= :minAge");
        params.put("minAge", minAge);
    }

    var query = em.createQuery(jpql.toString(), User.class);
    params.forEach(query::setParameter);
    return query.getResultList();
}
```

### Querydsl로 같은 쿼리

```java
public List<User> search(String name, Integer minAge, String city) {
    return queryFactory
        .selectFrom(user)
        .where(
            nameEq(name),
            ageGoe(minAge),
            cityEq(city)
        )
        .fetch();
}

// 조건 메서드 (재사용·테스트 가능)
private BooleanExpression nameEq(String name) {
    return name != null ? user.name.eq(name) : null;
}
private BooleanExpression ageGoe(Integer age) {
    return age != null ? user.age.goe(age) : null;
}
```

→ **컴파일 타임에 타입 체크**, IDE 자동 완성, 메서드 추출로 재사용.

## 작동 원리 — Q타입 코드 생성

빌드 시 **annotation processor**가 `@Entity` 클래스로부터 `Q` 클래스 생성:

```java
@Entity
public class User {
    @Id Long id;
    String name;
    int age;
}
```

→ 빌드하면 `QUser.java` 자동 생성:

```java
public class QUser extends EntityPathBase<User> {
    public static final QUser user = new QUser("user");
    public final NumberPath<Long> id = createNumber("id", Long.class);
    public final StringPath name = createString("name");
    public final NumberPath<Integer> age = createNumber("age", Integer.class);
}
```

### Gradle 설정 (Spring Boot 3.x+)

```kotlin
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("com.querydsl:querydsl-jpa:5.1.0:jakarta")
    annotationProcessor("com.querydsl:querydsl-apt:5.1.0:jakarta")
    annotationProcessor("jakarta.annotation:jakarta.annotation-api")
    annotationProcessor("jakarta.persistence:jakarta.persistence-api")
}
```

> Spring Boot 3.x = Jakarta. classifier `:jakarta` 필수.

## 핵심 문법

### 기본 SELECT

```java
QUser user = QUser.user;

// 전체 조회
List<User> users = queryFactory.selectFrom(user).fetch();

// 조건
User found = queryFactory
    .selectFrom(user)
    .where(user.name.eq("Alice").and(user.age.gt(18)))
    .fetchOne();

// 정렬·페이징
List<User> page = queryFactory
    .selectFrom(user)
    .orderBy(user.age.desc(), user.name.asc())
    .offset(20)
    .limit(10)
    .fetch();
```

### 조인

```java
// 일반 조인
queryFactory
    .selectFrom(order)
    .join(order.user, user)
    .where(user.email.eq("a@b.com"))
    .fetch();

// fetch join (N+1 해결)
queryFactory
    .selectFrom(order)
    .join(order.items, item).fetchJoin()
    .fetch();
```

### 서브쿼리

```java
QUser userSub = new QUser("userSub");

queryFactory
    .selectFrom(user)
    .where(user.age.gt(
        JPAExpressions.select(userSub.age.avg()).from(userSub)
    ))
    .fetch();
```

### DTO 프로젝션

```java
// 1) @QueryProjection (성능 최고, DTO에 의존성 추가)
public class UserDto {
    private final String name;
    private final int age;
    @QueryProjection
    public UserDto(String name, int age) { this.name = name; this.age = age; }
}
queryFactory.select(new QUserDto(user.name, user.age)).from(user).fetch();

// 2) Projections.constructor (DTO 의존성 X)
queryFactory.select(Projections.constructor(UserDto.class, user.name, user.age))
    .from(user).fetch();

// 3) Projections.fields
queryFactory.select(Projections.fields(UserDto.class, user.name, user.age))
    .from(user).fetch();
```

## 동적 쿼리 — 두 가지 패턴

### BooleanBuilder (절차적)

```java
BooleanBuilder builder = new BooleanBuilder();
if (name != null) builder.and(user.name.eq(name));
if (age != null) builder.and(user.age.eq(age));

queryFactory.selectFrom(user).where(builder).fetch();
```

장점: 직관적. 단점: 메서드 추출 어렵고 재사용성 낮음.

### BooleanExpression 분리 (선언적, **권장**)

```java
queryFactory.selectFrom(user)
    .where(
        usernameEq(cond.username()),
        ageGoe(cond.ageGoe()),
        cityEq(cond.city())
    )
    .fetch();

private BooleanExpression usernameEq(String name) {
    return name != null ? user.name.eq(name) : null;
}
private BooleanExpression ageGoe(Integer age) {
    return age != null ? user.age.goe(age) : null;
}
```

장점:
- 조건 메서드 단위로 **재사용**·**단위 테스트** 가능
- `null` 자동 무시 (`where(null, ...)` 안전)
- **조합 가능** — `usernameEq(n).and(ageGoe(a))`
- 가독성 최고

→ **실무 표준 패턴.**

## 페이징

```java
// 데이터만
List<User> content = queryFactory
    .selectFrom(user)
    .offset(pageable.getOffset())
    .limit(pageable.getPageSize())
    .fetch();

// count 별도
Long total = queryFactory
    .select(user.count())
    .from(user)
    .fetchOne();

return new PageImpl<>(content, pageable, total);
```

> Querydsl 5.x부터 `fetchResults()` deprecated. count는 별도 쿼리로.

## Spring Data 통합 (커스텀 리포지토리)

```java
// 1) 표준 인터페이스
public interface UserRepository
    extends JpaRepository<User, Long>, UserRepositoryCustom { }

// 2) 커스텀 인터페이스
public interface UserRepositoryCustom {
    Page<User> search(UserSearchCond cond, Pageable pageable);
}

// 3) 구현 (Impl 접미사가 핵심 — Spring Data 컨벤션)
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepositoryCustom {
    private final JPAQueryFactory queryFactory;

    public Page<User> search(UserSearchCond cond, Pageable pageable) {
        var content = queryFactory.selectFrom(user)
            .where(/* BooleanExpression 조건들 */)
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        var total = queryFactory.select(user.count())
            .from(user)
            .where(/* 같은 조건 */)
            .fetchOne();

        return new PageImpl<>(content, pageable, total);
    }
}
```

### JPAQueryFactory Bean 등록

```java
@Configuration
public class QuerydslConfig {
    @Bean
    public JPAQueryFactory jpaQueryFactory(EntityManager em) {
        return new JPAQueryFactory(em);
    }
}
```

## 실무 운영 팁

- **서비스 계층**은 검색 조건 DTO를 넘긴다 (Querydsl 의존성 누설 방지)
- **Querydsl 전용 BooleanExpression 조합**은 조회 리포지토리 안에 둔다
- 단순 쿼리는 **Spring Data JPA 메서드 쿼리**로 충분 (`findByEmailAndStatus`)
- **fetch join + 페이징** 같이 쓰면 메모리 페이징 경고 — 별도 쿼리 분리
- N+1은 fetch join 또는 `@EntityGraph`로

## 대안 라이브러리

| 라이브러리 | 특징 |
|----------|------|
| **Querydsl JPA** | 가장 보편적 (이 페이지) |
| jOOQ | SQL 친화, DB 스키마에서 코드 생성, 비싸지만 강력 |
| Spring Data JDBC | 가벼움, JPA 미사용 시 |
| MyBatis | XML 매핑, SQL을 직접 쓰는 환경 |
| Exposed (Kotlin) | Kotlin DSL, JPA 대안 |

## 학습 자료

- [Querydsl 공식 reference](http://querydsl.com/static/querydsl/latest/reference/html/)
- 김영한 _실전! Querydsl_ (인프런) — 한국어 사실상 표준
- [Baeldung Querydsl 가이드](https://www.baeldung.com/intro-to-querydsl)

## 원본 출처

- raw: `raw/java-study/java-study-ch07-데이터접근과SQL.md`
- 공식: [Querydsl 프로젝트](http://querydsl.com/)
- GitHub: [querydsl/querydsl](https://github.com/querydsl/querydsl)

## 관련 페이지

- [[concept-spring-core]] — Spring Data JPA 통합 맥락
- [[src-spring-data-access-ref]] — Spring Data Access 전반
- [[src-java-study-2024-2025]] — Ch06 데이터 접근과 SQL
- [[concept-db-connection-pool]] — Querydsl이 사용하는 DataSource 풀
- [[concept-varchar-length-prefix]] — Entity 컬럼 길이 설계
- [[src-kakaopay-ddd]] — DDD에서 Querydsl로 조회 전용 Repository 분리
