---
title: "오브젝트 실전 강의 — 부록 A"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 부록A.md]
created: 2026-06-21
updated: 2026-06-27
---

# 오브젝트 실전 강의 교재

## 부록 A — 계약에 의한 설계 (Design by Contract)

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **계약 (Contract)** 의 의미와 3 요소 (사전·사후·불변).
- 계약 어길 시 **누구 책임** 의 명시화 — 호출자 vs 메서드.
- **자식의 계약 규칙** (LSP 의 형식적 기반) — 공변·반공변.
- 자바에서 계약 표현 — `requireNonNull`·`assert`·`@NonNull`·Javadoc·Bean Validation.
- *Effective Java* Item 49·56·70 과 직접 연결.

### 0.2 큰 그림 — 계약의 3 요소

```
[ 사전조건 (Precondition) ]
  메서드 호출 전 만족해야 할 조건
  → 호출자 책임 (어기면 호출자 잘못)

[ 메서드 본문 ]
  사전조건이 참이면 동작 보장

[ 사후조건 (Postcondition) ]
  메서드 반환 후 만족하는 조건
  → 메서드 책임 (어기면 메서드 잘못)

[ 불변식 (Invariant) ]
  객체가 항상 (모든 메서드 호출 전후) 만족하는 조건
  → 객체 책임 (어기면 도메인 일관성 깨짐)
```

> **비유 — "계약서"**
>
> 집을 사고파는 매매 계약을 떠올려 봅시다. 구매자는 계약하기 전에 대금을 치를 자격을 갖춰야 하고, 판매자는 계약이 끝나면 약속한 집을 온전히 넘겨줍니다. 그리고 거래가 진행되는 동안 그 집은 망실되지 않고 그대로 유지되어야 합니다. 어느 한쪽이 이 약속을 어기면, 어긴 쪽이 책임을 집니다.
>
> 계약에 의한 설계도 같은 순서를 따릅니다. 계약하기 전에 갖춰야 할 자격이 사전조건이고, 거래가 끝난 뒤 보장되는 약속이 사후조건이며, 거래 내내 깨지면 안 되는 상태가 불변식입니다. 그리고 조건을 어긴 쪽이 책임을 진다는 원칙도 그대로입니다.

### 0.3 현업에서 왜 중요한가

- **API 의 계약 명시** = 사용자 (호출자) 의 책임과 우리 (메서드) 의 책임 명확화.
- 13장 LSP 의 형식적 기반 — "자식이 부모 대체 가능" 의 정확한 의미.
- Spring `@Valid`·Bean Validation 이 정확히 사전조건의 자동화.
- *Effective Java* Item 49 (매개변수 검증)·56 (Javadoc)·70 (예외) 의 종합.

---

## 1. 협력과 계약

### 1.1 부수효과를 명시적으로

메서드의 동작을 **외부에 약속** — 코드·문서·검증으로 보이게.

> 명시되지 않은 약속 = 호출자가 추측. 추측이 빗나가면 버그.

### 1.2 Bertrand Meyer 와 Eiffel

계약에 의한 설계 (DbC) = Bertrand Meyer 가 Eiffel (1986) 언어에서 도입.
- 언어 차원에서 `require` (사전)·`ensure` (사후)·`invariant` (불변) 키워드.
- 자바에는 직접 없지만 동일 사고 적용 가능.

---

## 2. 계약에 의한 설계 — 3 요소

### 2.1 사전조건 (Precondition)

> **메서드 호출 전 만족해야 할 조건**. 호출자 책임.

```java
public Money withdraw(int amount) {
    // 사전조건: amount > 0 && amount <= balance
    if (amount <= 0)
        throw new IllegalArgumentException("amount must be positive: " + amount);
    if (amount > balance)
        throw new InsufficientBalanceException(balance, amount);

    balance -= amount;
    return new Money(amount, currency);
}
```

#### 사전조건 위반 = 호출자 잘못

- 호출자가 음수·잔액 초과를 보낸 것.
- 메서드는 잘못된 호출을 거부 (예외) 하지만, **호출자 책임으로 둠**.

#### Spring `@Valid` = 사전조건 자동화

```java
@PostMapping("/orders")
public OrderResponse create(@Valid @RequestBody CreateOrderRequest req) {
    // @Valid 가 사전조건 (userId 비어있지 X, amount > 0 등) 검증
    return orderService.create(req);
}

public record CreateOrderRequest(
    @NotBlank String userId,
    @Positive int amount
) {}
```

→ Bean Validation 이 사전조건을 어노테이션으로. Spring 이 자동 검증.

### 2.2 사후조건 (Postcondition)

> **메서드 반환 후 만족하는 조건**. 메서드 책임.

