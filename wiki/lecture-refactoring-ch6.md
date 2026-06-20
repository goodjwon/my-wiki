---
title: "리팩터링 2판 실전 강의 — 6장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 6장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 6장 — 기본적인 리팩터링

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x, IntelliJ

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 모든 리팩터링의 **기본기 11개** 를 손에 익힌다.
- ★ 5개(함수 추출·변수 추출·함수 선언 바꾸기·매개변수 객체·단계 쪼개기)는 무의식적으로 적용 가능 수준까지.
- 각 기법의 **절차(작은 단계)** 를 따르는 습관 — 어디서 멈춰도 동작 보존.

### 0.2 큰 그림 — "분해와 명명"

```
[ 분해 ]                    [ 명명 ]                      [ 묶기 ]
 6.1 함수 추출 ★            6.5 함수 선언 바꾸기 ★       6.8 매개변수 객체
 6.2 함수 인라인 (반대)      6.7 변수 이름 바꾸기           6.9 여러 함수 → 클래스
 6.3 변수 추출 ★            6.6 변수 캡슐화                6.10 여러 함수 → 변환 함수
 6.4 변수 인라인 (반대)                                      6.11 단계 쪼개기 ★
```

> **비유 — 6장은 "주방의 칼·도마·계량컵"입니다.**
>
> 모든 리팩터링은 결국 분해(작게)·명명(이름)·묶기(응집)의 조합. 화려한 기법(다형성·합성)도 이 기본기 위에 얹어지는 것.

### 0.3 현업에서 왜 중요한가

- 코드 리뷰의 80%는 **함수 추출·이름 바꾸기·매개변수 정리** 가 처방.
- IDE 단축키 매핑이 가장 잘 되어 있어 **자동화 가성비 폭증**.
- 7~12장 카탈로그는 거의 모두 6장 위에 쌓임.

---

## 6.1 함수 추출하기 (Extract Function) ★

### 한 줄 정의

긴 함수의 한 단락을 **의도가 드러나는 이름의 함수** 로 분리.

### 비유 — "레시피에서 부분 동작 떼어내기"

긴 레시피 "양파를 까서, 다지고, 기름에 볶고, 토마토를 넣고, 끓이고, 간을 본다" 를 **"양파 볶기 → 토마토 졸이기 → 간 보기"** 세 함수로.

### Before / After

```java
// Before
public void printOwing(Invoice invoice) {
    printBanner();
    double outstanding = 0;
    for (Order o : invoice.orders) outstanding += o.amount;   // ← 의도 단락
    System.out.println("name: " + invoice.customer);          // ← 의도 단락
    System.out.println("amount: " + outstanding);
}

// After
public void printOwing(Invoice invoice) {
    printBanner();
    double outstanding = calculateOutstanding(invoice);
    printDetails(invoice, outstanding);
}

private double calculateOutstanding(Invoice invoice) {
    double result = 0;
    for (Order o : invoice.orders) result += o.amount;
    return result;
}

private void printDetails(Invoice invoice, double outstanding) {
    System.out.println("name: " + invoice.customer);
    System.out.println("amount: " + outstanding);
}
```

### 동기

- **의도와 구현 분리** — 함수 이름이 "무엇" 을, 본문이 "어떻게" 를.
- 같은 동작 **재사용** 가능해짐.
- **테스트하기 쉬워짐** — 작은 함수가 단위.

### 언제 추출하나

- "이 코드가 무슨 일을 하는지 한 줄 주석으로 설명할 수 있다" → 그 주석을 함수 이름으로.
- 한 함수 안에 빈 줄로 구분된 블록이 2개 이상.

### 절차

1. 새 함수 만들고 **의도를 드러내는 이름** 부여.
2. 추출할 코드를 새 함수로 옮김.
3. 옮긴 코드가 쓰는 **지역 변수를 매개변수로** 추가.
4. 옮긴 코드 자리에 새 함수 호출 삽입.
5. 테스트.

### 함정

