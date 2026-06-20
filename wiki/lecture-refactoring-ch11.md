---
title: "리팩터링 2판 실전 강의 — 11장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 11장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 11장 — API 리팩터링

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 공개 API의 **계약(시그니처·매개변수·반환·예외)** 을 다듬는 13가지.
- ★ **CQS(질의-변경 분리, 11.1)** — 동시성·테스트·예측 가능성의 기반.
- 생성자·플래그·예외 처리의 표준 변환.
- "한 번 공개되면 영원하다" 의 책임감.

### 0.2 큰 그림 — 6 묶음

```
[ CQS·매개변수 ]                 [ 변경 형태 ]                  [ 호출 형태 ]
 11.1 질의-변경 분리 (CQS) ★      11.4 객체 통째로 넘기기         11.9 함수 → 명령
 11.2 함수 매개변수화              11.5 매개변수 → 질의            11.10 명령 → 함수 (반대)
 11.3 플래그 인수 제거             11.6 질의 → 매개변수 (반대)
                                   11.7 세터 제거

[ 생성·반환·예외 ]
 11.8 생성자 → 팩터리
 11.11 수정된 값 반환
 11.12 오류 코드 → 예외
 11.13 예외 → 사전 확인
```

> **비유 — API는 "식당 메뉴판"입니다.**
>
> 한 번 인쇄해 손님이 외운 메뉴는 함부로 못 바꿈. 메뉴 이름·옵션·세트 구성·가격 단위 — 처음 설계가 영원.

### 0.3 현업에서 왜 중요한가

- Controller·Service·Repository의 public 메서드 = 회사의 자산.
- *Effective Java* 51·52·53·56과 거의 1:1 대응.
- API 변경 한 번에 호출자 N+1 PR — 마이그레이션 비용 큼.

---

## 11.1 질의 함수와 변경 함수 분리하기 (Separate Query from Modifier) ★

### 한 줄 정의

**값을 반환하는 함수는 부작용을 가지면 안 된다** (CQS — Command-Query Separation).

```java
// Before — getter인데 부작용
public String getTotalOutstandingAndSendBill() {
    double total = customer.totalOutstanding();
    sendBillEmail(customer);   // ❌ 부작용
    return total;
}

// After — 분리
public double totalOutstanding() {
    return customer.totalOutstanding();
}

public void sendBill() {
    sendBillEmail(customer);
}
```

### 동기

- 호출 순서·횟수가 결과에 영향 없음 → **추론·테스트·캐싱** 모두 쉬워짐.
- 부작용 있는 메서드는 명령 (`sendBill`), 없는 메서드는 질의 (`totalOutstanding`) — **이름으로 구분**.

### 함정

- "현재 값을 가져오면서 카운터 증가" 같은 통계용 부작용도 위험. 진짜 조회와 분리.

### *오브젝트* 연결

6.04 "명령-쿼리 분리 원칙" 과 같은 메시지.

---

## 11.2 함수 매개변수화하기 (Parameterize Function)

### 한 줄 정의

비슷한 일을 하는 여러 함수를 **매개변수화한 하나** 로.

```java
// Before
double tenPercentRaise(Employee e) { return e.salary * 1.10; }
double fivePercentRaise(Employee e) { return e.salary * 1.05; }

// After
double raise(Employee e, double rate) { return e.salary * (1 + rate); }
```

### 동기

- 중복 제거.
- 의도가 매개변수로 명시.

### 함정

- 매개변수가 너무 다양해지면 함수 책임이 흐려짐 — 매개변수 객체(6.8) 고려.

---

## 11.3 플래그 인수 제거하기 (Remove Flag Argument)

### 한 줄 정의

`boolean` 또는 enum 플래그가 함수 동작을 갈라놓는다면 **별도 함수** 로.

```java
// Before
shipOrder(order, true);    // true가 뭐?
shipOrder(order, false);

// After
shipOrderRegular(order);
shipOrderPriority(order);
```

