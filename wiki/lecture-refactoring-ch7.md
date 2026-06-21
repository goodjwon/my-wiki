---
title: "리팩터링 2판 실전 강의 — 7장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 7장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 7장 — 캡슐화

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 데이터의 **내부 표현을 외부로부터 숨기는 9가지 기법** 을 익힌다.
- "데이터를 노출하지 말고 행동을 노출하라" 를 손에 익힌다.
- **거대 클래스** (악취 3.20) 를 잘라내는 표준 절차.
- 위임의 **숨기기 ↔ 중개자 제거** 균형.

### 0.2 큰 그림

```
[ 데이터 캡슐화 ]                  [ 큰 단위 캡슐화 ]
 7.1 레코드 캡슐화                  7.5 클래스 추출
 7.2 컬렉션 캡슐화                  7.6 클래스 인라인 (반대)
 7.3 기본형을 객체로                7.7 위임 숨기기
 7.4 임시 변수를 질의 함수로         7.8 중개자 제거 (반대)
                                     7.9 알고리즘 교체
```

> **비유 — 캡슐화는 "포장"입니다.**
>
> 내용물(데이터 구조)을 안 보이게 포장하고, 손잡이(메서드)만 노출. 안의 내용을 바꿔도 손잡이가 같으면 사용자는 모름. 그래서 변경에 강함.

### 0.3 현업에서 왜 중요한가

- JPA 엔티티의 setter 남용, Service의 거대화, DTO 컬렉션 노출 — 모두 7장 처방.
- *Effective Java* Item 15(접근 최소화)·17(불변)·50(방어적 복사) 의 실전 기법.

---

## 7.1 레코드 캡슐화하기 (Encapsulate Record)

### 한 줄 정의

가변 데이터 묶음(`Map`, plain 객체) 을 **클래스 뒤로 숨겨** 접근을 통제.

```java
// Before — Map으로 떠다님
Map<String, Object> org = new HashMap<>();
org.put("name", "Acme");
org.put("country", "KR");
String name = (String) org.get("name");   // 타입·키 안전성 X

// After
public class Organization {
    private String name;
    private String country;
    public String name() { return name; }
    public String country() { return country; }
    public void rename(String newName) { ... }
}
```

### 동기

- `Map<String, Object>` 는 컴파일 검사 X·오타 위험·타입 캐스팅 폭증.
- 클래스로 감싸면 IDE·컴파일러가 검증.

### Spring 현업

JSON 응답 처리 시 `Map<String, Object>` 대신 record DTO 권장.

```java
public record OrganizationResponse(String name, String country) {}
```

---

## 7.2 컬렉션 캡슐화하기 (Encapsulate Collection)

### 한 줄 정의

가변 컬렉션을 **그대로 노출하지 말고**, 변경은 메서드 통하게, 조회는 **불변 뷰** 로.

```java
// Before
public class Order {
    private final List<OrderItem> items = new ArrayList<>();
    public List<OrderItem> getItems() { return items; }   // ❌ 외부가 직접 add/remove
}

// After
public class Order {
    private final List<OrderItem> items = new ArrayList<>();

    public List<OrderItem> items() {
        return List.copyOf(items);   // 불변 복사본
        // 또는: return Collections.unmodifiableList(items);
    }

    public void addItem(OrderItem item) {
        if (items.size() >= 100) throw new IllegalStateException("max 100 items");
        items.add(item);
    }

    public void removeItem(OrderItem item) { items.remove(item); }
}
```

### 동기

- 컬렉션 그대로 노출 → 호출자가 마음대로 변경 → 객체 불변식 깨짐.
- 추가·제거에 **검증·이벤트** 끼워 넣기 가능.

### Effective Java 연결

Item 50(방어적 복사)·Item 17(불변 클래스).

### 함정

- 매번 복사 비용 — 핫패스라면 `unmodifiableList` 뷰 사용.
- `unmodifiableList` 는 **원본이 바뀌면 뷰도 바뀜**. 진짜 고정이 필요하면 `List.copyOf`.

---

## 7.3 기본형을 객체로 바꾸기 (Replace Primitive with Object)

### 한 줄 정의

도메인 의미가 있는 String/int를 **전용 값 객체(record)** 로.

```java
// Before
public Order createOrder(String userId, int amountInCents, String paymentMethod) { ... }

// After
public Order createOrder(UserId userId, Money amount, PaymentMethod method) { ... }

public record UserId(String value) {
    public UserId { Objects.requireNonNull(value); }
}

public record Money(long amountInCents, Currency currency) {
    public Money plus(Money other) { ... }
    public Money minus(Money other) { ... }
}

public enum PaymentMethod { CARD, BANK_TRANSFER, MOBILE }
```