- **매개변수가 7개+ 되면** → 추출 잘못 잘랐거나, 매개변수 객체(6.8)가 필요한 신호.
- **부작용을 가진 함수** 를 별생각 없이 추출하면 호출 순서가 바뀌어 사고. 11.1(CQS)과 같이 고려.

### IDE

- IntelliJ: `Ctrl/Cmd + Alt + M` — Extract Method. 자동으로 매개변수·반환값 분석.

---

## 6.2 함수 인라인하기 (Inline Function)

### 한 줄 정의

**과한 분해·성의 없는 함수** 를 본문으로 다시 합치기. 6.1의 반대.

### Before / After

```java
// Before — 함수가 너무 작아 본문보다 호출이 길다
boolean moreThanFiveLateDeliveries(Driver d) {
    return d.numberOfLateDeliveries > 5;
}
boolean isInExperienced(Driver d) {
    return moreThanFiveLateDeliveries(d);   // 위임만
}

// After
boolean isInExperienced(Driver d) {
    return d.numberOfLateDeliveries > 5;
}
```

### 동기

- 추출했는데 의미가 안 살아남 (성의 없는 요소 — 악취 3.14).
- 위임만 하는 중간 함수가 가독성 해침.

### 절차

1. 다형성 메서드가 아닌지 확인 (오버라이드되면 인라인 X).
2. 호출 지점들 찾기.
3. 각 호출 지점에 함수 본문을 채워 넣음.
4. 원본 함수 제거.

### IDE

- IntelliJ: `Ctrl/Cmd + Alt + N` — Inline Method.

---

## 6.3 변수 추출하기 (Extract Variable) ★

### 한 줄 정의

복잡한 식의 일부를 **의도가 드러나는 변수** 로 분리.

### Before / After

```java
// Before
double price = quantity * itemPrice
    - Math.max(0, quantity - 500) * itemPrice * 0.05
    + Math.min(quantity * itemPrice * 0.1, 100);

// After
double basePrice = quantity * itemPrice;
double quantityDiscount = Math.max(0, quantity - 500) * itemPrice * 0.05;
double shipping = Math.min(basePrice * 0.1, 100);
double price = basePrice - quantityDiscount + shipping;
```

### 동기

- 디버거에서 중간 값 확인 가능.
- 의도가 식이 아니라 **변수 이름** 으로 드러남.
- 6.1 함수 추출의 전 단계 — 변수가 충분히 모이면 함수로.

### 절차

1. 추출할 식의 부작용 여부 확인 (없어야 안전).
2. 변경 불가 변수(`final` 또는 `var`)로 새 변수 선언, 추출할 식 대입.
3. 원래 식을 새 변수로 교체.
4. 테스트.

### IDE

- IntelliJ: `Ctrl/Cmd + Alt + V` — Extract Variable.

---

## 6.4 변수 인라인하기 (Inline Variable)

### 한 줄 정의

이름이 의미를 보태지 않는 변수를 식으로 직접 대체. 6.3의 반대.

```java
// Before
double basePrice = anOrder.basePrice();   // 그저 한 번 쓰는 임시
return basePrice > 1000;

// After
return anOrder.basePrice() > 1000;
```

### 언제

- 변수가 식보다 의미를 추가하지 않을 때.
- 다른 리팩터링(예: 함수 추출) 의 전 단계로 본문을 잠시 단순화할 때.

---

## 6.5 함수 선언 바꾸기 (Change Function Declaration) ★

### 한 줄 정의

함수의 **이름·매개변수·반환** 을 바꿔 계약을 정정.

### 동기

- 이름이 의도를 못 드러냄 (악취 3.1 기이한 이름).
- 매개변수 순서·타입이 부적절.
- 매개변수 추가·제거.

### Before / After (이름 변경)

```java
// Before
void circum(double radius) { ... }   // circum이 뭐?

// After
void circumference(double radius) { ... }
```

### Before / After (매개변수 추가 — 안전 절차)

이름·시그니처 변경은 호출자가 많을수록 위험. 안전 절차 두 가지.

#### 간단 절차 (호출자 적음, IDE 도움 가능)

1. 새 시그니처로 한 번에 변경.
2. 모든 호출자 갱신.
3. 테스트.

