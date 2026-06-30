---
title: Spring 핵심 개념 (IoC · DI · Bean · AOP · MVC)
type: concept
tags: [spring, ioc, di, bean, aop, mvc, dispatcher-servlet, proxy]
sources: [java-study/java-study-ch06-Spring과프로젝트실행.md, spring/Spring Framework Versions.md]
external:
  - https://docs.spring.io/spring-framework/reference/core/beans.html
  - https://docs.spring.io/spring-framework/reference/core/aop/proxying.html
  - https://docs.spring.io/spring-framework/reference/web/webmvc.html
created: 2026-04-18
updated: 2026-06-06
---

# Spring 핵심 개념

Spring Framework의 다섯 기둥 — **IoC · DI · Bean · AOP · MVC**. 이 다섯 개를 이해하면 Spring/Spring Boot의 거의 모든 동작이 설명된다.

## 1. IoC (Inversion of Control)

### 정의

객체 생성·결합·생명주기 관리의 **제어권을 코드 바깥(컨테이너)으로 넘기는 것**. 직접 `new`로 의존 객체를 만드는 대신, 컨테이너가 만들어 주입해준다.

### Before / After

```java
// IoC 없음 (직접 제어)
public class OrderService {
    private final OrderRepository repo = new JdbcOrderRepository(
        new HikariDataSource(...)
    );
}

// IoC 있음 (컨테이너가 제어)
@Service
public class OrderService {
    private final OrderRepository repo;
    public OrderService(OrderRepository repo) {  // 컨테이너가 주입
        this.repo = repo;
    }
}
```

### IoC 컨테이너 종류

| 컨테이너 | 특징 | 사용처 |
|---------|------|-------|
| **BeanFactory** | 가장 기본. DI + 생명주기만 | 메모리 제약 환경 (드묾) |
| **ApplicationContext** | BeanFactory 확장. 이벤트, i18n, 어노테이션 기반 설정 | **사실상 모든 Spring 앱** |

Spring Boot는 내부적으로 `AnnotationConfigApplicationContext` (또는 웹의 경우 `AnnotationConfigServletWebServerApplicationContext`)를 사용한다.

## 2. DI (Dependency Injection)

### 정의

IoC를 **실현하는 가장 일반적인 방법**. 의존 객체를 어떻게 받느냐의 패턴.

### 세 가지 주입 방식

| 방식 | 코드 | 권장? |
|------|------|------|
| **생성자 주입** (Constructor) | `public X(Y y) { this.y = y; }` | ✅ **기본 권장** |
| **세터 주입** (Setter) | `public void setY(Y y) { ... }` | △ 선택적 의존성에만 |
| **필드 주입** (Field) | `@Autowired private Y y;` | ❌ **사용 금지** |

### 생성자 주입이 권장되는 이유

1. **의존성이 시그니처에 드러난다** — 클래스를 보면 무엇이 필요한지 즉시 보임
2. **`final` 키워드로 불변성 보장** — 객체 생성 후 의존성이 절대 안 바뀜
3. **테스트가 쉽다** — `new OrderService(mockRepo)` 한 줄로 생성, Spring 없이 단위 테스트 가능
4. **순환 참조 컴파일 시 발견** — Spring이 시작 시 즉시 에러 (필드 주입은 런타임 NPE)

Spring 4.3+ 부터는 **생성자가 1개면 `@Autowired` 자동 적용** — 생략 가능.

```java
@Service
public class OrderService {
    private final OrderRepository repo;
    private final PaymentClient payment;

    // @Autowired 생략 가능 (생성자 1개라서)
    public OrderService(OrderRepository repo, PaymentClient payment) {
        this.repo = repo;
        this.payment = payment;
    }
}
```

→ [[concept-claude-md|CLAUDE.md]]의 STOP 트리거에 "`@Autowired` 필드 주입 금지" 항목이 있는 이유.

## 3. Bean

### 정의

**Spring 컨테이너가 생성·관리하는 객체**. 거의 모든 Spring 애플리케이션의 구성 요소.

### Bean 등록 방법 3가지

| 방법 | 형태 | 적합 |
|------|------|------|
| **컴포넌트 스캔** | `@Component` 등의 어노테이션 + `@ComponentScan` | 직접 작성한 클래스 |
| **`@Bean` 메서드** | `@Configuration` 클래스 안에 `@Bean` 메서드 | 외부 라이브러리 객체, 조건부 생성 |
| XML 설정 | `<bean class="..."/>` | 레거시 호환만 |