### 동기

- **기본형 집착** (악취 3.11) 처방.
- 도메인 행동(`Money.plus`)을 데이터 옆에 둘 수 있음.
- 인자 순서 실수 차단 (`UserId`와 `Email`이 다른 타입).

### 절차

1. 변수 캡슐화(6.6).
2. 새 값 클래스 만들기 (record + 검증).
3. setter를 새 객체 받게 변경, getter를 새 객체 반환하게.
4. 호출부 점진 마이그레이션.

### Effective Java 연결

Item 62(다른 타입이 적절하면 문자열 회피)·Item 34(enum).

---

## 7.4 임시 변수를 질의 함수로 바꾸기 (Replace Temp with Query)

### 한 줄 정의

한 번만 쓰이는 임시 변수를 함수 호출로 대체 → 함수 추출(6.1)을 가능케 함.

```java
// Before
double basePrice = quantity * itemPrice;
if (basePrice > 1000) return basePrice * 0.95;
else return basePrice * 0.98;

// After
private double basePrice() { return quantity * itemPrice; }

if (basePrice() > 1000) return basePrice() * 0.95;
else return basePrice() * 0.98;
```

### 동기

- 임시 변수가 함수 안에 갇혀 다른 함수로 옮길 수 없음.
- 변수 → 함수로 바꾸면 **다른 함수에서도 재사용** 가능.
- 1장 단계 3·4에서 본 패턴.

### 함정

- 함수가 **부작용** 을 일으키면 안 됨. 같은 입력에 같은 출력이어야.
- 매 호출마다 계산 — 비싼 계산이면 캐싱 고려.

---

## 7.5 클래스 추출하기 (Extract Class)

### 한 줄 정의

한 클래스의 일부 필드·메서드를 떼어 **새 클래스** 로.

```java
// Before — Person 안에 전화번호 정보가 섞임
public class Person {
    private String name;
    private String officeAreaCode;
    private String officeNumber;
    public String getOfficeTel() { return officeAreaCode + "-" + officeNumber; }
}

// After
public class Person {
    private String name;
    private TelephoneNumber officeTel;
    public TelephoneNumber officeTel() { return officeTel; }
}

public class TelephoneNumber {
    private final String areaCode;
    private final String number;
    public String format() { return areaCode + "-" + number; }
}
```

### 동기

- **거대 클래스** (3.20)·**데이터 뭉치** (3.10)·**임시 필드** (3.16) 처방.
- 함께 변하는 필드·메서드가 한 클래스에 — 응집도 ↑.
- 도메인 개념(`TelephoneNumber`) 명시화.

### 절차

1. 새 클래스 만들기 (이름 결정).
2. 원본 클래스에 새 클래스 인스턴스 필드 추가.
3. 옮길 필드를 새 클래스로 이동 (8.2 필드 옮기기).
4. 옮길 메서드를 새 클래스로 이동 (8.1 함수 옮기기).
5. 원본 클래스의 외부 호출자가 새 클래스를 직접 쓸지·원본 통할지 결정.

---

## 7.6 클래스 인라인하기 (Inline Class)

### 한 줄 정의

거의 비어 있거나 한 클래스의 일부로 흡수되는 게 자연스러운 클래스를 **본문에 합치기**. 7.5의 반대.

### 동기

- **성의 없는 요소** (3.14)·**추측성 일반화** (3.15) 처방.
- 두 클래스가 거의 같은 일을 하면 합치는 게 명료.

---

## 7.7 위임 숨기기 (Hide Delegate)

### 한 줄 정의

`a.getB().doSomething()` 같은 위임 사슬을 **`a.doSomething()`** 으로 단순화.

```java
// Before
manager.getDepartment().getName();   // 메시지 체인 (악취 3.17)

// After
manager.departmentName();
```

### 동기

- 메시지 체인 (3.17) 처방.
- 클라이언트가 **중간 객체를 몰라도 됨** — 결합도 ↓.

### 함정

- 위임을 너무 많이 숨기면 → **중개자** (3.18) 악취 → 7.8 (중개자 제거) 으로 되돌리기.

---

## 7.8 중개자 제거하기 (Remove Middle Man)

### 한 줄 정의

위임만 하는 메서드가 너무 많으면 **클라이언트가 직접 내부 객체** 를 쓰게.

### 7.7 vs 7.8 — 균형

