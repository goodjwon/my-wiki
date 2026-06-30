---
title: "Java 스터디 — 객체지향 설계와 패턴"
type: source
tags: [java, study, notion, ch04]
sources: [java-study/java-study-ch04-객체지향설계와패턴.md]
created: 2026-04-18
updated: 2026-06-30
---

> 📘 [[src-java-study-2024-2025]] 원본 교재 본문. 학습 흐름은 [[guide-java-learning-path]] 참조.

# 객체지향 설계와 패턴

## 🎯 이 장에서 배우는 것

- 디자인 패턴 8종을 "바뀌는 것 분리" 도구로 사용
- 전략·템플릿·팩토리·싱글톤·옵저버·프록시·어댑터·파사드
- if-else를 전략 패턴으로 리팩터링

**단계**: 1단계 — Java Core · **앞 장**: [[java-study-ch03]] · **다음 장**: [[java-study-ch05]]

> **따라 하는 법**: 위에서 아래로 읽으며 코드를 직접 쳐본다. 패턴마다 Before/After 코드를 비교하고, 4.9 실전문제로 OCP를 코드로 확인한다. 깊이: [[concept-design-patterns]].

---

원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 4.0 전략 패턴

**🎯 목표**: 전략 패턴으로 바뀌는 행위를 분리해 교체 가능하게 만든다.

#### 개요

전략 패턴은 **행위를 캡슐화하여 실행 시점에 교체할 수 있게 만드는 패턴**입니다. 같은 역할을 하는 여러 알고리즘이 있고, 상황에 따라 적절한 구현을 선택해야 할 때 유용합니다.

초중급 Java 개발자에게 이 패턴이 중요한 이유는, 실무에서 가장 자주 만나는 구조적 문제 중 하나가 바로 `if-else`와 `switch`의 비대화이기 때문입니다. 전략 패턴은 이 문제를 객체지향적으로 풀어내는 대표적인 방법입니다.

#### 언제 사용하는가

- 같은 역할을 하는 여러 구현이 존재할 때
- 정책, 계산 방식, 외부 연동 방식이 자주 바뀔 때
- 분기문이 계속 늘어나 유지보수가 어려워질 때

#### Before

```java
public class PaymentService {
    public void processPayment(String paymentMethod, int amount) {
        if ("creditCard".equals(paymentMethod)) {
            System.out.println("신용카드로 " + amount + "원 결제를 처리합니다.");
        } else if ("bankTransfer".equals(paymentMethod)) {
            System.out.println("계좌이체로 " + amount + "원 결제를 처리합니다.");
        } else {
            throw new IllegalArgumentException("지원하지 않는 결제 방식입니다.");
        }
    }
}
```

이 구조에서는 새로운 결제 수단이 추가될 때마다 `PaymentService`를 수정해야 합니다. 정책이 늘어날수록 서비스는 점점 더 비대해집니다.

#### After

```java
public interface PaymentStrategy {
    void pay(int amount);
}

public class CreditCardStrategy implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("신용카드로 " + amount + "원 결제를 처리합니다.");
    }
}

public class BankTransferStrategy implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("계좌이체로 " + amount + "원 결제를 처리합니다.");
    }
}
```

```java
public class PaymentContext {
    public void processPayment(PaymentStrategy strategy, int amount) {
        System.out.println("결제 전략: " + strategy.getClass().getSimpleName());
        System.out.println("결제를 시작합니다...");
        strategy.pay(amount);
    }
}

PaymentContext context = new PaymentContext();
context.processPayment(new CreditCardStrategy(), 10000);
context.processPayment(new BankTransferStrategy(), 20000);
```

이제 컨텍스트는 구체 구현이 아니라 `PaymentStrategy` 인터페이스에만 의존합니다. 정책 추가는 새로운 구현 클래스를 만드는 일로 바뀝니다.

#### 핵심 포인트

- 바뀌는 행위를 객체로 분리합니다.
- 컨텍스트는 인터페이스에 의존합니다.
- 정책 추가가 기존 코드 수정으로 바로 이어지지 않게 만듭니다.

#### 장점

- 조건 분기를 줄일 수 있습니다.
- OCP에 가까운 구조를 만들 수 있습니다.
- 테스트에서 Mock 전략을 주입하기 쉽습니다.

#### 주의할 점

- 단순한 한 번짜리 분기까지 전략으로 만들면 과한 설계가 됩니다.
- 전략 수가 지나치게 많아지면 클래스 수가 빠르게 늘어날 수 있습니다.

#### 실무 연결 포인트

