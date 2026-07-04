---
title: 계약에 의한 설계 (Design by Contract)
type: concept
tags: [java, oop, design, dbc, contract, lsp, validation]
sources: [object/오브젝트 실전 강의 교재 부록A.md]
external:
  - https://en.wikipedia.org/wiki/Design_by_contract
  - https://www.eiffel.com/values/design-by-contract/
created: 2026-07-04
updated: 2026-07-04
---

# 계약에 의한 설계 (Design by Contract)

## 정의

계약에 의한 설계는 메서드와 호출자 사이의 약속을 **사전조건·사후조건·불변식**이라는 세 가지 조건으로 명시하고, 조건을 어긴 쪽이 책임을 지게 하는 설계 기법입니다. 용어는 Bertrand Meyer가 Eiffel 언어를 설계하면서 만들었고, 1986년 무렵의 논문들과 저서 *Object-Oriented Software Construction* (1판 1988, 2판 1997)에서 체계화되었습니다. Eiffel은 `require`(사전조건)·`ensure`(사후조건)·`invariant`(불변식)를 언어 키워드로 내장했으며, "Design by Contract"라는 표현 자체는 Eiffel Software가 2004년에 등록한 상표입니다. Java에는 대응하는 키워드가 없지만 같은 사고방식을 여러 수단으로 실현할 수 있습니다.

인테리어 공사를 계약서 없이 맡겼다고 해 봅시다. 집주인은 자재를 바꿔치기하지 않는지 매일 현장에 나가 확인하고, 시공자는 대금이 제때 들어올지 몰라 공정을 자꾸 늦춥니다. 반대로 계약서를 한 장 쓰면 풍경이 달라집니다. 집주인은 약속한 날짜에 대금만 준비하면 되고, 시공자는 약속한 사양대로 완성만 하면 됩니다. 서로를 매번 의심하며 들이던 확인 비용이 계약서 한 장으로 사라집니다.

메서드 호출도 같은 거래입니다. 호출자가 호출 전에 갖춰야 할 자격이 사전조건이고, 메서드가 반환하면서 보장하는 결과가 사후조건이며, 거래가 오가는 내내 깨지면 안 되는 객체의 상태가 불변식입니다. 계약이 명시되면 메서드 본문은 인자를 매번 의심하는 방어 코드를 걷어낼 수 있고, 호출자는 반환값을 다시 검사할 필요가 없어집니다. 그리고 조건을 어긴 쪽이 책임진다는 원칙도 공사 계약과 똑같이 적용됩니다.

## 계약의 3요소

세 조건이 각각 무엇을 약속하고, 누가 지키며, 누가 이득을 보는지가 이 기법의 뼈대입니다. 아래 표로 정리합니다.

| 요소 | 무엇을 약속하는가 | 지키는 쪽 (어기면 누구 잘못) | 이득 보는 쪽 |
|------|------------------|---------------------------|-------------|
| **사전조건** (Precondition) | 메서드 호출 전에 참이어야 할 조건 | **호출자** | **메서드** — 본문에서 조건을 참으로 가정하고 방어 코드를 생략합니다 |
| **사후조건** (Postcondition) | 메서드 반환 후에 참임이 보장되는 조건 | **메서드** | **호출자** — 반환값·상태를 재검증할 필요가 없어집니다 |
| **불변식** (Invariant) | 모든 public 메서드 호출 전후에 항상 참인 조건 | **객체 자신** | **협력하는 모든 객체** — 언제 접근해도 일관된 상태를 신뢰합니다 |

책임 배분이 핵심입니다. 사전조건 위반은 호출자의 버그이고, 사후조건 위반은 메서드의 버그이며, 불변식 위반은 객체 설계의 버그입니다. 장애가 났을 때 "어느 쪽 코드를 고쳐야 하는가"가 계약만 보고 판별됩니다.

원전인 Eiffel에서는 세 요소가 이렇게 언어 문법으로 표현됩니다.

```eiffel
withdraw (amount: INTEGER)
    require
        positive:   amount > 0
        sufficient: amount <= balance
    do
        balance := balance - amount
    ensure
        decremented: balance = old balance - amount
    end

invariant
    non_negative: balance >= 0
```

## Java에서의 실현 수단

Java에는 `require`/`ensure` 키워드가 없으므로 표준 라이브러리·관례·어노테이션을 조합합니다. 각 수단이 어느 계약 요소를 담당하는지부터 표로 잡습니다.