```java
public Money withdraw(int amount) {
    int oldBalance = balance;
    // 사전조건 검증 생략 표시
    balance -= amount;
    Money result = new Money(amount, currency);

    // 사후조건:
    // 1. balance == oldBalance - amount
    // 2. 반환값 == new Money(amount, currency)
    assert balance == oldBalance - amount : "balance not decremented correctly";
    assert result.amount() == amount : "returned wrong amount";
    return result;
}
```

#### 사후조건 위반 = 메서드 잘못

- 메서드가 약속한 결과를 안 줌. 호출자는 책임 없음.

#### 자바에서의 표현

- 본문 후 `assert` (개발 환경에서만).
- 단위 테스트로 검증.
- Javadoc `@return` 으로 명시.

### 2.3 불변식 (Invariant)

> **객체가 항상 (모든 메서드 호출 전후) 만족하는 조건**.

```java
public class Account {
    private int balance;

    // 불변식: balance >= 0 (모든 시점)

    public Account(int initial) {
        if (initial < 0) throw new IllegalArgumentException();
        this.balance = initial;
        // 불변식 만족 확인
        assert invariant();
    }

    public void withdraw(int amount) {
        // 사전조건
        if (amount <= 0 || amount > balance) throw new IllegalArgumentException();
        balance -= amount;
        // 불변식 유지 확인
        assert invariant();
    }

    public void deposit(int amount) {
        if (amount <= 0) throw new IllegalArgumentException();
        balance += amount;
        assert invariant();
    }

    private boolean invariant() {
        return balance >= 0;
    }
}
```

→ **모든 public 메서드 종료 시점에 불변식 유지**. 객체가 자기 일관성 책임.

---

## 3. 계약에 의한 설계와 서브타이핑

### 3.1 계약 규칙 — 자식의 계약 (Liskov)

자식이 부모 대체하려면:

| 요소 | 자식의 규칙 | 방향 |
|------|------------|------|
| **사전조건** | 부모와 같거나 **더 완화** | 반공변 (contravariant) |
| **사후조건** | 부모와 같거나 **더 강화** | 공변 (covariant) |
| **불변식** | 부모 것 **유지** | invariant |

> 한 줄로: "**자식은 더 받아들이고 더 보장한다**".

### 3.2 위반 예시

#### 사전조건 강화 — LSP 위배

```java
public class Account {
    public void deposit(int amount) {
        if (amount <= 0) throw new IllegalArgumentException();   // 사전: amount > 0
        balance += amount;
    }
}

public class PremiumAccount extends Account {
    @Override
    public void deposit(int amount) {
        if (amount < 10000) throw new IllegalArgumentException();   // 사전: amount >= 10000 (더 엄격)
        super.deposit(amount);
    }
}

// 클라이언트
void process(Account a) {
    a.deposit(5000);   // 부모 계약으로는 OK, PremiumAccount 면 예외 — LSP 위배
}
```

→ 부모 계약 (amount > 0) 으로는 5000 OK 인데 자식이 거부 → 클라이언트 깨짐.

#### 사후조건 약화 — LSP 위배

자식이 부모보다 약한 보장 → 클라이언트가 기대한 결과 못 얻음.

### 3.3 가변성 규칙 (자바)

- **반환 타입**: 공변 가능 — 자식이 더 구체적 타입 반환 OK.
- **매개변수 타입**: invariant — 자바 메서드 오버라이드는 매개변수 동일.
- **예외**: 자식이 부모보다 더 좁은 예외 던지기 OK (체크 예외).

### 3.4 함수 타입과 서브타이핑

함수형 언어 (Haskell·Scala) 에서 함수 타입의 공변/반공변 규칙.

```scala
// Scala
val f: (Animal => String) = (a: Animal) => a.name   // 부모 → String
val g: (Dog => Object) = f                            // 자식 → Object (반공변·공변)
```

자바의 `Function<? super T, ? extends R>` 가 같은 정신.

---

## 4. 자바에서 계약 표현

### 4.1 명시적 검증 (사전조건)

```java
public void withdraw(int amount) {
    Objects.requireNonNull(amount, "amount");
    if (amount <= 0) throw new IllegalArgumentException("amount must be positive: " + amount);
    if (amount > balance) throw new InsufficientBalanceException(balance, amount);
    // ... 본문
}
```

→ public 메서드는 항상 명시적 검증 (운영에서도 작동).

### 4.2 어서션 (개발·테스트)

```java
private void process(int[] sorted) {
    assert sorted != null && isSorted(sorted) : "sorted is required";
    // ...
}
```

- `-ea` JVM 옵션 켜야 작동. 운영은 비활성.
- private 메서드 + 사후조건·불변식 검증에 적합.
- public API 검증에는 부적합 (운영에서 안 작동).

### 4.3 정적 분석 — `@NonNull` · JSpecify

```java
import org.jspecify.annotations.NonNull;

public void send(@NonNull String message, @NonNull User recipient) { ... }
```

