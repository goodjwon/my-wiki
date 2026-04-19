# Spring Framework Data Access Reference
원본: https://docs.spring.io/spring-framework/reference/data-access.html
Spring Framework 7.0.7 공식 문서 중 Data Access 섹션 핵심 내용.

---


## Transaction Management

Spring Framework의 트랜잭션 관리. JTA, JDBC, Hibernate, JPA에 대한 일관된 프로그래밍 모델.

핵심 토픽:
- Declarative Transaction Management (@Transactional)
- Programmatic Transaction Management (TransactionTemplate)
- Transaction-bound Events
- Transaction Propagation (REQUIRED, REQUIRES_NEW, NESTED 등)

---

## @Transactional 사용법

선언적 트랜잭션의 핵심 어노테이션.

### 주요 속성

| 속성 | 기본값 | 설명 |
|------|--------|------|
| propagation | REQUIRED | 전파 수준 |
| isolation | DEFAULT | 격리 수준 |
| readOnly | false | 읽기 전용 |
| timeout | -1 | 타임아웃(초) |
| rollbackFor | RuntimeException, Error | 롤백 트리거 예외 |

### 클래스/메서드 레벨 적용

```java
@Transactional(readOnly = true)
public class DefaultFooService implements FooService {

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void updateFoo(Foo foo) { ... }
}
```

### 다중 트랜잭션 매니저

```java
@Transactional("order")
public void setSomething(String name) { ... }

@Transactional("account")
public void doSomething() { ... }
```

### 주의사항
- 프록시 모드(기본)에서는 외부 호출만 트랜잭션 적용 (self-invocation 불가)
- AspectJ 모드로 self-invocation 지원 가능
- Spring 6.2부터 `rollbackOn=ALL_EXCEPTIONS` 전역 설정 가능

---

## Data Access with JDBC

Spring JDBC 추상화: 개발자는 SQL과 파라미터에만 집중, 나머지는 Spring이 처리.

### 핵심 클래스

| 클래스 | 역할 |
|--------|------|
| JdbcTemplate | JDBC 핵심 클래스, 리소스 관리/콜백/에러 처리 |
| JdbcClient | 모던 fluent API |
| NamedParameterJdbcTemplate | 이름 기반 파라미터 |
| SimpleJdbcInsert / SimpleJdbcCall | 메타데이터 기반 고수준 추상화 |

### 책임 분리

| 작업 | Spring | 개발자 |
|------|--------|--------|
| 커넥션 열기/닫기 | O | |
| SQL 작성 | | O |
| 파라미터 제공 | | O |
| 결과 반복 처리 설정 | O | |
| 예외 처리 | O | |
| 트랜잭션 관리 | O | |

---

## JPA (Java Persistence API)

Spring JPA 통합: EntityManagerFactory 설정, DAO 구현, 트랜잭션 관리.

### EntityManagerFactory 설정 3가지

| 방식 | 용도 |
|------|------|
| LocalEntityManagerFactoryBean | 단순 환경/테스트 |
| JNDI Lookup | Jakarta EE 서버 |
| **LocalContainerEntityManagerFactoryBean** | **프로덕션 권장** |

### DAO 구현 (@PersistenceContext 권장)

```java
@Repository
public class ProductDaoImpl implements ProductDao {

    @PersistenceContext
    private EntityManager em;

    public Collection loadProductsByCategory(String category) {
        return em.createQuery("from Product p where p.category = :category")
                 .setParameter("category", category)
                 .getResultList();
    }
}
```

### 트랜잭션 설정

```java
@Bean
public JpaTransactionManager transactionManager(EntityManagerFactory emf) {
    return new JpaTransactionManager(emf);
}
```

---

## DAO Support

일관된 DAO 패턴과 예외 변환.

### @Repository 어노테이션
- 자동 예외 변환 (DataAccessException 계층으로 통일)
- 컴포넌트 스캔으로 자동 발견
- 기술 독립적인 DAO 구현

```java
@Repository
public class JdbcMovieFinder implements MovieFinder {
    private JdbcTemplate jdbcTemplate;

    @Autowired
    public void init(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }
}
```

### 장점
- 기술 독립성: JDBC ↔ JPA ↔ Hibernate 전환 용이
- 일관된 예외 처리: DataAccessException 계층
- 유연한 DI: @Autowired, @PersistenceContext 등

---