Spring에서는 DI를 통해 전략 패턴을 매우 자연스럽게 구현합니다. 예를 들어 결제 수단별 처리기, 알림 채널별 발송기, 파일 포맷별 파서, 외부 API 공급자별 클라이언트는 모두 전략 패턴으로 정리하기 좋은 대상입니다.


### ✏️ 직접 해보기

결제 수단(카드·현금·포인트)을 전략 인터페이스로 분리해 새 수단 추가가 기존 코드 수정 없이 되게 하라.

#### 한 줄 정리

전략 패턴은 **같은 역할을 하는 여러 행위를 분리하고, 상황에 따라 교체 가능하게 만드는 구조**입니다.

---

## 4.1 템플릿 메서드 패턴

**🎯 목표**: 템플릿 메서드로 불변 골격과 가변 단계를 분리한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
템플릿 메서드 패턴은 **알고리즘의 전체 흐름은 상위 클래스가 고정하고, 세부 단계는 하위 클래스가 구현하도록 위임하는 패턴**입니다. 공통 처리 순서를 유지하면서도 단계별 구현만 다르게 만들고 싶을 때 효과적입니다.
이 패턴은 프레임워크를 이해할 때 특히 중요합니다. Spring의 여러 템플릿 계열 API는 내부 실행 순서를 프레임워크가 잡고, 개발자는 필요한 부분만 채워 넣는 방식으로 동작합니다.

### 언제 사용하는가
- 전체 처리 순서는 같지만 일부 단계만 달라질 때
- 여러 클래스에서 같은 작업 순서를 반복하고 있을 때
- 하위 클래스가 전체 흐름을 임의로 깨지 못하게 하고 싶을 때

### Before
```java
public class CsvDataProcessor {
    public void process() {
        System.out.println("[공통] 데이터를 조회합니다.");
        String data = "id,name,role";
        String processedData = data.replace(",", ", ");
        System.out.println("[저장] " + processedData);
    }
}

public class TxtDataProcessor {
    public void process() {
        System.out.println("[공통] 데이터를 조회합니다.");
        String data = "id,name,role";
        String processedData = data.replace(",", " ");
        System.out.println("[저장] " + processedData);
    }
}
```
공통 로직이 중복되므로, 조회나 저장 방식이 바뀌면 모든 구현체를 함께 수정해야 합니다.

### After
```java
public abstract class AbstractDataProcessor {

    public final void process() {
        String data = loadData();
        String processedData = transformData(data);
        saveData(processedData);
    }

    private String loadData() {
        System.out.println("[공통] 데이터를 조회합니다.");
        return "id,name,role";
    }

    private void saveData(String data) {
        System.out.println("[저장] " + data);
    }

    protected abstract String transformData(String data);
}
```
```java
public class CsvDataProcessor extends AbstractDataProcessor {
    @Override
    protected String transformData(String data) {
        return data.replace(",", ", ");
    }
}

public class TxtDataProcessor extends AbstractDataProcessor {
    @Override
    protected String transformData(String data) {
        return data.replace(",", " ");
    }
}
```

### 핵심 포인트
- 상위 클래스가 처리 순서를 고정합니다.
- 하위 클래스는 바뀌는 단계만 구현합니다.
- `final` 메서드로 전체 흐름을 보호할 수 있습니다.

### 장점
- 공통 로직을 한곳에 모을 수 있습니다.
- 하위 클래스 구현이 단순해집니다.
- 처리 순서가 일관되게 유지됩니다.

### 주의할 점
- 상속 기반이라 계층이 깊어지면 복잡해질 수 있습니다.
- 변경 지점이 많다면 템플릿 메서드보다 전략 패턴이 더 적합할 수 있습니다.

### 실무 연결 포인트
`JdbcTemplate`, 테스트 템플릿, 공통 배치 처리 구조처럼 “흐름은 고정하되 세부 구현만 바꾸는” 지점에서 이 패턴을 자주 볼 수 있습니다.

### 한 줄 정리
템플릿 메서드 패턴은 **공통 흐름은 재사용하고, 세부 단계만 교체하고 싶을 때** 사용하는 패턴입니다.

### ✏️ 직접 해보기

음료 제조(끓이기→추출→붓기) 골격을 두고 커피·차로 추출 단계만 다르게 구현하라.

## 4.2 팩토리 메서드 패턴

**🎯 목표**: 팩토리 메서드로 객체 생성을 서브클래스에 위임한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
팩토리 메서드 패턴은 **객체 생성 책임을 별도의 생성 구조로 분리하는 패턴**입니다. 클라이언트는 구체 클래스를 직접 생성하지 않고, 생성 메서드를 통해 객체를 받습니다.
초중급 개발자가 이 패턴을 익혀야 하는 이유는, 실무 코드에서 생성과 사용이 한 클래스에 뒤섞이면 테스트와 확장이 급격히 어려워지기 때문입니다.