| 너무 노출 | 균형 | 너무 위임 |
|----------|------|----------|
| 메시지 체인 (3.17) | 적절 | 중개자 (3.18) |
| 위임 숨기기(7.7) 적용 | | 중개자 제거(7.8) 적용 |

→ 어느 한쪽이 정답이 아니라 **현재 코드의 균형 점검**.

---

## 7.9 알고리즘 교체하기 (Substitute Algorithm)

### 한 줄 정의

같은 결과를 내는 **더 명료하거나 빠른 알고리즘** 으로 함수 본문 통째 교체.

```java
// Before — 수동 루프
public String foundPerson(List<String> people) {
    for (String p : people) {
        if (p.equals("Don")) return "Don";
        if (p.equals("John")) return "John";
        if (p.equals("Kent")) return "Kent";
    }
    return "";
}

// After — Set으로 단순화
public String foundPerson(List<String> people) {
    Set<String> targets = Set.of("Don", "John", "Kent");
    return people.stream()
        .filter(targets::contains)
        .findFirst()
        .orElse("");
}
```

### 동기

- 더 명료한 표현이 보이면 바로 교체.
- 표준 라이브러리(stream·Set) 활용.

### 절차

1. **테스트가 충분한지 먼저 확인** — 같은 결과를 보장할 안전망.
2. 새 알고리즘으로 함수 본문 교체.
3. 테스트.

---

## 7장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| Map<String,Object> 떠다님 | **레코드 캡슐화(7.1)** |
| 가변 컬렉션 그대로 노출 | **컬렉션 캡슐화(7.2)** |
| String/int로 도메인 표현 | **기본형을 객체로(7.3)** |
| 임시 변수가 함수 안에 갇힘 | **임시 변수를 질의 함수로(7.4)** |
| 거대 클래스·데이터 뭉치 | **클래스 추출(7.5)** |
| 빈 클래스·과한 분리 | **클래스 인라인(7.6)** |
| 메시지 체인 (a.b().c().d()) | **위임 숨기기(7.7)** |
| 위임만 하는 클래스 | **중개자 제거(7.8)** |
| 더 명료한 알고리즘이 있음 | **알고리즘 교체(7.9)** |

### 종합 체크리스트 (코드 리뷰용)

- [ ] 외부에 가변 컬렉션을 그대로 노출하지 않는가
- [ ] 도메인 의미 있는 값을 String/int로 들고 있지 않은가
- [ ] 거대 Service에 함께 변하는 일부 메서드를 잘라낼 수 있는가
- [ ] `a.getB().getC().getD()` 같은 체인이 있는가
- [ ] 위임만 80%+ 하는 중개 클래스가 있는가

### 종합 퀴즈

**Q1. 가변 컬렉션을 그대로 노출하면 왜 위험한가?**

**A.** 호출자가 add/remove로 객체의 불변식을 우회해 깨뜨릴 수 있다. 예: Order의 items 리스트를 직접 노출하면 `order.getItems().add(...)` 로 검증 없이 추가됨. **변경은 메서드, 조회는 불변 뷰**.

**Q2. 위임 숨기기(7.7)와 중개자 제거(7.8)가 둘 다 있는 이유?**

**A.** 균형의 문제이기 때문. 위임이 너무 적으면 메시지 체인(3.17) 악취, 너무 많으면 중개자(3.18) 악취. 양방향 도구로 들고 상황 따라.

**Q3. 7.5 클래스 추출의 신호 3가지?**

**A.** (1) **거대 클래스** (3.20) — 필드 20+ / 메서드 30+, (2) **데이터 뭉치** (3.10) — 늘 함께 다니는 필드 묶음, (3) **임시 필드** (3.16) — 일부 메서드만 쓰는 필드.

**Q4. 임시 변수를 질의 함수로(7.4) 바꾸는 게 함수 추출의 전 단계인 이유?**

**A.** 임시 변수는 함수 안에 갇혀 다른 함수로 옮길 수 없다. 함수로 승격하면 다른 함수에서도 호출 가능 → 추출(6.1)·옮기기(8.1) 의 단위가 됨. 1장의 단계 2가 정확히 이 변환.

---

## 다음 장 예고 — 8장: 기능 이동

7장이 "안에서 정리" 였다면 8장은 **"어디 두는가"** — 함수·필드·문장을 **올바른 자리** 로 옮기는 9가지 기법. **산탄총 수술** (악취 3.8) 의 처방, 반복문을 파이프라인으로 바꾸는 모던 자바 패턴까지.