### 컴포넌트 스테레오타입 — 4종

`@Component`는 부모이고 나머지는 의미 분화:

| 어노테이션 | 의미 (관습) | 부가 동작 |
|----------|-----------|---------|
| `@Component` | 일반 컴포넌트 | 기본 |
| `@Service` | **비즈니스 로직** 레이어 | 의미 표시만 (Spring이 자동 동작 X) |
| `@Repository` | **데이터 접근** 레이어 (DAO) | DB 예외 → Spring `DataAccessException`으로 자동 변환 |
| `@Controller` / `@RestController` | **HTTP 핸들러** | DispatcherServlet 매핑, @RequestMapping 인식 |

→ 자동 동작이 가장 큰 것은 `@Repository`. 나머지는 의미 표시.

### Bean 스코프

| 스코프 | 인스턴스 개수 | 사용처 |
|-------|------------|-------|
| **`singleton`** (기본) | 컨테이너당 1개 | 모든 stateless 서비스 |
| **`prototype`** | 요청할 때마다 새 인스턴스 | 가변 상태 보유 객체 |
| `request` | HTTP 요청당 1개 | 요청 컨텍스트 객체 |
| `session` | HTTP 세션당 1개 | 사용자 상태 객체 |
| `application` | ServletContext당 1개 | 거의 안 씀 |
| `websocket` | WebSocket 세션당 1개 | WebSocket 컨텍스트 |

```java
@Service
@Scope("prototype")  // 또는 @Scope(BeanDefinition.SCOPE_PROTOTYPE)
public class StatefulCalculator { ... }
```

> **싱글톤 함정**: Bean 안에 가변 필드(`Map`, `List`, mutable counter 등)를 두면 **동시성 문제** 직격탄. 싱글톤 Bean은 stateless로 유지.

### Bean 생명주기 (생애)

```
1. Instantiation        — 생성자 호출, 객체 생성
2. Populate Properties  — DI (의존성 주입)
3. BeanNameAware 등 콜백
4. @PostConstruct       — 초기화 로직 (DB 연결 등)
5. InitializingBean.afterPropertiesSet()
6. ... 사용 가능 ...
7. @PreDestroy          — 정리 로직 (커넥션 close 등)
8. DisposableBean.destroy()
```

가장 자주 쓰는 두 어노테이션:

```java
@Service
public class CacheLoader {
    @PostConstruct
    public void warmup() { /* 시작 시 캐시 로딩 */ }

    @PreDestroy
    public void cleanup() { /* 종료 시 자원 해제 */ }
}
```

## 4. AOP (Aspect-Oriented Programming)

### 정의

**관심사 분리(Cross-cutting Concerns)** — 로깅·트랜잭션·보안처럼 여러 클래스에 흩어지는 공통 동작을 한 곳에서 처리. Spring은 **프록시 기반 AOP**.

### Spring AOP가 적용되는 어노테이션들

| 어노테이션 | 부가 동작 |
|----------|---------|
| `@Transactional` | 트랜잭션 begin/commit/rollback |
| `@Async` | 별도 스레드 풀에서 실행 |
| `@Cacheable`, `@CachePut`, `@CacheEvict` | 메서드 결과 캐싱 |
| `@PreAuthorize`, `@Secured` | 호출 권한 검사 |
| `@Retryable` (Spring Retry) | 실패 시 재시도 |
| 사용자 정의 `@Aspect` | 직접 정의한 부가 동작 |

### 프록시 종류 2가지

| 종류 | 조건 | 특징 |
|------|------|------|
| **JDK Dynamic Proxy** | 대상이 **인터페이스 구현** | `java.lang.reflect.Proxy` 사용, 인터페이스 메서드만 가능 |
| **CGLIB Proxy** | 대상이 **인터페이스 없는 클래스** | 대상 클래스를 **상속**해서 서브클래스 생성, `final` 메서드 프록시 불가 |

**Spring Boot 2.x+ 기본 = CGLIB** (인터페이스 유무 무관). 이전엔 인터페이스 있으면 JDK Proxy였음.

### 🚨 핵심 함정: Self-Invocation

