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

## JdbcTemplate / JdbcClient 사용법 (코드 예제)

### JdbcTemplate 설정

```java
public class JdbcCorporateEventDao implements CorporateEventDao {
    private final JdbcTemplate jdbcTemplate;

    public JdbcCorporateEventDao(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }
}
```

### 쿼리 예제 (SELECT)

```java
// 단일 값
int rowCount = jdbcTemplate.queryForObject("select count(*) from t_actor", Integer.class);

// 바인드 변수
int count = jdbcTemplate.queryForObject(
    "select count(*) from t_actor where first_name = ?", Integer.class, "Joe");

// 단일 도메인 객체
Actor actor = jdbcTemplate.queryForObject(
    "select first_name, last_name from t_actor where id = ?",
    (rs, rowNum) -> {
        Actor a = new Actor();
        a.setFirstName(rs.getString("first_name"));
        a.setLastName(rs.getString("last_name"));
        return a;
    }, 1212L);

// 리스트 조회
List<Actor> actors = jdbcTemplate.query(
    "select first_name, last_name from t_actor",
    (rs, rowNum) -> new Actor(rs.getString("first_name"), rs.getString("last_name")));
```

### 업데이트 예제 (INSERT/UPDATE/DELETE)

```java
jdbcTemplate.update("insert into t_actor (first_name, last_name) values (?, ?)", "Leonor", "Watling");
jdbcTemplate.update("update t_actor set last_name = ? where id = ?", "Banjo", 5276L);
jdbcTemplate.update("delete from t_actor where id = ?", actorId);
```

### 자동 생성 키 조회

```java
KeyHolder keyHolder = new GeneratedKeyHolder();
jdbcTemplate.update(connection -> {
    PreparedStatement ps = connection.prepareStatement(INSERT_SQL, new String[]{"id"});
    ps.setString(1, name);
    return ps;
}, keyHolder);
// keyHolder.getKey() → 생성된 키
```

### JdbcClient (Spring 6.1+) — 모던 fluent API

```java
JdbcClient jdbcClient = JdbcClient.create(dataSource);

// 조회
List<Actor> actors = jdbcClient.sql("select first_name, last_name from t_actor")
    .query(Actor.class).list();

// 단일 조회
Actor actor = jdbcClient.sql("select * from t_actor where id = ?")
    .param(1212L).query(Actor.class).single();

// Optional
Optional<Actor> actor = jdbcClient.sql("select * from t_actor where id = ?")
    .param(1212L).query(Actor.class).optional();

// 업데이트
jdbcClient.sql("insert into t_actor (first_name, last_name) values (:firstName, :lastName)")
    .param("firstName", "Leonor").param("lastName", "Watling").update();

// 객체 파라미터
jdbcClient.sql("insert into t_actor (first_name, last_name) values (:firstName, :lastName)")
    .paramSource(new Actor("Leonor", "Watling")).update();
```

### NamedParameterJdbcTemplate

```java
String sql = "select count(*) from t_actor where first_name = :first_name";
SqlParameterSource params = new MapSqlParameterSource("first_name", firstName);
return namedParameterJdbcTemplate.queryForObject(sql, params, Integer.class);

// BeanPropertySqlParameterSource
SqlParameterSource params = new BeanPropertySqlParameterSource(actor);
return namedParameterJdbcTemplate.queryForObject(sql, params, Integer.class);
```

### 핵심 포인트
- JdbcTemplate은 **thread-safe** — 하나의 인스턴스를 여러 DAO에서 공유
- Spring이 커넥션 열기/닫기, 예외 처리, 트랜잭션 관리를 담당
- 개발자는 SQL과 파라미터, 결과 매핑에만 집중

---

## Transaction Propagation 상세

### PROPAGATION_REQUIRED (기본값)

- 기존 트랜잭션이 있으면 **참여**, 없으면 **새로 생성**
- 참여 시 외부 트랜잭션의 isolation, timeout, readOnly 설정은 무시
- 내부에서 rollback-only 설정하면 외부 커밋 시 `UnexpectedRollbackException` 발생