### 언제 사용하는가
- 생성 대상이 자주 바뀔 수 있을 때
- 클라이언트가 구체 클래스에 직접 의존하지 않게 하고 싶을 때
- 생성 규칙을 한곳에 모으고 싶을 때

### Before
```java
public class NotificationService {
    public void sendNotification(String type, String message) {
        Notifier notifier;
        if ("EMAIL".equalsIgnoreCase(type)) {
            notifier = new EmailNotifier();
        } else if ("SMS".equalsIgnoreCase(type)) {
            notifier = new SmsNotifier();
        } else {
            throw new IllegalArgumentException("알 수 없는 알림 타입입니다.");
        }
        notifier.send(message);
    }
}
```
생성과 사용이 한곳에 섞여 있어 새로운 타입이 추가될 때마다 기존 코드를 수정하게 됩니다.

### After
```java
public interface Notifier {
    void send(String message);
}

public interface NotifierFactory {
    Notifier createNotifier();
}
```
```java
public class EmailNotifierFactory implements NotifierFactory {
    @Override
    public Notifier createNotifier() {
        return new EmailNotifier();
    }
}

public class SmsNotifierFactory implements NotifierFactory {
    @Override
    public Notifier createNotifier() {
        return new SmsNotifier();
    }
}
```
```java
public class Client {
    public void send(NotifierFactory factory, String message) {
        Notifier notifier = factory.createNotifier();
        notifier.send(message);
    }
}

Client client = new Client();
client.send(new EmailNotifierFactory(), "주문이 완료되었습니다.");
client.send(new SmsNotifierFactory(), "인증번호는 1234입니다.");
```
```text
예상 결과
이메일로 주문이 완료되었습니다. 메시지를 전송합니다.
SMS로 인증번호는 1234입니다. 메시지를 전송합니다.
```

### 핵심 포인트
- 객체 생성 책임을 클라이언트 밖으로 분리합니다.
- 클라이언트는 생성 규칙보다 사용에 집중합니다.
- 생성 대상이 늘어나도 기존 사용 코드는 유지하기 쉽습니다.

### 장점
- 생성 로직을 한곳에 모을 수 있습니다.
- 구체 클래스 의존을 줄일 수 있습니다.
- 테스트 시 생성 전략을 바꾸기 쉽습니다.

### 주의할 점
- 단순 생성까지 모두 팩토리로 감싸면 과한 추상화가 됩니다.
- 생성 규칙이 거의 바뀌지 않는다면 이 패턴이 불필요할 수 있습니다.

### 실무 연결 포인트
Spring Bean 생성, 메시지 발송기 선택, 결제 클라이언트 생성, 파일 파서 선택처럼 “무엇을 생성할지”가 자주 달라지는 구간에서 유용합니다.

### 한 줄 정리
팩토리 메서드 패턴은 **객체를 직접 만들지 않고 생성 책임을 분리해 결합도를 낮추는 구조**입니다.

### ✏️ 직접 해보기

도형 종류 문자열을 받아 알맞은 `Shape` 객체를 만드는 팩토리를 작성하라.

## 4.3 싱글톤 패턴

**🎯 목표**: 싱글톤으로 인스턴스를 하나로 보장한다(스프링 빈과의 관계 포함).

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
싱글톤 패턴은 **클래스의 인스턴스를 하나만 유지하고, 그 인스턴스에 전역적으로 접근할 수 있게 만드는 패턴**입니다. 설정 정보, 캐시, 공용 리소스처럼 애플리케이션 전체에서 하나만 있어야 하는 객체를 다룰 때 자주 언급됩니다.
다만 Spring을 사용하는 개발자라면, 전통적인 싱글톤 구현보다 **컨테이너가 Bean을 싱글톤 스코프로 관리한다**는 점을 먼저 이해하는 편이 실무에 더 가깝습니다.

### 언제 사용하는가
- 애플리케이션 전역에서 하나만 있어야 하는 객체일 때
- 생성 비용이 크고 여러 번 만들 필요가 없을 때
- 상태를 중앙에서 관리해야 할 때

### Before
```java
public class AppConfig {
    private static final AppConfig INSTANCE = new AppConfig();

    private AppConfig() {
    }

    public static AppConfig getInstance() {
        return INSTANCE;
    }
}
```
원리는 단순하지만 전역 상태와 테스트 어려움이 함께 따라오기 쉽습니다.