| 수단 | 담당 계약 요소 | 작동 시점 |
|------|--------------|----------|
| `Objects.requireNonNull` | 사전조건 (null 금지) | 런타임 — 항상 |
| `if-throw` + `IllegalArgumentException`/`IllegalStateException` | 사전조건 (인자 값 / 수신 객체 상태) | 런타임 — 항상 |
| `assert` | 사후조건·불변식 (내부 확인) | 런타임 — `-ea` 옵션을 켰을 때만 |
| Bean Validation (`@NotNull`·`@Positive` 등) + `@Valid` | 사전조건 (경계 입력의 선언적 검증) | 런타임 — 프레임워크 진입 시 |
| JSpecify (`@NullMarked`·`@Nullable`) | null 계약 (사전·사후조건의 타입 표기) | 컴파일·정적 분석 시점 |

### Objects.requireNonNull — null 사전조건

public 메서드의 첫머리에서 null 사전조건을 한 줄로 검증합니다. 위반 시 어느 인자가 문제인지 메시지로 남습니다.

```java
public Transfer(Account from, Account to) {
    this.from = Objects.requireNonNull(from, "from account");
    this.to   = Objects.requireNonNull(to, "to account");
}
```

### if-throw 관례 — 값·상태 사전조건

null 이외의 사전조건은 `if-throw`로 검증하며, 예외 선택에 관례가 있습니다. **인자 값이 잘못이면 `IllegalArgumentException`, 수신 객체의 상태가 호출에 부적합하면 `IllegalStateException`**입니다 (*Effective Java* Item 72 표준 예외 — [[lecture-effective-java-ch10]]).

```java
public Money withdraw(int amount) {
    if (amount <= 0)
        throw new IllegalArgumentException("amount must be positive: " + amount);
    if (frozen)
        throw new IllegalStateException("account is frozen: " + id);
    balance -= amount;
    return new Money(amount, currency);
}
```

### assert — 사후조건·불변식

`assert`는 JVM 옵션 `-ea`를 켠 개발·테스트 환경에서만 작동하므로 public API의 사전조건에는 부적합하고, **메서드가 자기 자신에게 거는 사후조건·불변식 확인**에 적합합니다.

```java
public Money withdraw(int amount) {
    int oldBalance = balance;
    balance -= amount;
    assert balance == oldBalance - amount : "balance not decremented correctly";
    assert invariant() : "invariant broken: balance < 0";
    return new Money(amount, currency);
}

private boolean invariant() {
    return balance >= 0;
}
```

### Bean Validation — 사전조건의 선언적 자동화

Spring의 `@Valid`는 요청 DTO의 사전조건을 어노테이션으로 선언하고 컨트롤러 진입 시 자동 검증합니다. 사전조건을 코드가 아니라 선언으로 옮긴 형태입니다.

```java
public record CreateOrderRequest(
    @NotBlank String userId,
    @Positive int amount
) {}

@PostMapping("/orders")
public OrderResponse create(@Valid @RequestBody CreateOrderRequest req) {
    return orderService.create(req);   // 여기 도달했으면 사전조건은 이미 참
}
```

### JSpecify — null 계약을 컴파일 시점으로

JSpecify는 null 가능 여부라는 계약을 타입 표기로 끌어올려, 위반을 실행 전에 정적 분석기가 잡게 합니다. 파라미터의 `@Nullable`은 "null도 받는다"는 사전조건 완화이고, 반환 타입의 `@Nullable`은 "null이 나올 수 있다"는 사후조건 명시입니다. 상세는 [[concept-jspecify-null-safety]] 참고.

```java
@NullMarked   // 이 클래스의 타입은 기본 non-null 계약
public class UserService {
    public User register(String email) { ... }             // 인자·반환 모두 null 금지
    public @Nullable User findByEmail(String email) { ... } // 사후조건: null 반환 가능 명시
}
```

## LSP와의 관계 — 자식의 계약

리스코프 치환 원칙(LSP)의 형식적 기반이 바로 계약입니다. 자식 타입이 부모 자리를 대체하려면 **부모의 계약을 지키는 범위 안에서만** 조건을 바꿀 수 있습니다.

| 요소 | 자식에게 허용되는 방향 | 금지 |
|------|--------------------|------|
| 사전조건 | 같거나 **더 완화** (더 많이 받아들임) | **강화 금지** — 부모 계약으로 유효한 호출을 자식이 거부하면 클라이언트가 깨집니다 |
| 사후조건 | 같거나 **더 강화** (더 많이 보장) | **완화 금지** — 클라이언트가 부모 계약으로 기대한 보장이 사라집니다 |
| 불변식 | 부모 것 **유지** | 파기 금지 |