→ IDE·정적 분석기가 컴파일 전 검증. `null` 전달 가능성을 경고.

### 4.4 Javadoc — 계약 문서화

```java
/**
 * 계좌에서 금액을 인출한다.
 *
 * @param amount 인출 금액 (양수, 잔액 이하 — 사전조건)
 * @return 인출된 금액 객체 (amount 와 동일 금액)
 * @throws IllegalArgumentException amount <= 0 또는 amount > balance
 * @throws IllegalStateException 계좌가 동결 상태
 */
public Money withdraw(int amount) { ... }
```

→ *Effective Java* Item 56.

### 4.5 Bean Validation (사전조건 자동화)

```java
public record CreateUserRequest(
    @NotBlank @Email String email,
    @NotBlank @Size(min = 8, max = 50) String password,
    @NotNull @Past LocalDate birthDate
) {}
```

→ Spring `@Valid` 가 자동 검증. 사전조건의 선언적 표현.

### 4.6 종합 — 계약 표현 매트릭스

| 위치 | 도구 |
|------|------|
| **public API 사전조건** | `requireNonNull` + `if-throw` + Bean Validation |
| **public API 사후조건** | 단위 테스트 + Javadoc `@return` |
| **public API 예외** | Javadoc `@throws` |
| **private 메서드** | `assert` |
| **불변식** | private `invariant()` 메서드 + `assert` |
| **컴파일 시점** | `@NonNull` / JSpecify |

---

## 핵심 교훈

1. **계약 = 객체 협력의 약속** — 사전·사후·불변.
2. **사전조건 위반 = 호출자 책임**, **사후조건 위반 = 메서드 책임**, **불변식 위반 = 객체 책임**.
3. **자식의 계약** = 사전 완화·사후 강화·불변 유지. LSP 의 형식적 기반.
4. **자바 표현** = `requireNonNull`·`assert`·`@NonNull`·Javadoc·Bean Validation 의 조합.
5. **Spring `@Valid`** = 사전조건의 선언적 자동화.

---

## 함정 / 주의

- **Java `assert` 는 기본 비활성** — 운영 검증에 부적합. public 은 `if-throw`.
- **계약 도그마 X** — 모든 메서드에 사전·사후 명시는 과함. **핵심 도메인** 만.
- **사전조건 강화 = LSP 위배** — 자식이 부모보다 엄격하면 클라이언트 깨짐.
- **불변식 검증 X** — 객체가 일관성 깨진 상태로 동작하면 추적 어려운 버그.

---

## 체크리스트

- [ ] public 메서드에 사전조건 검증 (requireNonNull + if-throw)
- [ ] Javadoc 에 `@param` (사전)·`@return` (사후)·`@throws` 명시
- [ ] Spring DTO 에 Bean Validation 어노테이션
- [ ] 자식 클래스가 부모 계약 강화 안 하는가 (LSP)
- [ ] 객체의 불변식이 코드에 명시 (private invariant 메서드)

---

## 퀴즈

1. **계약의 3 요소** 와 각각의 책임 주체?
2. **자식 계약 규칙** — 사전·사후·불변의 가변성?
3. **사전조건 강화** 가 LSP 위배인 이유?
4. 자바에서 **public API 계약 표현** 의 표준 도구 3 가지?
5. **Spring `@Valid`** 가 계약에 의한 설계의 어느 부분?

### 정답·해설

1. **사전조건** = 호출 전 조건, **호출자 책임**. **사후조건** = 반환 후 조건, **메서드 책임**. **불변식** = 항상 만족, **객체 책임**.
2. **사전**: 부모와 같거나 더 **완화** (반공변). **사후**: 부모와 같거나 더 **강화** (공변). **불변식**: 부모 것 **유지**. 한 줄로 "자식은 더 받아들이고 더 보장".
3. **클라이언트가 부모 계약으로 호출 가능** 한데 자식이 거부 → 클라이언트 입장에서 자식 인스턴스가 부모 자리에 들어오면 갑자기 거부당함. 다형성 깨짐 — LSP (자식이 부모 대체 가능) 위배.
4. **(1) 명시적 검증** (`requireNonNull` + `if-throw` + Bean Validation), **(2) Javadoc** (`@param`·`@return`·`@throws`), **(3) 정적 분석** (`@NonNull` / JSpecify). 세 가지 조합이 표준.
5. **사전조건의 선언적 자동화**. `@Valid` + `@NotBlank`·`@Positive` 같은 Bean Validation 어노테이션이 사전조건을 선언적으로 표현, Spring 이 컨트롤러 진입 시 자동 검증. 위반 시 `MethodArgumentNotValidException`.

---

## 다음 — 부록 B: 타입 계층의 구현

타입 계층을 표현하는 여러 메커니즘 — 클래스·인터페이스·추상 클래스·결합·덕 타이핑·믹스인. 각 메커니즘의 트레이드오프 비교.
