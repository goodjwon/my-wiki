---
title: 디자인 패턴 (GoF + 실무 8선)
type: concept
tags: [java, design-pattern, oop, spring, gof]
sources: [java-study/java-study-ch04-객체지향설계와패턴.md]
external:
  - https://refactoring.guru/design-patterns
created: 2026-04-18
updated: 2026-06-07
---

# 디자인 패턴

## 정의

**반복되는 설계 문제에 대한 검증된 해법 카탈로그.** GoF(Gang of Four)의 _Design Patterns_(1994) 책에서 23개 패턴을 정리한 것이 시초이며, Spring·Java 표준 라이브러리에 깊게 녹아 있다.

> 패턴을 외우는 것보다, **언제 패턴이 필요한 신호를 알아보는 것**이 더 중요.

## GoF 23패턴 분류

| 카테고리 | 패턴 (이 위키 보강 = ★) |
|---------|------------------------|
| **생성 (Creational)** | ★Factory Method, Abstract Factory, Builder, Prototype, ★Singleton |
| **구조 (Structural)** | ★Adapter, Bridge, Composite, Decorator, ★Façade, Flyweight, ★Proxy |
| **행위 (Behavioral)** | Chain of Responsibility, Command, Iterator, Mediator, Memento, ★Observer, State, ★Strategy, ★Template Method, Visitor, Interpreter |

이 페이지에서는 Java·Spring 실무에서 가장 자주 쓰는 **8개**를 깊이 다룬다.

## 1. 전략 (Strategy)

**핵심**: 동일한 작업의 **여러 알고리즘을 객체로 분리**, 런타임에 교체 가능.

```java
// Before: 분기로 알고리즘 선택
public long shipping(Order o) {
    if (o.type == FAST) return 5000;
    else if (o.type == STANDARD) return 3000;
    else if (o.type == BULK) return o.weight * 500;
    throw new IllegalStateException();
}

// After: 전략 분리
interface ShippingStrategy { long fee(Order o); }
class FastShipping implements ShippingStrategy { public long fee(Order o) { return 5000; } }

@Service
public class OrderService {
    private final Map<ShippingType, ShippingStrategy> strategies;
    public long shipping(Order o) { return strategies.get(o.type).fee(o); }
}
```

**Spring 활용**: DI 그 자체. 결제·알림·할인 계산 등 "교체 가능한 알고리즘" 어디서나.

## 2. 템플릿 메서드 (Template Method)

**핵심**: **전체 흐름은 고정**, 일부 단계만 하위 클래스가 채운다.

```java
abstract class ReportGenerator {
    public final Report generate() {  // 흐름 고정
        var data = fetchData();
        var processed = process(data);
        return render(processed);
    }
    protected abstract Data fetchData();
    protected abstract Data process(Data d);
    protected Report render(Data d) { return new HtmlReport(d); }
}
```

**Spring 활용**:
- `JdbcTemplate` — connection 관리·예외 변환은 고정, SQL만 사용자가
- `RestTemplate`, `TransactionTemplate`
- Spring Batch — Reader → Processor → Writer 흐름 고정

## 3. 팩토리 메서드 (Factory Method)

**핵심**: 객체 생성 자체를 **별도 메서드/클래스**로 분리. 호출자는 어떤 구체 타입이 만들어지는지 모른다.

```java
class NotificationFactory {
    public static NotificationSender create(NotificationType type) {
        return switch (type) {
            case EMAIL -> new EmailSender();
            case SLACK -> new SlackSender();
            case SMS   -> new SmsSender();
        };
    }
}
```

**Spring 활용**:
- `@Bean` 메서드 자체가 팩토리 메서드
- `FactoryBean<T>` — 복잡한 Bean 생성 로직 캡슐화
- `BeanFactory` — 전체 Bean 생성의 중앙 팩토리

## 4. 싱글톤 (Singleton)

**핵심**: 앱 전체에서 **인스턴스가 단 하나**.

```java
// enum 싱글톤 (Joshua Bloch 권장)
public enum Cache {
    INSTANCE;
    public void put(...) { ... }
}
```

**Spring 활용**: Bean의 기본 스코프 = singleton ([[concept-spring-core]]).

**함정**:
- **싱글톤 + 가변 상태 = 동시성 폭탄** — 싱글톤 Bean에 `Map`/mutable counter 두면 race condition
- 테스트 어려움 — 상태가 전역이라 격리 X
- 해결: 가능하면 **stateless**, 상태 필요하면 `prototype` 스코프

## 5. 옵저버 (Observer)

**핵심**: **상태 변화를 관심 있는 객체들에게 자동 통보**.