한 줄로 줄이면 "자식은 더 받아들이고 더 보장합니다". 예를 들어 부모 `Account.deposit`이 양수면 받는데 자식 `PremiumAccount`가 1만 원 미만을 거부하면, 부모 타입으로 5천 원을 입금하던 클라이언트가 자식 인스턴스를 만나는 순간 예외를 맞습니다 — 사전조건 강화가 곧 LSP 위배입니다. SOLID 전체 맥락은 [[concept-solid]], 서브클래싱·서브타이핑 구분은 [[lecture-object-ch13]], 계약 관점의 상세 예제는 [[lecture-object-appendixA]] §3 참고.

## 방어적 프로그래밍과의 구분

계약과 방어적 프로그래밍은 검증 코드를 어디에 두는가로 갈립니다. 기준은 **신뢰 경계**입니다.

| 구분 | 계약에 의한 설계 | 방어적 프로그래밍 |
|------|----------------|-----------------|
| 적용 위치 | 신뢰 경계 **안** — 같은 팀·같은 코드베이스의 협력 | 신뢰 경계 **밖** — 외부 입력 (HTTP 요청·파일·타 시스템) |
| 기본 태도 | 계약을 지켰다고 **신뢰**하고, 위반은 버그로 취급해 즉시 실패 | 무엇이 들어올지 모르니 **모든 입력을 의심**하고 정화 |
| 위반 시 처리 | 예외로 빠르게 실패 — 어긴 쪽 코드를 고칩니다 | 거부·정규화·기본값 대체 등 회복 처리 |
| 중복 검증 | 계약이 명시되면 안쪽 계층의 재검증을 **제거**할 수 있습니다 | 경계 지점에서는 검증이 의무입니다 |

둘은 경쟁 관계가 아니라 배치의 문제입니다. 경계에서 Bean Validation으로 방어하고, 경계 안쪽에서는 계약을 믿고 검증 중복을 걷어내는 조합이 실무 표준입니다. 모든 계층에서 같은 값을 반복 검증하는 코드는 계약이 없다는 신호입니다.

## 같은 인사이트 패턴 — "규약을 문서가 아니라 실행 가능한 형태로"

주석·위키에만 적힌 규약은 코드와 어긋나도 아무도 모릅니다. 규약을 실행 가능한 형태로 옮겨 위반이 즉시 드러나게 하는 패턴이 위키의 여러 페이지에 반복됩니다.

| 페이지 | 규약 | 실행 가능한 형태 |
|--------|------|----------------|
| **이 페이지** | 호출자·메서드 간 약속 | `requireNonNull`·`if-throw`·`assert`·`@Valid`가 위반 즉시 예외 |
| [[concept-tdd-laws-and-first]] | 코드가 해야 할 일의 명세 | 테스트 코드 — 실행하면 통과/실패로 판정되는 명세 |
| [[concept-jspecify-null-safety]] | null 가능 여부 | `@Nullable` 타입 표기 — 정적 분석기가 컴파일 시점에 위반 차단 |

## 빠른 진단 체크리스트

- [ ] public 메서드의 사전조건을 `requireNonNull` + `if-throw`로 명시적으로 검증하는가?
- [ ] 인자 잘못은 `IllegalArgumentException`, 상태 잘못은 `IllegalStateException`으로 구분하는가?
- [ ] `assert`를 public API 검증에 쓰고 있지 않은가? (`-ea` 없이는 침묵)
- [ ] 자식 클래스가 부모보다 엄격한 사전조건을 요구하지 않는가? (LSP)
- [ ] 핵심 도메인 객체의 불변식이 코드로 존재하는가? (private `invariant()` + `assert`)
- [ ] 신뢰 경계 안에서 같은 값을 계층마다 반복 검증하고 있지 않은가?

## 원본 출처

- raw: `raw/object/오브젝트 실전 강의 교재 부록A.md` — 조영호 『오브젝트』 부록 A
- 원전: Bertrand Meyer, *Object-Oriented Software Construction* (Prentice Hall, 1판 1988 / 2판 1997) — [Wikipedia: Design by contract](https://en.wikipedia.org/wiki/Design_by_contract)
- 상표·Eiffel 구현: [Eiffel Software — Design by Contract](https://www.eiffel.com/values/design-by-contract/)

## 관련 페이지

- [[lecture-object-appendixA]] — 이 페이지의 기반 강의노트 (자식의 계약·가변성 상세)
- [[concept-oop]] — 책임 분배 관점의 OOP, 계약은 책임의 형식화
- [[entity-object]] — 『오브젝트』 책 전체 지도
- [[lecture-effective-java-ch10]] — 표준 예외 관례 (Item 72)·예외 문서화
- [[concept-jspecify-null-safety]] — null 계약의 컴파일 시점 강제
- [[concept-tdd-laws-and-first]] — 테스트 = 실행 가능한 명세 (같은 패턴)
- [[concept-solid]] — LSP를 포함한 SOLID 5원칙