#### 마이그레이션 절차 (호출자 많음, 라이브러리 API)

1. **새 함수** 만듦 (목표 시그니처).
2. 원본 함수를 새 함수로 **위임** 하게 변경.
3. 호출자들을 **하나씩** 새 함수로 이전.
4. 모든 호출이 새 함수로 옮겨졌으면 원본 제거.

### Spring 현업

```java
// 1단계
@GetMapping("/orders")
public List<Order> orders(@RequestParam String userId) { ... }   // 원본

// 2단계 — 새 함수 추가
@GetMapping("/v2/orders")
public List<Order> ordersByUser(UserId userId) { ... }   // 목표

// 3단계 — 호출자 마이그레이션 + 4단계 원본 deprecate/제거
```

`@Deprecated(since = "...")` 와 결합하면 안전 진행.

### 함정

- 라이브러리 공개 API는 한 번 바뀌면 사용자에 폭탄. 마이그레이션 절차 필수.
- 동적 참조(SpEL·JSON 키)는 자동 Rename이 못 잡음.

### IDE

- IntelliJ: `Ctrl/Cmd + F6` — Change Signature.

---

## 6.6 변수 캡슐화하기 (Encapsulate Variable)

### 한 줄 정의

직접 접근하는 변수를 **getter/setter** 또는 **불변 인터페이스** 뒤로 숨김.

```java
// Before
public class Config {
    public static int port = 8080;   // 누구나 변경 가능
}

// After
public class Config {
    private static int port = 8080;
    public static int port() { return port; }
    public static void setPort(int p) {
        if (p < 1 || p > 65535) throw new IllegalArgumentException();
        port = p;
    }
}
```

### 동기

- **전역 데이터** (악취 3.5) 처방의 첫 단계.
- 변경 추적·검증·로깅 가능해짐.
- 나중에 가변→불변 전환의 발판.

### 절차

1. 변수에 접근하는 **함수(get/set) 만들기**.
2. 모든 외부 참조를 함수 호출로 변경.
3. 변수의 가시성 제한 (`private`).
4. 테스트.

---

## 6.7 변수 이름 바꾸기 (Rename Variable)

### 한 줄 정의

이름이 의도를 못 드러내면 즉시 바꿔라.

```java
// Before
int d;   // 일수
// After
int daysSinceLastVisit;
```

### IDE

- IntelliJ: `Shift + F6` — Rename. 전체 코드베이스 일괄 변경, 동적 참조 경고까지.

### 함정

- 변수가 **여러 의미** 로 쓰이고 있으면 이름 바꾸기만으로는 부족 — **변수 쪼개기(9.1)** 필요.
- 짧은 임시 변수(`i`, `n`) 는 그대로 둬도 좋음 — 짧은 범위에선 가독성 손해 없음.

---

## 6.8 매개변수 객체 만들기 (Introduce Parameter Object)

### 한 줄 정의

함께 다니는 매개변수 묶음(데이터 뭉치 — 악취 3.10) 을 **하나의 객체/record** 로.

```java
// Before
boolean amountInRange(int amount, int min, int max);

// After
boolean amountInRange(int amount, Range range);

public record Range(int min, int max) {
    public Range {
        if (min > max) throw new IllegalArgumentException();
    }
    public boolean includes(int v) { return min <= v && v <= max; }
}
```

### 동기

- 매개변수 4개+ (악취 3.4) 처방.
- 묶음 자체에 **행동** 을 부여 가능 (`Range.includes`).
- 도메인 개념을 코드에 명시.

### 절차

1. 후보 record/클래스 만들기.
2. 함수 선언 바꾸기(6.5) — 매개변수 자리에 새 타입.
3. 호출자들을 새 객체 생성으로 변경.
4. 함수 본문에서 개별 인자 대신 객체 메서드 사용.
5. 묶음을 쓰는 다른 함수들도 단계적으로 옮김.

### Java 17 record와 궁합

record는 자동 equals/hashCode/toString/생성자 → 6.8의 최적 도구.

---