### 동기

- 호출부에서 의도가 한 번에 보임.
- 함수 본문이 단순해짐.

### Effective Java 연결

Item 51(boolean 매개변수보다는 enum, 또는 분리).

### 함정

- 플래그가 3개 이상 조합되면 함수 폭발 — 그땐 매개변수 객체나 빌더 패턴 고려.

---

## 11.4 객체 통째로 넘기기 (Preserve Whole Object)

### 한 줄 정의

객체의 여러 필드를 따로 넘기지 말고 **객체 자체** 를 넘김.

```java
// Before
if (room.withinPlan(plan.low, plan.high)) { ... }

// After
if (room.withinPlan(plan)) { ... }
```

### 동기

- 매개변수 줄어듦.
- 호출 후 객체에 새 필드가 추가되어도 시그니처 안 바뀜.
- 그 객체 안의 행동 활용 가능.

### 함정

- **결합도 증가** — 받는 함수가 객체 전체를 알게 됨. 받는 쪽이 일부만 필요하면 그대로.

---

## 11.5 매개변수를 질의 함수로 바꾸기 (Replace Parameter with Query)

### 한 줄 정의

매개변수가 함수 안에서 **다른 매개변수로 유도 가능** 하면 제거.

```java
// Before
double finalPrice(double basePrice, double discountLevel) { ... }
finalPrice(basePrice, basePrice > 1000 ? 2 : 1);   // 호출자가 매번 계산

// After
double finalPrice(double basePrice) {
    int discountLevel = basePrice > 1000 ? 2 : 1;
    // ...
}
```

### 동기

- 호출 단순.
- 계산 로직 한 곳.

### 함정

- 호출자마다 다른 값이 필요해질 가능성이 있으면 매개변수 유지.

---

## 11.6 질의 함수를 매개변수로 바꾸기 (Replace Query with Parameter)

### 한 줄 정의

함수 안의 **불순한 의존**(전역 상태·외부 시스템 조회) 을 매개변수로 빼냄. 11.5의 반대.

```java
// Before — 함수 안에서 전역 상태 조회
double targetTemperature(HeatingPlan plan) {
    int currentTemp = thermostat.currentTemperature();   // 외부 의존
    return plan.adjustTo(currentTemp);
}

// After — 의존을 매개변수로
double targetTemperature(HeatingPlan plan, int currentTemp) {
    return plan.adjustTo(currentTemp);
}
```

### 동기

- 함수가 **순수** 해짐 — 테스트·재사용 쉬움.
- 의존 주입(DI) 의 한 형태.

---

## 11.7 세터 제거하기 (Remove Setter)

### 한 줄 정의

생성 후 변경되면 안 되는 필드의 setter는 제거.

```java
// Before
public class Person {
    private String name;
    public void setName(String name) { this.name = name; }
}

// After
public class Person {
    private final String name;
    public Person(String name) { this.name = name; }
    public String name() { return name; }
}
```

### 동기

- 불변성 → 동시성 안전, 추론 쉬움.
- "필드는 생성 시점에만 결정" 이라는 의도가 코드에 명시.

### Effective Java 연결

Item 17(변경 가능성 최소화).

### Spring/JPA 현업

JPA 엔티티의 setter 남용은 사고 단골. **변경이 필요한 행동만 메서드로**, 나머지는 setter 제거.

```java
// ❌ — 무지성 @Setter
@Setter
public class Order {
    private OrderStatus status;
}
order.setStatus(OrderStatus.CANCELLED);   // 검증·이벤트 없음

// ✅
public class Order {
    private OrderStatus status;
    public void cancel() {
        if (status != OrderStatus.PAID) throw new IllegalStateException();
        this.status = OrderStatus.CANCELLED;
        registerEvent(new OrderCancelledEvent(this));
    }
}
```

---

## 11.8 생성자를 팩터리 함수로 바꾸기 (Replace Constructor with Factory Function)