### After
```java
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class SpringAppConfig {

    @PostConstruct
    public void init() {
        System.out.println("SpringAppConfig Bean 초기화 완료");
    }
}
```
```java
@SpringBootTest(classes = SpringAppConfig.class)
class SpringSingletonTest {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    void singletonBeanTest() {
        SpringAppConfig config1 = applicationContext.getBean(SpringAppConfig.class);
        SpringAppConfig config2 = applicationContext.getBean(SpringAppConfig.class);

        assertSame(config1, config2);
    }
}
```
```text
예상 결과
SpringAppConfig Bean 초기화 완료
테스트에서 config1과 config2는 같은 인스턴스로 확인됩니다.
```

### 핵심 포인트
- 전통적인 싱글톤은 클래스 스스로 인스턴스 수를 제한합니다.
- Spring은 컨테이너 수준에서 싱글톤을 관리합니다.
- 실무에서는 직접 싱글톤을 구현하기보다 Bean 스코프를 이해하는 편이 더 중요합니다.

### 장점
- 자원을 하나만 유지할 수 있습니다.
- 설정 관리나 공용 컴포넌트에 적합합니다.
- Spring에서는 직접 구현 부담 없이 사용할 수 있습니다.

### 주의할 점
- mutable 상태를 가진 싱글톤은 동시성 문제를 일으킬 수 있습니다.
- 전역 상태가 많아지면 테스트가 어려워집니다.
- 싱글톤 패턴과 Spring 싱글톤 Bean은 비슷하지만 관리 주체가 다릅니다.

### 실무 연결 포인트
`@Service`, `@Component`, `@Repository`로 등록한 대부분의 Bean은 기본적으로 싱글톤입니다. 그래서 실무에서는 “싱글톤 패턴을 직접 짜는 법”보다 “싱글톤 Bean에서 상태를 어떻게 다뤄야 하는가”가 더 중요합니다.

### 한 줄 정리
싱글톤 패턴은 **하나의 인스턴스를 공유하는 구조**이고, Spring은 이 개념을 컨테이너 차원에서 기본 제공한다고 이해하면 됩니다.

### ✏️ 직접 해보기

스레드 안전한 싱글톤을 만들고 여러 번 호출해도 같은 인스턴스인지 확인하라.

## 4.4 옵저버 패턴

**🎯 목표**: 옵저버로 상태 변화를 구독자에게 통지한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
옵저버 패턴은 **한 객체의 상태 변화가 여러 객체에 자동으로 전파되도록 만드는 패턴**입니다. 발행자와 구독자를 느슨하게 연결할 수 있어, 기능이 늘어나는 시스템에서 특히 유용합니다.
Spring에서는 `ApplicationEventPublisher`와 `@EventListener`를 통해 이 개념을 비교적 자연스럽게 구현할 수 있습니다.

### 언제 사용하는가
- 한 이벤트에 여러 후속 처리가 연결될 때
- 발행자와 처리 로직을 분리하고 싶을 때
- 기능 확장이 잦아 결합도를 낮춰야 할 때

### Before
```java
public class OrderService {
    private final InventoryService inventoryService = new InventoryService();
    private final ShippingService shippingService = new ShippingService();

    public void placeOrder(String productId, String address) {
        System.out.println("주문 완료");
        inventoryService.updateStock(productId);
        shippingService.prepareShipping(address);
    }
}
```
주문 후 처리 로직이 늘어날수록 `OrderService`는 점점 더 비대해지고 결합도도 높아집니다.

### After
```java
public class OrderPlacedEvent {
    private final String productId;
    private final String address;

    public OrderPlacedEvent(String productId, String address) {
        this.productId = productId;
        this.address = address;
    }

    public String getProductId() {
        return productId;
    }

    public String getAddress() {
        return address;
    }
}
```
```java
@Service
public class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    public OrderService(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    public void placeOrder(String productId, String address) {
        System.out.println("주문 완료");
        eventPublisher.publishEvent(new OrderPlacedEvent(productId, address));
    }
}
```
```java
@Service
public class InventoryService {
    @EventListener
    public void onOrderPlaced(OrderPlacedEvent event) {
        System.out.println("재고 차감: " + event.getProductId());
    }
}

@Service
public class ShippingService {
    @EventListener
    public void onOrderPlaced(OrderPlacedEvent event) {
        System.out.println("배송 준비: " + event.getAddress());
    }
}
```
```text
예상 결과
--- 주문 처리를 시작합니다 ---
주문이 성공적으로 완료되었습니다.
>> 'OrderPlacedEvent'를 발행합니다...
[재고] OrderPlacedEvent 수신 -> 상품 재고 차감
[배송] OrderPlacedEvent 수신 -> 배송 준비
[쿠폰] OrderPlacedEvent 수신 -> 후속 보상 처리
```
이 순서에서 중요한 점은 주문 서비스가 후속 작업을 직접 호출하지 않아도, 이벤트 발행 뒤에 여러 처리기가 느슨하게 반응할 수 있다는 점입니다.