## 6.9 여러 함수를 클래스로 묶기 (Combine Functions into Class)

### 한 줄 정의

같은 데이터를 공유하며 함께 변하는 함수들을 한 클래스로.

```java
// Before — 함수 3개가 같은 데이터에 작용
double baseCharge(Reading r) { ... }
double taxableCharge(Reading r) { ... }
double calcAmount(Reading r) { ... }

// After
public class Bill {
    private final Reading reading;
    public Bill(Reading r) { this.reading = r; }
    public double baseCharge() { ... }
    public double taxableCharge() { ... }
    public double calcAmount() { ... }
}
```

### 동기

- 함께 변하는 함수 = 함께 있는 게 자연스러움 (응집도).
- 매개변수 반복 사라짐.
- **데이터 클래스** (악취 3.22) 에 행동을 끌어오는 처방.

### 절차

1. 공통 데이터를 받는 새 클래스 만들기.
2. 함수들을 차례로 옮기기 (함수 옮기기 — 8.1).
3. 각 함수의 데이터 매개변수를 클래스 필드로 대체.
4. 테스트.

---

## 6.10 여러 함수를 변환 함수로 묶기 (Combine Functions into Transform)

### 한 줄 정의

원본 데이터를 받아 **파생 정보를 채워 반환** 하는 변환 함수로 묶기.

```java
// Before — 같은 reading에서 여러 계산을 흩어 호출
double base = baseCharge(reading);
double tax = taxableCharge(reading);
double amount = calcAmount(reading);

// After
EnrichedReading enriched = enrich(reading);
double base = enriched.baseCharge();
double tax = enriched.taxableCharge();
```

### 6.9 vs 6.10

| 6.9 클래스 묶기 | 6.10 변환 함수 묶기 |
|----------------|---------------------|
| 함께 변하는 행동 | 함께 계산되는 파생값 |
| 원본 데이터 가변 가능 | 원본 데이터 불변 가정 (함수형) |
| OO 친화 | 함수형/파이프라인 친화 |

### 동기

- 같은 파생값이 여러 곳에서 따로 계산 → 변환 함수 한 곳에 모으기.
- 계산 결과 일관성 보장.

---

## 6.11 단계 쪼개기 (Split Phase) ★

### 한 줄 정의

서로 다른 두 가지 일을 하는 함수를 **명확한 두 단계** 로 분리.

### Before / After

```java
// Before — 파싱 + 계산 + 출력이 한 함수
String orderSummary(String csv) {
    // CSV 파싱
    String[] tokens = csv.split(",");
    String name = tokens[0];
    int qty = Integer.parseInt(tokens[1]);
    int price = Integer.parseInt(tokens[2]);

    // 계산
    int total = qty * price;

    // 출력
    return name + ": " + qty + "개 × " + price + "원 = " + total + "원";
}

// After — 2단계 분리
OrderData parse(String csv) {
    String[] t = csv.split(",");
    return new OrderData(t[0], Integer.parseInt(t[1]), Integer.parseInt(t[2]));
}

String render(OrderData o) {
    int total = o.qty() * o.price();
    return o.name() + ": " + o.qty() + "개 × " + o.price() + "원 = " + total + "원";
}
```

### 동기

- **뒤엉킨 변경** (악취 3.7) 처방 — 파싱 형식 변경 / 출력 형식 변경이 한 함수에 묶이지 않음.
- 1장의 `statement()` → `htmlStatement()` 가 정확히 이 리팩터링.
- 단계가 분리되면 **각 단계 단독 테스트** 가능.

### 절차

1. 두 번째 단계에 해당하는 코드를 **함수 추출(6.1)**.
2. 첫 단계가 두 번째 단계에 넘길 **중간 데이터 구조** 정의.
3. 첫 단계가 그 구조를 만들도록 변경.
4. 두 번째 단계는 그 구조만 받게 변경.

### Spring 현업