### 한 줄 정의

`new Foo(...)` 대신 **이름 있는 정적 메서드** `Foo.of(...)`.

```java
// Before
Employee e = new Employee("Sam", "Engineer", 5);

// After
Employee e = Employee.engineer("Sam", 5);
Employee m = Employee.manager("Sam", 5);
```

### 동기

- 의도가 이름으로 드러남.
- 서브타입 반환 가능 (`Employee` 타입으로 받지만 실제 `Engineer`).
- 생성 비용 캐싱·재사용 (예: `Boolean.valueOf`).

### Effective Java 연결

Item 1(정적 팩터리). 동일 권고.

---

## 11.9 함수를 명령으로 바꾸기 (Replace Function with Command)

### 한 줄 정의

복잡한 함수를 **상태를 가진 객체(Command)** 로 승격.

```java
// Before — 매개변수 많고 본문이 긴 함수
double score(Candidate candidate, MedicalExam exam, ScoringGuide guide) {
    // 100줄
}

// After — Command 객체
public class Scorer {
    private final Candidate candidate;
    private final MedicalExam exam;
    private final ScoringGuide guide;

    public Scorer(Candidate c, MedicalExam e, ScoringGuide g) { ... }

    public double execute() {
        // 100줄을 단계 메서드로 분해
        scoreBasic();
        scoreModifiers();
        return total;
    }

    private void scoreBasic() { ... }
    private void scoreModifiers() { ... }
}
```

### 동기

- 큰 함수를 **작은 private 메서드** 로 분해 가능 (필드 = 상태 공유).
- GoF Command 패턴.
- 실행 큐·재시도·취소 가능.

### 함정

- 단순 함수까지 Command화는 과함. **본문이 길고 단계 분해가 필요할 때**.

---

## 11.10 명령을 함수로 바꾸기 (Replace Command with Function)

### 한 줄 정의

복잡도가 사라진 Command를 다시 단순 함수로. 11.9의 반대.

---

## 11.11 수정된 값 반환하기 (Return Modified Value)

### 한 줄 정의

값을 변경하는 함수가 **변경된 값을 반환** 하게 → 호출자가 의도 인지.

```java
// Before
double total;
calculateAdjustments(orders, total);   // total이 바뀜? 안 바뀜?

// After
double total = calculateAdjustments(orders);   // 명확
```

### 동기

- 가변 매개변수보다 **반환값으로 새 값** 이 의도 명확.
- 함수형 스타일 일관.

---

## 11.12 오류 코드를 예외로 바꾸기 (Replace Error Code with Exception)

### 한 줄 정의

함수가 `-1` 같은 **오류 코드** 를 반환하면 예외로 전환.

```java
// Before
int code = doSomething();
if (code == -1) { /* 오류 처리 */ }
else if (code == -2) { /* 다른 오류 */ }

// After
try {
    doSomething();
} catch (NetworkException e) { ... }
  catch (ValidationException e) { ... }
```

### 동기

- 오류 코드는 **무시 가능** — 호출자가 검사 잊으면 사고.
- 예외는 **타입 시스템이 강제** (checked) 또는 **로그·디버깅 정보 풍부** (stack trace).

### Effective Java 연결

Item 70(checked vs unchecked).

---

## 11.13 예외를 사전확인으로 바꾸기 (Replace Exception with Precheck)

### 한 줄 정의

**예측 가능한 조건** 으로 발생하는 예외는 미리 체크. 11.12의 반대.

```java
// Before
try {
    return list.get(i);
} catch (IndexOutOfBoundsException e) {
    return null;
}

// After
if (i < list.size()) return list.get(i);
return null;
```

### 동기

- 예외는 **진짜 예외 상황만** ([[entity-effective-java]] Item 69).
- 사전 확인이 가능한 조건에 예외는 비싸고 의도 흐림.

### 11.12 vs 11.13 — 균형