### 핵심 포인트
- 발행자는 이벤트만 발행합니다.
- 후속 작업은 개별 리스너가 담당합니다.
- 새로운 후처리가 필요해도 발행자를 크게 수정하지 않습니다.

### 장점
- 결합도를 낮출 수 있습니다.
- 기능을 수평적으로 확장하기 쉽습니다.
- 도메인 이벤트 구조와 연결하기 좋습니다.

### 주의할 점
- 흐름이 여러 리스너로 분산되면 추적이 어려울 수 있습니다.
- 트랜잭션 경계와 실행 시점을 명확히 이해해야 합니다.
- 모든 후처리를 이벤트로 빼면 디버깅이 어려워질 수 있습니다.

### 실무 연결 포인트
주문 완료 후 알림, 재고 차감, 포인트 적립, 감사 로그 저장처럼 “한 사건 뒤에 여러 후속 작업이 이어지는” 상황에서 효과적입니다. 회원가입 이후 이메일 발송, SMS 발송, 추천인 처리, 슬랙 알림이 차례로 붙는 구조도 같은 문제이며, 이 경우에도 서비스 본문은 이벤트 발행에만 집중하고 후처리는 개별 리스너로 분리하는 편이 훨씬 안정적입니다.

### 한 줄 정리
옵저버 패턴은 **상태 변화를 여러 처리로 느슨하게 연결하는 구조**이며, Spring 이벤트 모델은 이를 구현하는 좋은 도구입니다.

### ✏️ 직접 해보기

발행자에 구독자 여러 개를 등록해, 발행 시 모두 통지받는지 확인하라.

## 4.5 프록시 패턴

**🎯 목표**: 프록시로 접근 제어·부가 기능을 구현한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
프록시 패턴은 **실제 객체에 직접 접근하지 않고, 그 앞에 대리 객체를 두어 접근을 제어하거나 부가 기능을 추가하는 패턴**입니다. 핵심은 비즈니스 로직을 건드리지 않고 공통 관심사를 분리하는 데 있습니다.
Spring AOP, 트랜잭션, 보안, 지연 로딩은 모두 이 프록시 개념과 연결됩니다. 그래서 프록시 패턴은 단순 예제가 아니라 Spring 내부 동작을 이해하는 기반 개념입니다.

### 언제 사용하는가
- 접근 제어가 필요할 때
- 로깅, 트랜잭션, 성능 측정 같은 공통 기능을 분리하고 싶을 때
- 실제 객체 생성을 지연하고 싶을 때

### Before
```java
public class EventService {
    public void processEvent(String eventName) {
        long startTime = System.currentTimeMillis();

        System.out.println("이벤트 처리 시작: " + eventName);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("이벤트 처리 완료.");

        long endTime = System.currentTimeMillis();
        System.out.println("실행 시간: " + (endTime - startTime) + "ms");
    }
}
```
공통 관심사인 실행 시간 측정이 비즈니스 코드 안에 직접 들어가 있습니다.

### After
```java
@Aspect
@Component
public class PerformanceAspect {

    @Around("execution(* com.example.service..*(..))")
    public Object measureExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();
        try {
            return joinPoint.proceed();
        } finally {
            long endTime = System.currentTimeMillis();
            System.out.println(joinPoint.getSignature().toShortString()
                    + " 실행 시간: " + (endTime - startTime) + "ms");
        }
    }
}
```
```java
@Service
public class EventService {
    public void processEvent(String eventName) {
        System.out.println("이벤트 처리 시작: " + eventName);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("이벤트 처리 완료.");
    }
}
```
```text
예상 결과
이벤트 처리 시작: order-created
이벤트 처리 완료.
EventService.processEvent(..) 실행 시간: 약 1000ms
```

### 핵심 포인트
- 실제 객체 앞에 대리 객체를 둡니다.
- 공통 관심사를 비즈니스 로직에서 분리합니다.
- 클라이언트는 실제 객체를 직접 다루지 않아도 됩니다.

### 장점
- 코드 중복을 줄일 수 있습니다.
- 트랜잭션, 로깅, 보안 같은 공통 기능을 모듈화할 수 있습니다.
- 핵심 로직이 더 단순해집니다.

### 주의할 점
- 내부 자기 호출에는 프록시가 적용되지 않는 경우가 있습니다.
- 모든 공통 기능을 AOP로 몰아넣으면 흐름 추적이 어려워질 수 있습니다.
- 패턴 자체보다 무엇을 분리할지 판단하는 것이 더 중요합니다.

