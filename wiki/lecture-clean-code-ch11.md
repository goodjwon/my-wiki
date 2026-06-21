---
title: "Clean Code 실전 강의 — 11장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 11장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 11장 — 시스템

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **제작 (Construction)** 과 **사용 (Use)** 의 분리.
- **의존성 주입 (DI)** — Spring 의 핵심 원리.
- **횡단 관심사 (Cross-cutting concerns)** 와 **AOP**.
- 시스템도 **점진적·진화적** 으로 — TDD처럼.

### 0.2 큰 그림

```
[ 제작/사용 분리 ]              [ 확장 ]                       [ 진화 ]
 11.1 Main 분리                 11.4 횡단 관심사 (AOP)          11.5 TDD 시스템 아키텍처
 11.2 팩토리                    11.4.1 자바 프록시               11.6 의사 결정 최적화
 11.3 의존성 주입                11.4.2 AspectJ
                                                                 11.7 표준 현명하게
```

> **비유 — 시스템은 "도시"입니다.**
>
> 도시는 전기·수도·교통 같은 **추상화 계층** 으로 작동. 도시민은 모르고도 살아감. 시스템도 비슷 — 코드 사용자가 객체 생성·연결을 모르고도 쓸 수 있어야.

### 0.3 현업에서 왜 중요한가

- Spring IoC 컨테이너 = 11장의 직접 구현체.
- `@Bean`·`@Component`·`@Autowired` = DI 자동화.
- `@Transactional`·`@Async`·`@Cacheable` = AOP 횡단 관심사.

---

## 11.1 시스템 제작과 시스템 사용을 분리하라

### 한 줄 정의

객체 **생성·연결** 코드와 **사용** 코드를 분리. main (또는 IoC 컨테이너) 이 생성, 도메인이 사용.

### Before / After

```java
// Before — 사용 중에 생성
public Service getService() {
    if (service == null) service = new MyServiceImpl(...);   // 게으른 초기화
    return service;
}

// After — Main에서 미리 생성
public class Main {
    public static void main(String[] args) {
        Service service = new MyServiceImpl(...);
        App app = new App(service);
        app.run();
    }
}
```

### 11.1.1 Main 분리

모든 객체 생성을 main 함수 (또는 Spring 의 `@Configuration`) 한 곳에서.

```java
@Configuration
public class AppConfig {
    @Bean public OrderService orderService(OrderRepository repo) {
        return new OrderService(repo);
    }
}
```

### 11.1.2 팩토리

생성 시점이 사용 시점에 결정되어야 하면 **추상 팩토리**:

```java
public interface OrderFactory {
    Order create(OrderDetails details);
}

public class OrderProcessor {
    private final OrderFactory factory;
    public void process(OrderDetails details) {
        Order o = factory.create(details);   // 사용 시점에 생성
        ...
    }
}
```

### 11.1.3 의존성 주입 (DI)

객체가 의존성을 **요구하지 않고 받음**. 제어가 반전됨 (IoC).

```java
// Before — 객체가 의존성 만듦
public class OrderService {
    private final OrderRepository repo = new JpaOrderRepository();   // 결합
}

// After — 외부에서 주입
public class OrderService {
    private final OrderRepository repo;
    public OrderService(OrderRepository repo) { this.repo = repo; }
}
```

→ *Effective Java* Item 5 와 같은 메시지.

---

## 11.2 확장

### 한 줄 정의

시스템은 **점진적 진화** 가 가능하도록 설계. 한 번에 완벽한 설계 X.

### 11.2.1 횡단 관심사

여러 모듈에 걸친 공통 관심사: 로깅·트랜잭션·보안·캐싱·재시도.

**핵심**: 비즈니스 코드와 섞이면 안 됨.

```java
// ❌ 비즈니스 + 횡단 섞임
public void transfer(...) {
    log.info("transfer start");      // 횡단
    securityCheck();                  // 횡단
    transactionBegin();               // 횡단
    try {
        // 진짜 비즈니스
        fromAccount.withdraw(amount);
        toAccount.deposit(amount);
        transactionCommit();          // 횡단
    } catch (Exception e) {
        transactionRollback();        // 횡단
        throw e;
    }
    log.info("transfer end");         // 횡단
}

// ✅ AOP로 분리
@Transactional
public void transfer(...) {
    // 진짜 비즈니스만
    fromAccount.withdraw(amount);
    toAccount.deposit(amount);
}
```

---

## 11.3 자바 프록시 / 11.4 AOP

### Spring AOP

런타임에 프록시 객체를 생성해 횡단 관심사를 비즈니스 메서드 호출에 끼움.

```java
@Aspect
@Component
public class LoggingAspect {
    @Around("execution(* com.example..*Service.*(..))")
    public Object logExecution(ProceedingJoinPoint pjp) throws Throwable {
        long start = System.currentTimeMillis();
        try {
            return pjp.proceed();
        } finally {
            log.info("{} took {}ms", pjp.getSignature(), System.currentTimeMillis() - start);
        }
    }
}
```

