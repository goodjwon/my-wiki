---
title: "TDD 실전 강의 — 9장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 9장.md]
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 실전 강의 교재

## 9장 — 우리가 사는 시간(times)

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 할 일 → REFACTOR → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, JUnit 5

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 자식 클래스의 `times` 가 거의 같은 구조 — **차이는 반환 객체 생성자뿐**.
- `currency` 필드를 도입하면 차이가 **데이터** 로 환원.
- 자식 차이를 데이터로 표현 → 자식 클래스 자체가 점점 빈약 → 제거의 길.
- "**타입으로 표현하던 차이를 데이터로**" 라는 OO 의 핵심 전략을 손에 익힌다.

### 0.2 큰 그림 — "타입 코드 → 데이터"

```
[ 현재 ]                              [ 9장 후 ]                       [ 11장 ]
 Dollar.times → Dollar 생성           Money.times + currency 필드      자식 클래스 제거
 Franc.times → Franc 생성             (자식이 거의 빈 껍데기)            Money 한 클래스만
```

> **비유 — "공장 라인 통합"**
>
> 두 라인 (Dollar 공장·Franc 공장) 이 같은 제품 (Money) 을 만들고 있다면, 한 라인 + 통화 라벨로 충분. 라인 두 개는 낭비.

### 0.3 현업에서 왜 중요한가

- "타입 코드를 서브클래스로" (*리팩터링* 12.6) 의 정반대 — **서브클래스를 타입 코드로** (12.7 서브클래스 제거).
- 도메인 객체 (결제 수단·할인 등급) 를 자식 클래스로 폭증시키지 말고, 필드 + 정책 객체로 표현하는 게 보통 더 단순.

---

## 1. 할 일 목록 갱신

```
[x] Dollar 와 Franc 중복 제거
[x] 통화가 다르면 equals false
[x] Money.dollar() / Money.franc()
[ ] times 를 Money 부모로                ← 이번
[ ] 자식 클래스 제거                      ← 11장
[ ] hashCode()
[ ] $5 + 10 CHF = $10
```

---

## 2. 현재 자식 `times` 비교

```java
public class Dollar extends Money {
    public Money times(int multiplier) { return Money.dollar(amount * multiplier); }
}

public class Franc extends Money {
    public Money times(int multiplier) { return Money.franc(amount * multiplier); }
}
```

**차이는 단 하나** — `Money.dollar` 호출 vs `Money.franc` 호출. 즉 **반환 객체의 통화**.

→ **통화를 필드로** 만들면 차이가 사라진다.

---

## 3. REFACTOR — currency 필드 도입

### 단계 1: Money 에 currency 필드 추가

```java
public class Money {
    protected final int amount;
    protected final String currency;

    protected Money(int amount, String currency) {
        this.amount = amount;
        this.currency = currency;
    }

    public String currency() { return currency; }

    public static Money dollar(int amount) { return new Dollar(amount); }
    public static Money franc(int amount)  { return new Franc(amount); }

    @Override
    public boolean equals(Object o) {
        if (o == null) return false;
        if (getClass() != o.getClass()) return false;
        Money m = (Money) o;
        return amount == m.amount;
    }
}
```

### 단계 2: 자식 생성자가 currency 부모로 전달

```java
public class Dollar extends Money {
    public Dollar(int amount) { super(amount, "USD"); }
    public Money times(int multiplier) { return Money.dollar(amount * multiplier); }
}

public class Franc extends Money {
    public Franc(int amount) { super(amount, "CHF"); }
    public Money times(int multiplier) { return Money.franc(amount * multiplier); }
}
```

### 단계 3: 테스트 추가

```java
@Test
void 통화() {
    assertEquals("USD", Money.dollar(1).currency());
    assertEquals("CHF", Money.franc(1).currency());
}
```

→ 통과.

---

## 4. 통과했지만 — `times` 통합 가능?

자식 `times` 가 여전히 다름:
```java
return Money.dollar(amount * multiplier);   // Dollar
return Money.franc(amount * multiplier);    // Franc
```