### 실무 연결 포인트
`@Transactional`, `@Async`, 메서드 보안, Hibernate 지연 로딩 프록시는 모두 프록시 개념을 기반으로 이해할 수 있습니다.

### 한 줄 정리
프록시 패턴은 **실제 객체 앞에서 공통 기능을 대신 처리하게 하여 핵심 로직을 더 깨끗하게 유지하는 방식**입니다.

### ✏️ 직접 해보기

실제 객체 호출 전후로 로그를 남기는 프록시를 만들어 보라.

## 4.6 어댑터 패턴

**🎯 목표**: 어댑터로 호환되지 않는 인터페이스를 연결한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
어댑터 패턴은 **서로 호환되지 않는 인터페이스를 연결해 기존 시스템 안에서 함께 동작하게 만드는 패턴**입니다. 이미 잘 돌아가는 구조를 크게 건드리지 않고 새로운 라이브러리나 기존 코드를 붙일 때 자주 사용됩니다.
초중급 개발자에게 이 패턴이 중요한 이유는, 실무에서는 새 코드를 작성하는 일보다 기존 시스템과 외부 시스템을 연결하는 일이 훨씬 더 자주 일어나기 때문입니다.

### 언제 사용하는가
- 기존 인터페이스를 유지한 채 새로운 구현을 붙여야 할 때
- 외부 라이브러리의 API가 현재 시스템과 맞지 않을 때
- 기존 코드를 최대한 바꾸지 않고 확장하고 싶을 때

### Before
```java
interface DataProcessor {
    void processData();
}

class XmlDataProcessor implements DataProcessor {
    @Override
    public void processData() {
        System.out.println("XML 데이터를 처리합니다.");
    }
}

class NewJsonLibrary {
    public void parseAndRunJson(String jsonData) {
        System.out.println("JSON 데이터를 처리합니다: " + jsonData);
    }
}

public class DataService {
    public void process(Object processor, String data) {
        if (processor instanceof XmlDataProcessor) {
            ((XmlDataProcessor) processor).processData();
        } else if (processor instanceof NewJsonLibrary) {
            ((NewJsonLibrary) processor).parseAndRunJson(data);
        }
    }
}
```
클라이언트가 구체 타입을 모두 알아야 하므로 구조가 쉽게 경직됩니다.

### After
```java
public class JsonAdapter implements DataProcessor {
    private final NewJsonLibrary newJsonLibrary;
    private final String jsonData;

    public JsonAdapter(NewJsonLibrary newJsonLibrary, String jsonData) {
        this.newJsonLibrary = newJsonLibrary;
        this.jsonData = jsonData;
    }

    @Override
    public void processData() {
        newJsonLibrary.parseAndRunJson(jsonData);
    }
}
```
```java
public class DataService {
    public void process(DataProcessor processor) {
        processor.processData();
    }
}

DataService service = new DataService();
service.process(new JsonAdapter(new NewJsonLibrary(), "{\"name\":\"Kim\"}"));
```
```text
예상 결과
[어댑터 작동] 표준 processData() 호출을 -> newJsonLibrary.parseAndRunJson()으로 변환합니다.
새로운 라이브러리로 JSON 데이터를 처리합니다: {"name":"Kim"}
```

### 핵심 포인트
- 기존 표준 인터페이스는 그대로 유지합니다.
- 호환되지 않는 구현은 어댑터가 감쌉니다.
- 클라이언트는 변환 과정을 몰라도 됩니다.

### 장점
- 기존 코드를 크게 바꾸지 않아도 됩니다.
- 외부 라이브러리 연동이 쉬워집니다.
- 변화의 영향을 어댑터 안으로 가둘 수 있습니다.

### 주의할 점
- 단순 래퍼가 너무 많아지면 구조가 산만해질 수 있습니다.
- 인터페이스 변환이 정말 필요한지 먼저 확인해야 합니다.

### 실무 연결 포인트
Spring MVC의 `HandlerAdapter`, 외부 API 클라이언트를 감싸는 래퍼, 레거시 서비스 인터페이스 정리 같은 곳에서 자주 등장합니다.

### 한 줄 정리
어댑터 패턴은 **기존 인터페이스를 유지하면서 다른 구조를 무리 없이 끼워 넣는 방식**입니다.

### ✏️ 직접 해보기

다른 시그니처의 외부 클래스를 어댑터로 감싸 기존 방식으로 호출하게 하라.

## 4.7 파사드 패턴