같은 클래스 안에서 다른 메서드를 직접 호출하면 **프록시를 우회** — `@Transactional` · `@Async` · `@Cacheable` 등이 작동 안 한다.

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder(Order o) {
        repo.save(o);
        sendNotification(o);  // ⚠️ self-invocation
    }

    @Transactional(propagation = REQUIRES_NEW)
    public void sendNotification(Order o) {
        // 새 트랜잭션이 생기지 않는다!
        // placeOrder의 트랜잭션 안에서 그냥 실행됨.
    }
}
```

**원인**: `placeOrder` 안의 `sendNotification(o)`는 `this.sendNotification(o)`인데, `this`는 **프록시가 아닌 실제 객체**. 프록시는 외부에서 들어오는 호출만 가로챈다.

### 해결책 3가지

1. **별도 Bean으로 분리** (권장):
   ```java
   @Service
   public class OrderService {
       private final NotificationService notification;
       @Transactional
       public void placeOrder(Order o) {
           repo.save(o);
           notification.send(o);  // 다른 Bean → 프록시 통과 ✅
       }
   }
   ```

2. **자기 자신 주입** (anti-pattern으로 보는 의견 다수):
   ```java
   @Service
   public class OrderService {
       @Lazy private final OrderService self;
       // self.sendNotification(o) → 프록시 통과
   }
   ```

3. **`AopContext.currentProxy()`** — `@EnableAspectJAutoProxy(exposeProxy = true)` 필요. 코드가 지저분해짐.

→ 1번이 정답. [[concept-transactional-rollback-policy|@Transactional 롤백 정책]]과 함께 알아야 할 두 가지 함정.

## 5. MVC (Spring Web MVC)

### 요청 처리 흐름

```
[클라이언트]
    ↓ HTTP Request
[DispatcherServlet]  ← 모든 요청의 단일 진입점 (Front Controller 패턴)
    ↓ "어느 핸들러가 처리?"
[HandlerMapping]  ← @RequestMapping 등을 보고 매칭
    ↓ HandlerExecutionChain (Handler + Interceptors)
[HandlerAdapter]  ← 다양한 핸들러 타입을 통일된 방식으로 실행
    ↓
[Controller (핸들러 메서드)]
    ↓ ModelAndView 또는 @ResponseBody
[ViewResolver]  ← view 이름 → 실제 View 객체로 해석
    ↓
[View (Thymeleaf, JSON 등)] → 렌더링
    ↓ HTTP Response
[클라이언트]
```

### 핵심 컴포넌트

| 컴포넌트 | 역할 |
|---------|------|
| **DispatcherServlet** | 모든 HTTP 요청의 진입점. 흐름 조정자 |
| **HandlerMapping** | URL → 핸들러 매핑 (`RequestMappingHandlerMapping`이 대표) |
| **HandlerAdapter** | 핸들러 실행 (`RequestMappingHandlerAdapter`가 대표) |
| **HandlerInterceptor** | 핸들러 실행 전/후 가로채기 (인증 등) |
| **HandlerExceptionResolver** | 예외 → 응답 변환 (`@ControllerAdvice` 동작 지점) |
| **ViewResolver** | view 이름 → View 인스턴스 (JSON일 땐 사용 안 함) |

### @RestController vs @Controller

| | `@Controller` | `@RestController` |
|---|--------------|------------------|
| 반환값 처리 | view 이름으로 해석 (ViewResolver 거침) | **`@ResponseBody`가 자동 적용** (JSON·XML 직렬화) |
| 사용처 | 서버사이드 렌더링 (Thymeleaf) | REST API |
| 효과 | `@Controller` | `@Controller + @ResponseBody` |

### 일반적인 레이어 흐름

```
@RestController       (HTTP/JSON 경계)
    ↓
@Service              (비즈니스 로직, @Transactional 경계)
    ↓
@Repository           (DB 접근, DataAccessException 변환)
    ↓
