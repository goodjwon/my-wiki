---
title: "Effective Java 실전 강의 — 2장"
type: source
tags: [book, effective-java, bloch, lecture]
sources: [effective_java/이펙티브 자바 실전 강의 교재 2장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 이펙티브 자바 실전 강의 교재

## 2장 — 객체 생성과 파괴

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 설명 → 비유 → 현업 예제 → 따라하기(실습) → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x, IntelliJ / VS Code

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

이 장을 끝내면 수강생은 다음을 할 수 있습니다.

- 객체를 **언제, 어떻게 생성**하는 것이 좋은지 상황별로 판단한다.
- `new`를 무심코 쓰던 습관을, **정적 팩터리·빌더·의존성 주입**으로 의식적으로 교체한다.
- "객체가 생성되고 사라지는 한살이(lifecycle)"를 이해하고, **메모리 누수와 자원 누수**를 예방한다.

### 0.2 큰 그림 — 객체의 한살이로 2장 읽기

2장은 흩어진 9개 규칙처럼 보이지만, **객체의 생애주기**라는 한 줄에 꿰면 외울 필요가 없어집니다.

```
[ 어떻게 만들까? ]              [ 얼마나 만들까? ]           [ 어떻게 치울까? ]
 아이템 1  정적 팩터리           아이템 6  불필요한 생성 회피     아이템 7  참조 해제
 아이템 2  빌더                  아이템 3  싱글턴               아이템 8  finalizer 회피
 아이템 4  인스턴스화 방지        아이템 5  의존성 주입           아이템 9  try-with-resources
```

> **비유 — 객체는 "주방의 그릇"입니다.**
> 
> - 만들 때(1·2·4): 그릇을 어떻게 빚을지 (직접 손으로? 틀로? 주문서로?)
> - 얼마나(3·5·6): 그릇을 매번 새로 빚을지, 하나를 돌려쓸지, 누가 채워줄지
> - 치울 때(7·8·9): 다 쓴 그릇을 싱크대에 쌓아두면 주방이 마비됩니다(메모리/자원 누수).

### 0.3 현업에서 왜 중요한가

여러분이 매일 쓰는 Spring은 이미 2장 규칙으로 만들어져 있습니다.

- `@Bean`, `@Component` → **싱글턴(아이템 3)**
- 생성자 주입 `@Autowired` → **의존성 주입(아이템 5)**
- `List.of(...)`, `LocalDate.now()` → **정적 팩터리(아이템 1)**
- `try (var conn = dataSource.getConnection())` → **try-with-resources(아이템 9)**

즉 이 장은 "새로운 규칙"이 아니라, **이미 쓰고 있는 코드의 원리를 언어화**하는 과정입니다.

---

## 아이템 1. 생성자 대신 정적 팩터리 메서드를 고려하라

### 한 줄 요약

`new Order(...)` 대신, **이름이 있는 정적 메서드** `Order.of(...)`, `Order.draft()` 로 객체를 만드는 선택지를 항상 검토하라.

### 비유 — "카페 주문 창구"

- **생성자**: 손님이 직접 주방에 들어가 "에스프레소 30ml + 물 200ml + 얼음 5개"를 조합 → 매번 헷갈림.
- **정적 팩터리**: 창구에서 `"아이스 아메리카노"` 라고 **이름**으로 주문 → 의도가 명확하고, 내부 레시피는 가게가 알아서 처리.

### 문제: 생성자만 쓸 때

```java
// 인자 순서·의미를 호출부가 외워야 함. true가 뭐였더라?
Contract c1 = new Contract(LocalDate.now(), true, false);
Contract c2 = new Contract(LocalDate.now(), false, true);
```

생성자는 **이름이 같아서** 의도를 드러낼 수 없습니다. `(true, false)`가 무슨 뜻인지 호출부만 봐서는 모릅니다.

### 해법: 이름 있는 정적 팩터리 메서드

```java
public class Contract {
    private final LocalDate startDate;
    private final ContractStatus status;

    private Contract(LocalDate startDate, ContractStatus status) {
        this.startDate = startDate;
        this.status = status;
    }

    // 이름으로 의도를 표현한다.
    public static Contract draft() {
        return new Contract(LocalDate.now(), ContractStatus.DRAFT);
    }

    public static Contract active(LocalDate startDate) {
        return new Contract(startDate, ContractStatus.ACTIVE);
    }
}
```

```java
Contract draft  = Contract.draft();          // 의도가 명확
Contract active = Contract.active(today);     // 가독성 ↑
```

### 정적 팩터리의 5가지 장점 (요약)

1. **이름을 가질 수 있다** — `Contract.draft()` vs `new Contract(...)`.
2. **호출마다 새 인스턴스를 만들 필요가 없다** — 캐싱·재사용 가능(아이템 6과 연결). 예: `Boolean.valueOf(true)`.
3. **반환 타입의 하위 타입을 반환할 수 있다** — 구현을 숨기고 인터페이스를 노출. 예: `List.of()` → 내부 구현은 감춰짐.
4. **입력에 따라 다른 클래스를 반환할 수 있다** — `EnumSet.of()`는 원소 수에 따라 `RegularEnumSet`/`JumboEnumSet`을 골라 반환.
5. **반환 객체의 클래스가 작성 시점에 없어도 된다** — JDBC `DriverManager.getConnection()` 같은 서비스 제공자 프레임워크의 기반.

### 단점

- private 생성자만 두면 **상속이 불가능**해진다(아이템 18 컴포지션 권장과는 오히려 궁합이 좋음).
- 정적 팩터리는 일반 메서드와 구분이 어렵다 → **명명 규칙**으로 보완.

### 명명 규칙 (현업 컨벤션)

|이름|쓰임|예시|
|---|---|---|
|`from`|매개변수 1개 → 타입 변환|`Date.from(instant)`|
|`of`|여러 매개변수 → 집계|`List.of(a, b, c)`|
|`valueOf`|from/of의 더 자세한 버전|`BigInteger.valueOf(5)`|
|`instance` / `getInstance`|인스턴스 반환(같다는 보장 없음)|`Calendar.getInstance()`|
|`create` / `newInstance`|매번 새 인스턴스 보장|`Array.newInstance(...)`|

### 현업 예제 — Spring/JDK에 이미 가득합니다

```java
// JDK
List<String> roles = List.of("ADMIN", "USER");   // 정적 팩터리
LocalDate today = LocalDate.now();               // 정적 팩터리
Optional<User> u = Optional.ofNullable(found);   // 정적 팩터리

// Spring
ResponseEntity<?> res = ResponseEntity.ok(body);          // 정적 팩터리
ResponseEntity<?> nf  = ResponseEntity.notFound().build();
```

### 따라하기 (실습 1-A)

1. `User` 클래스를 만들고 생성자를 `private`으로 막는다.
2. `User.of(email, name)` 와 `User.guest()` 두 개의 정적 팩터리를 만든다.
3. `guest()`는 호출할 때마다 새 객체를 만들지 말고 **하나를 캐싱**해서 반환하도록 바꿔본다(아이템 6 예고편).

```java
public class User {
    private static final User GUEST = new User("guest@local", "게스트");
    private final String email;
    private final String name;

    private User(String email, String name) {
        this.email = email;
        this.name = name;
    }
    public static User of(String email, String name) { return new User(email, name); }
    public static User guest() { return GUEST; }   // 매번 new 하지 않음
}
```

### 체크리스트

- [ ] 생성자 인자가 `boolean`/같은 타입이 여러 개라 헷갈리는가? → 정적 팩터리로 이름 부여
- [ ] 같은 시그니처의 생성자가 2개 이상 필요한가? → 정적 팩터리로 분리
- [ ] 인스턴스를 재사용하고 싶은가? → 정적 팩터리 + 캐싱

### 퀴즈

<details><summary>Q1. <code>new Boolean(true)</code> 보다 <code>Boolean.valueOf(true)</code>가 권장되는 이유는?</summary>

`valueOf`는 미리 만들어 둔 `TRUE`/`FALSE` 인스턴스를 **재사용**하므로 불필요한 객체 생성을 피합니다(장점 2 + 아이템 6). `new`는 항상 새 객체를 만듭니다.

</details> <details><summary>Q2. 정적 팩터리만 제공하고 public/protected 생성자가 없는 클래스의 가장 큰 제약은?</summary>

**상속이 불가능**합니다. 다만 이는 상속보다 컴포지션을 권하는 아이템 18 관점에서는 단점이 아닐 수 있습니다.

</details>

---

## 아이템 2. 생성자에 매개변수가 많다면 빌더를 고려하라

### 한 줄 요약

선택적 매개변수가 4개 이상이면 **점층적 생성자(telescoping)**도 **자바빈즈(setter)**도 답이 아니다. **빌더**를 써라.

### 비유 — "햄버거 주문서"

- **점층적 생성자**: "패티2, 양상추O, 피클X, 양파O, 소스2종..."을 순서대로 한 줄에 말하기 → 틀리기 쉬움.
- **자바빈즈(setter)**: 일단 빈 햄버거를 받고 하나씩 끼워넣기 → **중간 상태가 미완성**이라 불안정(불변 불가).
- **빌더**: 체크박스가 있는 **주문서**에 원하는 것만 표시 → 가독성 + 완성 시점이 명확.

### 문제 1: 점층적 생성자 패턴

```java
// 안 쓰는 값에도 0/null을 채워야 하고, 인자 순서를 외워야 한다.
NutritionFacts cola = new NutritionFacts(240, 8, 100, 0, 35, 27);
```

### 문제 2: 자바빈즈 패턴

```java
NutritionFacts cola = new NutritionFacts();
cola.setServingSize(240);   // 이 사이에 다른 스레드가 미완성 객체를 보면? → 불변성 깨짐
cola.setServings(8);
```

### 해법: 빌더 패턴

```java
public class NutritionFacts {
    private final int servingSize;   // 필수
    private final int servings;      // 필수
    private final int calories;      // 선택
    private final int sodium;        // 선택

    public static class Builder {
        private final int servingSize;
        private final int servings;
        private int calories = 0;
        private int sodium = 0;

        public Builder(int servingSize, int servings) {   // 필수값은 생성자로
            this.servingSize = servingSize;
            this.servings = servings;
        }
        public Builder calories(int v) { this.calories = v; return this; }   // 선택값은 메서드 체이닝
        public Builder sodium(int v)   { this.sodium = v;   return this; }
        public NutritionFacts build()  { return new NutritionFacts(this); }
    }

    private NutritionFacts(Builder b) {
        this.servingSize = b.servingSize;
        this.servings    = b.servings;
        this.calories    = b.calories;
        this.sodium      = b.sodium;
    }
}
```

```java
NutritionFacts cola = new NutritionFacts.Builder(240, 8)
        .calories(100)
        .sodium(35)
        .build();   // 불변 + 가독성
```

### 현업 예제 — 도메인 모델링 관점

공공 계약관리에서 `계약(Contract)`은 필수 필드(계약번호, 발주기관)와 선택 필드(특약사항, 첨부, 담당자메모)가 섞입니다. **필수는 빌더 생성자, 선택은 체이닝**으로 분리하면 "유효하지 않은 계약은 애초에 만들 수 없는" 도메인 모델이 됩니다.

```java
Contract c = Contract.builder("2026-수의-0012", "○○광역시")  // 필수
        .specialTerms("지체상금 1일당 0.075%")               // 선택
        .managerNote("ISMS-P 검토 대기")                    // 선택
        .build();
```

> **실무 팁**: 직접 빌더를 손으로 쓰기 번거로우면 **Lombok `@Builder`**를 씁니다. 단, 강의에서는 **원리를 먼저 손으로 한 번 짜본 뒤** Lombok으로 넘어가야 "마법"이 아니라 "단축"으로 이해됩니다.

```java
@Builder
public class Contract {
    private final String contractNo;
    private final String agency;
    private final String specialTerms;
}
```

### 따라하기 (실습 2-A)

1. 필드 6개짜리 `Member`를 점층적 생성자로 만들어 보고, 호출부의 불편함을 체감한다.
2. 같은 `Member`를 빌더로 리팩터링한다.
3. `build()`에서 **유효성 검증**(예: email 형식, 필수 누락)을 넣어 잘못된 객체 생성을 차단한다(아이템 49 예고편).

```java
public Member build() {
    if (email == null || !email.contains("@"))
        throw new IllegalStateException("이메일 형식 오류");
    return new Member(this);
}
```

### 함정/주의

- 빌더는 객체를 하나 더 만든다 → **성능이 극도로 중요한 핫패스**에서는 비용 고려.
- 매개변수가 2~3개로 적고 잘 안 늘어날 거면 빌더는 **과설계**. 정적 팩터리로 충분.

### 체크리스트

- [ ] 선택적 매개변수가 4개 이상인가? → 빌더
- [ ] 객체를 불변으로 만들고 싶은가? → 빌더(자바빈즈 금지)
- [ ] 계층 구조 객체인가? → 빌더는 상속과도 잘 어울림(self-type 트릭)

### 퀴즈

<details><summary>Q. 자바빈즈 패턴(setter)이 불변 객체에 부적합한 이유 두 가지는?</summary>

①객체 생성이 여러 호출에 걸쳐 일어나 **중간에 일관성이 깨진 상태**가 노출될 수 있다. ②모든 필드에 setter가 열려 있어 **불변(final)으로 만들 수 없다**.

</details>

---

## 아이템 3. private 생성자나 열거 타입으로 싱글턴임을 보증하라

### 한 줄 요약

인스턴스가 단 하나여야 한다면, **enum 싱글턴**이 가장 안전하다.

### 비유 — "회사의 대표 전화번호"

대표번호는 회사에 **딱 하나**여야 합니다. 직원마다 다른 대표번호를 만들면 혼란이 옵니다. 싱글턴은 "이 객체는 시스템에 하나만 존재함"을 강제하는 장치입니다.

### 세 가지 구현법

```java
// 1) public static final 필드
public class Service {
    public static final Service INSTANCE = new Service();
    private Service() {}
}

// 2) 정적 팩터리 (유연함: 나중에 싱글턴을 깰 수 있음)
public class Service {
    private static final Service INSTANCE = new Service();
    private Service() {}
    public static Service getInstance() { return INSTANCE; }
}

// 3) 열거 타입 — 권장 (직렬화·리플렉션 공격에도 안전)
public enum Service {
    INSTANCE;
    public void doWork() { /* ... */ }
}
```

### 왜 enum이 가장 안전한가

- 리플렉션으로 private 생성자를 강제 호출해 두 번째 인스턴스를 만드는 공격을 **원천 차단**.
- 직렬화/역직렬화 시 새 인스턴스가 생기는 문제를 **자동 방지**(아이템 89와 연결).

### 현업 예제 — Spring을 쓰면 직접 싱글턴을 거의 안 짠다

실무에서 싱글턴이 필요하면 **직접 구현하지 말고 Spring 빈으로** 등록하는 것이 정석입니다. `@Component`/`@Service`는 기본 스코프가 싱글턴입니다.

```java
@Service   // 컨테이너가 단 하나의 인스턴스를 관리한다
public class ContractNumberGenerator {
    public String next() { /* 동시성 고려 필요 */ return ...; }
}
```

> **주의**: "스프링 싱글턴"은 **JVM 전역 싱글턴이 아니라 컨테이너 단위**입니다. 또한 싱글턴 빈에 **가변 상태**를 두면 동시성 버그가 납니다(아이템 78). 상태는 스레드 안전하게 다루거나 무상태로 설계하세요.

### 따라하기 (실습 3-A)

1. `Logger`를 enum 싱글턴으로 구현한다.
2. 같은 `Logger`를 두 곳에서 가져와 `==`로 동일성을 확인한다.
3. 직렬화→역직렬화 후에도 같은 인스턴스인지 확인한다(enum이 자동으로 보장).

### 함정/주의

- 싱글턴은 **테스트하기 어렵다**(전역 상태). 가능하면 싱글턴보다 **DI(아이템 5)**로 주입받는 설계를 우선.

### 퀴즈

<details><summary>Q. enum 싱글턴이 막아주는 두 가지 우회 공격은?</summary>

**리플렉션을 통한 생성자 강제 호출**과 **직렬화에 의한 인스턴스 중복 생성**.

</details>

---

## 아이템 4. 인스턴스화를 막으려거든 private 생성자를 사용하라

### 한 줄 요약

정적 메서드만 모은 **유틸리티 클래스**는 `private` 생성자로 인스턴스화를 막아라.

### 비유 — "공구함"

공구함(`Math`, `Collections`)은 안에 든 **도구**를 쓰려고 있지, 공구함 자체를 복제해서 들고 다니진 않습니다.

### 문제

생성자를 명시하지 않으면 컴파일러가 **기본 생성자(public)**를 자동으로 만들어, 의도치 않게 `new StringUtils()`가 가능해집니다.

### 해법

```java
public class StringUtils {
    private StringUtils() {                       // 인스턴스화 금지
        throw new AssertionError("인스턴스화 금지");  // 내부 리플렉션 호출도 방어
    }
    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
```

### 현업 예제

- JDK: `java.lang.Math`, `java.util.Collections`, `java.util.Arrays`
- Spring: `org.springframework.util.StringUtils`, `Assert`
- 우리 코드: `DateUtils`, `MaskingUtils`(개인정보 마스킹) 등

> **실무 의견**: 최근 코드베이스는 유틸 클래스 남발보다 **도메인 객체의 메서드**나 **Spring 빈**으로 옮기는 추세입니다. 그래도 순수 함수 모음(포맷/검증)은 유틸 클래스가 여전히 적절합니다.

### 따라하기 (실습 4-A)

1. `MaskingUtils.maskEmail("user@domain.com")` → `u***@domain.com` 구현.
2. 생성자를 막고, 리플렉션으로 강제 호출 시 `AssertionError`가 나는지 테스트.

### 퀴즈

<details><summary>Q. 추상 클래스로 만들면 인스턴스화를 막을 수 있을까?</summary>

**불가능**합니다. 하위 클래스를 만들어 인스턴스화할 수 있기 때문입니다. 반드시 `private` 생성자를 써야 합니다.

</details>

---

## 아이템 5. 자원을 직접 명시하지 말고 의존 객체 주입을 사용하라 ⭐현업 최핵심

### 한 줄 요약

클래스가 다른 자원에 의존한다면, 그 자원을 **내부에서 직접 만들지 말고 생성자로 주입**받아라. (= Spring DI의 본질)

### 비유 — "식당과 식자재"

좋은 식당은 식자재를 **직접 농사짓지 않고 납품**받습니다. 그래야 거래처(자원)를 바꾸기 쉽고, 테스트(맛 시연)할 때 원하는 재료를 끼워 넣을 수 있습니다.

### 문제: 자원을 직접 만들거나 고정

```java
public class SpellChecker {
    private final Dictionary dict = new KoreanDictionary();   // ❌ 사전이 고정됨
    // 영어 사전, 테스트용 가짜 사전으로 바꿀 수 없다 → 유연성·테스트성 ↓
}
```

싱글턴/정적 유틸로 자원을 박아두면 **교체가 불가능**하고 **단위 테스트가 거의 불가능**해집니다.

### 해법: 의존성 주입

```java
public class SpellChecker {
    private final Dictionary dict;

    public SpellChecker(Dictionary dict) {     // ✅ 외부에서 주입
        this.dict = Objects.requireNonNull(dict);
    }
}
```

```java
SpellChecker ko = new SpellChecker(new KoreanDictionary());
SpellChecker en = new SpellChecker(new EnglishDictionary());
SpellChecker test = new SpellChecker(new FakeDictionary());  // 테스트용 주입
```

### 현업 예제 — 이게 바로 Spring 생성자 주입

```java
@Service
public class ContractService {
    private final ContractRepository repository;
    private final NotificationClient notifier;

    // 생성자 주입: @Autowired 생략 가능(생성자 1개일 때)
    public ContractService(ContractRepository repository, NotificationClient notifier) {
        this.repository = repository;
        this.notifier = notifier;
    }
}
```

테스트에서는 가짜(Mock) 구현을 주입합니다.

```java
@Test
void 계약_생성시_알림이_발송된다() {
    NotificationClient fakeNotifier = mock(NotificationClient.class);
    ContractService sut = new ContractService(new InMemoryContractRepository(), fakeNotifier);
    // given-when-then ...
    verify(fakeNotifier).send(any());
}
```

> **현업 규칙**: 필드 주입(`@Autowired` 필드)보다 **생성자 주입**을 쓰세요. ①`final`로 불변 보장 ②테스트에서 new로 주입 가능 ③순환 의존성을 컴파일/기동 시점에 발견.

### 변형 — 팩터리 주입 (Supplier)

자원을 "그때그때" 생성해야 하면, 자원 자체가 아니라 **자원을 만드는 팩터리**를 주입합니다.

```java
public Tile create(Supplier<? extends Tile> tileFactory) {
    return tileFactory.get();
}
```

### 따라하기 (실습 5-A)

1. `DiscountPolicy` 인터페이스와 두 구현(`RateDiscount`, `FixedDiscount`)을 만든다.
2. `OrderService`가 `DiscountPolicy`를 **생성자로 주입**받게 한다.
3. 테스트에서 정책을 바꿔 끼우며 결과가 달라지는지 검증한다.
4. (심화) 같은 코드를 Spring 빈으로 등록하고 `@Primary`/`@Qualifier`로 구현을 골라본다.

### 체크리스트

- [ ] 클래스 내부에 `new XxxRepository()` / `new XxxClient()`가 있는가? → 주입으로 빼라
- [ ] 단위 테스트에서 가짜 구현을 넣기 어려운가? → 의존성이 박혀 있다는 신호
- [ ] 필드 주입을 쓰고 있는가? → 생성자 주입으로 교체

### 퀴즈

<details><summary>Q. 필드 주입 대신 생성자 주입을 권장하는 이유 세 가지는?</summary>

①의존성을 `final` 불변으로 만들 수 있다. ②프레임워크 없이 `new`로 객체를 만들어 **단위 테스트**가 쉽다. ③필수 의존성 누락/순환 참조를 **객체 생성 시점에** 발견한다.

</details>

---

## 아이템 6. 불필요한 객체 생성을 피하라

### 한 줄 요약

같은 기능의 객체를 매번 새로 만들지 말고, **하나를 재사용**하라. 단, **성급한 최적화는 금물**.

### 비유 — "텀블러 vs 일회용 컵"

물 마실 때마다 종이컵을 새로 뜯으면 쓰레기(GC 부담)가 쌓입니다. 변하지 않는 것은 텀블러처럼 **재사용**합니다.

### 대표 함정 1: 정규식 Pattern을 매번 컴파일

```java
// ❌ 호출마다 Pattern을 새로 컴파일 (비싼 작업)
static boolean isEmail(String s) {
    return s.matches("^[\\w.]+@[\\w.]+$");
}

// ✅ Pattern을 한 번만 컴파일해 재사용
private static final Pattern EMAIL =
        Pattern.compile("^[\\w.]+@[\\w.]+$");
static boolean isEmail(String s) {
    return EMAIL.matcher(s).matches();
}
```

### 대표 함정 2: 오토박싱

```java
// ❌ Long 객체가 2^31번 생성됨 (끔찍하게 느림)
Long sum = 0L;
for (long i = 0; i <= Integer.MAX_VALUE; i++) sum += i;

// ✅ 기본 타입 사용
long sum = 0L;
```

### 현업 예제

- `DateTimeFormatter`, `ObjectMapper`(Jackson), `Pattern`은 **스레드 안전하므로 상수로 재사용**합니다. 핸들러마다 `new ObjectMapper()`를 만드는 것은 흔한 성능 실수입니다.

```java
private static final DateTimeFormatter YMD =
        DateTimeFormatter.ofPattern("yyyy-MM-dd");
```

### 함정/주의 (반대 방향도 위험)

- "객체 생성은 비싸니 무조건 재사용"은 **틀린 격언**입니다. 작은 객체 생성/GC는 매우 저렴합니다.
- 방어적 복사(아이템 50)가 필요한 곳에서 재사용하면 **버그**가 생깁니다. _불필요한 객체를 만들지 말라 ≠ 필요한 복사를 하지 말라._

### 따라하기 (실습 6-A)

1. 이메일 검증을 `String.matches`로 짠 뒤, 100만 번 호출 시간을 측정한다.
2. `Pattern` 상수 버전으로 바꿔 다시 측정하고 차이를 비교한다.

### 퀴즈

<details><summary>Q. 다음 코드의 문제는? <code>String s = new String("hi");</code></summary>

리터럴 `"hi"`가 이미 String 객체인데 `new`로 **불필요하게 하나 더** 만듭니다. `String s = "hi";`로 충분하며, 문자열 풀의 인스턴스를 재사용합니다.

</details>

---

## 아이템 7. 다 쓴 객체 참조를 해제하라

### 한 줄 요약

GC가 있어도 **메모리 누수**는 난다. "다 쓴 참조"를 잡고 있으면 그 객체는 영원히 못 치운다.

### 비유 — "다 읽은 책을 책장에 계속 꽂아두기"

다 읽은 책(객체)을 계속 책장(컬렉션/캐시)에 꽂아두면, 새 책 둘 자리가 없어집니다. GC는 "누가 아직 들고 있는 책"은 버리지 못합니다.

### 대표 함정: 직접 구현한 스택/캐시

```java
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    Object result = elements[--size];
    elements[size] = null;   // ✅ 다 쓴 참조 해제 (이 줄이 없으면 누수)
    return result;
}
```

배열이 size 밖의 원소를 계속 참조하면, 꺼낸 객체가 GC되지 않습니다.

### 메모리 누수의 3대 출처

1. **자기 메모리를 직접 관리하는 클래스**(스택, 풀, 캐시) — null 처리 필요.
2. **캐시** — 다 쓴 엔트리가 안 빠짐 → `WeakHashMap`이나 만료 정책 사용.
3. **리스너/콜백** — 등록만 하고 해제 안 함 → 약한 참조로 저장하거나 명시적 해제.

### 현업 예제 — 실제로 자주 터지는 곳

- `static` 컬렉션에 무한정 add (예: 요청 로그를 static List에 누적)
- `ThreadLocal` 사용 후 `remove()` 누락 → **톰캣 스레드풀에서 심각한 누수**(스레드가 재사용되므로)

```java
try {
    contextHolder.set(userContext);
    // ... 요청 처리 ...
} finally {
    contextHolder.remove();   // ✅ 반드시 해제
}
```

### 함정/주의

- **모든 객체에 null을 대입하라는 뜻이 아님.** 변수의 **유효 범위(scope)를 최소화**(아이템 57)하면 대부분 자연히 해결됩니다. null 처리는 직접 메모리를 관리하는 **예외적인 경우**에만.

### 따라하기 (실습 7-A)

1. null 해제 없는 스택을 만들고, 큰 객체를 push/pop 반복하며 힙을 모니터링(VisualVM/IntelliJ Profiler).
2. `elements[size] = null;`을 추가한 뒤 힙 사용량을 비교한다.

### 퀴즈

<details><summary>Q. ThreadLocal을 톰캣 같은 WAS에서 쓸 때 finally에서 remove를 꼭 해야 하는 이유는?</summary>

WAS는 스레드를 **풀로 재사용**합니다. remove하지 않으면 다음 요청이 같은 스레드를 쓸 때 **이전 사용자 데이터가 남아** 정보 노출/메모리 누수가 발생합니다.

</details>

---

## 아이템 8. finalizer와 cleaner 사용을 피하라

### 한 줄 요약

`finalize()`/`Cleaner`로 자원 정리를 **기대하지 마라**. 언제 실행될지, 실행될지조차 보장되지 않는다.

### 비유 — "나중에 알아서 치워주겠지"

청소를 누군가 "나중에 알아서" 해줄 거라 믿고 안 하는 것과 같습니다. 그 "나중에"는 영영 안 올 수도 있습니다.

### 왜 피해야 하나

- **실행 시점 보장 없음** — GC 타이밍에 좌우됨. 즉시 정리되지 않음.
- **실행 자체 보장 없음** — 프로그램 종료 시 안 돌 수도 있음.
- **성능 저하 + 예외 무시 + 보안 취약점**(finalizer 공격).

### 올바른 대안

자원을 가진 클래스는 `AutoCloseable`을 구현하고, 사용자가 **try-with-resources(아이템 9)**로 닫게 합니다. `Cleaner`는 어디까지나 **안전망(safety net)**으로만.

### 현업 예제

DB 커넥션, 파일 핸들, 소켓은 `close()`로 명시적 해제합니다. `finalize`에 의존한 자원 정리는 **운영에서 커넥션 고갈**로 이어진 대표적 사고 원인입니다.

### 퀴즈

<details><summary>Q. finalizer/cleaner의 정당한(거의 유일한) 용도 두 가지는?</summary>

①`close()` 호출을 깜빡한 경우를 대비한 **안전망**, ②네이티브 피어(자바 객체가 위임한 비자바 객체) 자원 회수.

</details>

---

## 아이템 9. try-finally보다는 try-with-resources를 사용하라 ⭐현업 필수

### 한 줄 요약

`close()`가 필요한 자원은 **try-with-resources**로 자동·안전하게 닫아라.

### 비유 — "자동 소등 센서"

화장실을 나갈 때 불을 직접 끄려면(try-finally) 까먹기 쉽습니다. 센서(try-with-resources)는 **나가면 자동으로** 꺼줍니다.

### 문제: try-finally의 함정

```java
// ❌ 자원이 2개면 중첩되고, 예외가 가려진다
BufferedReader br = new BufferedReader(new FileReader(path));
try {
    return br.readLine();
} finally {
    br.close();   // 여기서도 예외가 나면, try의 예외가 사라짐(가려짐)
}
```

try와 finally 양쪽에서 예외가 나면 **두 번째 예외가 첫 번째를 덮어** 디버깅이 어려워집니다.

### 해법: try-with-resources

```java
// ✅ 자동 close + 첫 예외 보존(나머지는 suppressed로 첨부)
try (BufferedReader br = new BufferedReader(new FileReader(path))) {
    return br.readLine();
}
```

여러 자원도 깔끔합니다.

```java
try (InputStream in = new FileInputStream(src);
     OutputStream out = new FileOutputStream(dst)) {
    in.transferTo(out);
}   // out → in 순서로 자동 close
```

### 전제 조건

자원 클래스가 **`AutoCloseable`(또는 `Closeable`)을 구현**해야 합니다. `Connection`, `Statement`, `ResultSet`, `InputStream` 등 JDK 자원은 모두 구현되어 있습니다.

### 현업 예제 — JDBC 직접 다룰 때

```java
String sql = "SELECT name FROM member WHERE id = ?";
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql)) {
    ps.setLong(1, id);
    try (ResultSet rs = ps.executeQuery()) {
        return rs.next() ? rs.getString("name") : null;
    }
}   // rs → ps → conn 순서로 누락 없이 닫힘 (커넥션 누수 방지)
```

> **실무 메모**: JdbcTemplate/JPA를 쓰면 이 정리를 프레임워크가 대신 해줍니다. 하지만 **순수 JDBC, 파일 I/O, 외부 연동 스트림**을 다룰 땐 try-with-resources가 필수입니다. 레거시에서 `finally { conn.close(); }`로 짠 코드를 발견하면 이 패턴으로 교체 후보입니다.

### 따라하기 (실습 9-A)

1. 파일을 읽는 코드를 try-finally로 작성하고, 일부러 readLine과 close 양쪽에서 예외를 던져 본다.
2. 어떤 예외가 출력되는지 확인(close 예외가 readLine 예외를 가림).
3. try-with-resources로 바꾼 뒤, `Throwable.getSuppressed()`로 가려진 예외가 보존되는지 확인한다.

### 체크리스트

- [ ] `finally { xxx.close(); }` 패턴이 보이는가? → try-with-resources 후보
- [ ] 자원이 2개 이상 중첩되는가? → 한 try 괄호에 나열
- [ ] 내가 만든 자원 클래스인가? → `AutoCloseable` 구현 추가

### 퀴즈

<details><summary>Q. try-finally 대비 try-with-resources의 예외 처리상 장점은?</summary>

자원을 닫는 과정에서 예외가 나도 **try 블록의 원래 예외가 보존**되고, close 예외는 **suppressed(억제됨)**로 첨부됩니다. try-finally는 close 예외가 원래 예외를 **덮어버립니다**.

</details>

---

## 2장 종합 정리

### 한눈에 보는 결정 가이드

|상황|선택|
|---|---|
|인자가 헷갈리거나 의도를 이름으로 표현하고 싶다|**정적 팩터리(1)**|
|선택적 인자가 많다(4개+) + 불변|**빌더(2)**|
|인스턴스가 하나여야 한다|**enum 싱글턴(3)** / 현업은 Spring 빈|
|정적 메서드만 모은 유틸|**private 생성자(4)**|
|다른 자원에 의존한다|**의존성 주입(5)** ← 현업 최우선|
|같은 불변 객체를 반복 사용|**재사용(6)** (단, 과최적화 금지)|
|직접 메모리를 관리한다|**참조 해제(7)**|
|자원 정리가 필요하다|finalizer 금지(8) → **try-with-resources(9)**|

### 종합 체크리스트 (코드 리뷰용)

- [ ] `new`로 직접 객체를 박아두지 않았는가 → 정적 팩터리/DI 검토
- [ ] 생성자 인자 4개+ → 빌더 검토
- [ ] 싱글턴을 직접 구현 → Spring 빈으로 대체 가능?
- [ ] `new ObjectMapper()`/`Pattern.matches`를 핫패스에서 반복 → 상수 재사용
- [ ] ThreadLocal `remove()`, 리스너 해제 누락 없는가
- [ ] `finally { close() }` → try-with-resources로 교체

### 종합 퀴즈

<details><summary>Q1. "정적 팩터리·빌더·DI" 세 가지를 한 문장으로 관통하는 공통 가치는?</summary>

객체 생성의 **유연성과 의도 표현**을 높여, 변경과 테스트에 강한 코드를 만든다.

</details> <details><summary>Q2. GC가 있는 자바에서 메모리 누수가 나는 근본 이유는?</summary>

GC는 **도달 불가능한** 객체만 회수합니다. 다 쓴 객체라도 **참조가 살아 있으면(도달 가능하면)** 회수하지 못합니다.

</details> <details><summary>Q3. 이 장에서 Spring이 이미 적용하고 있는 아이템을 두 개 이상 들어라.</summary>

빈의 싱글턴 스코프(아이템 3), 생성자 주입(아이템 5), `ResponseEntity.ok()` 등 정적 팩터리(아이템 1) 등.

</details>

---

## 다음 장 예고 — 3장: 모든 객체의 공통 메서드

`equals`/`hashCode`/`toString`/`Comparable`을 **언제, 어떻게** 재정의하는지 다룹니다. 현업에서는 **JPA 엔티티의 equals/hashCode 함정**, **DTO toString의 민감정보 노출**처럼 곧바로 사고로 이어지는 주제가 기다리고 있습니다.