**🎯 목표**: 파사드로 복잡한 하위 시스템을 단순한 창구로 감싼다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
파사드 패턴은 **복잡한 서브시스템을 감싸고, 바깥에는 단순한 진입점 하나만 제공하는 패턴**입니다. 사용자는 내부 구조를 모두 알 필요 없이, 파사드가 제공하는 메서드만 호출하면 됩니다.
실무에서는 시스템이 커질수록 여러 서비스를 정해진 순서로 묶어 호출해야 하는 상황이 많아집니다. 이때 파사드 패턴은 복잡한 절차를 읽기 쉬운 진입점으로 정리하는 데 큰 도움이 됩니다.

### 언제 사용하는가
- 여러 서비스를 항상 같은 순서로 묶어 호출할 때
- 클라이언트가 내부 구조를 너무 많이 알아야 할 때
- 복잡한 호출 절차를 단순한 진입점으로 감싸고 싶을 때

### Before
```java
public class OrderClient {
    private final InventoryService inventoryService = new InventoryService();
    private final PaymentService paymentService = new PaymentService();
    private final ShippingService shippingService = new ShippingService();
    private final NotificationService notificationService = new NotificationService();

    public void placeOrder() {
        inventoryService.checkStock("노트북");
        paymentService.processPayment("홍길동");
        shippingService.arrangeShipping("서울시 강남구");
        notificationService.sendNotification("홍길동");
    }
}
```
클라이언트가 서브시스템의 세부 절차를 모두 알아야 하므로 변경 영향이 커집니다.

### After
```java
public class OrderFacade {
    private final InventoryService inventoryService = new InventoryService();
    private final PaymentService paymentService = new PaymentService();
    private final ShippingService shippingService = new ShippingService();
    private final NotificationService notificationService = new NotificationService();

    public void placeOrder(String item, String user, String address) {
        inventoryService.checkStock(item);
        paymentService.processPayment(user);
        shippingService.arrangeShipping(address);
        notificationService.sendNotification(user);
    }
}
```
```java
public class OrderClient {
    private final OrderFacade orderFacade = new OrderFacade();

    public void placeOrder() {
        orderFacade.placeOrder("노트북", "홍길동", "서울시 강남구");
    }
}
```
```text
예상 결과
재고 확인: 노트북
결제 처리: 홍길동
배송 준비: 서울시 강남구
알림 발송: 홍길동
```
이 예제의 핵심은 클라이언트가 재고, 결제, 배송, 알림의 세부 순서를 모두 기억하지 않아도 된다는 점입니다.

### 핵심 포인트
- 복잡한 내부 절차를 한곳에 모읍니다.
- 클라이언트는 파사드만 알면 됩니다.
- 사용 흐름이 단순해지고 진입점이 명확해집니다.

### 장점
- 클라이언트 코드가 간결해집니다.
- 서브시스템 변경의 영향 범위를 줄일 수 있습니다.
- 서비스 조합 로직을 한곳에서 관리하기 좋습니다.

### 주의할 점
- 파사드가 너무 많은 책임을 가지면 또 다른 거대한 클래스가 될 수 있습니다.
- 모든 조합 로직을 무조건 파사드로 모으는 것은 좋은 설계가 아닙니다.

### 실무 연결 포인트
복합 서비스 조합, 외부 시스템 연계 흐름, 결제-재고-배송 묶음 처리처럼 “단일 진입점이 있으면 더 읽기 쉬워지는” 영역에서 효과적입니다.

### 한 줄 정리
파사드 패턴은 **복잡한 내부 구조를 감추고, 바깥에는 단순한 사용 지점을 제공하는 구조**입니다.

### ✏️ 직접 해보기

주문·결제·배송 여러 단계 호출을 파사드 한 메서드로 묶어 보라.

## 4.9 전략 패턴 실전문제

**🎯 목표**: 패턴 지식을 실전 설계 문제로 적용한다.

<!-- 2026-06-29 라이브 Notion에서 수집 (4월 ingest 이후 추가분) -->

### 개요
이 문서는 `전략 패턴` 본문을 읽은 뒤 바로 이어서 푸는 실전문제 모음입니다. 개념을 설명으로 끝내지 않고, 실제 설계 판단 문제로 연결하는 데 목적이 있습니다. 전략 패턴의 핵심은 바뀌는 행위를 별도의 객체로 분리하고, 컨텍스트는 그 구현이 아니라 공통 인터페이스에 의존하도록 만드는 데 있습니다.

### 어떻게 활용하면 좋은가
- 먼저 각 시나리오에서 무엇이 전략인지 스스로 찾아봅니다.
- `if-else` 구조를 전략 패턴으로 어떻게 바꿀지 설명해봅니다.
- Spring DI와 연결했을 때 어떤 형태로 확장되는지도 함께 생각해봅니다.

### 문제 구성

#### 1. 배송 서비스
- 배송 방식이 여러 개일 때 전략과 컨텍스트를 구분하는 문제

