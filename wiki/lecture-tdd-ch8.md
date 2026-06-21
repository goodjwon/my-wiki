---
title: "TDD 실전 강의 — 8장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 8장.md]
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 실전 강의 교재

## 8장 — 객체 만들기

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 할 일 → RED → GREEN → REFACTOR → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, JUnit 5

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 호출자가 `new Dollar(5)` / `new Franc(5)` 같이 **구체 클래스를 직접 알지 않도록** 정적 팩터리 메서드를 도입한다.
- `Money.dollar(5)` / `Money.franc(5)` 가 호출자의 진입점.
- **호출자가 구체 클래스를 모르면** 11장에서 자식 클래스를 제거할 때 호출자 코드 무영향.
- *Effective Java* Item 1 (생성자 대신 정적 팩터리 메서드) 가 TDD 사이클에서 자연 도입.

### 0.2 큰 그림 — "캡슐화의 두 번째 층"

```
[ 1층 — 필드 캡슐화 ]                [ 2층 — 생성 캡슐화 ]
 (4장)                                (8장)
 amount private                       new Dollar() 노출 X
 → 내부 표현 자유                       → 구체 클래스 자유
```

> **비유 — "메뉴판 vs 주방"**
>
> 손님은 메뉴판 (`Money.dollar(5)`) 만 봄. 주방에서 어떤 그릇 (`Dollar` / `Franc` / `Money`) 으로 만드는지는 가게 마음. 주방을 바꿔도 메뉴판이 같으면 손님 불만 없음.

### 0.3 현업에서 왜 중요한가

- `new Foo()` 직접 호출 = 호출자가 구체 클래스에 결합. 교체 자유 잃음.
- Spring DI 가 정확히 이 원리 — 호출자는 인터페이스만, 생성은 컨테이너.
- `ResponseEntity.ok()`, `List.of()`, `LocalDate.now()` 등 표준 라이브러리도 같은 패턴.

---

## 1. 할 일 목록 갱신

```
[x] Dollar 와 Franc 중복 제거
[x] 통화가 다르면 equals false
[ ] Money.dollar() / Money.franc() 도입   ← 이번
[ ] hashCode()
[ ] $5 + 10 CHF = $10
```

---

## 2. RED — 호출자 의도 명시

테스트를 새 진입점으로 다시 쓰기:

```java
@Test
void 곱셈() {
    Money five = Money.dollar(5);
    assertEquals(Money.dollar(10), five.times(2));
}

@Test
void Franc_곱셈() {
    Money five = Money.franc(5);
    assertEquals(Money.franc(10), five.times(2));
}
```

→ 컴파일 실패. `Money.dollar`·`Money.franc` 없음.

---

## 3. GREEN — 정적 팩터리 추가

### 단계 1: 정적 메서드 만들기

```java
public class Money {
    protected final int amount;
    protected Money(int amount) { this.amount = amount; }

    public static Money dollar(int amount) { return new Dollar(amount); }
    public static Money franc(int amount)  { return new Franc(amount); }

    // equals 등 그대로
}
```

호출자는 `Money.dollar(5)` 만 사용. 내부에서 `new Dollar(5)` 는 숨김.

### 단계 2: 반환 타입을 `Money` 로

기존 `times` 는 자식 타입 반환 (`Dollar.times(...)` → `Dollar`):

```java
public class Dollar extends Money {
    public Dollar(int amount) { super(amount); }
    public Money times(int multiplier) { return Money.dollar(amount * multiplier); }
    //     ^^^^^^ Dollar → Money
}

public class Franc extends Money {
    public Franc(int amount) { super(amount); }
    public Money times(int multiplier) { return Money.franc(amount * multiplier); }
}
```

→ 호출자가 받는 타입은 항상 `Money`. 구체 자식 클래스 노출 X.

### 단계 3: `times` 를 부모로 끌어올림 (예고)

자식의 `times` 가 거의 같은 구조 — 9·10장에서 통합.

---

## 4. REFACTOR — 호출자 코드 모두 새 진입점으로

기존에 `new Dollar(5)` 직접 호출하는 곳이 있으면 모두 `Money.dollar(5)` 로 교체.

테스트만 있는 현재 단계에서는 테스트 코드만 변경. 실제 프로젝트라면 IDE Find Usages 로 전체 코드베이스 일괄 교체.

---

## 5. 통과했지만 — 자식 클래스가 점점 빈약해진다