| 11.12 | 11.13 |
|-------|-------|
| 예측 어려운 오류 (네트워크 끊김) | 예측 가능한 조건 (인덱스 범위) |
| 정상 흐름과 분리 가치 | 사전 검사가 명료 |
| → 예외 | → if-check |

---

## 11장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 함수가 값을 반환하면서 부작용 | **CQS 분리(11.1) ★** |
| 비슷한 함수 여러 개 | **함수 매개변수화(11.2)** |
| boolean 인자가 동작 분기 | **플래그 제거(11.3)** |
| 같은 객체의 여러 필드 전달 | **객체 통째로(11.4)** |
| 매개변수가 유도 가능 | **매개변수 → 질의(11.5)** |
| 함수 안 외부 의존 | **질의 → 매개변수(11.6)** |
| 생성 후 변경 X 필드의 setter | **세터 제거(11.7)** |
| 생성 의도가 이름으로 드러나야 | **생성자 → 팩터리(11.8)** |
| 큰 함수를 단계 분해 | **함수 → 명령(11.9)** |
| 함수가 매개변수를 변경 | **수정된 값 반환(11.11)** |
| 함수가 오류 코드 반환 | **예외로 변환(11.12)** |
| 예측 가능한 조건의 예외 | **사전 확인으로(11.13)** |

### 종합 체크리스트

- [ ] getter처럼 보이는 함수가 부작용을 가지고 있지 않은가
- [ ] boolean 매개변수가 함수 동작을 갈라놓고 있는가
- [ ] JPA 엔티티의 모든 필드에 setter가 노출되어 있는가
- [ ] `new Order(...)` 대신 `Order.of(...)` 가 더 의도적인가
- [ ] 오류를 -1 같은 코드로 반환하는 메서드가 있는가
- [ ] try/catch가 정상 흐름 제어로 쓰이고 있지 않은가

### 종합 퀴즈

<details><summary>Q1. CQS(11.1)가 ★ 인 이유?</summary>

부작용 없는 질의 = **호출 순서·횟수가 결과에 영향 없음** → 추론·테스트·캐싱·동시성 모두 자유. 부작용 있는 명령은 명확히 따로. 동시성·예측 가능성의 기반.

</details>

<details><summary>Q2. JPA 엔티티에 무지성 <code>@Setter</code> 가 위험한 이유?</summary>

setter는 모든 필드 변경을 허용 → 도메인 불변식·상태 전이 규칙을 우회. 결제 안 한 주문이 갑자기 `setStatus(PAID)` 가 가능. **변경은 의미 있는 메서드(cancel·confirm·pay)** 로만, setter는 제거. 11.7의 가장 흔한 사례.

</details>

<details><summary>Q3. 11.12와 11.13이 둘 다 있는 이유?</summary>

균형. **예측 어려운 오류 → 예외**, **예측 가능한 조건 → 사전 확인**. 양극단 모두 안티패턴 (모든 걸 try-catch, 모든 걸 if-check). 상황에 맞춰 양방향 도구.

</details>

<details><summary>Q4. 11.8 (생성자 → 팩터리) 와 Effective Java Item 1의 관계?</summary>

같은 권고의 다른 표현. *Effective Java* Item 1이 "왜·언제" 라면, 11.8은 "어떻게 변환" 의 절차. 의도가 이름으로 드러남(`of`/`from`/`valueOf`), 서브타입 반환, 캐싱·재사용 등 동일.

</details>

---

## 다음 장 예고 — 12장: 상속 다루기

상속은 양날의 검 — **잘 쓰면 강력, 잘못 쓰면 LSP 위반·취약한 기반 클래스**. 11가지 기법으로 메서드·필드를 위·아래로 옮기고, 슈퍼클래스를 추출하고, 마지막 ★★ **서브클래스를 위임으로 바꾸기** 까지. *Effective Java* Item 18·*오브젝트* 11장과 직결.