#### 2. 소셜 로그인
- 로그인 수단별 인증 로직을 전략으로 분리하는 문제

#### 3. 파일 압축
- 압축 방식 교체와 예외 처리 기준을 생각하는 문제

#### 4. 알림 서비스
- 푸시, SMS, 이메일 발송 방식을 분리하는 문제

### 문제 1. 배송 서비스의 전략 찾기
```text
온라인 쇼핑몰에서 일반 배송, 당일 배송, 새벽 배송 중 하나를 선택할 수 있다.
배송 서비스는 선택된 방식에 따라 같은 요청을 서로 다른 방식으로 처리한다.
```
다음 항목을 구분해보세요.
- 전략(Strategy): 무엇이 바뀌는가
- 컨텍스트(Context): 어떤 객체가 전략을 사용해 작업을 수행하는가
- 클라이언트(Client): 누가 전략을 선택하는가

### 문제 2. 코드 빈칸 완성
```java
public interface DeliveryStrategy {
    void deliver(String address);
}

public class DeliveryService {
    private DeliveryStrategy strategy;

    public void setStrategy(DeliveryStrategy strategy) {
        this.strategy = _______;
    }

    public void execute(String address) {
        if (_______ == null) {
            throw new IllegalStateException("배송 방식이 선택되지 않았습니다.");
        }
        strategy.deliver(address);
    }
}
```
- 빈칸 두 곳을 채우세요.
- 컨텍스트가 구체 구현을 직접 알지 않아도 되는 이유를 설명하세요.

### 문제 3. 소셜 로그인 리팩터링
```java
public void login(String provider, String token) {
    if ("google".equals(provider)) {
        // 구글 로그인
    } else if ("kakao".equals(provider)) {
        // 카카오 로그인
    } else if ("naver".equals(provider)) {
        // 네이버 로그인
    }
}
```
위 코드의 문제점을 두 가지 적어보세요.
- 새로운 로그인 수단이 추가될 때 어떤 문제가 생기는가
- 이 메서드가 너무 많은 책임을 갖는 이유는 무엇인가

### 문제 4. Spring에서의 전략 선택
```java
@Service
public class NotificationService {
    private final Map<String, NotificationStrategy> strategies;

    public NotificationService(Map<String, NotificationStrategy> strategies) {
        this.strategies = strategies;
    }
}
```
다음 질문에 답해보세요.
- `List<NotificationStrategy>` 대신 `Map<String, NotificationStrategy>`를 쓸 때의 장점은 무엇인가
- 런타임에 전략을 선택해야 할 때 어떤 구조가 더 자연스러운가

### 문제 5. 설계 판단
다음 중 전략 패턴을 적용할 가치가 높은 상황을 고르세요.
- 결제 수단별 처리 방식이 자주 추가되는 결제 서비스
- 한 번만 쓰이는 단순한 `if` 분기 하나
- 외부 API 공급자별 호출 방식이 다른 연동 서비스
- 할인 정책이 계속 추가되는 주문 서비스
그리고 왜 그런지 한 문장으로 설명해보세요.

### 풀이 전 체크 포인트
- 전략과 컨텍스트를 정확히 분리했는가
- 새로운 전략 추가가 기존 코드 수정 없이 가능한가
- 인터페이스가 실제로 공통 계약 역할을 하는가
- Spring DI와 연결했을 때도 구조가 유지되는가

### 예상 답안 방향
이 문서는 문제집이지만, 독자가 전혀 감 없이 멈추지 않도록 최소한의 판단 방향은 잡아 두는 편이 좋습니다.
- 배송 서비스 문제: 바뀌는 것은 배송 방식이고, 배송 서비스 본체는 컨텍스트입니다.
- 소셜 로그인 문제: `provider` 분기가 늘어날수록 로그인 메서드가 인증 수단 선택 책임까지 떠안게 됩니다.
- Spring 전략 선택 문제: 런타임에 이름이나 키로 전략을 고를 때는 `Map<String, Strategy>`가 더 자연스럽습니다.
- 설계 판단 문제: 자주 늘어나는 정책, 공급자, 결제/알림/압축 방식은 전략 패턴 후보입니다.

### 정리
전략 패턴 문제는 정답 클래스 이름을 맞히는 것이 목표가 아닙니다. 어떤 코드가 바뀌는 부분인지, 그 바뀌는 부분을 어떻게 객체로 분리할 수 있는지 판단하는 훈련이 핵심입니다.

### 한 줄 정리
전략 패턴 연습 문제의 핵심은 분기문을 줄이는 것이 아니라, 바뀌는 행위를 독립된 객체로 분리하는 판단력을 기르는 데 있습니다.