DataSource / JPA      (실제 SQL)
```

→ DTO는 Controller ↔ Service 경계에서 변환. Entity를 Controller에 직접 노출하지 않는 것이 [[concept-api-backward-compatibility|API 안정성]]에도 좋다.

## 6. 같은 인사이트 패턴

| 영역 | 위험 | 권장 |
|------|------|------|
| **이 페이지: AOP self-invocation** | 같은 클래스 내부 호출 → 프록시 우회 | 별도 Bean으로 분리 |
| **이 페이지: 싱글톤 + 가변 필드** | 동시성 문제 | stateless 유지 또는 `prototype` |
| [[concept-transactional-rollback-policy]] | `@Transactional` 체크 예외 commit | `rollbackFor = Exception.class` |
| [[concept-api-backward-compatibility]] | 클라이언트 JSON 라이브러리 기본값 | Tolerant Reader 명세 |

→ 공통 원리: **"프레임워크가 제공하는 마법(`@어노테이션`)에는 항상 작동 조건이 있다."** 무작정 어노테이션 붙이지 말고 그 동작 모델을 이해해야 한다.

## 7. 빠른 진단 명령어

```bash
# 1) @Autowired 필드 주입 찾기 (생성자 주입으로 바꿀 후보)
grep -rn "^\s*@Autowired" src/main/java/ --include="*.java" | grep -v "//" | head

# 2) 같은 클래스 내부에서 @Transactional 메서드를 self-call 가능성
#    (Entity·Service 클래스에서 this.* 호출이 많은 곳 확인)
grep -rn "this\." src/main/java/ --include="*Service.java" | head

# 3) Bean 등록 통계 (Spring Boot 실행 후 actuator beans 엔드포인트)
curl -s http://localhost:8080/actuator/beans | jq '.contexts.application.beans | keys | length'

# 4) 가장 큰 Bean (메모리)
curl -s http://localhost:8080/actuator/metrics/jvm.memory.used
```

## 8. 빠른 참고 어노테이션 표

| 어노테이션 | 카테고리 | 자주 쓰는 속성 |
|----------|---------|--------------|
| `@Component`/`@Service`/`@Repository`/`@Controller` | Bean 등록 | 없음 |
| `@Autowired` | DI (필드/세터, **권장 X**) | `required=false` |
| `@Qualifier("name")` | DI 충돌 해결 | 동명 빈이 여럿일 때 |
| `@Primary` | DI 충돌 해결 | 우선순위 빈 |
| `@Lazy` | 지연 초기화 | self-injection 용도 등 |
| `@Scope("prototype")` | Bean 스코프 | singleton/prototype/... |
| `@PostConstruct` / `@PreDestroy` | 라이프사이클 | (없음) |
| `@Configuration` + `@Bean` | 명시적 Bean 등록 | `@Bean(initMethod, destroyMethod)` |
| `@ComponentScan` | 스캔 범위 | `basePackages` |
| `@Transactional` | AOP (트랜잭션) | `rollbackFor`, `propagation`, `isolation` |
| `@Async` | AOP (비동기) | `executor` 이름 |
| `@Cacheable` | AOP (캐시) | `value`(캐시 이름), `key` |
| `@EventListener` | 이벤트 | (없음) |

## 원본 출처

- raw: `raw/java-study/java-study-ch06-Spring과프로젝트실행.md`
- 공식: [Spring — The IoC Container](https://docs.spring.io/spring-framework/reference/core/beans.html)
- 공식: [Spring AOP — Proxying Mechanisms](https://docs.spring.io/spring-framework/reference/core/aop/proxying.html)
- 공식: [Spring Web MVC](https://docs.spring.io/spring-framework/reference/web/webmvc.html)
- 공식: [Spring Bean Scopes](https://docs.spring.io/spring-framework/reference/core/beans/factory-scopes.html)

## 관련 페이지

- [[entity-spring-framework]] / [[entity-spring-boot]] — Spring 제품군
- [[entity-effective-java]] — Spring DI의 이론적 근거는 *Effective Java* Item 5(자원을 직접 명시하지 말고 의존성 주입을 사용하라). `@Bean`=Item 3 싱글턴, `@Transactional`=Item 39 애너테이션
- [[concept-transactional-rollback-policy]] — `@Transactional`의 또 다른 함정
- [[concept-api-backward-compatibility]] — Controller 응답 설계 시 고려
- [[src-spring-data-access-ref]] — `@Repository`, `@Transactional` 자세히
- [[src-spring-web-mvc-ref]] — DispatcherServlet, MVC 자세히
- [[src-spring-guide]] — 실무 디렉터리·계층 구조 가이드
- [[concept-design-patterns]] — Spring에서 활용되는 패턴 (프록시·팩토리·싱글톤)
- [[src-java-study-2024-2025]] — Java 스터디 Ch5~Ch8
- [[src-kakaopay-ddd]] — DDD 레이어와 Spring Bean 책임 분리
- [[concept-claude-md]] — STOP 트리거 후보 (`@Autowired` 필드 주입 금지 등)