`@Transactional`·`@Async`·`@Cacheable`·`@PreAuthorize` 가 모두 이 메커니즘.

### 함정

- Spring AOP 는 **public 메서드 + 외부 호출** 만 가로챔 (같은 클래스 내부 호출 X).
- 정적 메서드·`final` 메서드 X.
- 디버깅 어려움 — 프록시 거치므로 스택 트레이스가 길어짐.

---

## 11.5 테스트 주도 시스템 아키텍처 구축

### 한 줄 정의

아키텍처도 **간단히 시작·점진적 진화**. 처음부터 EJB·마이크로서비스 같은 거대 구조 도입 X.

### 진화 순서

1. 단순 모놀리스 → 테스트로 안전망
2. 도메인 모델 명확화 → 모듈 분리
3. 부하 증가 → 일부 모듈 분리·캐싱
4. 진짜로 필요해진 시점에만 마이크로서비스

→ YAGNI. 사용자 0명의 마이크로서비스는 낭비.

---

## 11.6 의사 결정을 최적화하라

### 핵심

큰 결정은 **가장 늦게 가능한 시점에**. 정보가 더 많을수록 결정 품질 ↑.

- DB 선택: 도메인 안정 후
- 캐시: 부하 측정 후
- 마이크로서비스: 모놀리스가 한계 도달 후

---

## 11.7 명백한 가치가 있을 때 표준을 현명하게 사용하라

### 한 줄 정의

표준 (EJB·OSGi·...) 은 **명백한 가치** 가 있을 때만. "있어 보이려고" 도입 X.

---

## 핵심 교훈

1. **제작과 사용 분리** — Main 또는 IoC 컨테이너가 생성.
2. **DI** 가 OO 의 핵심 원리. 객체가 의존성을 요구하지 않고 받음.
3. **횡단 관심사는 AOP** 로 분리.
4. **점진적 아키텍처** — 처음부터 완벽 X, YAGNI.
5. **표준은 가치가 있을 때만** — 도그마 X.

---

## 함정 / 주의

- Spring AOP의 자체 호출 함정 — `this.method()` 는 프록시 거치지 않아 `@Transactional` 등 무효.
- DI 컨테이너 없이 인터페이스 의존만 도입하면 객체 그래프 복잡도 폭증 → Spring 같은 컨테이너 권장.
- 마이크로서비스를 "트렌드라서" 도입은 위험. 모놀리스가 진짜 한계 도달 후.

---

## 체크리스트

- [ ] 객체 생성·연결이 비즈니스 코드와 섞여있는가
- [ ] DI 받지 않고 `new Repository()` 같이 직접 생성하는 클래스가 있는가
- [ ] 비즈니스 메서드 안에 로깅·트랜잭션·재시도가 섞여있는가
- [ ] Spring `@Transactional` 자체 호출 함정에 빠지지 않았는가
- [ ] 아직 필요 없는 마이크로서비스 분리를 진행 중인가

---

## 퀴즈

**Q1. "제작과 사용 분리" 가 OO 원칙과 어떻게 연결?**

**A.** **DIP (의존성 역전 원칙)**. 객체는 자기 의존성을 만들지 않고 외부에서 받음 → 결합도 ↓, 테스트 자유, 교체 자유. Spring DI 가 정확히 이 구현.

**Q2. AOP 가 횡단 관심사에 적합한 이유?**

**A.** 로깅·트랜잭션·보안 같은 관심사가 **모든 비즈니스 메서드에 반복** 되면 (1) 본질 흐려짐, (2) 변경 시 산탄총 수술. AOP 가 한 곳에 두고 자동 적용 → SRP·DRY 모두 충족.

**Q3. Spring AOP 의 자체 호출 함정?**

**A.** `this.method()` 는 프록시를 거치지 않으므로 `@Transactional`·`@Async` 무효. 트랜잭션 적용 안 됨에도 모르고 지나가 사고. **다른 빈을 통한 호출** 만 프록시 작동.

**Q4. "테스트 주도 시스템 아키텍처" 가 의미하는 바?**

**A.** 아키텍처도 **점진적 진화**. 처음부터 거대 구조 X, 단순 시작 → 안전망 (테스트) 위에서 진화. YAGNI 정신을 시스템 단위로.

**Q5. "의사 결정을 가장 늦게" 의 실천적 이유?**

**A.** 늦을수록 **더 많은 정보** — 도메인 안정·실제 부하·사용 패턴. DB 선택, 캐시 도입, MSA 분리 모두 정보가 쌓인 후 결정해야 후회 적음.

---

## 다음 장 예고 — 12장: 창발성 (창발적 설계)

**Kent Beck의 단순한 설계 4규칙** — 모든 테스트 통과 / 중복 없음 / 의도 표현 / 최소 클래스·메서드. 이 4규칙만 지켜도 좋은 설계가 **창발 (emerge)** 한다는 메시지.
