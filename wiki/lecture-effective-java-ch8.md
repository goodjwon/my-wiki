---
title: "Effective Java 실전 강의 — 8장"
type: source
tags: [book, effective-java, bloch, lecture]
sources: [effective_java/이펙티브 자바 실전 강의 교재 8장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 이펙티브 자바 실전 강의 교재

## 8장 — 메서드

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 설명 → 비유 → 현업 예제 → 따라하기(실습) → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 메서드의 **첫 줄**(매개변수 검증)부터 **반환**(null·Optional)까지 일관된 계약을 만든다.
- 변경 가능한 외부 객체를 받을 때 **방어적 복사**가 언제 필요한지 판단한다.
- **시그니처 설계** 시 다중정의·가변인수·과한 매개변수의 함정을 피한다.
- API에 **문서화 주석(Javadoc)** 을 붙여 사용자에게 명확한 계약을 전달한다.

### 0.2 큰 그림 — 메서드의 "입구·몸통·출구"

```
[ 입구: 받는 것 ]                [ 몸통: 시그니처 ]              [ 출구: 주는 것 ]
 아이템 49  매개변수 검증           아이템 51  시그니처 설계        아이템 54  빈 컬렉션/배열
 아이템 50  방어적 복사 ⭐           아이템 52  다중정의 신중       아이템 55  Optional 신중
                                    아이템 53  가변인수 신중       아이템 56  Javadoc 작성
```

> **비유 — 메서드는 "식당의 한 코스 요리"입니다.**
>
> - **입구(49·50)**: 손님이 가져온 재료(파라미터)를 받을 때, 상한 건 거절하고(검증), 잘라 쓸 거면 직접 잘라야(복사) 주방이 안전합니다.
> - **몸통(51·52·53)**: 메뉴 이름·옵션·세트 구성을 헷갈리지 않게 만들어야 손님이 주문 실수 안 합니다.
> - **출구(54·55·56)**: 빈 접시 대신 빈 컬렉션, "선택적" 표시는 Optional, 메뉴판 설명은 Javadoc.

### 0.3 현업에서 왜 중요한가

- 공개 API(Controller/Service의 public 메서드, Repository, 라이브러리)의 **계약 품질**이 곧 시스템 안정성.
- 매개변수 검증·방어적 복사를 안 하면 호출자의 실수가 **내부 상태를 깨뜨려** 추적 어려운 버그가 됩니다.
- Spring 컨트롤러의 `@Valid`, JPA 엔티티의 setter, DTO record 등은 모두 8장 원칙의 변형입니다.

---

## 아이템 49. 매개변수가 유효한지 검사하라

### 한 줄 요약

메서드 본문이 시작되기 **전에** 매개변수가 약속(불변식)을 지키는지 검증하라. 빨리 깨면 빨리 고친다(fail-fast).

### 비유 — "주방 입구의 위생 검사"

상한 재료를 받아 요리하고 나서 "왜 이상하지?" 하는 것보다, **입구에서 거절**하는 게 훨씬 빠르고 책임 추적도 명확합니다.

### 안티패턴 — 검증 없이 진입

```java
public Money calculateDiscount(int orderAmount, int discountRate) {
    return Money.of(orderAmount * discountRate / 100);   // 음수 들어오면? 100% 초과면?
}
```

오류가 메서드 깊숙이서 터지면 스택 트레이스가 진짜 원인(호출자의 잘못된 인자)을 안 가리킵니다.

### 권장 — 첫 줄에 검증

```java
public Money calculateDiscount(int orderAmount, int discountRate) {
    if (orderAmount < 0) throw new IllegalArgumentException("orderAmount < 0: " + orderAmount);
    if (discountRate < 0 || discountRate > 100)
        throw new IllegalArgumentException("discountRate 범위 위반: " + discountRate);
    return Money.of(orderAmount * discountRate / 100);
}
```

`java.util.Objects` 활용:

```java
public void register(User user) {
    Objects.requireNonNull(user, "user must not be null");
    Objects.checkIndex(index, list.size());      // Java 9+
}
```

### Spring/JPA 현업 예제

```java
@RestController
public class OrderController {
    @PostMapping("/orders")
    public OrderResponse create(@Valid @RequestBody OrderRequest req) {  // ← @Valid가 49의 자동화
        return service.create(req);
    }
}

public record OrderRequest(
    @NotBlank String userId,
    @Positive int amount
) {}
```

Bean Validation(`@Valid`/`@NotBlank`/`@Positive`)이 **컨트롤러 입구의 49번 자동화 버전**입니다.

### 예외: 검증을 생략해도 되는 경우

1. **검증 비용이 크고**, 본문에서 자연스럽게 같은 예외가 던져진다 (`list.sort(null)` → NPE).
2. **private/package-private 메서드**: 호출자를 통제하므로 `assert`로 충분.

```java
private void process(int[] sorted) {
    assert sorted != null && isSorted(sorted) : "must be sorted ascending";
    // ...
}
```

### 함정

- **묵시적 NPE를 검증으로 위장하지 마라**. `user.getName()` 가 자연스럽게 NPE를 던지면 보이지만, `requireNonNull(user, "user")`은 메시지로 진짜 원인을 가리킨다.
- **검증을 너무 깊이 미루면** 호출 스택 한참 아래에서 터져 디버깅 비용 폭증.

### 체크리스트

- [ ] public/protected 메서드의 첫 줄이 매개변수 검증인가
- [ ] `Objects.requireNonNull(x, "x")` 처럼 **이름**을 메시지에 담았는가
- [ ] Spring 진입점에 `@Valid` + Bean Validation 애너테이션을 붙였는가
- [ ] private 메서드는 `assert`로 가벼운 보호를 했는가

---

## 아이템 50. 적시에 방어적 복사본을 만들라

### 한 줄 요약

**변경 가능한** 외부 객체를 필드로 보관하거나 반환할 때는 **복사본**으로 저장·반환하라. 원본 참조를 그대로 들고 있으면 외부가 내부 상태를 깨뜨릴 수 있다.

### 비유 — "원본 계약서 vs 사본"

손님이 가져온 원본 서류(가변 객체)를 보관함에 넣어두면, 손님이 나중에 원본을 고치는 순간 우리 보관함의 내용도 바뀝니다. 사본을 떠 보관해야 안전합니다.

### 안티패턴 — 가변 객체를 그대로 보관

```java
public final class Period {
    private final Date start, end;
    public Period(Date start, Date end) {
        if (start.after(end)) throw new IllegalArgumentException();
        this.start = start;   // ❌ 외부 Date 참조 그대로 보관
        this.end = end;       // ❌
    }
    public Date start() { return start; }   // ❌ 내부 참조 그대로 노출
}

// 공격
Date s = new Date(), e = new Date();
Period p = new Period(s, e);
s.setYear(2000);   // 💥 Period 내부도 같이 바뀜
```

### 권장 — 입력에서 복사, 출력에서도 복사

```java
public Period(Date start, Date end) {
    this.start = new Date(start.getTime());   // ✅ 복사 후 검증 (TOCTOU 회피: 검증을 복사 뒤에)
    this.end = new Date(end.getTime());
    if (this.start.after(this.end)) throw new IllegalArgumentException();
}
public Date start() { return new Date(start.getTime()); }   // ✅ 복사본 반환
```

> **TOCTOU 함정**: 검증을 먼저 하고 복사를 나중에 하면, 다른 스레드가 그 사이에 원본을 바꿔치기할 수 있다. **복사 후 검증** 순서가 정답.

### 더 좋은 해법 — 불변 타입 사용

Java 8+ `java.time` 의 `Instant`/`LocalDate`/`LocalDateTime` 등은 **불변**이라 방어적 복사 불필요.

```java
public final class Period {
    private final Instant start, end;
    public Period(Instant start, Instant end) {
        if (start.isAfter(end)) throw new IllegalArgumentException();
        this.start = start;   // 불변이라 그대로 OK
        this.end = end;
    }
    public Instant start() { return start; }   // 그대로 반환 OK
}
```

### Spring/JPA 현업 예제

```java
// ❌ JPA 엔티티의 컬렉션 getter
public class Order {
    private final List<OrderItem> items = new ArrayList<>();
    public List<OrderItem> getItems() { return items; }   // 외부가 직접 add/remove 가능
}

// ✅ 방어
public List<OrderItem> getItems() { return List.copyOf(items); }   // 불변 복사본
// 또는
public List<OrderItem> getItems() { return Collections.unmodifiableList(items); }   // 읽기 뷰
```

### 함정

- **clone() 사용 신중**. 하위 클래스가 악의적으로 오버라이드 가능. 생성자/팩터리로 복사하는 게 안전.
- **`Date`, `Calendar`, 가변 컬렉션**은 대표 위험. `java.time` + 불변 컬렉션으로 갈수록 안전.
- **모든 곳에 방어적 복사는 과하다**. 호출자가 같은 패키지·신뢰 영역이면 생략 가능. 단, 공개 API는 기본 적용.

### 체크리스트

- [ ] 생성자가 받는 가변 객체를 복사 후 검증하는가
- [ ] getter가 가변 컬렉션·`Date`를 그대로 노출하는가
- [ ] 가능하면 `java.time` 불변 타입·`List.copyOf()`로 교체했는가

---

## 아이템 51. 메서드 시그니처를 신중히 설계하라

### 한 줄 요약

한 번 공개된 시그니처는 영원히 가져가야 한다. **이름·매개변수 수·타입·순서**를 처음부터 신중히.

### 다섯 가지 권장 (모두 일관 적용)

1. **메서드 이름은 표준 명명 규칙**(아이템 68) — `findBy*`, `is*/has*`, `to*`, `of/from/valueOf` 등.
2. **너무 많은 메서드 생성 자제** — 같은 일을 다른 이름으로 4개 만들지 마라.
3. **매개변수 수는 4개 이하** — 넘어가면 시그니처가 헷갈린다.
4. **같은 타입 매개변수 연속 금지** — `(String, String, String)`는 호출부에서 순서를 외워야 함.
5. **boolean 매개변수보다는 enum**.

### 안티패턴 모음

```java
// ❌ 1) 매개변수 7개 — 호출부가 외움
service.createUser(name, email, phone, age, address, role, active);

// ❌ 2) 같은 타입 4연속
copy(source, target, source, target);   // 어느 게 src? dst?

// ❌ 3) boolean 의미 불명
report.generate(true, false, true);   // ???
```

### 해법

```java
// ✅ 1) 매개변수 객체화 (Parameter Object) — record 활용
public record CreateUserCommand(String name, String email, String phone, int age, ...) {}
service.createUser(command);

// ✅ 2) 타입으로 의미 부여
copy(Source src, Target dst);

// ✅ 3) boolean → enum
report.generate(Format.PDF, Pagination.NONE, Headers.INCLUDED);
```

### Spring/JPA 현업 예제

```java
// ❌
List<Order> findOrders(String status, LocalDate from, LocalDate to, boolean includeCancelled);

// ✅ — 조건 객체 + enum
List<Order> findOrders(OrderSearchCondition condition);

public record OrderSearchCondition(
    OrderStatus status,
    DateRange period,
    IncludeCancelled includeCancelled
) {}
```

### 체크리스트

- [ ] 매개변수 4개 이하인가? 넘으면 조건 객체로
- [ ] boolean 매개변수가 의미 불명하지 않은가? enum으로
- [ ] 같은 타입 매개변수가 연속되어 순서 혼동 위험이 있는가?

---

## 아이템 52. 다중정의는 신중히 사용하라

### 한 줄 요약

**오버로딩(다중정의)**은 컴파일 타임에 시그니처로 결정된다 — 호출자가 헷갈리기 쉽다. **다른 이름의 메서드**(`writeBoolean`, `writeInt`)로 분리하라.

### 비유 — "한 이름, 다른 메뉴"

`order("아메리카노")`와 `order(아메리카노객체)` 는 손님 입장에서 "같은 동작"으로 기대하지만, 컴파일러는 정적 타입을 보고 다른 메서드를 호출합니다.

### 함정 사례

```java
public class CollectionClassifier {
    public static String classify(Set<?> s) { return "Set"; }
    public static String classify(List<?> l) { return "List"; }
    public static String classify(Collection<?> c) { return "Unknown"; }

    public static void main(String[] args) {
        Collection<?>[] cs = {new HashSet<>(), new ArrayList<>(), new HashMap<>().values()};
        for (Collection<?> c : cs) {
            System.out.println(classify(c));   // 모두 "Unknown" 출력
        }
    }
}
```

직관: "Set, List, Unknown"이 나올 것 같지만, **정적 타입이 모두 `Collection<?>`** 이라 모두 세 번째가 호출됨.

### 해법 — 이름을 분리

```java
public static String classifySet(Set<?> s) { return "Set"; }
public static String classifyList(List<?> l) { return "List"; }
public static String classifyOther(Collection<?> c) { return "Other"; }
```

Java 표준 라이브러리도 이 원칙을 따름:
- `ObjectOutputStream`: `writeBoolean()`, `writeInt()`, `writeLong()`, ... (오버로딩 X)

### 오버로딩이 안전한 경우

- **매개변수 개수가 다름** (오버로딩 + 디폴트 사용)
- **타입이 근본적으로 다름** (`int` vs `String`은 자동 변환이 거의 없음)
- **모두 같은 일을 다른 입력으로 한다** (`String.valueOf(int)`, `String.valueOf(boolean)`)

### Spring/JPA 현업 예제

```java
// JdbcTemplate.query는 의도적으로 매우 다양한 오버로딩을 제공하지만, 같은 의미(SQL 실행).
// 우리가 만드는 service 메서드는 이름 분리가 안전.

// ❌
public Order save(Order o);
public Order save(OrderDto dto);   // 둘이 의미가 다름

// ✅
public Order save(Order o);
public Order createFromDto(OrderDto dto);
```

### 체크리스트

- [ ] 오버로딩 후 모든 시그니처가 "같은 일을 다른 입력으로"인가?
- [ ] 매개변수 수가 같으면 사용자가 헷갈릴 가능성이 큰가? → 이름 분리

---

## 아이템 53. 가변인수는 신중히 사용하라

### 한 줄 요약

`varargs`(`T... args`)는 편하지만 **매번 배열을 새로 만든다**. 성능 민감한 곳에선 오버로딩으로 분리.

### 비유 — "무제한 토핑 vs 고정 메뉴"

가변인수는 "토핑 몇 개든 받아요" 같지만, 매번 새 접시(배열)를 차립니다. 99%가 토핑 0~2개라면 그 경우 고정 메뉴를 따로 두는 게 효율적.

### 기본 사용

```java
static int sum(int... nums) {
    int total = 0;
    for (int n : nums) total += n;
    return total;
}
sum();         // 0 — 빈 배열도 OK
sum(1, 2, 3);  // 6
```

### 패턴: "1개 이상 필수"는 컴파일 시점에 강제

```java
// ❌ — 런타임에 0개 검증
static int min(int... nums) {
    if (nums.length == 0) throw new IllegalArgumentException();
    int min = nums[0];
    for (int i = 1; i < nums.length; i++) if (nums[i] < min) min = nums[i];
    return min;
}

// ✅ — 첫 인자를 분리해 컴파일 강제
static int min(int first, int... rest) {
    int min = first;
    for (int n : rest) if (n < min) min = n;
    return min;
}
```

### 성능 패턴: 자주 호출되는 경우 오버로딩 분리

```java
public void log(String msg)                       { ... }
public void log(String msg, Object a1)            { ... }
public void log(String msg, Object a1, Object a2) { ... }
public void log(String msg, Object... args)       { ... }   // 3개 초과만
```

`EnumSet.of`, `List.of`가 정확히 이 패턴.

### Spring/JPA 현업 예제

```java
// SLF4J — 의도적 오버로딩
log.info("user={}", userId);                       // 가변인수 X
log.info("user={}, order={}", userId, orderId);   // 가변인수 X
log.info("a={}, b={}, c={}, d={}", a, b, c, d);   // 가변인수
```

핫패스 로그(`debug`/`trace`)에서 효과 큼.

### 체크리스트

- [ ] "최소 1개" 같은 제약은 매개변수 분리로 컴파일 강제했는가
- [ ] 성능 민감 메서드라면 자주 쓰는 인자 수만큼 오버로딩 제공했는가
- [ ] 무지성 `Object...` 남용은 박싱·배열 생성 비용을 부르는가

---

## 아이템 54. null이 아닌, 빈 컬렉션이나 배열을 반환하라

### 한 줄 요약

비어 있는 결과를 알리고 싶다면 **null이 아니라 빈 컬렉션/배열**. 호출자에게 NPE 위험을 강요하지 마라.

### 비유 — "빈 접시 vs 접시 없음"

손님 테이블에 음식 없음을 표현할 때, **빈 접시**를 두는 것과 접시 자체를 안 주는 것은 다릅니다. 접시가 없으면 손님은 매번 "있나?" 확인해야 합니다.

### 안티패턴 — null 반환

```java
public List<Order> findByUser(String userId) {
    List<Order> result = repository.findByUser(userId);
    return result.isEmpty() ? null : result;   // ❌
}

// 호출자 — null 체크 강요
List<Order> orders = service.findByUser("u1");
if (orders != null) {                          // 잊으면 NPE
    for (Order o : orders) { ... }
}
```

### 권장 — 빈 컬렉션/배열

```java
public List<Order> findByUser(String userId) {
    return repository.findByUser(userId);   // 빈 List 그대로
}

// 호출자 — 군더더기 없음
for (Order o : service.findByUser("u1")) { ... }
```

### 성능 — 빈 컬렉션 상수 재사용

```java
// 성능 민감 + 빈 결과가 잦으면
private static final Order[] EMPTY = new Order[0];

public Order[] findRecent() {
    return result.isEmpty() ? EMPTY : result.toArray(new Order[0]);
}
// 또는
return Collections.emptyList();
return List.of();
```

### Spring/JPA 현업 메모

- Spring Data JPA `Repository.findAll()` 등은 **항상 빈 List 반환** (null 아님).
- 단건 조회 `findById()`는 `Optional<T>` (55와 직결).

### 체크리스트

- [ ] 컬렉션·배열 반환 메서드가 null을 반환하지 않는가
- [ ] 호출자에 null 체크 군더더기가 있다면 → 반환 변경 후 제거

---

## 아이템 55. Optional 반환은 신중히 하라

### 한 줄 요약

**값이 없을 수도 있는 단건 반환**에 `Optional<T>` 가 명시적이고 좋다. 단, 컬렉션·맵·`int`/`long`·필드·매개변수에는 쓰지 마라.

### 비유 — "포장된 선물 vs 빈 상자도 같이"

선물(`T`)이 있을 수도 없을 수도 있을 때, `Optional<T>` 는 "있다/없다"를 명시한 **포장지**입니다. 단, 컬렉션은 이미 빈 컬렉션으로 "없다"를 표현할 수 있으니 굳이 포장하지 마세요.

### 권장 — 단건 조회

```java
// ✅
public Optional<User> findByEmail(String email) {
    return repository.findByEmail(email);
}

// 호출자
String name = userService.findByEmail(email)
    .map(User::getName)
    .orElse("(unknown)");
```

### 안티패턴 — 컬렉션을 Optional로 감쌈

```java
// ❌ — 빈 List가 이미 "없음" 표현
public Optional<List<Order>> findByUser(String userId);

// ✅
public List<Order> findByUser(String userId);   // 빈 List 반환
```

### Optional 활용 패턴

```java
Optional<User> opt = ...;

// 값 처리
opt.ifPresent(u -> sendEmail(u));
String name = opt.map(User::getName).orElse("anonymous");
User user = opt.orElseThrow(() -> new UserNotFoundException(id));

// ❌ 절대 — Optional이 null이면 안 됨 (의미가 무너짐)
if (opt != null && opt.isPresent()) { ... }
```

### 쓰지 말아야 할 곳

| 자리 | 이유 |
|------|------|
| **필드** | 직렬화·메모리 비용. 필드는 그냥 `T` 또는 null + Javadoc |
| **매개변수** | 호출자가 항상 `Optional.of/empty` 감싸야 함 — 어색 |
| **컬렉션 원소** | 빈 컬렉션이 더 명확 |
| **`int`/`long` 단건** | `OptionalInt`/`OptionalLong` 사용 (박싱 회피) |

### Spring/JPA 현업 예제

```java
// ✅
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);   // Spring Data 표준
}

// ❌
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<List<User>> findActiveUsers();
    User findByEmail(String email);   // null 반환 — Optional 권장
}
```

### 체크리스트

- [ ] 값이 없을 수 있는 **단건** 반환에 Optional을 썼는가
- [ ] 컬렉션·배열·맵에 Optional을 씌우지 않았는가
- [ ] Optional을 필드·매개변수로 쓰지 않았는가
- [ ] Optional이 null이 될 가능성이 코드 어디에도 없는가

---

## 아이템 56. 공개된 API 요소에는 항상 문서화 주석을 작성하라

### 한 줄 요약

공개 API는 **Javadoc**으로 계약을 명시하라 — 무엇을 받고(@param), 무엇을 반환하며(@return), 무엇을 던지는가(@throws).

### 핵심 태그

| 태그 | 용도 |
|------|------|
| `@param` | 모든 매개변수 |
| `@return` | void가 아닌 모든 메서드 |
| `@throws` | 검사·비검사 예외 모두 |
| `@implSpec` | 메서드를 상속·구현할 때의 계약 (Java 8+) |
| `{@code ...}` | 코드 폰트 |
| `{@link ClassName#method}` | 다른 API 참조 |

### 예시

```java
/**
 * 주문에 대한 할인 금액을 계산한다.
 *
 * <p>할인은 회원 등급과 쿠폰을 모두 고려하며, 0원 이하로는 내려가지 않는다.
 *
 * @param order 할인을 계산할 주문 (null 불가)
 * @param coupon 적용할 쿠폰 (null이면 쿠폰 없음으로 처리)
 * @return 할인 금액 (0원 이상)
 * @throws IllegalArgumentException order가 null이거나 합계가 음수인 경우
 * @see Coupon
 */
public Money calculateDiscount(Order order, Coupon coupon) { ... }
```

### 권장 패턴

- **첫 문장은 메서드의 동작 요약** — 마침표로 끝남, Javadoc 인덱스에 그대로 노출.
- **단언이 아닌 사용자 관점** — "X를 할 수 있도록 한다" 가 아니라 "X를 반환한다".
- **부작용 명시** — 외부에 영향을 주면 반드시 적어라.
- **스레드 안전성** — Item 82와 직결.

### Spring/JPA 현업 메모

- 외부 라이브러리·SDK는 필수. 사내 코드도 **공개 API**(다른 팀이 호출)에는 적용.
- 컨트롤러는 OpenAPI(Swagger) 주석으로 대체 가능 (`@Operation`, `@Schema`).

### 체크리스트

- [ ] public/protected 메서드에 Javadoc이 있는가
- [ ] `@param`, `@return`, `@throws` 빠뜨림 없는가
- [ ] 첫 문장이 의도를 한 줄로 요약하는가
- [ ] 스레드 안전성·부작용을 명시했는가

---

## 8장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 매개변수 검증 | **첫 줄에 `Objects.requireNonNull` + `@Valid`(49)** |
| 가변 객체 받기·반환 | **방어적 복사(50)** 또는 불변 타입(`java.time`/`List.copyOf`) |
| 매개변수 4개 초과 | **조건 객체화(51)** — record 활용 |
| boolean 매개변수가 의미 모호 | **enum(51)** |
| 오버로딩 후보 | **이름 분리(52)** — 같은 일이 아니면 |
| 가변인수 + 성능 민감 | **자주 쓰는 인자 수만큼 오버로딩(53)** |
| 빈 결과 반환 | **빈 컬렉션/배열(54)** — null 금지 |
| 값이 없을 수 있는 단건 | **`Optional<T>`(55)** — 필드/매개변수/컬렉션엔 금지 |
| 공개 API | **Javadoc(56)** — `@param`/`@return`/`@throws` |

### 종합 체크리스트 (코드 리뷰용)

- [ ] public 메서드의 첫 줄이 매개변수 검증
- [ ] 가변 객체 보관은 복사 또는 불변 타입
- [ ] 매개변수 4개 초과 → record로 묶기
- [ ] boolean 인자가 의미 모호 → enum
- [ ] 오버로딩이 호출자에게 모호한 결과를 줄 위험은 없는가
- [ ] 컬렉션 반환이 null이 아닌 빈 컬렉션인가
- [ ] 단건 nullable 반환은 Optional인가 (컬렉션은 그냥 List)
- [ ] 공개 API에 Javadoc + `@param`/`@return`/`@throws`

### 종합 퀴즈

<details><summary>Q1. 매개변수 검증의 가장 큰 이점은?</summary>

**fail-fast** — 잘못된 입력이 메서드 깊숙이 흘러 들어가 추적 어려운 버그가 되는 대신, 호출 지점 가까이에서 명확한 예외로 터지게 한다.

</details>

<details><summary>Q2. 방어적 복사에서 "복사 후 검증" 순서가 중요한 이유는?</summary>

검증 후 복사하면, 검증과 복사 사이에 다른 스레드가 원본을 바꿔 **TOCTOU**(Time-Of-Check / Time-Of-Use) 취약점이 생긴다. 복사한 사본을 검증해야 사본의 일관성이 보장된다.

</details>

<details><summary>Q3. Optional을 필드·매개변수에 쓰지 말라는 이유 2가지?</summary>

(1) **직렬화·메모리 비용**: Optional 자체가 객체라 필드로 두면 모든 인스턴스가 추가 객체를 가짐. (2) **API 불편**: 매개변수가 Optional이면 호출자가 매번 `Optional.of/empty`로 감싸야 하고, null로 들어올 수 있어 의미가 무너짐.

</details>

<details><summary>Q4. Spring의 <code>@Valid</code>가 8장 어떤 아이템의 자동화인가?</summary>

아이템 49, **매개변수 검증**. 컨트롤러 진입점에서 Bean Validation 애너테이션을 보고 자동 검증 후 위반 시 `MethodArgumentNotValidException`을 던진다.

</details>

---

## 다음 장 예고 — 9장: 일반적인 프로그래밍 원칙

지역 변수·반복문·표준 라이브러리·실수 정밀도·박싱·문자열 사용·인터페이스 참조·리플렉션·최적화·명명 규칙까지 — **하루에 한 번 이상 마주치는 12가지 기본 원칙**을 다룹니다 (Item 57~68). "이미 알고 있다" 싶지만 의외로 실수가 잦은 영역입니다.

> 이어서 만들까요? (9장으로 진행 / 10장 예외로 점프 / 지금까지 만든 장들을 통합 교재로 묶기)