### PROPAGATION_REQUIRES_NEW

- 항상 **독립적인 물리적 트랜잭션** 생성
- 외부 트랜잭션과 완전히 분리 — 독립적으로 commit/rollback
- 자체 isolation, timeout, readOnly 설정 가능
- **주의**: 커넥션 풀 고갈/데드락 가능성 — 풀 크기를 동시 스레드 수 + 1 이상으로 설정

### PROPAGATION_NESTED

- **단일 물리적 트랜잭션** + 여러 **savepoint** 사용
- 내부 범위만 롤백하고 외부는 계속 진행 가능
- JDBC savepoint에 의존 → `DataSourceTransactionManager`에서만 동작

---

## Rollback 규칙 상세

### 기본 동작
- `RuntimeException`, `Error` → 롤백
- Checked Exception → 롤백하지 않음 (커밋)

### 커스텀 롤백 규칙

```java
@Transactional(rollbackFor = {NoProductInStockException.class})
public void updateStock() { ... }

@Transactional(noRollbackFor = {InstrumentNotFoundException.class})
public void processOrder() { ... }
```

### Spring 6.2+ 전역 설정
```java
@EnableTransactionManagement(rollbackOn = ALL_EXCEPTIONS)
```

### 프로그래밍 방식 롤백
```java
TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
```

---

## Programmatic Transaction 관리

### TransactionTemplate (권장)

```java
public class SimpleService {
    private final TransactionTemplate transactionTemplate;

    public SimpleService(PlatformTransactionManager txManager) {
        this.transactionTemplate = new TransactionTemplate(txManager);
    }

    public Object someServiceMethod() {
        return transactionTemplate.execute(status -> {
            updateOperation1();
            return resultOfUpdateOperation2();
        });
    }
}
```

### 롤백

```java
transactionTemplate.execute(new TransactionCallbackWithoutResult() {
    protected void doInTransactionWithoutResult(TransactionStatus status) {
        try {
            updateOperation1();
        } catch (SomeBusinessException ex) {
            status.setRollbackOnly();
        }
    }
});
```

### 설정 커스터마이징

```java
transactionTemplate.setIsolationLevel(TransactionDefinition.ISOLATION_READ_UNCOMMITTED);
transactionTemplate.setTimeout(30);
```

### PlatformTransactionManager 직접 사용

```java
DefaultTransactionDefinition def = new DefaultTransactionDefinition();
def.setName("SomeTxName");
def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);

TransactionStatus status = txManager.getTransaction(def);
try {
    // business logic
} catch (MyException ex) {
    txManager.rollback(status);
    throw ex;
}
txManager.commit(status);
```

---

## DataSource 설정 가이드

### 커넥션 풀 비교

| 구현체 | 용도 | 풀링 |
|--------|------|------|
| DriverManagerDataSource | 테스트 전용 | X |
| SingleConnectionDataSource | 테스트 전용 | X (단일 커넥션) |
| Apache Commons DBCP | 프로덕션 | O |
| C3P0 | 프로덕션 | O |
| **HikariCP** | **프로덕션 (권장)** | O |

### HikariCP 설정 (Spring Boot 기본)

```java
@Bean(destroyMethod = "close")
BasicDataSource dataSource() {
    BasicDataSource ds = new BasicDataSource();
    ds.setDriverClassName("org.hsqldb.jdbcDriver");
    ds.setUrl("jdbc:hsqldb:hsql://localhost:");
    ds.setUsername("sa");
    ds.setPassword("");
    return ds;
}
```

### TransactionManager 선택

| 매니저 | 용도 |
|--------|------|
| DataSourceTransactionManager | 기본 JDBC |
| JdbcTransactionManager | JDBC + 예외 번역 (Spring 5.3+, 권장) |
| JpaTransactionManager | JPA |
| JtaTransactionManager | 분산 트랜잭션 |

---