`Dollar` 의 메서드:
- 생성자 — 사실상 부모 호출만
- `times` — `Money.dollar` 호출만 (자식 알 필요 사실 없음)

→ 자식 클래스가 거의 비어가는 신호. **9·10·11장에서 자식 클래스 자체 제거** 가능성.

---

## 6. 현업 예제 — Spring·Java 표준 라이브러리

### Spring `ResponseEntity`

```java
ResponseEntity<User> response = ResponseEntity.ok(user);   // 정적 팩터리
ResponseEntity<Void> notFound = ResponseEntity.notFound().build();
```

→ 의도가 메서드 이름으로 드러남. `new ResponseEntity<>(user, HttpStatus.OK)` 보다 훨씬 명료.

### 표준 라이브러리

```java
List<Integer> list = List.of(1, 2, 3);           // 정적 팩터리
Map<String, Integer> map = Map.of("a", 1);
Optional<User> user = Optional.of(found);
LocalDate today = LocalDate.now();
Stream<String> stream = Stream.of("a", "b");
```

### *Effective Java* Item 1 — 4가지 장점

1. **이름이 있다** — `Money.dollar(5)` vs `new Money(5, "USD")` 의 의도 차이.
2. **호출마다 인스턴스 생성 안 해도 됨** — 캐싱 가능 (`Boolean.valueOf`).
3. **서브타입 반환 가능** — 호출자는 `Money` 받지만 실제는 `Dollar` (8장 정확히 이 패턴).
4. **입력 매개변수에 따라 다른 클래스 반환 가능** — `EnumSet.of(...)` 가 원소 수에 따라 다른 구현 반환.

---

## 7. 함정 / 주의

- **정적 팩터리만 두면 상속 불가** — Item 1 단점 1. 단, 컴포지션 권장 시대에는 큰 단점 아님.
- **이름 짓기 어려움** — 표준 (`of`/`from`/`valueOf`/`getInstance`/`create`/`newInstance`) 따르면 일관.
- **생성자도 같이 노출하면** 호출자가 새 진입점 안 쓰고 옛 방식 그대로. 생성자를 `private`/`protected` 로 막아 강제.

---

## 8. 체크리스트 (8장 완료 기준)

- [ ] 호출자가 `new Dollar(...)`·`new Franc(...)` 직접 호출 0인가
- [ ] `Money.dollar(...)` / `Money.franc(...)` 만 사용하는가
- [ ] `times` 반환 타입이 `Money` (자식 노출 X) 인가
- [ ] 생성자가 `private`/`protected` 로 외부 접근 막혔는가 (선택)

---

## 9. 퀴즈

1. 정적 팩터리 메서드의 4가지 장점 (Item 1)?
2. `Money.dollar(5)` 가 `new Dollar(5)` 보다 좋은 실용적 이유?
3. Spring `ResponseEntity.ok(...)` 가 8장의 어느 원리?
4. 호출자가 자식 클래스를 모르게 한 후 다음 단계는?
5. record 와 정적 팩터리는 어떻게 조합되나?

### 정답·해설

1. (1) 이름이 있어 의도 명확, (2) 매번 인스턴스 안 만들고 캐싱 가능, (3) 서브타입 반환 (구체 숨김), (4) 입력에 따라 다른 클래스 반환.
2. **호출자가 구체 클래스 (`Dollar`) 를 모름** → 나중에 자식 클래스를 제거하거나 새 구현 (예: `CachedDollar`) 으로 교체해도 호출자 코드 무변경. 교체 자유의 핵심.
3. **3번 장점 — 서브타입 반환**. 호출자는 `ResponseEntity<User>` 받지만 내부는 다른 구현일 수 있음. 의도 (`ok`·`notFound`·`badRequest`) 가 이름으로 드러남.
4. **자식 클래스 자체 제거** (11장). 호출자가 모르므로 안전. `Money` 단일 클래스 + `currency` 필드로 통합.
5. record 자체에 정적 팩터리 추가 가능. `public record Money(int amount, String currency) { public static Money dollar(int amount) { return new Money(amount, "USD"); } }`. record 의 자동 생성자 + 의미 있는 정적 팩터리 조합.

---

## 다음 장 예고 — 9장: 우리가 사는 시간(times)

자식 클래스의 `times` 가 거의 같은 구조 — 슈퍼클래스 `Money` 로 끌어올릴 수 있을지 탐색. `currency` 필드를 도입해 자식 차이를 데이터로 표현 가능. 11장의 "자식 클래스 제거" 의 전초전.