```java
// Before — Controller 안에 파싱·검증·비즈니스·DTO 변환 다 섞임
@PostMapping
public OrderResponse create(@RequestBody Map<String, Object> raw) {
    // 파싱·검증·서비스 호출·응답 변환 한 함수에
}

// After — 입력 DTO → 도메인 → 응답 DTO 3단계
@PostMapping
public OrderResponse create(@Valid @RequestBody CreateOrderRequest req) {
    Order order = service.create(req.toCommand());
    return OrderResponse.from(order);
}
```

---

## 6장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 긴 함수에 의도 단락이 보임 | **함수 추출(6.1) ★** |
| 함수가 위임만 함 | **함수 인라인(6.2)** |
| 복잡한 식의 의미가 안 드러남 | **변수 추출(6.3) ★** |
| 임시 변수가 의미를 못 보탬 | **변수 인라인(6.4)** |
| 이름·시그니처가 잘못됨 | **함수 선언 바꾸기(6.5) ★** |
| 전역·공용 변수 | **변수 캡슐화(6.6)** |
| 변수 이름이 의도 못 드러냄 | **변수 이름 바꾸기(6.7)** |
| 매개변수 묶음·4개+ | **매개변수 객체(6.8)** |
| 같은 데이터에 작용하는 함수들 | **여러 함수를 클래스로(6.9)** |
| 같은 파생값이 여러 곳에서 계산 | **여러 함수를 변환 함수로(6.10)** |
| 함수가 두 단계로 분리 가능 | **단계 쪼개기(6.11) ★** |

### 종합 체크리스트 (코드 리뷰용)

- [ ] 의도가 한 줄로 설명 가능한 단락 → 함수 추출
- [ ] 위임만 하는 함수 → 인라인 검토
- [ ] 디버거에서 보고 싶은 중간 값 → 변수 추출
- [ ] 이름이 의도를 정확히 드러냄
- [ ] 매개변수 4개+ → 매개변수 객체
- [ ] 같이 변하는 함수들 → 한 클래스로
- [ ] 한 함수에 파싱·계산·포맷이 섞임 → 단계 쪼개기

### 종합 퀴즈

<details><summary>Q1. 함수 추출(6.1)이 "모든 리팩터링의 기본기"라 불리는 이유?</summary>

다른 모든 리팩터링이 함수 추출의 결과 위에 쌓이기 때문. 추출이 없으면 옮길(8.1)·당길/내릴(12.1·12.4)·다형성으로 바꿀(10.4) 단위가 없다. 함수가 작아져야 모든 카탈로그가 적용 가능.

</details>

<details><summary>Q2. 함수 추출과 함수 인라인이 둘 다 카탈로그에 있는 이유?</summary>

문맥에 따라 어제 옳던 추출이 오늘 과한 분해(악취 3.14)가 되기 때문. 양방향 도구로 가져야 상황에 맞게 적용 가능. 5장의 "쌍" 원칙.

</details>

<details><summary>Q3. 매개변수 4개+가 단순한 가독성 문제가 아닌 이유?</summary>

매개변수 묶음 자체가 **이름 없는 도메인 개념** 인 경우가 많기 때문 (예: start/end → Period). 객체화 = 도메인 발견. 그래서 6.8은 가독성을 넘어 모델링 활동.

</details>

<details><summary>Q4. 단계 쪼개기(6.11)가 1장의 핵심 리팩터링인 이유?</summary>

`statement()` 가 "계산" 과 "출력" 을 한 함수에 묶고 있어, HTML 출력 추가가 거대 복붙을 부르는 상황이었음. 단계 쪼개기로 계산 데이터 구조를 만들어 두면 HTML 출력은 한 함수 추가만으로 끝. **새 기능 추가 비용이 한 자릿수로 줄어드는 리팩터링**.

</details>

---

## 다음 장 예고 — 7장: 캡슐화

기본 리팩터링(6장)이 손에 익었으니, OO의 핵심인 **캡슐화** 로 갑니다. 레코드/컬렉션을 어떻게 노출 안 하고 행동만 외부에 드러내는지, **기본형을 객체로** 승격해 도메인을 풍부하게 만드는 법, **클래스 추출** 로 거대 클래스를 자르는 절차, **위임 숨기기/중개자 제거** 의 균형까지.