```java
@Component
public class OrderEventPublisher {
    private final ApplicationEventPublisher publisher;
    public void orderPlaced(Order o) {
        publisher.publishEvent(new OrderPlacedEvent(o));
    }
}

// 여러 리스너가 같은 이벤트 구독
@Component class EmailNotifier {
    @EventListener void on(OrderPlacedEvent e) { sendEmail(e.order()); }
}
@Component class StatsCollector {
    @EventListener void on(OrderPlacedEvent e) { incrementCounter(); }
}
```

**Spring 활용**:
- `ApplicationEvent` + `@EventListener`
- `@TransactionalEventListener` — 트랜잭션 commit 후 발행
- 도메인 이벤트 — Aggregate 변경 → 외부 알림 ([[src-kakaopay-ddd]])

## 6. 프록시 (Proxy)

**핵심**: **원본 객체를 대신하는 대리자**를 두어, 호출 전/후에 부가 동작.

```java
interface UserService { User findById(long id); }
class UserServiceImpl implements UserService { ... }

class LoggingProxy implements UserService {  // 프록시
    private final UserService target;
    public User findById(long id) {
        log.info("find {}", id);     // before
        User result = target.findById(id);
        log.info("found {}", result); // after
        return result;
    }
}
```

**Spring 활용 (AOP의 본체)**:
- `@Transactional`, `@Async`, `@Cacheable`
- Spring Security `@PreAuthorize`

**함정**:
- **Self-invocation** — 같은 클래스 내부 호출은 프록시 우회 ([[concept-spring-core]])
- JDK Dynamic Proxy vs CGLIB — Spring Boot 2.x+ 기본 = CGLIB

## 7. 어댑터 (Adapter)

**핵심**: **호환되지 않는 두 인터페이스를 연결**.

```java
interface SmsGateway { void sendSms(String phone, String text); }
interface NotificationSender { void send(Notification n); }

class SmsNotificationAdapter implements NotificationSender {
    private final SmsGateway gateway;
    public void send(Notification n) {
        gateway.sendSms(n.recipient(), n.body());  // 변환
    }
}
```

**Spring 활용**:
- `HandlerAdapter` — 다양한 핸들러 타입을 통일된 방식으로 실행
- `MessageConverter` — JSON ↔ Java 객체 변환
- 외부 SDK를 우리 도메인 인터페이스로 감싸기

## 8. 파사드 (Façade)

**핵심**: **복잡한 서브시스템에 단순한 진입점**.

```java
@Service
public class OrderFacade {
    public OrderResult placeOrder(OrderRequest req) {
        inventory.reserve(req);
        payment.charge(req);
        shipping.schedule(req);
        notification.send(req);
        return OrderResult.success();
    }
}
```

**Spring 활용**: 외부 API 게이트웨이, Application Service, 복잡한 외부 라이브러리(AWS SDK) 래핑.

## 공통 교훈

1. **분기 2~3개까지는 if/switch가 가독성 좋다** — 패턴은 변화 가능성이 보일 때
2. **패턴을 아는 것 < 무엇을 분리할지 판단하는 것**
3. **Spring을 쓰면 이미 많은 패턴이 프레임워크 안에**
4. **패턴 이름이 무기가 아니다** — 팀 공통 어휘로만

## 안티 패턴

| 안티패턴 | 증상 |
|---------|------|
| **God Object** | 한 클래스가 모든 책임 (= 캡슐화 실패) |
| **Singleton 남용** | 모든 게 전역 = 테스트·동시성 지옥 |
| **빈 인터페이스** (구현체 1개만) | 추상화 비용 > 가치 |
| **상속 trap** | 깊은 상속 트리 → 변경 폭발 |
| **패턴 자랑** | 이름 붙이려고 만든 코드 |

## 학습 자료

- _Design Patterns: Elements of Reusable OO Software_ (GoF, 1994)
- _Head First Design Patterns_ — 초보자 친화
- _Effective Java_ — 자바스러운 패턴 활용
- [Refactoring.Guru](https://refactoring.guru/design-patterns) — 인터랙티브

## 원본 출처

- raw: `raw/java-study/java-study-ch04-객체지향설계와패턴.md`
- 학습: [Refactoring.Guru — Design Patterns](https://refactoring.guru/design-patterns)

## 관련 페이지

- [[concept-oop]] — 패턴의 기반이 되는 OO 원칙
- [[concept-spring-core]] — 패턴이 실무에서 적용되는 Spring 구조
- [[src-java-study-2024-2025]] — Ch04 객체지향 설계와 패턴
- [[src-kakaopay-ddd]] — DDD에서 패턴 활용
- [[concept-transactional-rollback-policy]] — 프록시 패턴의 함정 사례