근데 둘 다 결국 "**같은 통화로 새 Money**" 만들기. `currency` 필드가 있으니:

```java
return new Money(amount * multiplier, currency);   // 통합 가능?
```

→ `Money` 가 추상 클래스라 인스턴스화 불가. **10장에서 추상 제거** + 통합.

> **TDD 의 단계 분해**: 한 번에 통합하지 않고, `currency` 필드 도입 (9장) → `times` 통합 (10장) → 자식 제거 (11장). 각 단계가 작고 안전.

---

## 5. 현업 예제 — 자식 클래스를 필드로

### 사례: 결제 수단

```java
// Before — 자식 클래스 폭증
public abstract class Payment { ... }
public class CardPayment extends Payment { ... }
public class BankTransferPayment extends Payment { ... }
public class MobilePayment extends Payment { ... }
public class CryptoPayment extends Payment { ... }
// 결제 수단 추가마다 새 클래스 + 모든 `instanceof` 위치 수정

// After — 필드 + 정책 객체
public class Payment {
    private final PaymentMethod method;   // enum
    private final PaymentDetails details;  // 메서드별 부가 데이터
    // 동작은 method 가 결정 — Strategy 패턴
}

public enum PaymentMethod {
    CARD, BANK_TRANSFER, MOBILE, CRYPTO;
}
```

새 결제 수단 = enum 상수 + 정책 추가. 자식 클래스 폭증 X.

### *리팩터링* 12.7 서브클래스 제거

이 변환이 정확히 12.7. 9·10·11장이 그 살아있는 사례.

---

## 6. 함정 / 주의

- **자식 클래스 제거가 항상 정답 X**. 자식별로 **본질적으로 다른 동작** 이 있으면 다형성이 더 깔끔.
- 9~11장의 Money 는 자식별 차이가 **반환 객체의 통화뿐** 이라 데이터로 환원 가능. 동작이 진짜로 다르면 다른 결정.
- 필드 + switch 가 가독성 떨어지면 → 다형성 복귀 검토 ([[entity-refactoring]] 10.4).

---

## 7. 체크리스트 (9장 완료 기준)

- [ ] Money 에 `currency` 필드 + accessor 가 있는가
- [ ] 자식 생성자가 currency 를 부모로 전달하는가
- [ ] `times` 통합 가능성을 인지하고 다음 장에 빚으로 적었는가
- [ ] 모든 테스트 초록인가

---

## 8. 퀴즈

1. 자식 클래스의 `times` 차이가 단 하나 — 무엇이었나?
2. 그 차이를 어떻게 데이터로 환원했나?
3. *리팩터링* 의 어떤 기법이 9~11장 변환의 이름?
4. 9장에서 `times` 를 아직 통합 안 한 이유?
5. 자식 클래스 제거가 항상 정답이 아닌 경우는?

### 정답·해설

1. **반환 객체의 통화** — `Money.dollar(...)` vs `Money.franc(...)`. 그 외는 모두 동일.
2. **`currency` 필드 도입**. 자식이 부모 생성자에 `"USD"` / `"CHF"` 를 전달. 타입으로 표현하던 차이가 필드로.
3. **12.6 타입 코드를 서브클래스로 (Replace Type Code with Subclasses)** 의 정반대 — **12.7 서브클래스 제거 (Remove Subclass)**. 차이가 단순해지면 자식 → 필드로.
4. **단계 분리** — 한 번에 너무 많이 변경하면 실패 추적 어려움. currency 필드 도입 (9장) → times 통합 (10장) → 자식 제거 (11장). 각 단계가 작고 안전.
5. **자식별로 본질적으로 다른 동작** 이 있을 때. 예: `EmailNotification.send()` 와 `SmsNotification.send()` 가 진짜 다른 알고리즘이면 다형성이 더 깔끔. 9~11장 Money 는 차이가 데이터로 환원 가능한 특수 경우.

---

## 다음 장 예고 — 10장: 흥미로운 시간(times)

자식 `times` 가 모두 `return new Money(amount * multiplier, currency)` 로 통합 가능한지 확인 — Money 가 추상이라는 마지막 장애물 제거.
